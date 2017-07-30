/***************************************************************************
 *
 * Copyright (C) 2014 Elad Lahav (elad_lahav@users.sourceforge.net)
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ***************************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <time.h>
#include <sys/mman.h>
#ifdef STANDALONE
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#endif
#include "sort.h"

/*
 * -----------------------------------------------------------------------------
 * Configurable parameters.
 * -----------------------------------------------------------------------------
 */

#ifndef STRING_LEN_ORDER
#define STRING_LEN_ORDER       10   /** log2 of maximum string length. */
#endif

#ifndef HEAP_SIZE
#define HEAP_SIZE              15   /** Heap size for external sort. */
#endif

#ifndef STRING_ALIGN
#define STRING_ALIGN            1   /** String alignment within a page. */
#endif

#define PAGE_BUF_SIZE          256 * 1024 * 1024
#define DIRECTORY_LEN_BITS     STRING_LEN_ORDER
#define DIRECTORY_LEN_SIZE     (1 << DIRECTORY_LEN_BITS)
#define DIRECTORY_LEN_MASK     (DIRECTORY_LEN_SIZE - 1)
#define ALIGN_OFFSET(o)        ((o + (STRING_ALIGN - 1)) & ~(STRING_ALIGN - 1))
#define IS_POWER_OF_2(x)       (((x) & (x - 1)) == 0)

#if !IS_POWER_OF_2(STRING_ALIGN)
#error STRING_ALIGN needs to be a power of 2
#endif

#if !IS_POWER_OF_2(HEAP_SIZE + 1)
#error HEAP_SIZE needs to be one less than a power of 2
#endif

#ifdef DEBUG
#define DPRINT(...)             fprintf(stderr, __VA_ARGS__)
static void verify_heap(sort_page_t **heap, unsigned size, unsigned root);
static void verify_run(sort_page_t *page, unsigned runlen);
#else
#define DPRINT(...)
#define verify_heap(h, s, r)
#define verify_run(p, r)
#endif /* DEBUG */

/*
 * -----------------------------------------------------------------------------
 * Type definitions.
 * -----------------------------------------------------------------------------
 */

typedef struct sort_page_s      sort_page_t;
typedef struct sort_page_buf    sort_page_buf_t;

/**
 * Mapped buffer used for allocating pages.
 * The @buf field points to a mapped chunk of memory that is PAGE_BUF_SIZE in
 * length.
 * Buffers are linked so they can be unmapped upon a call to @sort_done().
 */
struct sort_page_buf
{
    sort_page_buf_t  *next;
    void             *buf;
};

/**
 * A header for a single page.
 * The header is embedded in a chunk of memory that is @sort_page_size in
 * length. The strings reside beginning at the @data offset of this structure.
 * The structure of a page is as follows:
 * +---------------------------------------------+
 * | header | data -> ...     | ... <- directory |
 * +---------------------------------------------+
 * The data (strings) grows towards the end of the page, while the directory,
 * with a single entry per string describing its offset from @data and length,
 * grows towards the beginning. The directory allows for strings to be sorted by
 * just moving their fixed-size directory entries.
 */
struct sort_page_s
{
    sort_page_t *next;
    sort_page_t *nextrun;
    uint32_t    nstrings;
    uint32_t    first;
    char        data[0];
};

/**
 * A descriptor used for sorting an arbitrary number of strings.
 * Maintains a linked list of pages to which strings can be added with
 * @sort_insert() and sorted with @sort_do().
 */
struct sort
{
    sort_page_t *head;
    sort_page_t *tail;
    unsigned    npages;
    int         sorted;
};

/**
 * An iterator over the list of strings described by a descriptor.
 */
struct sort_itr
{
    sort_page_t *page;
    unsigned    index;
    uint32_t    *dir;
};

/*
 * -----------------------------------------------------------------------------
 * Globals.
 * -----------------------------------------------------------------------------
 */

static size_t					sort_page_size;
static sort_page_buf_t          *sort_page_bufs;
static sort_page_t              *sort_page_freelist;
static sort_page_t              *sort_qsort_page;

/*
 * -----------------------------------------------------------------------------
 * Directory operations.
 * -----------------------------------------------------------------------------
 */

/**
 * Given a page, returns a pointer to the directory.
 * Note that the directory needs to be indexed using negative values, i.e.,
 * the first entry is at index -1, the second at -2, etc.
 */
static __inline uint32_t *
page_directory(sort_page_t *page)
{
    return (uint32_t *)((uint8_t *)page + sort_page_size);
}

/**
 * Returns the directory entry for a page at the given 0-based index.
 */
static __inline uint32_t
page_dirent(sort_page_t *page, unsigned index)
{
    return *(page_directory(page) - (index + 1));
}

/**
 * Creates a directory entry for a combination of offset and length.
 */
static __inline uint32_t
make_dirent(uint32_t offset, uint32_t len)
{
    return (offset << DIRECTORY_LEN_BITS) | len;
}

/**
 * Returns the offset of a string from its directory entry.
 */
static __inline uint32_t
dirent_offset(uint32_t dirent)
{
    return dirent >> DIRECTORY_LEN_BITS;
}

/**
 * Returns the length of a string from its directory entry.
 */
static __inline uint32_t
dirent_length(uint32_t directory)
{
    return directory & DIRECTORY_LEN_MASK;
}

/*
 * -----------------------------------------------------------------------------
 * Page allocator.
 * -----------------------------------------------------------------------------
 */

/**
 * Allocate a page.
 * @return A pointer to the embedded sort_page_t header if successful, NULL
 *         otherwise.
 */
static sort_page_t *
get_page()
{
    static uint8_t      *buf = NULL;
    static unsigned     used;
    sort_page_t         *page;

    /*
     * Use a page from the free list, if one is available.
     */
    if (sort_page_freelist) {
        page = sort_page_freelist;
        assert(page->nstrings == 0);
        sort_page_freelist = page->next;
        page->next = NULL;
        return page;
    }

    /*
     * If there is no buffer to allocate from, map a new one.
     */
    if (buf == NULL) {
        sort_page_buf_t *pb;

        pb = (sort_page_buf_t *)malloc(sizeof(sort_page_buf_t));
        pb->buf = mmap(0, PAGE_BUF_SIZE, PROT_READ | PROT_WRITE,
                       MAP_PRIVATE | MAP_ANON, -1, 0);
        if (pb->buf == MAP_FAILED) {
            return NULL;
        }

        pb->next = sort_page_bufs;
        sort_page_bufs = pb;

        buf = (uint8_t *)pb->buf;
        used = 0;
    }

    /*
     * Carve a page from the current buffer.
     */
    page = (sort_page_t *)buf;
    assert(page->nstrings == 0);
    buf += sort_page_size;
    used += sort_page_size;

    /*
     * Check if the buffer is full.
     */
    if (used >= PAGE_BUF_SIZE) {
        buf = NULL;
    }

    return page;
}

/**
 * Free a page that is no longer being used.
 * The page is put back on the free list.
 * @param page The page to free
 */
static void
put_page(sort_page_t *page)
{
    assert(sort_page_freelist == NULL || sort_page_freelist->nstrings == 0);
    memset(page, 0, sizeof(*page));
    page->next = sort_page_freelist;
    sort_page_freelist = page;
}

/*
 * -----------------------------------------------------------------------------
 * Page and string operations.
 * -----------------------------------------------------------------------------
 */

/**
 * Adds a string to a page.
 * The string is put at the next available offset and uses the next directory
 * entry.
 * @param page The page to add the string to
 * @param str  The string to add
 * @param len  The string's length (including a terminating NULL, if available)
 * @return 0 if successful, -1 if the page is full.
 */
static int
add_string(sort_page_t *page, const char *str, uint32_t len)
{
    uint32_t    *directory;
    uint32_t    offset;

    /*
     * Get the directory entry for the new string.
     */
    directory = page_directory(page);
    directory -= (page->nstrings + 1);

    /*
     * Calculate the page offset for the string.
     */
    if (page->nstrings == 0) {
        offset = 0;
    } else {
        offset = ALIGN_OFFSET(dirent_offset(directory[1]) +
                              dirent_length(directory[1]));
    };

    /*
     * Check if the string fits in the page.
     */
    if ((page->data + offset + len) > (char *)directory) {
        return -1;
    }

    /*
     * Copy the string into the page.
     */
    memcpy(page->data + offset, str, len);

    /*
     * Update the directory entry for the string.
     */
    directory[0] = make_dirent(offset, len);
    page->nstrings++;
    return 0;
}

/**
 * Compares two strings on two arbitrary pages.
 * @param dir1  The directory entry of the first string
 * @param dir2  The directory entry of the second string
 * @param page1 The page on which the first string resides
 * @param page2 The page on which the second string resides
 * @return -1, 0 or 1 if the first string ranks lower, the same or higher than
 *         the second, respectively
 */
static int
comp_strings(uint32_t dir1, uint32_t dir2, sort_page_t *page1,
             sort_page_t *page2)
{
    uint32_t    off1 = dirent_offset(dir1);
    uint32_t    off2 = dirent_offset(dir2);
#ifdef USE_MEMCMP
    uint32_t    len1 = dirent_length(dir1);
    uint32_t    len2 = dirent_length(dir2);
    uint32_t    complen;
    int         bylen;
    int         bystr;

    /*
     * Determine the minimum length to use for the comparison.
     * If the strings are the same up to that length, use the length as the
     * comparison criterion.
     */
    if (len1 == len2) {
        complen = len1;
        bylen = 0;
    } else if (len1 < len2) {
        complen = len1;
        bylen = -1;
    } else {
        complen = len2;
        bylen = 1;
    }

    /*
     * Compare strings.
     */
    bystr = memcmp(&page1->data[off1], &page2->data[off2], complen);
    if (bystr == 0) {
        return bylen;
    }

    return bystr;
#else
    return strcmp(&page1->data[off1], &page2->data[off2]);
#endif
}

/**
 * Compares two strings on a the page identified by @qsort_page.
 * Used as a callback function for qsort.
 * @param p1   Pointer to the directory entry of the first string
 * @param p2   Pointer to the directory entry of the second string
 * @return -1, 0 or 1 if the first string ranks lower, the same or higher than
 *         the second, respectively
 */
static int
comp_page_strings(const void *p1, const void *p2)
{
    uint32_t    dir1 = *(uint32_t *)p1;
    uint32_t    dir2 = *(uint32_t *)p2;

    /*
     * Compare the strings on the same page.
     * Uses reverse-comparison to have the directory entries sorted backwards.
     */
    return comp_strings(dir2, dir1, sort_qsort_page, sort_qsort_page);
}

/**
 * Compares the first strings on two pages.
 * Assuming the pages are sorted, the comparison determines the lowest ranking
 * string between the two pages.
 * @param page1 Pointer to the first page
 * @param page1 Pointer to the second page
 * @return -1, 0 or 1 if the first string on the first page ranks lower, the
 *         same or higher than the first string on the second page, respectively
 */
static int
comp_pages(sort_page_t *page1, sort_page_t *page2)
{
    uint32_t    dir1 = page_dirent(page1, page1->first);
    uint32_t    dir2 = page_dirent(page2, page2->first);

    return comp_strings(dir1, dir2, page1, page2);
}

/*
 * -----------------------------------------------------------------------------
 * Heap operations.
 * -----------------------------------------------------------------------------
 */

/**
 * Propagates a root node in a heap to a new location, such that the heap is
 * valid.
 * The function may operate on any sub-heap in the given array.
 * @param heap A page-run array, where the sub-heap identified by the root is
 *             valid, with the possible exception of the root itself
 * @param size The number of elements in the array
 * @param root The index of the root node to operate on.
 */
static void
heapify(sort_page_t **heap, unsigned size, unsigned root)
{
    unsigned    left;
    unsigned    right;
    unsigned    swap;
    int         comp;

    while (root < size) {
        swap = root;
        left = root * 2 + 1;
        right = left + 1;

        if (left < size) {
            /*
             * Compare with the left child.
             */
            comp = comp_pages(heap[root], heap[left]);
            if (comp > 0) {
                swap = left;
            }

            if (right < size) {
                /*
                 * Compare with either the root or the left child, based on the
                 * earlier comparison.
                 */
                comp = comp_pages(heap[swap], heap[right]);
                if (comp > 0) {
                    swap = right;
                }
            }
        }

        if (swap != root) {
            sort_page_t     *tmp = heap[root];
            heap[root] = heap[swap];
            heap[swap] = tmp;
            root = swap;
        } else {
            /*
             * Root has a lower rank than either children, nothing more to do.
             */
            break;
        }
    }
}

/**
 * Given a heap size, returns the 0-indexed depth of the bottom level.
 * This is essentially a log2(size) operation.
 */
static __inline unsigned
bottom_level(unsigned size)
{
    static const unsigned   size_to_level[HEAP_SIZE + 1] = {
        0, 0,
#if HEAP_SIZE >= 3
        1, 1,
#endif
#if HEAP_SIZE >= 7
        2, 2, 2, 2,
#endif
#if HEAP_SIZE >= 15
        3, 3, 3, 3, 3, 3, 3, 3,
#endif
#if HEAP_SIZE >= 31
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
#endif
#if HEAP_SIZE >= 63
#error Implement me!
#endif
    };

    return size_to_level[size];
}

/**
 * Builds a heap out of a page-run array.
 * @param heap The page-run array
 * @param size The number of elements in the array
 */
static void
make_heap(sort_page_t **heap, unsigned size)
{
    unsigned   level;
    unsigned   heapidx;
    unsigned   nheaps;

    if (size <= 1) {
        return;
    }

    /*
     * Initialize values based on the heap's bottom level.
     */
    level = bottom_level(size) - 1;
    heapidx = (1 << level) - 1;
    nheaps = 1 << level;

    for (;;) {
        /*
         * Run heapify on sub-heaps.
         */
        unsigned   i;

        for (i = 0; i < nheaps; i++) {
            heapify(heap, size, heapidx + i);
            verify_heap(heap, size, heapidx + i);
        }

        /*
         * Stop if this was the last level.
         */
        if (heapidx == 0) {
            break;
        }

        /*
         * Go to the next level.
         */
        heapidx >>= 1;
        nheaps >>= 1;
    }

    verify_heap(heap, size, 0);
}

/*
 * -----------------------------------------------------------------------------
 * Sort implementation.
 * -----------------------------------------------------------------------------
 */

/**
 * Sorts the strings in the given page.
 * Only the directory is affected. Strings remain in their place on the page,
 * but their directory entries are moved to reflect the sorting order.
 * @param page The page to sort
 */
static void
sort_page(sort_page_t *page)
{
    uint32_t   *directory;

    /*
     * Sort the directory.
     */
    directory = page_directory(page);
    directory -= page->nstrings;
    sort_qsort_page = page;
    qsort(directory, page->nstrings, sizeof(uint32_t), comp_page_strings);
}

/**
 * Merges a heap of page-runs into a new, sorted, run.
 * @param heap The heap to merge
 * @param size The number of elements in the heap
 * @return The page at the head of the merged run, if successful, NULL
 *         otherwise
 */
static sort_page_t *
merge(sort_page_t **heap, unsigned size)
{
    sort_page_t    *head;
    sort_page_t    *dstpage;
    sort_page_t    *next;

    DPRINT("Merging %p...%p (%u)\n", heap[0], heap[size - 1], size);

    /*
     * Allocate the first destination page.
     */
    dstpage = get_page();
    if (dstpage == NULL) {
        errno = ENOMEM;
        return NULL;
    }
    head = dstpage;

    /*
     * Build a heap.
     */
    make_heap(heap, size);

    for (;;) {
        sort_page_t *srcpage = heap[0];
        uint32_t    dir = page_dirent(srcpage, srcpage->first);
        const char  *str = &srcpage->data[dirent_offset(dir)];
        uint32_t    len = dirent_length(dir);

        /*
         * Copy the lowest-ranking string to the destination page.
         */
        if (add_string(dstpage, str, len) != 0) {
            /*
             * Page is full, get a new one and try again.
             */
            next = get_page();
            if (next == NULL) {
                errno = ENOMEM;
                return NULL;
            }
            dstpage->next = next;
            dstpage = next;

            if (add_string(dstpage, str, len) != 0) {
                errno = ENOSPC;
                return NULL;
            }
        }

        srcpage->nstrings--;
        srcpage->first++;

        /*
         * Check if the source page is now empty.
         */
        if (srcpage->nstrings == 0) {
            /*
             * Get the next page in the run.
             */
            next = srcpage->next;
            put_page(srcpage);
            srcpage = next;
            if (srcpage == NULL) {
                size--;
                if (size == 0) {
                    /*
                     * Heap is empty, done.
                     */
                    break;
                }

                /*
                 * Promote the last run in the heap.
                 */
                srcpage = heap[size];
            }

            heap[0] = srcpage;
        }

        /*
         * Update the heap.
         */
        heapify(heap, size, 0);
        verify_heap(heap, size, 0);
    }

    DPRINT("Merging done, head=%p\n", head);
    assert(dstpage->next == NULL);
    return head;
}

/**
 * Performs external sort on a list of pages.
 * Each sub-list of @HEAP_SIZE length is merged into a sorted run. These runs
 * are then merged, until only one, sorted, run is available.
 * @param pagelist The list of pages to sort
 * @param npages   The length of the list
 * @return The page at the head of the sorted run
 */
static sort_page_t *
external_sort(sort_page_t *pagelist, unsigned npages)
{
    unsigned    runlen = 1;
    sort_page_t *page = pagelist;
    sort_page_t **prevrun = &pagelist;
    sort_page_t *next;
    sort_page_t *heap[HEAP_SIZE];
    unsigned    heapidx = 0;

    DPRINT("External sort: run length=%u\n", runlen);

    for (;;) {
#ifdef NO_INLINE_SORT
        if (runlen == 1) {
            sort_page(page);
        }
#endif

        /*
         * Put the next run head on the current heap.
         */
        verify_run(page, runlen);
        heap[heapidx++] = page;
        next = page->nextrun;

        /*
         * If the heap is now full, merge runs.
         */
        if (heapidx == HEAP_SIZE) {
            page = merge(heap, HEAP_SIZE);
            heapidx = 0;

            /*
             * Link the sorted runs.
             */
            *prevrun = page;
            prevrun = &page->nextrun;
        }

        /*
         * Check if finished going through the page list.
         */
        if (next == NULL) {
            /*
             * Check for left-ovr runs.
             */
            if (heapidx > 0) {
                page = merge(heap, heapidx);
                heapidx = 0;

                /*
                 * Link the sorted runs.
                 */
                *prevrun = page;
                prevrun = &page->nextrun;
            }

            /*
             * Update the run length.
             */
            runlen *= HEAP_SIZE;
            if (runlen > npages) {
                /*
                 * Finished sorting.
                 */
                break;
            }

            DPRINT("External sort: run length=%u\n", runlen);

            /*
             * Start over.
             */
            page = pagelist;
            prevrun = &pagelist;
        } else {
            page = next;
        }
    }

    return page;
}

/*
 * -----------------------------------------------------------------------------
 * Public interface.
 * -----------------------------------------------------------------------------
 */

/**
 * Creates a sort descriptor.
 * @return A new descriptor that should be freed by @sort_done()
 */
sort_t *
sort_init()
{
    sort_t    *desc;

    sort_page_size = (1 << 22);

    /*
     * Allocate a descriptor.
     */
    desc = (sort_t *)malloc(sizeof(sort_t));
    if (desc == NULL) {
        return NULL;
    }

    /*
     * Allocate an initial page.
     * Will also initialize the page allocator if this is the first page
     * requested.
     */
    desc->head = get_page();
    if (desc->head == NULL) {
        free(desc);
        return NULL;
    }

    desc->tail = desc->head;
    desc->npages = 1;
    desc->sorted = 1;
    return desc;
}

/**
 * Adds a string to the list maintained by a descriptor.
 * @param desc The sort descriptor
 * @param str  The string to add
 * @param len  The string's length, including the NULL terminator, if used
 * @return 0 if successful, -1 otherwise (and errno is set)
 */
int
sort_insert(sort_t *desc, const char *str, unsigned len)
{
    /*
     * Make sure the line is not too long.
     */
    if (len > DIRECTORY_LEN_SIZE) {
        DPRINT("String too long (%s,%u)\n", str, len);
        return -1;
    }

    if (add_string(desc->tail, str, (uint32_t)len) != 0) {
        sort_page_t     *newpage;

#ifndef NO_INLINE_SORT
        /*
         * Page is full, sort it.
         */
        sort_page(desc->tail);
        desc->sorted = 1;
#endif

        /*
         * Get a new page.
         */
        newpage = get_page();
        if (newpage == NULL) {
            errno = ENOMEM;
            return -1;
        }

        /*
         * Link the pages.
         * Use the nextrun field to prepare for external sorting.
         */
        desc->tail->nextrun = newpage;
        desc->tail = newpage;
        desc->npages++;

        /*
         * Add the string to the new page.
         */
        if (add_string(desc->tail, str, len) != 0) {
            errno = ENOSPC;
            return -1;
        }
    } else {
#ifndef NO_INLINE_SORT
        desc->sorted = 0;
#endif
    }

    return 0;
}

/**
 * Sorts the list of strings maintained by a descriptor.
 * @param desc The sort descriptor
 * @return 0 if successful, -1 otherwise (and errno is set)
 */
int
sort_do(sort_t *desc)
{
#ifndef NO_INLINE_SORT
    /*
     * Sort the last page, if needed.
     */
    if (!desc->sorted) {
        sort_page(desc->tail);
    }
#endif

    /*
     * If the descriptor holds more than one page, run external sort.
     */
    if (desc->npages > 1) {
        desc->head = external_sort(desc->head, desc->npages);
    } else {
#ifdef NO_INLINE_SORT
        sort_page(desc->tail);
#endif
    }

    return 0;
}

/**
 * Cleans up resources used by a sort descriptor.
 * @warning The function is not thread safe and assumes there is only one
 *          descriptor at a time.
 * @param desc The sort descriptor
 */
void
sort_done(sort_t *desc)
{
    sort_page_buf_t *pb;
    sort_page_buf_t *next;

    /*
     * Unmap all page buffers.
     */
    for (pb = sort_page_bufs; pb != NULL; pb = next) {
        munmap(pb->buf, PAGE_BUF_SIZE);
        next = pb->next;
        free(pb);
    }

    /*
     * Free the descriptor.
     */
    free(desc);
}

/**
 * Allocates an iterator over a list of strings.
 * @param desc The sort descriptor
 * @return A new initialized iterator if successful, NULL otherwise
 */
sort_itr_t *
sort_itr_init(sort_t *desc)
{
    sort_itr_t    *itr;

    /*
     * Allocate an iterator.
     */
    itr = (sort_itr_t *)malloc(sizeof(sort_itr_t));
    if (itr == NULL) {
        return NULL;
    }

    /*
     * Initialize the iterator.
     */
    itr->page = desc->head;
    itr->index = 0;
    itr->dir = page_directory(itr->page) - 1;

    return itr;
}

/**
 * Populates pointers with information on the current string represented by the
 * iterator, and moves the iterator to the next string.
 * @param      itr  The sort iterator
 * @param[out] strp Holds a pointer to the string the iterator was over
 * @param[out] len[ Holds the length of the string the iterator was over
 * @return 0 if successful, -1 if the iterator is beyond the last string (in
 *         which case @strp and @lenp will not point to valid values)
 */
int
sort_itr_next(sort_itr_t *itr, char** strp, unsigned *lenp)
{
    uint32_t    offset;

    /*
     * Check for end-of-file.
     */
    if (itr->page == NULL) {
        return -1;
    }

    /*
     * Populate pointed values with the current string's data and length.
     */
    offset = dirent_offset(*itr->dir);
    *strp = &itr->page->data[offset];
    *lenp = (unsigned)dirent_length(*itr->dir);

    /*
     * Move to the next string, switching pages if required.
     */
    itr->index++;
    itr->dir--;
    if (itr->index == itr->page->nstrings) {
        itr->page = itr->page->next;
        itr->index = 0;
        itr->dir = page_directory(itr->page) - 1;
    }

    return 0;
}

/**
 * Cleans up resources used by an iterator.
 * @param itr The sort iterator
 */
void
sort_itr_done(sort_itr_t *itr)
{
    free(itr);
}

#ifdef DEBUG
/*
 * -----------------------------------------------------------------------------
 * Debugging support
 * -----------------------------------------------------------------------------
 */

static void
verify_heap(sort_page_t **heap, unsigned size, unsigned root)
{
    unsigned   left;
    unsigned   right;

    for (;;) {
        left = root * 2 + 1;
        right = left + 1;
        if (left < size) {
            assert(comp_pages(heap[root], heap[left]) <= 0);
            if (right < size) {
                assert(comp_pages(heap[root], heap[right]) <= 0);
            }
        } else {
            break;
        }

        root = left;
    }
}

static void
verify_run(sort_page_t *page, unsigned runlen)
{
    unsigned   i;

    for (i = 0; i < runlen; i++) {
        if (page == NULL) {
            break;
        }
        assert(page->first == 0);
        page = page->next;
    }

    assert(page == NULL || page->next == NULL);
}

static void
dump_pages(sort_page_t *page)
{
    uint32_t   *directory;
    uint32_t   i;

    while (page) {
        directory = page_directory(page) - 1;
        for (i = 0; i < page->nstrings; i++) {
            uint32_t   offset = dirent_offset(*directory);
            uint32_t   length = dirent_length(*directory);

            fwrite(&page->data[offset], 1, length, stdout);
            printf("\n");
            directory--;
        }
        page = page->next;
    }
}

void
dump_first_string(sort_page_t *page)
{
    uint32_t   dir = page_dirent(page, page->first);
    uint32_t   offset = dirent_offset(dir);
    uint32_t   length = dirent_length(dir);

    fwrite(&page->data[offset], 1, length, stdout);
    printf("\n");
}
#endif /* DEBUG */

#ifdef STANDALONE
/*
 * -----------------------------------------------------------------------------
 * Stand-alone sort programme.
 * Takes a file path as an argument and dumps the sorted list to stdout.
 * -----------------------------------------------------------------------------
 */

int
main(int argc, char **argv)
{
    int            fd;
    struct stat    st;
    void           *mapptr;
    size_t         filesize;
    char           *fileptr;
    char           *line;
    unsigned       linenum;
    unsigned       len;
    sort_t         *sort;
    sort_itr_t     *sort_itr;
    time_t         start;
    time_t         end;

    fprintf(stderr, "%s\n", sortlib_info());

    /*
     * Initialize sorting.
     */
    sort = sort_init();

    if (argc > 1) {
        fd = open(argv[1], O_RDONLY);
        if (fd < 0) {
            fprintf(stderr, "Failed to open %s: %s\n", argv[1], strerror(errno));
            return 1;
        }
    } else {
        fprintf(stderr, "Missing file name");
        return 1;
    }

    if (fstat(fd, &st) < 0) {
        fprintf(stderr, "Failed to stat %s: %s\n", argv[1], strerror(errno));
        return 1;
    }

    mapptr = mmap(0, st.st_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (mapptr == MAP_FAILED) {
        fprintf(stderr, "Failed to map %s: %s\n", argv[1], strerror(errno));
        return 1;
    }

    start = time(NULL);
    fileptr = mapptr;
    filesize = st.st_size;
    line = fileptr;
    len = 0;
    linenum = 1;
    for (;;) {
        if (filesize == 0) {
            break;
        }

        if (*fileptr == '\n') {
            *fileptr = '\0';
            len++;

            /*
             * Make sure the line is not too long.
             */
            if (len <= DIRECTORY_LEN_SIZE) {
                /*
                 * Add the line to the sorting file.
                 */
                if (sort_insert(sort, line, len) != 0) {
                    fprintf(stderr, "Failed to add string at line %u\n",
                            linenum);
                }
            } else {
                fprintf(stderr, "String too long (%u) at line %u\n", len, linenum);
            }

            fileptr++;
            filesize--;
            line = fileptr;
            len = 0;
            linenum++;
        } else {
            fileptr++;
            filesize--;
            len++;
        }
    }
    end = time(NULL);
    fprintf(stderr, "Reading file took %lu seconds\n", end - start);

    munmap(mapptr, st.st_size);

    /*
     * Sort.
     */
    start = time(NULL);
    if (sort_do(sort) < 0) {
        fprintf(stderr, "Failed to sort: %s\n", strerror(errno));
        return 1;
    }
    end = time(NULL);
    fprintf(stderr, "Sorting took %lu seconds\n", end - start);

    /*
     * Dump the sorted lines.
     */
    start = time(NULL);
    sort_itr = sort_itr_init(sort);
    while (sort_itr_next(sort_itr, &line, &len) == 0) {
        line[len - 1] = '\n';
        fwrite(line, len, 1, stdout);
    }
    end = time(NULL);
    fprintf(stderr, "Writing file took %lu seconds\n", end - start);

    sort_itr_done(sort_itr);
    sort_done(sort);
    return 0;
}
#endif // STANDALONE
