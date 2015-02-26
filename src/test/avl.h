/**************************************************************************
*
*   Filename:           avl.h
*
*   Author:             Marcelo Mourier
*   Created:            Thu Aug 24, 2000 9:41:06
*
*   Description:        AVL Tree library
*
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: avl.h,v 1.60 2013/04/11 14:25:33 ptregunn Exp $
*
***************************************************************************
*
*                  Copyright (c) 2000-2013 TiMetra, Inc., Alcatel, Alcatel-Lucent
*
**************************************************************************/

#ifndef AVL_H
#define AVL_H

/*
 * avl package: 1.5 1994/11/23 01:44:52 jik
 *
 * Copyright (c) 1988-1993, The Regents of the University of California.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of the University of California not
 * be used in advertising or publicity pertaining to distribution of 
 * the software without specific, written prior permission.  The University
 * of California makes no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without express or
 * implied warranty.
 *
 * THE UNIVERSITY OF CALIFORNIA DISCLAIMS ALL WARRANTIES WITH REGARD TO 
 * THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND 
 * FITNESS, IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE FOR
 * ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
 * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
 * CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN 
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifdef __cplusplus
//extern "C" {
#endif

#include <dllLib.h>
#include "common/std_types.h"

#define AVLP_FORWARD     0
#define AVLP_BACKWARD    1

#define AVLP_OK          0
#define AVLP_DUP         1
#define AVLP_ERR        -1

#define AVLP_DONE        0
#define AVLP_CONT        1
#define AVLP_RM_NODE   0x8000

#define AVL_MAX_RC_DEPTH 32

#define AVL_FLAG_USE_DLL   0x1
#define AVL_FLAG_EMBEDDED  0x2
#define AVL_FLAG_COMPACT   0x4

#define AVL_COMPARE_LEFT_BIGGER (-1)
#define AVL_COMPARE_RIGHT_BIGGER (1)
#define AVL_COMPARE_EQUAL (0)

int moja_funkcia();

bool operator==(const tIp6Addr& a, const tIp6Addr& b);
bool operator<(const tIp6Addr& a, const tIp6Addr& b);
bool operator>(const tIp6Addr& a, const tIp6Addr& b);

bool operator==(const TLS_MAC_ADDR & s, const TLS_MAC_ADDR & t)
    { return ((s.first == t.first) && (s.second == t.second)); }

bool operator<(const TLS_MAC_ADDR & s, const TLS_MAC_ADDR & t)
    {
    if (s.first < t.first) return true;
    if ((s.first == t.first) && (s.second < t.second)) return true;
    return false;
    }

size_t hash<TLS_MAC_ADDR>::operator()(TLS_MAC_ADDR s) const
    { return (size_t) (  s.first
                         + (s.second.MacAddrByte[0] + (s.second.MacAddrByte[1] << 8))
                         + (s.second.MacAddrByte[2] + (s.second.MacAddrByte[3] << 8))
                         + (s.second.MacAddrByte[4] + (s.second.MacAddrByte[5] << 8)));
    }

void moja_funkcia2(int a);

char *
ipsec_dump_policy_withports(policy, delimiter)
    void *policy;
    const char *delimiter;
{
    return ipsec_dump_policy1(policy, delimiter, (struct tAvlpTree){0});
}

int avlpNextSameKey3(tAvlpTree *tree, const char *key, void **lastNode, char **key_p, void **value_p);

void avlpLookup4(tree, key, (void **) 0);

typedef void (*pol_info_avlp_dup_cbk_p5)(tAvlpTree *dst_p, int key, int value, t_pol_info_type tree_type);

int moja_funkcia6() const
{
    return (int)(void *)(0 + (int) 1);
}

XmlSgsnLdpPeer::XmlSgsnLdpPeer() :
        ldpInstance(NULL),
        ipAddress(NULL),
        labelSpace(NULL),
        adjacencyType(NULL),
        state(NULL),
        maxPduLength(NULL),
        localAddress(NULL),
        localTcpPort(NULL),
        peerTcpPort(NULL),
        localKaTimeout(NULL),
        peerKaTimeout(NULL),
        grState(NULL),
        nbrLivenessTime(NULL),
        maxRecoveryTime(NULL),
        numberOfRestart(NULL),
        lastRestartTime(NULL),
        advertise(NULL),
        operState(NULL),
        helloFactor(NULL),
        holdTime(NULL),
        kaFactor(NULL),
        passiveMode(NULL),
        autoCreated(NULL),
        lastModified(NULL),
        activeAdj(NULL)

{
    LOG4CPLUS_TRACE( logger, "XmlSgsnLdpPeer::XmlSgsnLdpPeer() created" );
}

XmlSgsnLdpPeer::~XmlSgsnLdpPeer()
{
    //destructor
}

XmlSgsnLdpPeer::stepRead()
{
    delete this;
    //function definition
}

/* AVL Tree node */
typedef struct tAvlpBaseNode {
    struct tAvlpBaseNode *Left;
    struct tAvlpBaseNode *Right;
    int Height;
} tAvlpBaseNode;

typedef struct tAvlpNode {
    union {
        tAvlpBaseNode baseNode;
        struct {
            struct tAvlpNode *Left;
            struct tAvlpNode *Right;
            int Height;
        };
    };
    char *Key;
    void *Value;
    DL_NODE dllNode;
} tAvlpNode;

#define AVL_CAST_INT_TO_KEY(x)         ((char*)(intptr_t)(x))
#define AVL_CAST_KEY_TO_INT(inttype,x) ((inttype)(intptr_t)(x))

#define AVL_CAST_INT_TO_ARG(x)         ((void*)(intptr_t)(x))
#define AVL_CAST_ARG_TO_INT(inttype,x) ((inttype)(intptr_t)(x))

struct tAvlpTreeChecks;

typedef void* (*fAvlpMemAlloc) (size_t size, intptr_t arg);
typedef void  (*fAvlpMemFree)  (void* pMem, intptr_t arg);

/* AVL Tree */
typedef struct tAvlpTree {
    tAvlpBaseNode *root;
    DL_LIST   dll;
    int (*compar)(const char *, const char *);
    int num_entries;
    tInt16  modified: 1;
    tInt16  flags   : 15;
    tInt16  nodeOffset; // If embedded, the offset from the "Value" ptr where the avlNode ptr is
    char *unwind_key;
    
    fAvlpMemAlloc memMalloc;
    fAvlpMemFree  memFree;

    union {
        intptr_t memArg;
        int      keyOffset; /* used only in the compact case */
    };

    union {
        int valueArg; /* if non-0, pass the value ptr instead of memArg in memMalloc */
        int valueOffset; /* only used in the compact case */
    };
    
    struct tAvlpTreeChecks *pChecks;
    
} tAvlpTree2;

/* avlpNewTree:
 *
 * Allocate and initialize an AVL Tree object. The argument 'cmpFunc' 
 * specifies the function used to compare keys, and has the following 
 * prototype:
 *
 *        int cmpFunc(const char *key1, const char *key2);
 *
 * The function should return a negative value if 'key1' is less than
 * 'key2', zero if both keys are identical, and a positive value if 'key1'
 * is greater than 'key2'. For example, if variable-length strings are used
 * as keys, the compare function could be strcmp(). If the keys are simple
 * integers, the compare function could be avlpNumCmp(). And if the keys
 * are IEEE MAC addresses, the compare function could be avlpMacCmp(). 
 */
#define avlpNewTree( cmpFunc, modId)    avlpNewTreeExtMem( cmpFunc, (fAvlpMemAlloc)modMalloc, (fAvlpMemFree)modFree, modId)

extern tAvlpTree *avlpNewTreeExtMem(int (*cmpFunc)(const char *, const char *), 
                              fAvlpMemAlloc memMalloc,
                              fAvlpMemFree memFree,
                              intptr_t modId);

/* avlpNewTreeExtMem2:
 *
 * allow embedding of multiple AVL nodes within data structures. 
 * the 'arg' in memMalloc is actually the 'value' pointer of the new node
 * also, the tree is preallocated and passed by caller.
 * 
 * avlpTerminateTree must be called to clean up afterwards, unless avlpFreeTree
 *     was called 
 * 
 */
extern tAvlpTree *avlpNewTreeExtMem2(tAvlpTree *tree, int (*cmpFunc)(const char *, const char *), 
                                     fAvlpMemAlloc memMalloc,
                                     fAvlpMemFree memFree);

/* avlpFreeTree:
 *
 * Destroy the specified AVL Tree, freeing all dynamic memory referenced by
 * the nodes in the tree. The arguments 'freeKeyFunc' and 'freeValueFunc'
 * specify the functions used to free this memory.
 */
extern void avlpFreeTree(tAvlpTree *pAvl,
                        void (*freeKeyFunc)(char *),
                        void (*freeValueFunc)(void *));

/* avlpFreeTreeExtMem:
 *
 * Destroy the specified AVL Tree, freeing all dynamic memory referenced by
 * the nodes in the tree. The arguments 'freeKeyFunc' and 'freeValueFunc'
 * specify the functions used to free this memory and also use the specific
 * memArg passed while creation of the tree
 */
extern void avlpFreeTreeExtMem(tAvlpTree *pAvl,
                               void (*freeKeyFunc)(char *, intptr_t),
                               void (*freeValueFunc)(void *, intptr_t));

/* avlpInitTree:
 *
 * Initialize a preallocated AVL Tree object. 
 * avlpTerminateTree must be called to clean up before the AVL obj is destroyed
 * The argument 'cmpFunc' 
 * specifies the function used to compare keys, and has the following 
 * prototype:
 *
 *        int cmpFunc(const char *key1, const char *key2, int modId);
 *
 * The function should return a negative value if 'key1' is less than
 * 'key2', zero if both keys are identical, and a positive value if 'key1'
 * is greater than 'key2'. For example, if variable-length strings are used
 * as keys, the compare function could be strcmp(). If the keys are simple
 * integers, the compare function could be avlpNumCmp(). And if the keys
 * are IEEE MAC addresses, the compare function could be avlpMacCmp().
 *
 * Memory allocated from the give modId which in most cases will mean
 * it is allocated from that pool.
 */
extern void avlpInitTree(tAvlpTree *pAvl,
                         int (*cmpFunc)(const char *, const char *),
                         intptr_t modId);

/* avlpDisableLockChecks
 * 
 * Disable lock checks on tree.  Used if tree doesn't always need to be locked -
 * e.g. using dispatch
 * 
 */
void avlpDisableLockChecks(tAvlpTree *pAvl);

/* avlpTerminateTree
 * 
 * Need to be called to clean up preallocated AVL Tree object
 * 
 */
extern void avlpTerminateTree(tAvlpTree *pAvl); 
  
/* avlpInsert:
 *
 * Create a new node with the given key and insert it in the tree. It is
 * OK to insert duplicate keys. Return AVLP_OK when a new key is successfully
 * inserted. Return AVLP_DUP when a duplicate is successfully inserted. 
 * Otherwise return AVLP_ERR.
 */
extern int avlpInsert(tAvlpTree *pAvl, const char *Key, void *Value);

/* avlpInsertUnique:
 *
 * Create a new node with the given key and insert it in the tree ONLY when
 * a duplicate is NOT FOUND. This call was esp. written for cases where
 * application do avlpLookup() before avlpInsert() to insert unique nodes.
 * Return AVLP_OK when a new key is successfully inserted. Return AVLP_DUP 
 * and the value when a duplicate is found.
 * Otherwise return AVLP_ERR.
 */
extern int avlpInsertUnique(tAvlpTree *pAvl, const char *Key, void *Value, void **ValuePtr);

/* avlpInsertReplace:
 * 
 * Return AVLP_OK when a new key is successfully inserted.  If a
 * duplicate is found, replace and return existing key/value, and
 * return AVLP_DUP.  Return AVLP_ERR on failure.
 * 
 * WARNING: Invoking avlpInsertReplace on a tree which has duplicate
 * keys already will result in some random matching node getting
 * replaced
 */
 extern int avlpInsertReplace(tAvlpTree *pAvl, const char *Key, void *Value,
                              char **KeyPtr, void **ValuePtr);

/* avlpDelete:
 *
 * Delete the node associated with the specified key. The 'Key' and 'Value'
 * fields in the record are returned in the arguments 'KeyPtr' and
 * 'ValuePtr', so that the caller can free up any memory referenced by
 * these fields.
 */
extern int avlpDelete(tAvlpTree *pAvl, const char *Key, 
                     char **KeyPtr, void **ValuePtr);

/* avlpDeleteNode:
 *
 * Delete the node associated with the specified key and value. The 'Key' and 'Value'
 * fields in the record are returned in the arguments 'KeyPtr' and
 * 'ValuePtr', so that the caller can free up any memory referenced by
 * these fields. This call is useful to delete a specific <key, value> pair
 * when there are multiple nodes having the same key but different values.
 */
extern int avlpDeleteNode(tAvlpTree *pAvl, const char *Key, const void *Value,
                          char **KeyPtr, void **ValuePtr);
                
/* avlpDeleteTop:
 *
 * Delete the root node. The 'Key' and 'Value'
 * fields in the record are returned in the arguments 'KeyPtr' and
 * 'ValuePtr', so that the caller can free up any memory referenced by
 * these fields.
 */
extern int avlpDeleteTop(tAvlpTree *pAvl, char **KeyPtr, void **ValuePtr);
                
/* avlpDeleteAll:
 *
 * Delete all the nodes in the specified AVL Tree. The arguments
 * 'freeKeyFunc' and 'freeValueFunc' specify the functions used to
 * free the memory referenced by the nodes.
 */
extern void avlpDeleteAll(tAvlpTree *pAvl,
                         void (*freeKeyFunc)(char *),
                         void (*freeValueFunc)(void *));

/* avlpDeleteAll:
 *
 * Delete all the nodes in the specified AVL Tree. The arguments
 * 'freeKeyFunc' and 'freeValueFunc' specify the functions used to
 * free the memory referenced by the nodes. This extended function
 * Also uses the mem arg initialized while creating the tree to
 * delete the key and value nodes
 */
extern void avlpDeleteAllExtMem(tAvlpTree *tree, 
                         void (*freeKeyFunc) (), 
                         void (*freeValueFunc) ());

/* avlpLookup:
 *
 * Search the AVL Tree looking for a node with the specified key.
 * The 'Value' field in the node is returned in the argument 'ValuePtr'.
 */                     
extern int avlpLookup(tAvlpTree *pVal, const char *Key, void **ValuePtr);

/* avlpTop:
 *
 * Get the root node.
 */
extern int avlpTop(tAvlpTree *pVal, char **KeyPtr, void **ValuePtr);

/* avlpFirst:
 *
 * Find the first node in the tree: e.g. the node with the lowest
 * associated key.
 */
extern int avlpFirst(tAvlpTree *pVal, char **KeyPtr, void **ValuePtr);

/* avlpLast:
 *
 * Find the last node in the tree: e.g. the node with the highest
 * associated key.
 */
extern int avlpLast(tAvlpTree *pAvl, char **KeyPtr, void **ValuePtr);

/* avlpNext:
 *
 * Find the first node with a key that is larger than the specified
 * key.
 */
extern int avlpNext(tAvlpTree *pAvl, const char *Key, 
                   char **KeyPtr, void **ValuePtr);

/* avlpNextNode:
 *
 * Find the first node with a key that is larger than the key from the 
 * specified node. Uses DLL when it is enabled.
 */
extern int avlpNodeNext(tAvlpTree *pAvl, tAvlpNode *pIn,
                        tAvlpNode **pOut);

/* avlpPrev:
 *
 * Find the first node with a key that is smaller than the specified
 * key.
 */
extern int avlpPrev(tAvlpTree *pAvl, const char *Key, 
                   char **KeyPtr, void **ValuePtr);

#if 0

/* This procedures is commented out because it does not work properly
 * (see DTS73675). According to me correction is only possible if a
 * pointer to the parent node is added to the AVL node
 */

/* avlpNextSameKey:
 *
 * Find the next node with a key that is idetical to the key of lastNode 
 * NOTE - this routine may only be used if the caller there has been
 *        note changes to the tree between successive calls.
 */

int avlpNextSameKey(tAvlpTree *tree, const char *key, void **lastNode, char **key_p, void **value_p);

#endif

/* avlpDoForSameKey:
 *
 * Walk the tree forward calling the specified function
 * for the range of nodes with same keys' best
 * match until all nodes are visited, or until the handler function
 * returns AVLP_DONE. The handler function has the following prototype:
 *
 *   int handFunc(char *Key, void *Value, void *Arg1, void *Arg2);
 *
 * where the arguments 'Key' and 'Value' are the corresponding fields
 * in the given node, and the arguments 'Arg1' and 'Arg2' are the ones
 * passed in the call to avlpDoForSameKey().
 */
void avlpDoForSameKey(tAvlpTree *pAvl, const char *key, 
                           int (*handFunc)(char *, void *, void *, void *),
                           void *Arg1, void *Arg2);

/* avlpForEach:
 *
 * Walk the tree (forward or backward) calling the specified function
 * for each node found. The handler function has the following
 * prototype:
 *
 *   void handFunc(char *Key, void *Value, void *Arg1, void *Arg2);
 *
 * where the arguments 'Key' and 'Value' are the corresponding fields
 * in the given node, and the arguments 'Arg1' and 'Arg2' are the ones
 * passed in the call to avlpForEach().
 */
extern void avlpForEach(tAvlpTree *pAvl, 
                       void (*handFunc)(char *, void *, void *, void *),
                       int Direction, void *Arg1, void *Arg2);
                       
/* avlpDoWhile:
 *
 * Walk the tree (forward or backward) calling the specified function
 * for each node found, until all nodes are visited, or until the
 * handler function returns AVLP_DONE. The handler function has the 
 * following prototype:
 *
 *   int handFunc(char *Key, void *Value, void *Arg1, void *Arg2);
 *
 * where the arguments 'Key' and 'Value' are the corresponding fields
 * in the given node, and the arguments 'Arg1' and 'Arg2' are the ones
 * passed in the call to avlpDoWhile().
 *
 * return AVLP_DONE if the handlerFunc ever returned with AVLP_DONE
 */
extern int avlpDoWhile(tAvlpTree *pAvl, 
                       int (*handFunc)(char *, void *, void *, void *),
                       int Direction, void *Arg1, void *Arg2);

/* avlpDoWhileRW:
 *
 * Walk the tree (forward or backward) calling the specified function
 * for each node found, until all nodes are visited, or until the
 * handler function returns AVLP_DONE. The handler function has the 
 * following prototype:
 *
 *   int handFunc(char *Key, void *Value, void *Arg1, void *Arg2);
 *
 * where the arguments 'Key' and 'Value' are the corresponding fields
 * in the given node, and the arguments 'Arg1' and 'Arg2' are the ones
 * passed in the call to avlpDoWhile().
 *
 * return AVLP_DONE if the handlerFunc ever returned with AVLP_DONE
 * 
 * handFunc is allowed to remove the node it is processing if the tree is created
 * with AVL_FLAG_USE_DLL, and the function called with !readonly
 * 
 */
extern int avlpDoWhileRW(tAvlpTree *pAvl, 
                         int (*handFunc)(char *, void *, void *, void *),
                         int Direction, void *Arg1, void *Arg2, tBoolean readonly);

/* avlpDoWhileEvRmNode:
 *
 * As explained here above for avlpDoWhile, with the extra feature
 * of allowing handFunc to return with AVLP_RM_NODE bit set, 
 * indicating that the current node needs to be removed from 
 * the AVL tree. 
 * Doing so, the freeKeyFunc and/or freeValueFunc are called when 
 * not NULL
 *
 *  !! This feature can only be used for AVL_FLAG_USE_DLL    !!
 *  !! enabled avl-trees                                     !!
 */
extern int avlpDoWhileEvRmNode(tAvlpTree *pAvl, 
                       int (*handFunc)(char *, void *, void *, void *),
                       void (*freeKeyFunc)(char *),
                       void (*freeValueFunc)(void *),
                       int Direction, void *Arg1, void *Arg2);


/* avlpDoWhileFrom:
 *
 * Same functionality as avlpDoWhile, but with a start key, the entry 
 * matching the key is included.
 *
 * return AVLP_DONE if the handlerFunc ever returned with AVLP_DONE
 *  !! This feature can only be used for AVL_FLAG_USE_DLL    !!
 *  !! enabled avl-trees                                     !!
 */
extern int avlpDoWhileFrom(tAvlpTree *pAvl, const char *start_key,
                       int (*handFunc)(char *, void *, void *, void *),
                       int Direction, void *Arg1, void *Arg2);
                       
/* avlpDoForRange:
 *
 * Walk the tree (forward or backward) calling the specified function
 * for the range of nodes between the given start and end keys' best
 * match until all nodes are visited, or until the handler function
 * returns AVLP_DONE. The handler function has the following prototype:
 *
 *   int handFunc(char *Key, void *Value, void *Arg1, void *Arg2);
 *
 * where the arguments 'Key' and 'Value' are the corresponding fields
 * in the given node, and the arguments 'Arg1' and 'Arg2' are the ones
 * passed in the call to avlpDoForRange().
 */
extern void avlpDoForRange(tAvlpTree *pAvl,
                           const char *start_key, const char *end_key,
                           int (*handFunc)(char *, void *, void *, void *),
                           int Direction, void *Arg1, void *Arg2);
                       
/* avlpCount:
 *
 * Return the number of nodes in the tree.
 */
extern int avlpCount(const tAvlpTree *pAvl);

/* avlpNumCmp:
 *
 * Compare function used for integer keys.
 */
extern int avlpNumCmp(const char *, const char *);

/* avlpUnsignedNumCmp:
 *
 * Compare function used for unsigned integer keys.
 */
extern int avlpUnsignedNumCmp(const char *, const char *);

/* avlpMacCmp:
 *
 * Compare function used for IEEE MAC address keys.
 */
extern int avlpMacCmp(const char *, const char *);

/* avlpCheckTree:
 *
 * Chaeck the consistency of the specified AVL Tree.
 */
extern int avlpCheckTree(tAvlpTree *pAvl);   

/*
 *
 * Set optional check function when entering non-reentrant avl code
 * ->Set function to NULL to disable
 */
extern void avlpSetCheckFctAndArg(tAvlpTree *pAvl,
                                  void (*checkFct)(tAvlpTree *pAvl, tBoolean updating, void*, char*), 
                                  void* checkFctArg,
                                  char* name);

/*
 * Set/Reset the capability flags of the tree. The tree needs to be
 * empty for this operation to proceed. The nodeoffset argument is applicable
 * only in the case when the embedded flag is set.
 */
extern void avlpSetFlags(tAvlpTree *pTree, tInt16 flags, tInt16 nodeOffset);

extern void avlpSetCompactFlags(tAvlpTree *pTree, tInt16 flags, ptrdiff_t nodeOffset, ptrdiff_t keyOffset, ptrdiff_t valueOffset);

/*
 * Returns the size of an internal avl node. Useful in determining overhead to leave when using embedded nodes.
 */
extern int avlpNodeSize(void);
    
/*
 * 
 * Dump the knowledge that has been gathered about the locking requirements of the tree
 * 
 */            
extern void avlpDumpLockingInfo(tAvlpTree *pTree);

extern void avlpChangeOwnerTask(tAvlpTree *pTree, taskid_t taskid); 
extern void avlpIsALocalToTask(tAvlpTree *pTree);
    
/* Handy alias */         
#define avlpIsMember(tree, key)    avlpLookup(tree, key, (void **) 0)         

#ifdef __cplusplus
}
#endif

#endif /* !AVL_H */

