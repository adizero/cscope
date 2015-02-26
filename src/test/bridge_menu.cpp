/**************************************************************************
*
*   Filename:           bridgemenu.cpp
*                                   
*   Author:             Vikash Shukla
*   Created:            6/12/07
*
*   Description:        Code for programming the cell gen in Bridge FPGA on Lava
*                       This is primarily a rip off from Nuet functionality.
*
***************************************************************************
*
*                 Source Control System Information
*    $Id: bridge_menu.cpp,v 1.6 2012/09/20 14:27:30 lcolley Exp $
*
*
***************************************************************************
*
*                  Copyright (c) 2001-2012 TiMetra, Inc., Alcatel, Alcatel-Lucent
*
**************************************************************************/

#ifdef RCSID
static const char rcsid[] = "$Id: bridge_menu.cpp,v 1.6 2012/09/20 14:27:30 lcolley Exp $";
#endif

#include <stdlib.h>
#include <strLib.h>

#include "bringup/bringlib.h"
#include "bringup/data_style.h"
#include "bringup/qfdata.h"
#include "bsp/bsptime.h"
#include "bsp/tim1hw.h"
#include "common/std_types.h"
#include "common/timos_printf.h"
#include "debug/debug.h"
#include "rchips/bridgedriver.h"
#include "rchips/rchips.h"

#ifdef __cplusplus
extern "C" {
#endif

// Not sure right now how much would be common between
// Harry's test bridge fpga and final fpga
// So putting in the test fpga mem map
// will change stuff once we have the final bridge fpga map.

/* XPL to XPL2 Test FPGA Memory Map */

#define XPL_2_XPL2_BASE_ADDR            0x0

#define A64_XPL_2_XPL2_VERSION          0x0
#define A32_XPL_2_XPL2_VERSION_MSB      0x0

#define A64_XPL_TX_CONTROL              0x00000040
#define A64_XPL_TX_CONTROL_MSB          0x00000040
#define A64_XPL_TX_CONTROL_LSB          0x00000044
#define M_XPL_TX_CTRL_FE_ENABLE         0x00004000
#define M_XPL_TX_CTRL_PATTERN_GEN_SEL   0x40000000
#define S_XPL_TX_CTRL_PATTERN_GEN_SEL   30
#define M_XPL_TX_CTRL_XPL_LINE_LPBK     0x80000000
#define S_XPL_TX_CTRL_XPL_LINE_LPBK     31

#define A64_PATTERN_GEN_CONTROL         0x00200000
#define A32_PATTERN_GEN_CONTROL_MSB     0x00200000
#define A32_PATTERN_GEN_CONTROL_LSB     0x00200004
#define M_REPEAT_NUM_TIMES              0x0000FFFF
#define S_REPEAT_NUM_TIMES              0
#define M_MAX_ADDRESS                   0x03FF0000
#define S_MAX_ADDRESS                   16
#define M_TX_ENABLE                     0x80000000
#define S_TX_ENABLE                     31

#define A64_PATTERN_GEN_XPL_TX_CNT      0x00200008
#define A32_XPL_TX_SOC_CNT              0x00200008
#define A32_XPL_TX_SOF_CNT              0x0020000C
#define A32_XPL_TX_EOF_CNT              0x00200010

#define PATTERN_GEN_DATA_MEM_BASE_ADDR   0x00204000
#define PATTERN_GEN_DATA_MEM_BASE_ADDR_MSB   0x00204000
#define PATTERN_GEN_DATA_MEM_BASE_ADDR_LSB   0x00204004
#define PATTERN_GEN_DATA_MEM_SIZE        0x2000
#define PATTERN_GEN_DATA_MEM_MAX_ADDR    0x00205FFF
#define PATTERN_GEN_DATA_MEM_ENTRY_SIZE  64
#define PATTERN_MAX_INDEX_NUM            (PATTERN_GEN_DATA_MEM_SIZE/PATTERN_GEN_DATA_MEM_ENTRY_SIZE)

#define PATTERN_GEN_FLAG_MEM_BASE_ADDR  0x00206000
#define PATTERN_GEN_FLAG_MEM_SIZE       0x1000
#define PATTERN_GEN_FLAG_MEM_MAX_ADDR   0x00206FFF
#define PATTERN_GEN_FLAG_MEM_ENTRY_SIZE 32
#define M_FLAG_MEM_SOF                  0x00000001
#define M_FLAG_MEM_EOF                  0x00000002
#define M_FLAG_MEM_ABORT                0x00000004
#define M_FLAG_MEM_LENGTH               0x000003F8
#define S_FLAG_MEM_LENGTH               3
#define M_FLAG_MEM_CONTEXT              0x0003FC00
#define S_FLAG_MEM_CONTEXT              10
#define M_FLAG_MEM_PRIORITY             0x00040000
#define M_FLAG_MEM_SOC                  0x80000000
#define S_FLAG_MEM_SOC                  31

#define A64_PATTERN_CHK_CONTROL         0x00300000
#define A32_PATTERN_CHK_CONTROL_MSB     0x00300000
#define A32_PATTERN_CHK_CONTROL_LSB     0x00300004
#define M_PATTERN_CHK_SNAPSHOT_START    0x80000000

#define A64_PATTERN_CHK_XPL_RX_CNT      0x00300008
#define A32_XPL_RX_SOF_CNT              0x00300008
#define A32_XPL_RX_SOC_CNT              0x0030000C
#define A32_XPL_RX_FCS_ERR_CNT          0x00300010
#define A32_XPL_RX_EOF_CNT              0x00300014

#define SNAPSHOT_DATA_MEM_BASE_ADDR     0x00304000
#define SNAPSHOT_DATA_MEM_SIZE          0x2000
#define SNAPSHOT_DATA_MEM_MAX_ADDR      0x00305FFF

#define SNAPSHOT_FLAG_MEM_BASE_ADDR     0x00306000
#define SNAPSHOT_FLAG_MEM_SIZE          0x1000
#define SNAPSHOT_FLAG_MEM_MAX_ADDR      0x00306FFF

#define A64_HBUS_CONTROL_REG            0x00600000
#define A32_HBUS_CONTROL_REG_MSB        0x00600000
#define A32_HBUS_CONTROL_REG_LSB        0x00600004
#define M_HBUS_INTERNAL_LPBK            0x20000000
#define S_HBUS_INTERNAL_LPBK            29
#define M_HBUS_LINE_LPBK                0x40000000
#define S_HBUS_LINE_LPBK                30

typedef enum {
    LPBK_NONE,
    LPBK_LINE,
    LPBK_HBUS_INT,
    LPBK_HBUS_LINE,
    LPBK_INVALID,
} tBridgeLoopback;

/*=================================================================================*/

#define BR_WR_8(addr, val) \
   ({ \
        if (bridge->print_writes) timosPrintf("WR8 %08x: %08x\n", addr, val); \
        WR_8 (addr, val); \
    })

#define BR_WR_32(addr, val) \
   ({ \
        if (bridge->print_writes) timosPrintf("WR32 %08x: %08x\n", addr, val); \
        WR_32 (addr, val); \
    })

#define BR_RD_32(addr)  \
   ({ \
        tUint32 val; \
        val = RD_32(addr); \
        if (bridge->print_reads) timosPrintf("RD32 %08x: %08x\n", addr, val); \
        val; \
    })

#define BR_WAIT_USEC(val)  \
   ({ \
        sysDelayNanos((val)*1000); \
        if ((bridge->print_reads) || (bridge->print_writes)) timosPrintf("wait %d uSec\n", val); \
    })

#define BR_WAIT_MSEC(val)  \
   ({ \
        sysDelayNanos((val)*1000000); \
        if ((bridge->print_reads) || (bridge->print_writes)) timosPrintf("wait %d mSec\n", val); \
    })

#define GET_BRIDGE(mdaNum)                \
    tBridge* bridge;                      \
    bridge = &bridgeTable[mdaNum];

#define VALIDATE_BRIDGE(mdaNum)   \
        tBridge *bridge;                    \
        bridge  = &bridgeTable[mdaNum];     \
        ASSERT(bridge->initialized);

/*=================================================================================*/

typedef enum {
    BRIDGE_TX_FLAG,
    BRIDGE_TX_DATA,
    BRIDGE_RX_FLAG,
    BRIDGE_RX_DATA,
    BRIDGE_MEM_ALL,
} tBridgeMem;

typedef struct
{
    tUint32     numSOF;
    tUint32     numSOC;
    tUint32     numFCSErr;
    tUint32     numEOF;
} tBrGenRxStats;

typedef struct
{
    tUint32     numSOF;
    tUint32     numSOC;
    tUint32     numEOF;
} tBrGenTxStats;

typedef struct tBrGen tBridge;

struct tBrGen
{
    tUint32     baseaddr;
    tUint32     chip_num;
    tUint32     chip_index;

    tBoolean    initialized;
    tBridgeLoopback    loopback;
    tBoolean    print_reads;
    tBoolean    print_writes;    
    tBoolean    quiet;    

    tBrGenRxStats    rxStats;
    tBrGenTxStats    txStats;

};

tBridge     bridgeTable[3];

struct tCellHdr
{
    tUint32         soc         :1,
                    spare       :12,
                    prio        :1,
                    context     :8,
                    frame_length:7,
                    abort       :1,
                    eof         :1,
                    sof         :1;
};

#define XPL_CELL_SIZE   128
#define NUM_DATA_SLICES 6
#define MAX_FRAME_SIZE  1024

tUint32     num_breathers;
tUint32     global_index;

/*====================================================================================================================================================*/

PUBLIC void bridgeDataGen(tUint32 mdaNum, tUint8* data, tBringupDataStyle type, tUint32 len, tUint32 seed, tUint32 seqno)
{
    tUint32 i;

    GET_BRIDGE(mdaNum);

    if (bridge->quiet == FALSE)
        printf("bridgeDataGen %d - pattern %d, length:%d, seed %x\n", mdaNum, (tUint32)type, len, 0);

    if ( type != UNDEFINED_DATA ) 
    {
        tPatternGeneratorFn fn = get_pattern_generator(type);
        for(i=0; i<len;)
        {
            tUint32 word_length = fn(type, i, seqno, data, 0);
            
            data += word_length;
            i += word_length;
        }
        return;
    }
    printf("Data Type Undefined(%d)\n", (tUint32)type);
    return;
}

/*================================================================================*/

PUBLIC void bridgeAddBreatherSpacing(tUint32 mdaNum, tUint32 breather_spacing)
{

    tUint32 i, addr, addr1;

    GET_BRIDGE(mdaNum);
    addr = bridge->baseaddr + PATTERN_GEN_FLAG_MEM_BASE_ADDR + (global_index * sizeof(tCellHdr));
    addr1 = bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR + (global_index * sizeof(tUint64));
    for (i=0; i< breather_spacing; i++)
    {
        BR_WR_32(addr, 0);
        BR_WR_32(addr1, 0);
        addr1 +=4;
        BR_WR_32(addr1, 0);
        global_index++;
        addr +=4;
        addr1 +=4;
    }
}

/*================================================================================*/

PUBLIC void bridgeCellWrite(tUint32 mdaNum, tCellHdr* cellHdr, tUint8* data)
{
    tUint32 i, addr, addr1;

    GET_BRIDGE(mdaNum);
    printf("bridgeCellWrite(%d, %d), SOF: %s, EOF: %s, SOC: %s, context: %d, length: %d\n",
                mdaNum, global_index, cellHdr->sof? "TRUE":"FALSE", cellHdr->eof? "TRUE":"FALSE", cellHdr->soc? "TRUE":"FALSE",
                cellHdr->context, cellHdr->frame_length);

    addr = bridge->baseaddr + PATTERN_GEN_FLAG_MEM_BASE_ADDR + (global_index * sizeof(cellHdr));
    printf("      Flag Mem index:%04d(%03d)   address:0x%08x\n", global_index, num_breathers, addr);
    if (addr > (bridge->baseaddr + PATTERN_GEN_FLAG_MEM_MAX_ADDR))
    {
        printf("ERROR!!ERROR!! Flag Mem Addr:0x%x Greater than max:0x%x\n", addr, (bridge->baseaddr + PATTERN_GEN_FLAG_MEM_MAX_ADDR));
        return;
    }

    addr1 = bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR + (global_index * sizeof(tUint64));
    if (addr1 > (bridge->baseaddr + PATTERN_GEN_DATA_MEM_MAX_ADDR))
    {
        printf("ERROR!!ERROR!! Data Mem Addr:0x%x Greater than max:0x%x\n", addr1, (bridge->baseaddr + PATTERN_GEN_DATA_MEM_MAX_ADDR));
        return;
    }
    printf("      Data Mem index:%04d(%03d)   address:0x%08x\n", global_index, num_breathers, addr1);

    for (i=0; i<(cellHdr->frame_length+1)/8; i++, addr+=4, data+=4)
    {
        if (i == 0)
            BR_WR_32(addr, *((tUint32*)cellHdr));
        else
            BR_WR_32(addr, 0);
            
        BR_WR_32(addr1, *((tUint32*)data));
        addr1+=4;
        data+=4;
        BR_WR_32(addr1, *((tUint32*)data));
        addr1+=4;
        global_index++;
    }
    //Zero out the entries corresponding to the breather entry
    BR_WR_32(addr, 0);
    BR_WR_32(addr1, 0);
    addr1 +=4;
    BR_WR_32(addr1, 0);
    num_breathers++;
    global_index++;
}

/*================================================================================*/

PUBLIC void bridgeFramesCreate(tUint32 mdaNum, tBringupDataStyle type, tUint32 length, tUint32 context, tUint32 num_frames, tUint32 breather_spacing)
{
    tUint8      data[XPL_CELL_SIZE];
    tCellHdr    hdr = {0};
    tUint32     cell_size = 128;
    tUint32     loop_length;
    tUint32     fcs_addr;

    printf("bridgeFrameCreate(%d), data style:%d length:%d context:%d num_frames:%d\n", mdaNum, (tUint32)type, length, context, num_frames);
    GET_BRIDGE(mdaNum);
    printf("Base address:0x%08x\n",bridge->baseaddr);

    if ((length * num_frames) > PATTERN_GEN_DATA_MEM_SIZE)
    {
        printf("Too much memory required for %d number of frames with length %d\n", num_frames, length);
        printf("Max mem available is 0x2000, either reduce the frame length of number of frames\n");
        return;
    }

    for (tUint32 i=0;i<num_frames;i++)
    {
        printf("Writing frame_num:%d\n", i);
        tUint32     frame_fcs = 0xFFFFFFFF;
        tUint32     final_fcs = 0xFFFFFFFF;

        fcs_addr = bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR_MSB + (global_index * sizeof(tUint64));
        hdr.sof = TRUE;
        hdr.eof = FALSE;
        loop_length = length;
        prepareFrameDataWord(qchipGetChipNum(hwRchipMdaNumGetComplex(mdaNum), 0), type, 0); 
        while (loop_length > cell_size)
        {
            hdr.soc = TRUE;
            hdr.frame_length = cell_size - 1; //length in h/w is 0 based
            hdr.context = context;
            bridgeDataGen(mdaNum, &data[0], type, cell_size, 0, i);
            bridgeCellWrite(mdaNum, &hdr, data);
            frame_fcs = incrementalFcs(frame_fcs, &data[0], cell_size);
            fcs_addr += cell_size + sizeof(tUint64);
            loop_length -= cell_size;;
            hdr.sof = FALSE;
        }
        //Write out the last cell of the frame
            hdr.eof = TRUE;
            hdr.soc = TRUE;
            hdr.frame_length = loop_length - 1; //length in h/w is 0 based
            hdr.context = context;
            bridgeDataGen(mdaNum, &data[0], type, loop_length, 0, i);
            bridgeCellWrite(mdaNum, &hdr, data);
            frame_fcs = incrementalFcs(frame_fcs, &data[0], loop_length-4);
            fcs_addr += loop_length - sizeof(tUint32);
            final_fcs  = ~frame_fcs;
            for (unsigned j=0;j<4;j++)
                BR_WR_8(fcs_addr+j, ((final_fcs >> (j*8)) & 0xff)); //write the FCS in little endian
            bridgeAddBreatherSpacing(mdaNum, breather_spacing);
    }
}

PUBLIC void bridgeDumpMemory(tUint32 mdaNum, tBridgeMem memory)
{
    tUint32 i, aa;
    tUint32 tx_data1, tx_data2, tx_flag;
    tUint32 flag_content, data1_content, data2_content;

    GET_BRIDGE(mdaNum);

    printf("bridgeDumpMemory(%d,%d)\n", mdaNum, memory);

    tx_flag  = bridge->baseaddr + PATTERN_GEN_FLAG_MEM_BASE_ADDR;
    printf("base address tx_flag: 0x%08x\n", bridge->baseaddr + tx_flag);
    tx_data1 = bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR_MSB;
    printf("base address tx_data:0x%08x\n", bridge->baseaddr + tx_data1);
    tx_data2 = bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR_LSB;

    switch (memory)
    {
        case BRIDGE_TX_FLAG:      
            printf("Dumping Flag Memory from 0x%x\n", tx_flag);
            for (i=0; i<(PATTERN_GEN_FLAG_MEM_SIZE/PATTERN_GEN_FLAG_MEM_ENTRY_SIZE); i+=8) 
            {
                for (aa = 0; aa < 8; aa++)
                {
                   printf("%08x ", BR_RD_32(tx_flag));
                   tx_flag += 4;
                }
                printf("\n");
            }
            break;
        case BRIDGE_TX_DATA:      
            printf("Dumping Data Memory from 0x%x\n", tx_data1);
            for (i=0; i<(PATTERN_GEN_DATA_MEM_SIZE/PATTERN_GEN_DATA_MEM_ENTRY_SIZE); i+=8) 
            {
                for (aa = 0; aa < 8; aa++)
                {
                   printf("%08x %08x ", BR_RD_32(tx_data1), BR_RD_32(tx_data2));
                   tx_data1 += 4;
                   tx_data2 += 4;
                }
                printf("\n");
            }
            break;
        case BRIDGE_MEM_ALL:      
            for (i=0; i<(PATTERN_GEN_DATA_MEM_SIZE/PATTERN_GEN_DATA_MEM_ENTRY_SIZE); i++) 
            {
                flag_content = BR_RD_32(tx_flag);
                tx_flag +=4;
                printf(" %3d. flag 0x%08x : %08x data %08x : ", i, tx_flag, flag_content, tx_data1);
                data1_content = BR_RD_32(tx_data1);
                tx_data1 +=4;
                data2_content = BR_RD_32(tx_data1);
                tx_data1 +=4;
                printf("%08x %08x ", data1_content, data2_content);
                if (flag_content)
                    printf("SOF: %s, EOF: %s, SOC: %s length:%3d", 
                        (((tCellHdr*)&flag_content)->sof)?" TRUE":"FALSE", 
                        (((tCellHdr*)&flag_content)->sof)?" TRUE":"FALSE", 
                        (((tCellHdr*)&flag_content)->sof)?" TRUE":"FALSE",
                        (((tCellHdr*)&flag_content)->frame_length));
                printf("\n");
            }
            break;
        default: break;
    }


}
/*================================================================================*/

PUBLIC void bridgeClearMemory(tUint32 mdaNum, tBridgeMem memory, tBoolean verbose)
{
    tUint32 i;
    tUint32 *tx_data1, *tx_data2, *tx_flag;

    GET_BRIDGE(mdaNum);

    if (verbose)
        printf("bridgeClearMemory(%d,%d)\n", mdaNum, memory);

    tx_flag  = (tUint32*)(bridge->baseaddr + PATTERN_GEN_FLAG_MEM_BASE_ADDR);
    if (verbose)
        printf("base address tx_flag: 0x%08x\n", (tUint32)tx_flag);
    tx_data1 = (tUint32*)(bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR_MSB);
    if (verbose)
        printf("base address tx_data1:0x%08x\n", (tUint32)tx_data1);
    tx_data2 = (tUint32*)(bridge->baseaddr + PATTERN_GEN_DATA_MEM_BASE_ADDR_LSB);
    if (verbose)
        printf("base address tx_data2:0x%08x\n", (tUint32)tx_data2);

    switch (memory)
    {
        case BRIDGE_TX_FLAG:      
            for (i=0; i<(PATTERN_GEN_FLAG_MEM_SIZE/PATTERN_GEN_FLAG_MEM_ENTRY_SIZE); i++) 
            {
                *tx_flag++ = 0;
            } 
            break;
        case BRIDGE_TX_DATA:      
            for (i=0; i<(PATTERN_GEN_DATA_MEM_SIZE/PATTERN_GEN_DATA_MEM_ENTRY_SIZE); i++) 
            {
                *tx_data1 = 0; 
                *tx_data2 = 0;
                tx_data1 += 2;
                tx_data2 += 2;
            } 
            break;
        case BRIDGE_MEM_ALL:      
            for (i=0; i<(PATTERN_GEN_DATA_MEM_SIZE/PATTERN_GEN_DATA_MEM_ENTRY_SIZE); i++) 
            { 
                *tx_flag++ = 0; 
                *tx_data1 = 0; 
                *tx_data2 = 0;
                tx_data1 += 2;
                tx_data2 += 2;
            } 
            break;
        default: break;
    }
}

/*================================================================================*/

PUBLIC void bridgeSelectPatternGen(tUint32 mdaNum)
{
    tUint32 data;
    GET_BRIDGE(mdaNum);
    
    data = BR_RD_32(bridge->baseaddr + A64_XPL_TX_CONTROL_MSB);
    BR_WR_32(bridge->baseaddr + A64_XPL_TX_CONTROL_MSB, data | M_XPL_TX_CTRL_PATTERN_GEN_SEL | M_XPL_TX_CTRL_FE_ENABLE);

}

PUBLIC void bridgeWriteMaxAddress(tUint32 mdaNum)
{
    tUint32 data;
    GET_BRIDGE(mdaNum);
    
    data = BR_RD_32(bridge->baseaddr + A32_PATTERN_GEN_CONTROL_MSB);
    data &= ~M_MAX_ADDRESS;
    BR_WR_32(bridge->baseaddr + A32_PATTERN_GEN_CONTROL_MSB, data | (global_index << S_MAX_ADDRESS));

}

PUBLIC void bridgeTxEnable(tUint32 mdaNum, tBoolean enable)
{
    tUint32 data;
    GET_BRIDGE(mdaNum);

    printf("bridgeTxEnable(%d,%d)\n", mdaNum, enable);

    data = BR_RD_32(bridge->baseaddr + A32_PATTERN_GEN_CONTROL_MSB);
    if (enable)
        BR_WR_32(bridge->baseaddr + A32_PATTERN_GEN_CONTROL_MSB, M_TX_ENABLE | data);
    else
        BR_WR_32(bridge->baseaddr + A32_PATTERN_GEN_CONTROL_MSB, data & ~M_TX_ENABLE);
}

/*================================================================================*/

extern "C"  char* bridgeLoopbackName(tUint32 mdaNum)
{
    GET_BRIDGE(mdaNum);

    switch (bridge->loopback)
    {
        case LPBK_NONE:
            return "none";
        case LPBK_LINE:
            return "XPL line";
        case LPBK_HBUS_INT:
            return "HBUS Int";
        case LPBK_HBUS_LINE:
            return "HBUS line";
        default:
            return "error";
    }
}

    /*======================*/

extern "C"  tBridgeLoopback bridgeLoopbackGet(tUint32 mdaNum)
{
    GET_BRIDGE(mdaNum);

    printf("bridgeLoopback(%d) - %s\n", mdaNum, bridgeLoopbackName(mdaNum));
    return (bridge->loopback);
}

    /*======================*/

extern "C"  void bridgeLoopbackSet(tUint32 mdaNum, tBridgeLoopback loopback)
{
    tUint32 data;
    VALIDATE_BRIDGE(mdaNum);

    if (loopback == LPBK_HBUS_INT )
    {
        data = BR_RD_32(bridge->baseaddr + A32_HBUS_CONTROL_REG_MSB);
        data &= ~(M_HBUS_INTERNAL_LPBK);
        data |= M_HBUS_INTERNAL_LPBK;
        BR_WR_32(bridge->baseaddr + A32_HBUS_CONTROL_REG_MSB, data);
    } else if (loopback == LPBK_HBUS_LINE )
    {
        data = BR_RD_32(bridge->baseaddr + A32_HBUS_CONTROL_REG_MSB);
        data &= ~(M_HBUS_LINE_LPBK);
        data |= M_HBUS_LINE_LPBK;
        BR_WR_32(bridge->baseaddr + A32_HBUS_CONTROL_REG_MSB, data);
    } else if (loopback == LPBK_LINE)
    {
        data = BR_RD_32(bridge->baseaddr + A64_XPL_TX_CONTROL_LSB);
        data &= ~(M_XPL_TX_CTRL_XPL_LINE_LPBK);
        data |= M_XPL_TX_CTRL_XPL_LINE_LPBK;
        BR_WR_32(bridge->baseaddr + A64_XPL_TX_CONTROL_LSB, data);
    }
    else
    {
        data = BR_RD_32(bridge->baseaddr + A64_XPL_TX_CONTROL_LSB);
        data &= ~(M_XPL_TX_CTRL_XPL_LINE_LPBK);
        BR_WR_32(bridge->baseaddr + A64_XPL_TX_CONTROL_LSB, data);
    }
    bridge->loopback = loopback;
    printf("bridgeLoopbackSet(%d,%d) - %s\n", mdaNum, loopback, bridgeLoopbackName(mdaNum));
}

/*================================================================================*/

PUBLIC void bridgeFrameGenStart(tUint32 mdaNum)
{
    VALIDATE_BRIDGE(mdaNum);

    printf("bridgeFrameGenStart(%d)\n", mdaNum);

    bridgeWriteMaxAddress(mdaNum);

    bridgeTxEnable(mdaNum, TRUE);
    
    bridgeSelectPatternGen(mdaNum);
}

/*================================================================================*/

PUBLIC void bridgeFrameGenStop(tUint32 mdaNum)
{

    VALIDATE_BRIDGE(mdaNum);

    printf("bridgeFrameGenStop(%d)\n", mdaNum);

    bridgeTxEnable(mdaNum, FALSE);
}

/*================================================================================*/

PUBLIC void bridgeGatherTxStats(tUint32 mdaNum)
{
    GET_BRIDGE(mdaNum);

    bridge->txStats.numSOF= BR_RD_32(bridge->baseaddr + A32_XPL_TX_SOF_CNT);
    bridge->txStats.numSOC= BR_RD_32(bridge->baseaddr + A32_XPL_TX_SOC_CNT);
    bridge->txStats.numEOF= BR_RD_32(bridge->baseaddr + A32_XPL_TX_EOF_CNT);
}

    /*======================*/

PUBLIC void bridgeGatherStats(tUint32 mdaNum)
{
    bridgeGatherTxStats(mdaNum);
}

extern "C" tBoolean bridgeInited(tUint32 mdaNum, tBoolean verbose)
{
    GET_BRIDGE(mdaNum);

    if (verbose)
        printf("Bridge %d is %snitialized with base address:0x%x\n", mdaNum, bridge->initialized?"I":"Uni", bridge->baseaddr);
    return bridge->initialized;
}

    /*======================*/

extern "C"  tStatus bridgeInit(tUint32 mdaNum, tBoolean verbose)
{
    tUint32 chip_num;

    GET_BRIDGE(mdaNum);
    if (bridge->initialized) return OK; 

    if (verbose)
        printf("bridgeInit(%d)\n", mdaNum);

    num_breathers = 0;
    global_index = 0;

    chip_num = bridgechipGetChipNum(0, 0, (mdaNum-1));
    if (!bridgechipIsInitialised(chip_num))
    {
        if (verbose)
            printf("Bridge %d already initalised\n", mdaNum);
        return OK;
    }
    
    bridge->baseaddr = ( 0xa0000000 | getRchipBaseAddress(chip_num));

    //clear memories
    bridgeClearMemory(mdaNum, BRIDGE_MEM_ALL, verbose);

    // gather the stats, for the heck of it
    bridgeGatherStats(mdaNum);

    if (verbose)
        printf("Bridge %d initialized.\n", mdaNum);

    bridge->initialized = TRUE;

    return OK;
}

PUBLIC tStatus bridgeReset(tUint32 mdaNum)
{

    num_breathers = 0;
    global_index = 0;
    bridgeClearMemory(mdaNum, BRIDGE_MEM_ALL, FALSE);
    return OK;

}
        

PUBLIC void bridgePrintStats(tUint32 mdaNum, tBoolean verbose)
{
    GET_BRIDGE(mdaNum);

    bridgeGatherStats(mdaNum);
    timosPrintf("\nBridge-%d stats:", mdaNum);
    timosPrintf("\n     Tx stats:");
    if ((bridge->txStats.numSOF) || verbose)
        timosPrintf("\n            SOF Cnt: %08d", bridge->txStats.numSOF);
    if ((bridge->txStats.numSOC) || verbose)
        timosPrintf("\n            SOC Cnt: %08d", bridge->txStats.numSOC);
    if ((bridge->txStats.numEOF) || verbose)
        timosPrintf("\n            EOF Cnt: %08d", bridge->txStats.numEOF);
    timosPrintf("\n     Rx stats:");
    if ((bridge->rxStats.numSOF) || verbose)
        timosPrintf("\n            SOF Cnt: %08d", bridge->rxStats.numSOF);
    if ((bridge->rxStats.numSOC) || verbose)
        timosPrintf("\n            SOC Cnt: %08d", bridge->rxStats.numSOC);
    if ((bridge->rxStats.numEOF) || verbose)
        timosPrintf("\n            EOF Cnt: %08d", bridge->rxStats.numEOF);
    if ((bridge->rxStats.numFCSErr) || verbose)
        timosPrintf("\n      FCS Error Cnt: %08d", bridge->rxStats.numFCSErr);
    timosPrintf("\n");
}
/*================================================================================*/

PUBLIC void bridgeHelp()
{
    timosPrintf("\n");
    timosPrintf("bridgeInit         <mdaNum> <verbose>        : Init the pattern gen in bridge\n");
    timosPrintf("bridgeInited       <mdaNum>                  : Inquire if the pattern gen is inited\n");
    timosPrintf("bridgeFrameGenStart<mdaNum> <verbose>        : Start the frame gen engine\n");
    timosPrintf("bridgeFrameGenStop <mdaNum> <verbose>        : Stop the frame gen engine\n");
    timosPrintf("bridgeFramesCreate <mdaNum> <data style> <length> <context> <num frames> <breather_size>\n");
    timosPrintf("                                             : Create Frame in frame gen memory\n");
    timosPrintf("                                             : type bringupShowDataStyles for data styles\n");
    timosPrintf("                                             : breather_size is number of 64 bit blank entries between two frames\n");
    timosPrintf("bridgeRepeatCount  <mdaNum> <count>          : Number of times the gen engine sweeps the frame memory 0=infinite\n");
    timosPrintf("bridgePrintStats   <mdaNum> <verbose>        : Print Bridge Stats \n");
    timosPrintf("bridgeDumpMemory   <mdaNum> <which_mem>      : Dump Tx Memory flag=0, data=1, both=4\n");
    timosPrintf("bridgeClearMemory  <mdaNum> <which_mem>      : Clear Framegen memory\n");
    timosPrintf("                                               0=Tx Flag, 1=Tx Data, 4=All Mem\n");
    timosPrintf("bridgeLoopbackSet  <mdaNum> <which_lpbk>     : Set Bridge in line loopback 1= XPL line, 2= HBUS int, 3= HBUS line\n");
    timosPrintf("bridgeReset        <mdaNum>                  : Reset All data structures and clear all memories\n");
    timosPrintf("bridgePrintSet     <mdaNum> <flags>          : Change verbose settings read=1, write=2, both=3\n");
    timosPrintf("\n");
}

/*===============================================================================*/

PUBLIC void bridgePrintSet(tUint32 mdaNum, tUint32 flags)
{
    GET_BRIDGE(mdaNum);

    bridge->print_reads = (flags & 0x1) ? TRUE : FALSE;
    bridge->print_writes = (flags & 0x2) ? TRUE : FALSE;
}

    /*=====================================================================*/

PUBLIC void bridgePrintShow(tUint32 mdaNum)
{
    GET_BRIDGE(mdaNum);

    timosPrintf("\nbridge (%d):   reads=%d   writes=%d\n", mdaNum, bridge->print_reads, bridge->print_writes);
}

/*===============================================================================*/

#ifdef __cplusplus
};
#endif
