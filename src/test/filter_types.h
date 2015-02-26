/**************************************************************************
*
*   Filename:           filter_types.h
*
*   Author:             MAF
*   Created:            April 2005
*
*   Description:        Filter Types - split out from filter_api.h.
*
*
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: filter_types.h,v 1.27.8.2 2012/03/21 12:05:31 jborms Exp $
*
***************************************************************************
*
*                  Copyright (c) 2001-2012 - TiMetra, Inc., Alcatel, Alcatel-Lucent
*
**************************************************************************/

#ifndef _FILTER_TYPES_H_
#define _FILTER_TYPES_H_

typedef enum
{
    _SVC = 1,
    _NW_INT = 2
} _eFltrAppType;

#ifdef __cplusplus
extern "C" {
#endif

#include "common/ipv6_types.h"
#include "common/avl.h"

typedef enum
{
    SVC = 1,
    NW_INT = 2,
    NW_INT3 = 3
} eFltrAppType;

typedef enum {
    FltrTypeSel_None = 0, /* numbering must be consistent with SNMP TFilterType textual convention */
    FltrTypeSel_Ip,
    FltrTypeSel_Mac,
    FltrTypeSel_Cpm,
    FltrTypeSel_Ipv6,
    FltrTypeSel_Cpm6,
    FltrTypeSel_CpmMac,
    FltrTypeSel_Max
} eFilterTypeSelector;

typedef enum
    {
    SUBSCRIBER_TYPE_NONE,
    SUBSCRIBER_TYPE_IP_ONLY,
    SUBSCRIBER_TYPE_MAC_ONLY,
    SUBSCRIBER_TYPE_MAC_AND_IP,
    } eSubscriberType;

typedef enum {
    FltrEntryInsert_Config       = 0,   // non inserted entry (i.e. regular entry or LI entry
    FltrEntryInsert_Radius       = 1,   // 1 keep consistent with TFilterSubInsSpaceOwner.radius
    FltrEntryInsert_CreditCntrl  = 2,   // 2 keep consistent with TFilterSubInsSpaceOwner.creditControl
    FltrEntryInsert_BgpFlowSpec  = 3,   // 3 keep consistent with TFilterSubInsSpaceOwner.bgpFlowspec
    FltrEntryInsert_li           = 4,   // 4 keep consistent with TFilterSubInsSpaceOwner.li
    FltrEntryInsert_Max
} eFltrEntryInsertedBy;

#define USER_VISIBLE_FILTER_ENTRIES (~(1 << FltrEntryInsert_li))  // for use with anyFltrGetEntryCntPartial

typedef enum {
    FltrInsrtPtAction_OK = 0,
    FltrInsrtPtAction_Failed,
} eFltrInsrtPtActionRslt;

typedef enum {
    FltrEntryInsert_Begin = 0,
    FltrEntryInsert_End,
} eFltrEntryLocation;

typedef enum {
    e_ingress = 0,
    e_egress,
    e_both
} eFltrInsrtPtDirection;

typedef struct FltrInsrtPtKey
{
    /* key1:
     * - credit Control & Radius: either the slaProfIomId, or the filterProfileId
     * - BGP flowSpec           : always 0
     * In all cases 0 is used as wildcard
     */
    tUint32 key1;

    /* key2
     * key chosen by the application - 0 is used as wildcard
     * For creditCol    : 1 + CC CategoryMap NBR
     * For Radius       : the global hostId
     * For Bgp FlowSpec : internally assigned ruleId.
     */
    tUint32 key2;
}tFltrInsrtPtKey;

typedef enum {
    FltrRequest_Config = 0,        // regular request from CLI or SNMP
    FltrRequest_BgpFlowSpec,       // filter is a BGP flow spec filter
    FltrRequest_Max                // always keep as last entry in this list
} eFilterRequestor;

typedef enum {
    LiFltrAction_deleted = 0,
    LiFltrAction_created,
    LiFltrAction_activated,
    LiFltrAction_deactivated,
    LiFltrAction_changed
} eLiFltrActionSelector;

typedef enum {
    e_flowSpecAction_drop = 0, // first value should be 0.
    e_flowSpecAction_forward,
    e_flowSpecAction_forward_next_hop,
    e_flowSpecAction_forward_vrtr,
    e_flowSpecAction_max_val
} tFltrFlowSpecAction;

typedef struct FltrFlowSpecActionInfo
{
    tFltrFlowSpecAction action;
    tBoolean            sample;
    tBoolean            log;
    union
    {
        tUint32         vRtrId;  /* required if action == e_forward_vrtr     */
        tTimNetAddr     address; /* required if action == e_forward_next_hop */
    } u;
} tFltrFlowSpecActionInfo;

typedef enum {
    OtHttpRedirRef_Sla,
    OtHttpRedirRef_SubHost,
    OtHttpRedirRef_Max
} eOtHttpRedirRef;

typedef enum MatchListType
{
    MatchListType_PrefixIpv4 = 1, /* = VAL_tFilterPrefixListType_ipv4 */
    MatchListType_PrefixIpv6 = 2, /* = VAL_tFilterPrefixListType_ipv6 */
    /* MatchListType_Port, */
    /* MatchListType_MacAddr, */
    /* etc...*/
    MatchListType_Max
} eMatchListType ;

typedef enum FltrMatchListRef
{
    FltrMatchListRef_None   = 0,
    FltrMatchListRef_SrcIp  = 1 << 1,
    FltrMatchListRef_DstIp  = 1 << 2,
    FltrMatchListRef_BothIp = FltrMatchListRef_SrcIp |
                              FltrMatchListRef_DstIp
} eFltrMatchListRef;

typedef struct FltrMatchListRefEntry
{
    DL_NODE               listNode;    /* embedded DL_LIST node */
    eFilterTypeSelector   filterType;  /* a list can be ref'd by both normal and cpm filters */
    tUint32               filterId;
    tUint32               entryId;
    eFltrMatchListRef     refDir;
} tFltrMatchListRefEntry;

#ifdef __cplusplus
}
#endif

#endif /* _FILTER_TYPES_H_ */
