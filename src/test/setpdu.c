/* $Header: /swdev/cvsrep/panos/epilogue/target/src/wrn/wm/snmp/engine/setpdu.c,v 1.7 2011/12/16 12:56:25 mbrother Exp $ */

/****************************************************************************
 *
 *  *** Restricted Rights Legend ***
 *
 *  The programs and information contained herein are licensed only
 *  pursuant to a license agreement that contains use, reverse
 *  engineering, disclosure, and other restrictions; accordingly, it
 *  is "Unpublished--all rights reserved under the applicable
 *  copyright laws".
 *
 *  Use duplication, or disclosure by the Government is subject to
 *  restrictions as set forth in subparagraph (c)(1)(ii) of the Rights
 *  in Technical Data and Computer Licensed Programs clause of DFARS
 *  52.227 7013.
 *
 *  Copyright 2000-2001 Wind River Systems, Inc.
 *  Copyright 1988-1997 Epilogue Technology Corporation.
 *  Copyright 1998 Integrated Systems, Inc.
 *  All rights reserved.
 *
 *  *** Government Use ***
 *
 *  The Licensed Programs and their documentation were developed at
 *  private expense and no part of them is in the public domain.
 *
 *  The Licensed Programs are "Restricted Computer Software" as that
 *  term is defined in Clause 52.227-19 of the Federal Acquisition
 *  Regulations (FAR) and are "Commercial Computer Software" as that
 *  term is defined in Subpart 227.401 of the Department of Defense
 *  Federal Acquisition Regulation Supplement (DFARS).
 *
 *  (i) If the licensed Programs are supplied to the Department of
 *      Defense (DoD), the Licensed Programs are classified as
 *      "Commercial Computer Software" and the Government is acquiring
 *      only "restricted rights" in the Licensed Programs and their
 *      documentation as that term is defined in Clause 52.227
 *      7013(c)(1) of the DFARS, and
 *
 *  (ii) If the Licensed Programs are supplied to any unit or agency
 *      of the United States Government other than DoD, the
 *      Government's rights in the Licensed Programs and their
 *      documentation will be as defined in Clause 52.227-19(c)(2) of
 *      the FAR.
 ****************************************************************************/

/*
*/

static inline unsigned int
lubo(void)
{
    return;
}

#include <wrn/wm/snmp/engine/asn1conf.h>
#include <wrn/wm/snmp/engine/asn1.h>
#include <wrn/wm/snmp/engine/snmpdefs.h>
#include <wrn/wm/snmp/engine/snmp.h>
#include <wrn/wm/snmp/engine/mib.h>
#include <wrn/wm/snmp/engine/view.h>

#include <wrn/wm/util/common/bug.h>

#include <wrn/wm/util/common/dyncfg.h>
DYNCFG_VBL_DECLARE_EXTERN(envoy_use_v2_protos)
DYNCFG_VBL_DECLARE_EXTERN(agentx_master_component)

#ifdef TIMOS_EXTENSIONS
    #include "chmgr/chmgr_api.h"
    #include "chmgr/red_api.h"
#endif


int snmpRowInPduCount = 0;


/****************************************************************************
NAME:  SNMP_Process_Test_PDU

PURPOSE:  Process a set type pdu in an async fashion.  First we find objects
          for all the var binds (checking that the objects are in the view).
          If any var binds don't point to a valid object we flag a no such
          error.  After we have found all the objects we call the testproc
          routines to determine if the var binds may be set.

PARAMETERS:
        SNMP_PKT_T *    The decoded SET PDU

RETURNS:  int   0 all of the tests have been started successfully
                1 error of some sort, any error packet has been sent.
****************************************************************************/

int
  SNMP_Process_Test_PDU(SNMP_PKT_T *pktp)
{
VB_T *vbp;
int   count, indx, eret;
sbits32_t *err_stat;

#if INSTALL_ENVOY_SNMP_LOCK
/* if locks are installed we need to return the read lock and get
   a write lock */
if (pktp->lockflags != LOCK_READ) {
    pktp->error_complete(&pktp->pkt_src, &pktp->pkt_dst, 1,
                         pktp->async_cookie);
    return(1);
    }
ENVOY_SNMP_RELEASE_READ_LOCK((*pktp->coarse_lock));
pktp->lockflags = LOCK_NOLOCK;
if (ENVOY_SNMP_GET_WRITE_LOCK((*pktp->coarse_lock))) {
    BUG(BUG_ENVOY_LOCKING, BUG_CONTINUABLE, 0,
        (BUG_OUT, "SNMP_Process_Test_PDU: coarse lock is broken", 0));

    pktp->error_complete(&pktp->pkt_src, &pktp->pkt_dst, 1,
                         pktp->async_cookie);
    return(1);
    }
pktp->lockflags = LOCK_WRITE;

#endif /* INSTALL_ENVOY_SNMP_LOCK */

/* There is no need to really do much work on the PDU because   */
/* the returned form is almost exactly the received form.       */

/* get some initial information */
vbp = pktp->pdu.std_pdu.std_vbl.vblist;
count = pktp->pdu.std_pdu.std_vbl.vbl_count;

/* Assume that things are going to work */
pktp->pdu.std_pdu.error_status = NO_ERROR;

/* Also, no check will be made for oversize response if this is */
/* version 1, because of the simularity: a no-error response    */
/* will be exactly the  same size as the GET REQUEST, an error  */
/* response may be a bit larger (perhaps by a byte or two), but */
/* we are forced to send it.  For Version 2 and version 3 we    */
/* need to check the size as the max packet sizes may be        */
/* different. */

#if (ENVOY_USE_V2_PROTOS)
DYNCFG_IFCFGVBL_BEGIN(envoy_use_v2_protos)
if (pktp->snmp_version != SNMP_VERSION_1) {
    /* see if a maximum packet is small enough to fit in the
       given max size.  We set the error index to the vb count
       to simulate an and see how big that would be. */
    pktp->pdu.std_pdu.error_index = count;

    if (SNMP_Bufsize_For_Packet(pktp) > pktp->maxpkt) {
        ENVOY_Send_SNMP_Error_Packet(pktp, TOO_BIG, 0);
        return(1);
        }
    }
DYNCFG_IFCFGVBL_END(envoy_use_v2_protos)
#endif /* #if (ENVOY_USE_V2_PROTOS) */

/* set the error index to no errors */
pktp->pdu.std_pdu.error_index = 0;

/* do we actually have any work to do? */
if ((vbp == 0) || (count == 0))
    return(0);

/* We will be looking at the error status a lot so we get a local pointer
   to it to make things easier */
err_stat = &(pktp->pdu.std_pdu.error_status);

/* Try to get the infrastructure lock, we release it using
   the ENVOY_AX_MA_RELEASE_WRITE_LOCK macro */
#if (INSTALL_ENVOY_AGENTX_MASTER && INSTALL_ENVOY_SNMP_LOCK)
DYNCFG_IFCFGVBL_BEGIN(agentx_master_component)
if (ENVOY_SNMP_GET_WRITE_LOCK(SNMP_infrastructure_lock)) {
    BUG(BUG_ENVOY_LOCKING, BUG_CONTINUABLE, 0,
        (BUG_OUT, "SNMP_Process_Test_PDU: infrasturctue lock is broken", 0));

    ENVOY_Send_SNMP_Error_Packet(pktp, GEN_ERR, 0);
    return(1);
    }
DYNCFG_IFCFGVBL_END(agentx_master_component)
#endif

/* If necessary try to find the view index structure, if we want to do
   rfc1445 view checking find_object_node will expect this routine
   to have been run and to have inserted a pointer into pktp */
#if (INSTALL_ENVOY_SNMP_DYNAMIC_VIEWS)
if (SNMP_View_Find_Family(pktp) && (pktp->snmp_version == SNMP_VERSION_3)) {
    ENVOY_AX_MA_RELEASE_WRITE_LOCK(SNMP_infrastructure_lock);
    ENVOY_Send_SNMP_Error_Packet(pktp, AUTHORIZATION_ERROR, 0);
    return(1);
    }
#endif

for(indx = 0; indx < count; indx++,vbp++) {
    /* Check whether the varBind is in the view */
    eret = find_object_node(vbp, pktp, !SNMP_PKT_FROM_CLI(pktp));
    if (eret) {
        switch(eret) {
            case -1:
            default:
                *err_stat = NOT_WRITABLE;
                break;
            case -2:
                *err_stat = NO_ACCESS;
                break;
            case -3:
                *err_stat = GEN_ERR;
                indx = -1;
                break;
            }
        break;
        }

    /* Check the returned node, if it isn't a leaf it isn't
       modifiable */
    if (!(vbp->vb_ml.ml_flags & ML_IS_LEAF)) {
        *err_stat = NOT_WRITABLE;
        break;
        }

    /* second view check, this is necessary only if
       we aren't using the rfc1445 view scheme */
#if (!(INSTALL_ENVOY_SNMP_DYNAMIC_VIEWS))
    if (((vbp->vb_ml.ml_leaf)->write_mask & pktp->mib_view) == 0) {
        *err_stat = NO_ACCESS;
        break;
        }
#endif /* (!(INSTALL_ENVOY_SNMP_DYNAMIC_VIEWS)) */

    /* more checks on the node, see if the nodes access allows for writes */
    if (!((vbp->vb_ml.ml_leaf)->access_type & WRITE_ACCESS)) {
        *err_stat = NOT_WRITABLE;
        break;
        }
    /* Finally see if the vb's data type matches the node's type */
#if (INSTALL_ENVOY_AGENTX_MASTER)
DYNCFG_IFCFGVBL_BEGIN(agentx_master_component)
    if ((vbp->vb_ml.ml_node)->node_type & AGENTX_LEAF)
        continue;
DYNCFG_IFCFGVBL_END(agentx_master_component)
#endif

    if (vbp->vb_data_flags_n_type != (vbp->vb_ml.ml_leaf)->expected_tag) {
        *err_stat = WRONG_TYPE;
        break;
        }
    }

ENVOY_AX_MA_RELEASE_WRITE_LOCK(SNMP_infrastructure_lock);

if (*err_stat) {
    if (indx != -1)
        ENVOY_Send_SNMP_Error_Packet(pktp, *err_stat,
                                     (sbits32_t)(SNMP_ERROR_INDEX(indx)));
    else
        ENVOY_Send_SNMP_Error_Packet(pktp, *err_stat, 0);
    return(1);
    }

/* we have now found all of the requested objects and have passed all of
   the mib class tests, we now start up all of the tests and then return
   to await the responses */

/* Here we give the user a chance to examine the packet and exert control
   They have three options:
   Return -1 to indicate an inconsistent pdu, an error will be gennerated
   Return 0 to inidcate that normal processing should proceed, the user
        must not perform any sets though it may perfrom tests.
   Reurn 1 to indicate that it has performed all necessary processing.  */
#if defined(SNMP_validate_set_pdu)
switch(SNMP_validate_set_pdu(pktp)) {
    case -1:
        ENVOY_Send_SNMP_Error_Packet(pktp, GEN_ERR, 0);
        return(1);
    case 0:
        break;
    case 1:
    default:
        ENVOY_Send_SNMP_Packet(pktp);
        return(1);
    }
#endif

snmpRowInPduCount = 0;
for(vbp = pktp->pdu.std_pdu.std_vbl.vblist; count; count--, vbp++) {
    /* If the test started flag is set then either we set it above or
       the testproc of some other var bind has claimed responsibility for
       this var bind.  In either case we skip this var bind and continue */
    if (vbp->vb_flags & (VFLAG_TEST_STARTED | VFLAG_TEST_DONE))
        continue;      
    ((vbp->vb_ml.ml_leaf)->testproc)
      (vbp->vb_ml.ml_last_match, vbp->vb_ml.ml_remaining_objid.num_components,
       vbp->vb_ml.ml_remaining_objid.component_list, pktp, vbp);
    vbp->vb_flags |= VFLAG_TEST_STARTED;
    snmpRowInPduCount++;

    /* test the error code, if we had an error then mark any remaining
       vbs as having been tested (so we won't trip over them later).
       We need to skip the first vb as that is the one that
       caused the failure.  Then break because we are done */
    if (*err_stat) {
        for (vbp++, count--; count; count--, vbp++)
            if (!(vbp->vb_flags & VFLAG_TEST_STARTED))
                vbp->vb_flags |= VFLAG_TEST_STARTED | VFLAG_TEST_DONE;
        break;
        }
    }

#ifdef TIMOS_EXTENSIONS
if (!chMgrIsSnmpSetAllowed()) {
    *err_stat = INCONSISTENT_VALUE;
    ENVOY_Send_SNMP_Error_Packet(pktp, *err_stat, 0);
    return(1); 
}
#endif

return(0);
}

void snmp_clean_flags(VB_T * vbp)
{
    vbp->vb_flags = 0;
    /* free any memory allocated by the test routines */
    if (vbp->vb_free_priv) {
#if INSTALL_ENVOY_40_VB_FREE_COMPAT
        (*vbp->vb_free_priv)(vbp->vb_priv);
#else
        (*vbp->vb_free_priv)(vbp);
#endif
        vbp->vb_free_priv = 0;
        vbp->vb_priv = 0;
    }
}


/****************************************************************************
NAME:  SNMP_Process_Set_PDU                tvbp->vb_flags &= ~(VFLAG_TEST_STARTED | VFLAG_TEST_DONE);


PURPOSE:  This is the second stage of the set processing.  At this
          point all of one set of operations have completed and it's 
          time to survey are handiwork and decide what we need to do
          next.  The phase word from the packet will indicate what phase
          of the set we are performing.
          If we have just finished the tests we either found an error
          and send an error response or we start the sets.
          If we have just finsihed the sets we either found an error
          and start the undos or we send a good response.
          If we have just finsihed the undos we send an error response.

PARAMETERS:
        SNMP_PKT_T *    The decoded NEXT/BULK PDU

RETURNS:  int    0 The caller should send and free the packet
                 1 This stage is finished but more stages are required
****************************************************************************/

int
  SNMP_Process_Set_PDU(SNMP_PKT_T *pktp)
{
VB_T *vbp, *tvbp;
int count, tcount;
sbits32_t *err_stat;
int wait = 0;

if (((vbp = pktp->pdu.std_pdu.std_vbl.vblist) == 0) ||
    ((count = pktp->pdu.std_pdu.std_vbl.vbl_count) == 0))
    return(0);

/* We will be looking at the error status a lot so we get a local pointer
   to it to make things easier */
err_stat = &(pktp->pdu.std_pdu.error_status);

/* The phase word specifies whice phase we are involved with, note
   that there aren't breaks between the cases.  This is intentional.
   This routine is essentially linear code with multiple entry points
   selected by the phase word.  The phase word allows us to wait
   for operations to compelete and then to re-enter the code efficiently */

switch(pktp->phase) {
    /* if phase is 0, we are waiting for the tests to finish
       we see if they have finished.  If so we test for errors
       and bail out if one occurred.  Otherwise we start up the
       sets.  If we detect an error while starting a test we mark
       any remaining objects as having been undone then set the phase
       word to indicate the undo phase and let the undo case
       deal with starting any undos required. */
    case 0:
        for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++)
            if (!(tvbp->vb_flags & VFLAG_TEST_DONE))
                return(1);

        /* If we failed a test send an error packet */
        if (*err_stat) {
            /* Here we tell the user that one of tests
               failed, this gives them a chance to clean
               up, perhaps after validate_set_pdu */
#if defined(SNMP_user_set_failed)
            SNMP_user_set_failed(pktp);
#endif
            return(0);
            }

        /* The user gets another chance to examine the packet and exert
           control.  They again have three options:
           -1 indicates a bad pdu, an error will be generated
            0 inidcates normal processing should proceed, the user may
              start or perfrom any sets they desire.  But they better
              indicate what they have done.  If the user has started some
              sets and one of them fails they may either wait until they
              all finish and return a -1 or 1, or they way set the flag
              bits for the other vbs to be already set & undone and then
              let this code wait for the remaining tests to finish.  They
              also have to set the err status correctly.
            1 indicates the user has performed all necessary processing.  */
#if defined(SNMP_user_pre_set)
        switch(SNMP_user_pre_set(pktp)) {
            case -1:
                *err_stat = GEN_ERR;
                return(0);
            case 0:
                break;
            case 1:
            default:
                return(0);
            }
#endif

#ifdef TIMOS_EXTENSIONS
        redBeginConfig(FALSE /* isCli */, "SNMP cmd");
#endif

        if (snmpRowInPduCount > 1) {
            for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++) {
                snmp_clean_flags(tvbp);
            }
            snmpRowInPduCount = 0;
        } else {
            /* start the sets */
            for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++) {
                if (tvbp->vb_flags & (VFLAG_SET_STARTED | VFLAG_SET_DONE))
                    continue;      
                ((tvbp->vb_ml.ml_leaf)->setproc)
                    (tvbp->vb_ml.ml_last_match,
                     tvbp->vb_ml.ml_remaining_objid.num_components,
                     tvbp->vb_ml.ml_remaining_objid.component_list,
                     pktp, tvbp);
                setproc_started(pktp, tvbp);
                
                /* test the error code, if we had an error then mark any remaining
                   vbs as having been undone (as they were never done to begin
                   with).  We need to skip the first vb as that is the one that
                   caused the failure.  Then break because we are done */
                if (*err_stat) {
                    goto START_UNDO;
                }
            }
        }

        pktp->phase = VFLAG_SET_STARTED;

        /* fall through */

    case VFLAG_SET_STARTED:
        /* If we didn't have any errors, we test and see if all the
           sets finished if so we are done and can request a response
           packet be sent otherwise there are still sets outstanding
           and we indicated that we need to wait some more */
        for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++) {
            if (*err_stat != NO_ERROR) {
                break;
            }
            if (!(tvbp->vb_flags & (VFLAG_TEST_STARTED | VFLAG_TEST_DONE))) {
                ((tvbp->vb_ml.ml_leaf)->testproc)
                    (tvbp->vb_ml.ml_last_match, tvbp->vb_ml.ml_remaining_objid.num_components,
                     tvbp->vb_ml.ml_remaining_objid.component_list, pktp, tvbp);
                testproc_started(pktp, tvbp);
            }
            if (*err_stat != NO_ERROR) {
                break;
            }
            if (!(tvbp->vb_flags & VFLAG_TEST_DONE)) {
                wait = 1;
                break;
            }
            if (!(tvbp->vb_flags & (VFLAG_SET_STARTED | VFLAG_SET_DONE))) {
                ((tvbp->vb_ml.ml_leaf)->setproc)
                    (tvbp->vb_ml.ml_last_match,
                     tvbp->vb_ml.ml_remaining_objid.num_components,
                     tvbp->vb_ml.ml_remaining_objid.component_list,
                     pktp, tvbp);
                setproc_started(pktp, tvbp);
            }
            if (*err_stat != NO_ERROR) {
                break;
            }
            if (!(tvbp->vb_flags & VFLAG_SET_DONE)) {
                wait = 1;
                break;
            }
        }
        if (wait) {
#ifdef TIMOS_EXTENSIONS                
            redEndConfig(FALSE /* isCli */, "SNMP cmd");
#endif
            return(1);
        }
        if (*err_stat == NO_ERROR) {
#if defined(SNMP_user_post_set)
            /* The user gets another chance to examine the packet and exert
               control. */
            SNMP_user_post_set(pktp);
#endif
#ifdef TIMOS_EXTENSIONS
            redEndConfig(FALSE /* isCli */, "SNMP cmd");
#endif
            return(0);
        }

START_UNDO:
        for ( ; tcount; tcount--, tvbp++) {
            if (!(tvbp->vb_flags & VFLAG_SET_STARTED)) {
                tvbp->vb_flags |= VFLAG_UNDO_STARTED | VFLAG_UNDO_DONE;
            }
        }
        *err_stat = COMMIT_FAILED;
        pktp->phase = VFLAG_UNDO_STARTED;

  case VFLAG_UNDO_STARTED:
        for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++) {
            switch(tvbp->vb_flags & (VFLAG_SET_DONE | VFLAG_UNDO_BOTH)) {
                case 0:
                    /* The set hasn't finished so it doesn't require
                       an undo, but if it has one we start it up */
                    if (tvbp->undoproc) {
                        (tvbp->undoproc)
                          (tvbp->vb_ml.ml_last_match,
                           tvbp->vb_ml.ml_remaining_objid.num_components,
                           tvbp->vb_ml.ml_remaining_objid.component_list,
                           pktp, tvbp);
                        tvbp->vb_flags |= VFLAG_UNDO_STARTED;
                        }
                    break;

                case VFLAG_SET_DONE:
                    /* As the set has finished an undo is required,
                       if one doesn't exist we flag an undo_failed error
                       and set the undo_done flag */
                    if (tvbp->undoproc) {
                        (tvbp->undoproc)
                          (tvbp->vb_ml.ml_last_match,
                           tvbp->vb_ml.ml_remaining_objid.num_components,
                           tvbp->vb_ml.ml_remaining_objid.component_list,
                           pktp, tvbp);
                        tvbp->vb_flags |= VFLAG_UNDO_STARTED;
                        }
                    else 
                        undoproc_error(pktp, tvbp, UNDO_FAILED);
                    break;
                } /* switch (tvbp->flags ... ) */
            } /* for(tvbp = vbp, ... ) */

    case VFLAG_UNDO_DONE:
        /* Test to see if all of the undos have finished yet */
        for(tvbp = vbp, tcount = count; tcount; tcount--, tvbp++)
            if (!(tvbp->vb_flags & VFLAG_UNDO_DONE))
            {
#ifdef TIMOS_EXTENSIONS            
                redEndConfig(FALSE /* isCli */, "SNMP cmd");
#endif
                return(1);
            }
        /* Here we tell the user that one of sets
           failed, this gives them a chance to clean
           up, perhaps after user_pre_set */
#if defined(SNMP_user_set_failed)
        SNMP_user_set_failed(pktp);
#endif
#ifdef TIMOS_EXTENSIONS
        redEndConfig(FALSE /* isCli */, "SNMP cmd");
#endif
        return(0);
    } /* switch(pktp->phase) */

/* We should never get here, all of the options for the phase word should
   be covered in the above switch */
#ifdef TIMOS_EXTENSIONS
redEndConfig(FALSE /* isCli */, "SNMP cmd");
#endif
return(0);
}
