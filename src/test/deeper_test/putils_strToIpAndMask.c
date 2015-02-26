/**************************************************************************
*
*   Filename:           putils.c
*
*   Author:             Mike Shoemaker
*   Created:            Thu Jun 29 14:59:29 2000
*
*   Description:        Utility things needed by the RapidLogic CLI
*
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: putils.c,v 1.534 2013/04/23 13:09:05 mbrother Exp $
*
***************************************************************************
*
*              Copyright (c) 2000-2013 TiMetra, Inc., Alcatel, Alcatel-Lucent
*
**************************************************************************/

#ifdef RCSID
static const char rcsid[] = "$Id: putils.c,v 1.534 2013/04/23 13:09:05 mbrother Exp $";
#endif

#include <a_out.h>                  // N_TEXT
#include <stdio.h>
#include <ctype.h>
#include <shellLib.h>
#include <taskLib.h>
#include <ioLib.h>
#include <ptyDrv.h>
#include <resolv/resolv.h>
#include <sysSymTbl.h>
#include <tyLib.h>
#include <semLib.h>
#include <netinet6/in6.h>
#include <netinet6/in6_var.h>

#include "agent/agent_api.h"
#include "agent/default_config.h"
#include "agent/gen/ip_mib.h"
#include "agent/gen/timetra_eth_tunnel_mib.h"
#include "agent/gen/timetra_serv_mib.h"
#include "agent/gen/timetra_sap_mib.h"
#include "agent/gen/timetra_sdp_mib.h"
#include "agent/sia_err_msgs.h"
#include "agent/sia_esas_serv.h"
#include "agent/sia_esas_sap.h"
#include "agent/sia_esas_sdp.h"
#include "agent/sia_esas_vrtr.h"
#include "agent/sia_qos.h"
#include "bsp/bspapi.h"             // dnsLookupMutex
#include "bsp/bspenet.h"            // sysMgmtPortName()
#include "bsp/bspio.h"              // consoleFd
#include "bsp/bsptime.h"            // TIMOS_TICKS_PER_SEC
#include "chmgr/red_api.h"
#include "cli/cli_console.h"
#include "cli/cli_custom_env.h"     /* MAX_MESG_LENGTH */
#include "cli/cli_custom_validators.h"
#include "cli/cli_dns.h"
#include "cli/cli_error.h"
#include "cli/cli_fmt_utils.h"
#include "cli/cli_ip_utils.h"
#include "cli/cli_printf.h"
#include "cli/cli_priv.h"
#include "cli/cli_shell.h"
#include "cli/cli_show_utils.h"       // CLI_USER_QUIT
#include "cli/custom_env_priv.h"    /* shellFlag */
#include "cli/logger_printf.h"
#include "cli/putils_svc.h"
#include "cli/str_atm.h"
#include "cli/str_ip.h"
#include "cli/str_isis.h"
#include "cli/str_lag.h"
#include "cli/str_ldp.h"
#include "cli/str_mac.h"
#include "cli/str_num.h"
#include "cli/str_portid.h"
#include "cli/str_router.h"
#include "cli/str_svc.h"
#include "common/channelid_api.h"
#include "common/format_ip.h"
#include "common/format_svc.h"
#include "common/gen/mod_vxworks.h"
#include "common/gen/timos_build_type_beta.h"
#include "common/gen/timos_feature_ptp_daemon.h"
#include "common/ip_mib_util.h"
#include "common/ip_types.h"
#include "common/ip_util.h"
#include "common/ipv6_types.h"
#include "common/mac_types.h"
#include "common/modules.h"
#include "common/portid.h"
#include "common/portid_str.h"
#include "common/snprintf.h"
#include "common/snprintf_priv.h"
#include "common/sockutils.h"
#include "common/str_util.h"
#include "common/task.h"
#include "common/timos_printf.h"
#include "common/util.h"
#include "debug/debug.h"
#if TIMOS_BUILD_TYPE(BETA)
#include "debug/debugpw.h"
#endif
#include "debug/tracefn.h"
#include "isis/isis_api.h"
#include "filter/filter_api.h"
#include "ldp/ldp_api.h"
#include "pip/pip_api.h"
#include "pip/pip_db.h"
#include "platform/ptr_chck_api.h"
#include "pmgr/lagmgr_api.h"        /* VALID_LAG_ID */
#include "pmgr/pmgr_api.h"          /* pMgrPortEntryPtr() */
#include "rapidlogic/rc_environ.h"  // cli_env
#include "rapidlogic/rc_linklist.h"
#include "rapidlogic/rc_rlstdlib.h" // RC_MALLOC
#include "rapidlogic/rcc_cmd.h"     // RCC_CMD_Snmp...
#include "rapidlogic/rcc_db.h"      // RCC_DB_ExecuteCommand
#include "rapidlogic/rcc_ext.h"     /* RCC_EXT_WriteStr */
#include "rapidlogic/rcc_log.h"     /* RCC_LOG_Output() */
#include "rapidlogic/rcc_rcb.h"     // RCC_RCB_Write...
#include "rapidlogic/rcc_structs.h" // WriteHandle
#include "rapidlogic/rcc_telnet.h"
#include "rapidlogic/rcm_envoy.h"
#include "rapidlogic/rcm_ev_cnv.h"
#include "rapidlogic/rcm_snmp.h"    // OCSNMP_AssignSetCommunityString
#include "regexp/regex.h"
#include "svcmgr/smgr_api.h"        // SVC_VPRN_RTR_NAME_PREFIX
#include "svcmgr/smgr_base_types.h"
#include "svcmgr/smgr_types.h"
#include "tip/tip_api.h"

#define PUTILS_BUFFER_2k    2048
#define PUTILS_BUFFER_40      40
#define PUTILS_BUFFER_64      64
#define PUTILS_BUFFER_128    128

#define PREFIX_DIGITS          2

#define MAC_STRING_LEN 17 /* must be 12 hex digits, 5 separators (: or -) */

/*
 * This variable in_shell needs to be global.
 * It will be read when a telnet client session is initiated
 * from the CONSOLE session. If it is set to TRUE, the client
 * session will be blocked, because client from CONSOLE also
 * contends for stdin & stdout.
 */
PUBLIC int in_shell = FALSE;

/*
 * Created to allow one shell to disconnect another.
 */
PRIVATE SEM_ID kernelMutex = NULL;
PRIVATE int    forcedToDisconnect = FALSE;

PUBLIC int cliVprintfHook(cli_env *pCliEnv, const char *fmt, va_list args);

PUBLIC void repeatCmd(tUint32 low, tUint32 high, const char *cmdstr)
{
    tUint32     i;
    cli_env   * pCliEnv = getMyTaskCliEnv();

    if (pCliEnv == NULL)
    {
        printf("This shell command may only be used from within the CLI\n");
        return;
    }

    if ( (low > high) || (cmdstr == NULL) || ((high - low) > 1000) )
    {
        cliPrintf(pCliEnv, "Usage: shell repeatCmd <low> <high> \"command string with a %%d\"\n");
        return;
    }

    for (i = low ; i <= high ; i++)
    {
        RLSTATUS    status;
        char        cmdline[100]; // %%% use right constant

        // In case %d appears more than once in the cmdstr, we want it
        // expanded each time to the loop index.
        snprintf(cmdline, sizeof(cmdline), cmdstr, i, i, i, i, i, i, i, i);
        // Echo command
        cliPrintf(pCliEnv, "%s\n", cmdline);//%%%
        status = RCC_DB_ExecuteCommand(pCliEnv, cmdline);
        cliPrintMesgs(pCliEnv);
        if (status < 0)
            break;

        if (timosCLIOutputStopped(pCliEnv, FALSE))
            break;
    }
}

/* ----------------------- Shell command -------------------------------- */

PRIVATE int removeTelnetChars(int * state, int ch)
    {
    switch (*state)
        {
        case 0:     // normal
            if (ch == 255)     // IAC
                {
                *state = 1;
                return(-1);
                }
            break;

        case 1:     // prev was FF
            if (ch == 255)      // esc-esc
                {
                *state = 0;
                return(255);   // a real FF
                }
            else if (ch > 250)
                *state = 2;     // skip-option negotiation
            else if (ch < 250)
                *state = 0;     // done
            else                
                *state = 3;     // SB subneg. Skip until <255><240>

            ch = -1;
            break;

        case 2:
            ch = -1;
            *state = 0;         // done
            break;

        case 3:
            if (ch == 255)
                *state = 4;
            ch = -1;
            break;

        case 4:
            if (ch == 255)
                *state = 3;
            else if (ch == 240)
                *state = 0;         // done!
            ch = -1;
            break;
        }
    return(ch);
    }

// This is the RapidLogic CLI environment ptr at the time the shell cmd
// is invoked. It is intended to be used by debug routines that are only
// called by the vxWorks shell.
PRIVATE void xferTask(int from, int to, tBoolean filterTelnet)
    {
    int len, wlen=0, i;
    char buffer[PUTILS_BUFFER_2k];
    int telnetState = 0;

    do
        {
        len = read(from, buffer, sizeof(buffer));
        wlen = 0;
        if (len>0)
            {
            if (filterTelnet)
                {
                for (i=0; i<len; i++)
                    {
                    int ch = removeTelnetChars(&telnetState, buffer[i]);

                    if (ch >= 0)
                        {
                        char c = ch;
                        wlen += write(to, &c, 1);
                        }
                    else
                        wlen++;
                    }
                }
            else
                wlen = write(to, buffer, len);
            }
        }
    while (len > 0 && wlen == len);
    }


PRIVATE tStatus convertShellArg(cli_env *pCliEnv, const char *arg, char *buf, int buflen, intptr_t *pVal)
{
    const char * p = arg;
    char       * q = buf;
    intptr_t     result;
    tBoolean     hasComma = FALSE;
    size_t       len;


    // Non-existent args are zero
    if (arg == NULL)
    {
        *pVal = 0;
        return OK;
    }

    len = strlen(arg);
    if (len>=buflen) 
    {
        cliErrorMesg(pCliEnv, "Error: arg \"%s\" is too long ( >=%d characters)", arg, buflen);
        return FAIL;    
    }
    
    if (len && arg[len-1] == ',')
    {
        cliErrorMesg(pCliEnv, "Error: arg \"%s\" ends in a comma", arg);
        return FAIL;
    }

    // If string has embedded comma, we may not like it.
    if (strchr(arg, ',') != NULL)
    {
        hasComma = TRUE;
    }

    if (p[0] == '0' && p[1] == 'x')
    {
        // It's HEX! (allegedly)
        if (hasComma)
        {
            cliErrorMesg(pCliEnv, "Error: arg \"%s\" contains a comma", arg);
            return FAIL;
        }
        sscanf(&p[2], "%lx", &result);
        *pVal = result;
        return OK;
    }
    // Make sure it has all digits - if not it might be a string
    p = arg;
    if (*p == '-') p++; // Ignore leading minus sign
    if (isdigit(*p))
    {
        p++;
        while (*p)
        {
            if (!isdigit(*p))
                break;
            p++;
        }
        if (*p == '\0')
        {
            /* all digits - convert to long integer (aka intptr_t) */
            *pVal = atol(arg);
            return OK;
        }
    }

    /*
     * I guess it must be a string, so deal with special characters
     */
    if (hasComma)
        cliErrorMesg(pCliEnv, "Warning: arg \"%s\" contains a comma", arg);
    p = arg;
    while ((*q = *p++) != '\0')
    {
        if (*q == '\\')
        {
            switch (*p)
            {
                case '"':           // I wonder if we ever actually see this?
                    *q = '"';
                    break;
                case 'n':
                    *q = '\n';
                    break;
                case 'r':
                    *q = '\r';
                    break;
                default:
                    *q = *p;
                    break;
            }
            p++;
        }
        q++;
    }

    *pVal = (intptr_t)buf;
    return OK;
}

// Prompt for password and put it into supplied buffer
PRIVATE tStatus cliGetPass(cli_env *pCliEnv, char *pBuffer, tUint32 buffSize)
{
    tStatus status;

    tInt32  len = MEDIT_GetLength(pCliEnv);
    tInt32  cur = MEDIT_GetCursor(pCliEnv);

    RCC_EXT_WriteStr(pCliEnv, kRCC_PASSWORD_PROMPT); 

    status = RCC_EXT_Gets(pCliEnv, pBuffer, buffSize, &buffSize, FALSE);

    RCC_EXT_WriteStrLine(pCliEnv, "");

    MEDIT_SetLength(pCliEnv,  len);
    MEDIT_SetCursor(pCliEnv,  cur);

    return status;
}
            
// Prompt for password and check against supplied password
PRIVATE tStatus cliGetAndTestPass(cli_env *pCliEnv, const char *pass)
{
    char    enterpass[kRCC_MAX_PASSWORD_LEN];

    if (cliGetPass(pCliEnv, enterpass, sizeof(enterpass)) != OK)
        return ERROR;

    if (strcmp(enterpass, pass) != 0)
        return ERROR;
    
    return OK;
}

// Prompt for and verify CLI shell command password (if required)
PUBLIC tStatus cliInteractiveVerifyShellAccess(cli_env *pCliEnv)
{
#if TIMOS_BUILD_TYPE(BETA)
    if (shellFlag(pCliEnv) == FALSE)
    {
        return cliGetAndTestPass(pCliEnv, getCliShellCmdPassword());
    }
#endif
    return OK;
}

// Prompt for and verify CLI kernel command password (if required)
PUBLIC tStatus cliInteractiveVerifyKernelAccess(cli_env *pCliEnv)
{
#if TIMOS_BUILD_TYPE(BETA)
    if (kernelFlag(pCliEnv) == FALSE)
    {
        return cliGetAndTestPass(pCliEnv, getKernelPassword());
    }
#endif
    return OK;
}

/* CONSOLE Width definitions */
#define CLI_SHELL_CONSOLE_WIDTH       255

RLSTATUS cliShellCommand(cli_env *pCliEnv, const char *pCmd,
                         const char *pArg1, const char *pArg2,
                         const char *pArg3, const char *pArg4,
                         const char *pArg5, const char *pArg6,
                         const char *pArg7, const char *pArg8,
                         const char *pArg9, const char *pArg10)
{
    intptr_t (*vxCmd)(intptr_t arg1, intptr_t arg2, intptr_t arg3, intptr_t arg4, intptr_t arg5,
                      intptr_t arg6, intptr_t arg7, intptr_t arg8, intptr_t arg9, intptr_t arg10,
                      intptr_t arg11, intptr_t arg12);
    SYM_TYPE symType;
    intptr_t arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10;
    char buf1[CLI_SHELL_CONSOLE_WIDTH];
    char buf2[CLI_SHELL_CONSOLE_WIDTH];
    char buf3[CLI_SHELL_CONSOLE_WIDTH];
    char buf4[CLI_SHELL_CONSOLE_WIDTH];
    char buf5[CLI_SHELL_CONSOLE_WIDTH];
    char buf6[CLI_SHELL_CONSOLE_WIDTH];
    char buf7[CLI_SHELL_CONSOLE_WIDTH];
    char buf8[CLI_SHELL_CONSOLE_WIDTH];
    char buf9[CLI_SHELL_CONSOLE_WIDTH];
    char buf10[CLI_SHELL_CONSOLE_WIDTH];
    
    intptr_t result = 0;
    
    // Beta blocking access to shell
    if (cliInteractiveVerifyShellAccess(pCliEnv) != OK)
    {
        cliErrorMesg(pCliEnv, "Unidentified command");
        return ERROR;
    }

    // Bug 40403: Do not allow the user to type shell shell

    if(strcmp(pCmd, "shell") == 0) 
    {
        cliErrorMesg(pCliEnv, "Nesting of 'shell' is not allowed");
        return ERROR;
    }

    /* Look up the name in the symbol table and make
     * sure it corresponds to a function...
     */
    if (symFindByNameExt(sysSymTbl, (char *) pCmd,
                         (char **) &vxCmd,
                         &symType) != OK)
    {
        cliErrorMesg(pCliEnv, "Unknown command: %s", pCmd);
        return ERROR;
    }
    // Oddly enough, use N_TEXT from a_out.h, not SYM_TEXT from symLib.h.
    // Yes, it's documented that way in the man page for symLib.
    if ((symType & N_TYPE) != N_TEXT)
    {
        cliErrorMesg(pCliEnv, "\"%s\" is not a supported command", pCmd);
        return ERROR;
    }

    /* Are there any arguments? */
    if (convertShellArg(pCliEnv, pArg1, buf1, sizeof(buf1), &arg1) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg2, buf2, sizeof(buf2), &arg2) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg3, buf3, sizeof(buf3), &arg3) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg4, buf4, sizeof(buf4), &arg4) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg5, buf5, sizeof(buf5), &arg5) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg6, buf6, sizeof(buf6), &arg6) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg7, buf7, sizeof(buf7), &arg7) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg8, buf8, sizeof(buf8), &arg8) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg9, buf9, sizeof(buf9), &arg9) != OK) return ERROR;
    if (convertShellArg(pCliEnv, pArg10, buf10, sizeof(buf10),  &arg10) != OK) return ERROR;
    
    
    /* Call the handler... */
    debugStart();
    // the vxworks shell always passes 12 arguments to any shell commands.
    // So, in case there are shell commands expecting more than 10 
    // (cardcmdmda() which expects 11), we should ensure we pass 12
    // valid arguments
    
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf1, sizeof(buf1), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf2, sizeof(buf2), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf3, sizeof(buf3), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf4, sizeof(buf4), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf5, sizeof(buf5), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf6, sizeof(buf6), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf7, sizeof(buf7), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf8, sizeof(buf8), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf9, sizeof(buf9), TRUE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf10, sizeof(buf10), TRUE);

    // catch calls to printf or fprintf from this function, and channel them through cliPrintf instead, so 
    // we get uniform CR/LF handling. Have to disable 'more' though.

    void * old_context;
    void * old_hook = ioTaskPrintfHookSet((void*)cliVprintfHook, pCliEnv, &old_context);
    
    result = (*vxCmd)(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, 0, 0);
    
    ioTaskPrintfHookSet(old_hook, old_context, NULL);

    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf1, sizeof(buf1), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf2, sizeof(buf2), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf3, sizeof(buf3), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf4, sizeof(buf4), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf5, sizeof(buf5), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf6, sizeof(buf6), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf7, sizeof(buf7), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf8, sizeof(buf8), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf9, sizeof(buf9), FALSE);
    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(buf10, sizeof(buf10), FALSE);    
    
    debugStop();
    
    /* Flush stdout */
    fflush(stdout);

    // Cannot use 'pCmd' because the shell command might have recursively
    // invoked RapidLogic.
    cliPrintf(pCliEnv, "Result of '%s' = %ld = 0x%lx\n", pCmd, result, result);
    return OK;
}

RLSTATUS cliKernelCommand(cli_env *pCliEnv, const char *force)
{
    int sock, ptyM, ptyS;
    static int ptydone = FALSE;
    int old_out, old_in, old_err;
    taskid_t taskId;
    tStatus status =OK;
    tBoolean cliMoreEnabled;
        
    // Alpha blocking access to kernel
    if (cliInteractiveVerifyKernelAccess(pCliEnv) != OK)
    {
        cliErrorMesg(pCliEnv, "Unidentified command");
        return ERROR;
    }
    
    old_out = ioGlobalStdGet(STD_OUT);
    old_in  = ioGlobalStdGet(STD_IN);
    old_err = ioGlobalStdGet(STD_ERR);

    if (in_shell)
    {
        if (force != NULL && kernelMutex)
        {
            status = abortOperationPrompt(pCliEnv, "Disconnect existing shell session (y/n)? ", 1);
            if (status == OK || status == CLI_USER_QUIT)
            {
                return OK;
            }
            else
            {
                if (shellRunning())
                {
                    forcedToDisconnect = TRUE;
                    shellStop();
                }
                else
                {
                    cliErrorMesg(pCliEnv, "Unable to disconnect existing shell session");
                    return ERROR;
                }
            }
        }
        else
        {
            cliErrorMesg(pCliEnv, "Already in shell");
            return ERROR;
        }
    }

    /*
     * If a telnet session is initiated from CONSOLE it grabs the
     * Stdin and Stdout. If a telnet session is established from one
     * ESR to itself from CONSOLE, shell command is preveted just like
     * shell command will not take you into if a shell session is
     * active in an ESR in any of its user sessions.
     */
    if (ConsoleCliEnv->isClientActive == TRUE)
    {
        cliErrorMesg(pCliEnv, "Telnet client from console using stdin/stdout");
        return OK;
    }

    if (!kernelMutex)
    {
        kernelMutex = semMCreateX(SEM_Q_PRIORITY | SEM_DELETE_SAFE | SEM_INVERSION_SAFE, "kernelMutex", -1);
    }
    if (kernelMutex)
        semTake(kernelMutex, WAIT_FOREVER);

    in_shell = TRUE;

    // get our telnet handle (fd for in/out is the same)
    sock = ioTaskStdGet(0, STD_IN);

    // probably don't need to do this
    ptyDrv();
    if (!ptydone && ptyDevCreate("/pty/term.",2048,2048) == ERROR)
        {
        printf("Can't create pty driver\n");
        return(OK);
        }

    ptydone = TRUE;

    // open a slave telnet driver
    ptyS = open("/pty/term.S", O_RDWR, 0);
    if (ptyS == ERROR)
        {
        printf("Cant open telnet slave driver device!\n");
        return OK;
        }

    ptyM = open("/pty/term.M", O_RDWR, 0);
    if (ptyM == ERROR)
        {
        close(ptyS);
        printf("Cant open telnet master driver device!\n");
        return OK;
        }

    // spawn shell to talk to
    //
    // if the shell reentry flag (internal) is TRUE (e.g. when tShell has been taskDeleted) then
    // shellStart will set the stdio to the 'original' values (as set by shellOrigStdSet). If this flag
    // is FALSE it will set the original values to the global ones.
    //
    // If we set both original and global, it does not matter what the flag is set to:

    shellOrigStdSet(STD_IN,  ptyS);
    shellOrigStdSet(STD_OUT, ptyS);
    shellOrigStdSet(STD_ERR, ptyS);

    ioGlobalStdSet(STD_IN, ptyS);
    ioGlobalStdSet(STD_OUT, ptyS);
    ioGlobalStdSet(STD_ERR, ptyS);

    debugStart();       // starting to debug; don't crash-reboot

    tyAbortSet(0x03);       // allow ctrl-c to break into shell

    // Disable 'more' processing
    cliMoreEnabled = RCC_IsEnabled(pCliEnv, kRCC_FLAG_MORE);
    RCC_DisableFeature(pCliEnv, kRCC_FLAG_MORE);

    shellExitProtect = FALSE;   // no need for exit protection if we are spawning kernel from CLI
    if (shellStart() == OK)
        printf("Type \"exit\" to return to TiMOS CLI.\n");
    // Yeah, but what happens if this fails? Shouldn't we print something
    // and quit?

    // excJobAdd (shellRestart, TRUE, 0, 0, 0, 0, 0);  (restarts shell)

    // create tasks to handle pty I/O
    // use MOD_VXWORKS so that if tmm is out of memory we can still debug using vxworks memory
    taskSpawnX(MOD_VXWORKS, "to-pty", PTYIO_TASK_PRIORITY, 0, SMALL_STACK,
                 (FUNCPTR) xferTask, sock, ptyM,TRUE, 0,0,0,0,0,0,0);

    taskSpawnX(MOD_VXWORKS, "from-pty", PTYIO_TASK_PRIORITY, 0, SMALL_STACK,
                 (FUNCPTR) xferTask, ptyM, sock,FALSE,0,0,0,0,0,0,0);

    // Set the shell task-id in the pCliEnv. Will be used by routines 
    // running in the shell context to figure out if the shell was 
    // spawned by either CONSOLE or telnet task and correctly retreive 
    // the pCliEnv pointer without ambiguity.
    cliSubTaskSet(pCliEnv, shellGetTaskId());
    
    // Disable RED Cfg transaction tracking while in shell
    redTransConfigTrackDisable(TRUE);

    // wait while they're all still running
    // Shouldn't this be || instead of && ?
    while ((taskNameToId("to-pty")   != TASK_ID_ERROR) &&
           (taskNameToId("from-pty") != TASK_ID_ERROR) &&
            shellRunning())
        {
        taskDelay(10);
        }

    // Reenable RED Cfg transaction tracking.
    redTransConfigTrackDisable(FALSE);

    // now tidy up, close handles and kill any remaining tasks:
    
    cliSubTaskSet(pCliEnv, 0); // Reset the shell task-id in the pCliEnv. 

    close(ptyM);
    close(ptyS);

    taskDelay(1);      // let the tasks read from an invalid handle, and (hopefully) close

    debugStop();       // end debug session

    tyAbortSet(0xFF);  // disable ctrl-c handling

    // Re-enable 'more' processing
    if (cliMoreEnabled)
        RCC_EnableFeature(pCliEnv, kRCC_FLAG_MORE);


    if ((taskId = taskNameToId("to-pty")) != TASK_ID_ERROR)
        taskDelete(taskId);

    if ((taskId = taskNameToId("from-pty")) != TASK_ID_ERROR)
        taskDelete(taskId);

    shellStop();        // if user typed 'exit', shell has already stopped,
                        // but this does not hurt in case something else
                        // went wrong with the pty's or something

#if (VXWORKS_SHELL_MALLOC_HACK)
    // free up any dynamic memory leaked by the tShell task
    doShellGarbColl();
#endif

    ioGlobalStdSet(STD_IN, old_in);
    ioGlobalStdSet(STD_OUT, old_out);
    ioGlobalStdSet(STD_ERR, old_err);
    ioctl(STD_IN, FIOSETOPTIONS,
        OPT_ECHO         |
        OPT_CRMOD        |
        OPT_TANDEM       |
        OPT_7_BIT        |
        // OPT_MON_TRAP  |
        // OPT_ABORT     |
        OPT_LINE
        ); // vxworks shell send ^c ^x to rapidlogic

    // put the console in the mode the rapidlogic wants
    ioctl (STD_OUT, FIOSETOPTIONS, OPT_CRMOD | (ioctl(STD_OUT,FIOGETOPTIONS,0) & ~(OPT_LINE | OPT_ECHO)) );
    in_shell = FALSE;

    if (forcedToDisconnect)
    {
        forcedToDisconnect = FALSE;
        printf("\nDisconnected by another CLI shell\n");
    }
    if (kernelMutex)
        semGive(kernelMutex);

    // Ensure trace messages go to console (just in case user did shell cmd
    // to make trace message go elsewhere.
    if (traceFd != ERROR)                        // this means trace messages not being output to a fd
        traceFdSet(-1);                          // -1 means back to console fd
    return(OK);
}

/* Utility to print in progress indicator - see cli_priv.h for help on
 * using this utility
 */

#define CLI_IN_PROG_TASK_NAME_LEN     100
#define CLI_IN_PROG_TASK_NAME_SUFFIX  "-InProg"
#define CLI_IN_PROG_CLEAR_LINE        "\r                                                                               \r"

void
cliInProgressTask(cli_env     *pCliEnv,
                  tBoolean    *pParentInProg,
                  char       *pMsg)
{
    tUint32 i = 0;

    /* Disable Ctrl-C - So the printing of the in progress indicator ("...")
     * does not get disabled when the user enters Ctrl-C*/
    resetBreakFlag(pCliEnv);
    
    /* while waiting for parent task to finish processing, print "..." */
    while(*pParentInProg == TRUE)
    {
        if (i % 8 == 0)
            cliPrintf (pCliEnv, "%s%s", CLI_IN_PROG_CLEAR_LINE, pMsg);
        else
            cliPrintf (pCliEnv, ".");
        i++;
        taskDelay (TIMOS_TICKS_PER_SEC/2);
    }
    cliPrintf (pCliEnv, "%s", CLI_IN_PROG_CLEAR_LINE);

    /* Enable/Restore Ctrl-C */
    setBreakFlag(pCliEnv);
}

tStatus
cliInProgressIndicator(cli_env *pCliEnv, char *inProgMsg, 
                       int (*subroutine)(intptr_t, intptr_t, intptr_t, 
                                         intptr_t, intptr_t, intptr_t, 
                                         intptr_t, intptr_t, intptr_t, intptr_t),
                       intptr_t arg1, intptr_t arg2, intptr_t arg3, intptr_t arg4, intptr_t arg5,
                       intptr_t arg6, intptr_t arg7, intptr_t arg8, intptr_t arg9, intptr_t arg10)
{

    tStatus   status;
    char     taskname[CLI_IN_PROG_TASK_NAME_LEN];
    tBoolean  parentInProg; /* To signal when the parent task is complete */

    parentInProg = TRUE;
    snprintf(taskname, sizeof(taskname), "%s%s", 
             taskName(taskIdSelf()), CLI_IN_PROG_TASK_NAME_SUFFIX);

    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(&parentInProg, sizeof(parentInProg), TRUE);
    /* Spawn a subtask to display pinwheel cursor */
    if (0 == taskSpawnX(MOD_CLI, taskname, CONSOLE_TASK_PRIORITY, 0, LARGE_STACK,
                        (FUNCPTR) cliInProgressTask,
                        (intptr_t) pCliEnv, (intptr_t) (&parentInProg), (intptr_t) (inProgMsg),
                        0, 0, 0, 0, 0, 0, 0) )
    {
        PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(&parentInProg, sizeof(parentInProg), FALSE);
        cliErrorMesg(pCliEnv, "Not enough resources to spawn task");
        return ERROR;
    }

    status = (int)(*subroutine)(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);

    /* signal subtask that the parent is done */
    parentInProg = FALSE;

    /* wait for subtask to finish */
    while (taskNameToId(taskname) != TASK_ID_ERROR) 
    {
        RCC_Sleep(pCliEnv, 10);
    }

    PTR_CHCK_VALID_RANGE_SET_IF_ON_STACK(&parentInProg, sizeof(parentInProg), FALSE);

    return status;
}

/* -------------------- Utilities for string --> value ----------------- */
#define STR_NUM_SIGN_ADJUST( Str )              \
       (Str) = (*(Str) == '+') ? (Str)+1 : (Str);

#define STR_NUM_TOO_BIG( Str, VAL, StrLen, LEN ) \
       ((*(Str) < '0'   || *(Str) > '9') ||         \
        (StrLen > LEN) ||                       \
        (StrLen == LEN && strcmp((Str), VAL) > 0))

#define LARGEST_64BIT_UINT_STR   "18446744073709551615" /* 2^64 - 1 */

PUBLIC RLSTATUS strToUint64(const char *Str, tUint64 *pUint64)
{
    tUint32 strLen = strlen(Str);

    STR_NUM_SIGN_ADJUST(Str);
    if (STR_NUM_TOO_BIG( Str, LARGEST_64BIT_UINT_STR, strLen, 20))
        return ERROR;

    // sscanf is unable to handle an Uint64, so we do it manually
    *pUint64 = 0;
    while (*Str)
    {
        if (*Str < '0' || *Str > '9')
            return ERROR;

        *pUint64 = ((*pUint64)*10) + (*Str-'0');
        Str++;
    }
    return OK;
}

PUBLIC tStatus strToUint32(const char *Str, tUint32 *pUint32)
{
    RLSTATUS s = OK;
    char     trailingChar;
    tUint32  strLen = strlen(Str);

    STR_NUM_SIGN_ADJUST(Str);
    if (STR_NUM_TOO_BIG( Str, "4294967295", strLen, 10) ||
        (sscanf(Str, "%u%c", pUint32, &trailingChar) != 1))
        s = ERROR;

    return s;
}

PUBLIC tStatus strToUint32InRange(const char * Str, tUint32 * pUint32,
                                   tUint32 minValue, tUint32   maxValue)
{
    if (OK == strToUint32(Str, pUint32) &&
            minValue <= *pUint32 && *pUint32 <= maxValue)
        return OK;
    return ERROR;
}


PUBLIC RLSTATUS strToUint16(const char *Str, tUint16 *pUint16)
{
    RLSTATUS s = OK;
    char     trailingChar;
    tUint32  strLen = strlen(Str);

    STR_NUM_SIGN_ADJUST(Str);
    if (STR_NUM_TOO_BIG( Str, "65535", strLen, 5) ||
        (sscanf(Str, "%hu%c", pUint16, &trailingChar) != 1))
        s = ERROR;

    return s;
}

PUBLIC RLSTATUS strToUint8(const char *Str, tUint8 *pUint8)
{
    RLSTATUS s = OK;
    char     trailingChar;
    tUint32  strLen = strlen(Str);

    STR_NUM_SIGN_ADJUST(Str);
    if (STR_NUM_TOO_BIG( Str, "255", strLen, 3) ||
        (sscanf(Str, "%hhu%c", pUint8, &trailingChar) != 1))
        s = ERROR;

    return s;
}

PUBLIC tStatus strToInt32(const char *Str, tInt32 *pInt32)
{
    tStatus s = SUCCESS;
    char     trailingChar;
    tUint32  strLen;
    tBoolean negative;

    STR_NUM_SIGN_ADJUST(Str);
    if (Str[0] == '-')
    {
        negative = TRUE;
        Str++;
    }
    else
    {
        negative = FALSE;
    }
    strLen = strlen(Str);

    if (STR_NUM_TOO_BIG(Str, "2147483647", strLen, 10) ||
        (sscanf(Str, "%d%c", pInt32, &trailingChar) != 1))
        s = ERROR;

    if (negative)
        *pInt32 = -*pInt32;

    return s;
}

// This routine converts a string to PortId as does strToPortId, but
// it handles the ambigous '1/1/1' string on a fully concatenated
// SONET/TDM port, and returns the channel PortId instead of the physical
// PortId.
PUBLIC tStatus strToPathPortId(const char *str, tPortId *pPortId)
{
    return strToPathPortIdWithExec(FALSE, str, pPortId);   
}

PUBLIC tStatus strToPathPortIdWithExec(tBoolean ExecingFile, const char *str, tPortId *pPortId)
{
    tStatus     s;
    tPortId     PortId;
    tPortId     ChanId;

    *pPortId = INVALID_PORTID;
    s = strToPortIdOptsWithExec(ExecingFile, str, &PortId, STR_POPTS_NO_CCA_VPORT | STR_POPTS_NO_ENCAP);

    if (s != OK)
        return s;

    if (!IS_PORTID_PORT(PortId) && !IS_PORTID_APS_GRP(PortId))
    {
        *pPortId = PortId;
        return OK;
    }

    // If the port is xgig WAN, return the phys port rather than wan channel PortId.
    if (pMgrIsXgigWanPort(PortId))
    {
        *pPortId = PortId;
        return OK;
    }

    // If the port has no channels, we're done
    ChanId = chanFirstPath(PortId);
    if (ChanId == INVALID_PORTID)
    {
        *pPortId = PortId;
        return OK;
    }

    // We got a physical port with channels.
    // Return the clear channel.
    // If there is more than one channel, then fail because it is ambiguous
    while (ChanId != INVALID_PORTID)
    {
        tUint32 n = chanNumChildren(ChanId);
        if (n > 1)
            break;
        // Found leaf. Done.
        if (n == 0)
        {
            *pPortId = ChanId;        
            return OK;
        }

        ChanId = chanNextPath(ChanId);
    }
    // If we got here, fail.
    return FAIL;
}


/* Convert ASCII string to a SAP ID */
PUBLIC RLSTATUS strToSapId(const char *Str, tPortId *pPortId, tUint32 *pEncVal)
{
    return strToSapIdCliEnv(NULL, Str, pPortId, pEncVal);
}

PUBLIC RLSTATUS strToSapIdCliEnv(cli_env *pCliEnv, const char *Str, tPortId *pPortId, tUint32 *pEncVal)
{
    RLSTATUS status = OK;
    tPortEncapType EncTyp;
    char *delimStr = NULL;
    char *encapStr = NULL;

    /* If present, find the delimiter and terminate
     * the port ID portion of the SAP ID string.
     */
    if ((delimStr = strchr(Str, ':')) != NULL)
    {
        *delimStr = EOS;
        encapStr = delimStr + 1;
    }
        
    /* Convert port ID */
    if ((status = strToPathPortIdWithExec(execFlag(pCliEnv), Str, pPortId)) == OK)
    {
        /* If an encap value was specified, then
         * validate its format based on the port's
         * encap type.
         */
        EncTyp = pMgrGetEncapType(*pPortId);

        status = strToEncap(*pPortId, EncTyp, encapStr, pEncVal);
    }
    
    if (delimStr)
        *delimStr = ':';

    return status;
}

/////////////////////////////////////////////////////////////////////////
// strToRemoteSapId -- convert to sap id and validate against largest SR
//                     configuration (eg. allow 1/5/2 for SR7710)
//                     WARNING:  only supports physical and lag port ids
/////////////////////////////////////////////////////////////////////////
PUBLIC RLSTATUS strToRemoteSapId(
        const char *sapStrIn, 
        tInt32      encapType,
        tPortId    *pPortId, 
        tUint32    *pEncVal)
{
    RLSTATUS status = OK;
    char *delimStr = NULL;
    char *encapStr = NULL;
    char  sapStr[256];

    // No CLI handler should modify its input parameters, so make a local copy
    strlcpy(sapStr, sapStrIn, sizeof(sapStr));

    /* If present, find the delimeter and terminate
     * the port ID portion of the SAP ID string.
     */
    if ((delimStr = strchr(sapStr, ':')) != NULL)
    {
        *delimStr = EOS;
        encapStr = delimStr + 1;
    }

    // convert remote port ID
    if (strToLagId(sapStr, pPortId) == SUCCESS)
    {
        // now verify that the lag id is in the acceptable customer
        // configured range as the strToLagId validates a greater range.
        if (GET_LAG_ID(*pPortId) > MAX_REMOTE_USER_CFG_LAG_ID)
            return ERROR;
    } else {
        // Not a lag; convert to physical port
        if (strToRemotePhysPortId(sapStr, pPortId) != SUCCESS)
            return ERROR;
    }


    /* If an encap value was specified, then  validate its format based on the 
     * encap type.
     */
    status = strToEncap(*pPortId, encapType, encapStr, pEncVal);
    
    if (delimStr)
        *delimStr = ':';

    return status;
}

/* Convert ASCII string to a SAP encapsulation value;
   Supports only dot1q or qinq */

#define SAP_ENCAP_VAL_DUMMY "4094.4094"
/*
 <vlan-encap>         : dot1q          - *|qtag
                        qinq           - qtag1.qtag2 | qtag1.* | 0.*
                        qtag           - [0..4094]
                        qtag1          - [1..4094]
                        qtag2          - [0..4094]
*/
PUBLIC RLSTATUS strToSapEncapValue(
    const tUint32 encapType,
    const char *Str,
    tUint32 *pEncVal)
{
    tUint32 Val1 = 0;
    tUint32 Val2 = 0;
    char *pDot   = NULL;
    char *p1 = NULL;
    char *p2 = NULL;
    char EncapStr[] = SAP_ENCAP_VAL_DUMMY; 
    char dummy[] = SAP_ENCAP_VAL_DUMMY;
    size_t MaxEncapStrLen = strlen(SAP_ENCAP_VAL_DUMMY); 
    
    if ( !Str || (strlen(Str) == 0) || !pEncVal ) {
        return ERROR;
    }

    if ( strlen(Str) > MaxEncapStrLen ) {
        return ERROR;
    }

    /* Operate on a local copy */
    strcpyn(EncapStr, sizeof(EncapStr), Str);

    p1 = &EncapStr[0];

    if ((pDot = strchr(EncapStr, '.')) != NULL) {
        *pDot = EOS;
        p2 = pDot+1;
    }

    if ( *p1 == '*' ) {
        Val1 = DEF_SAP_VID;    
    } else if ( sscanf(p1, "%u%s", &Val1, dummy) != 1 ) {
        return ERROR;
    }  else if ( Val1 > MAX_SAP_VID ) {
        return ERROR;
    }

    if (pDot) {
        if (encapType != VAL_tmnxPortEncapType_qinqEncap)
            return ERROR;
        // QinQ
        if ( *p2 == '*' ) {
            Val2 = DEF_SAP_VID;    
        } else if ( sscanf(p2,"%u%s", &Val2, dummy) != 1 ) {
            return ERROR;
        } else {
            if ( Val2 > MAX_SAP_VID ) {
                return ERROR;
            }
            if ( Val1 == 0 ) {
                return ERROR;
            }
        }
        *pEncVal = (Val2 << 16) | (Val1);  // MSW=BotQ LSW=TopQ
    } else {
        if (encapType == VAL_tmnxPortEncapType_qinqEncap)
            return ERROR;
        *pEncVal = Val1; 
    }
    
    return OK;
    
}

// Supports only PORT_ENCAP_QTAG and PORT_ENCAP_QINQ 
PUBLIC char *FmtSapEncapValue(tUint32 EncVal, char *pStr, size_t bufSize)
{
    tUint32 TopVlanId = 0;
    tUint32 BotVlanId = 0;
    char TopStr[sizeof("4094")];
    char BotStr[sizeof("4094")];
    if ( !pStr ) {
        return pStr;
    }

    if ( EncVal == 0 ) {
        snprintf(pStr, bufSize, "0");
        return pStr;
    }
    TopVlanId = (EncVal & 0xffff);
    BotVlanId = (EncVal >> 16) & 0xffff;

    if ( TopVlanId == DEF_SAP_VID ) {
        snprintf(TopStr, sizeof(TopStr), "*");
    }  else {
        snprintf(TopStr, sizeof(TopStr), "%u", TopVlanId);
    }
    if ( BotVlanId == DEF_SAP_VID ) {
        snprintf(BotStr, sizeof(BotStr), "*");
    }  else {
        snprintf(BotStr, sizeof(BotStr), "%u", BotVlanId);
    }

    if ( BotVlanId ) {
        snprintf(pStr, bufSize, "%s.%s", TopStr, BotStr);
    } else {
        snprintf(pStr, bufSize, "%s", TopStr);
    }
    return pStr;
}

#undef SAP_ENCAP_VAL_DUMMY


/* Convert ASCII string to a ATM VPI[/VCI] */
PUBLIC RLSTATUS strToAtmVpiVci(const char *Str, tUint32 *pVpi, tUint32 *pVci)
{
    /* Find the delimeter */
    if (strchr(Str, '/') == NULL)
        return ERROR;

    return strToAtmVpiOptionalVci(Str, pVpi, pVci);
}

/* Convert ASCII string to a ATM VPI */
PUBLIC RLSTATUS strToAtmVpi(const char *Str, tUint32 *pVpi)
{
    char dummy[10] = "";
    
    /* Fetch VPI */
    if (sscanf(Str, "%u%s", pVpi, dummy) != 1)
        return ERROR;
        
    /* Some sanity checking */
    if (*pVpi > 4095)
        return ERROR;

    return OK;
}

/* Convert ASCII string to a ATM VPI range */
PUBLIC RLSTATUS strToAtmVpiRange(const char *Str, tUint32 *pStartVpi, tUint32 *pEndVpi)
{
    char    *p = NULL;
    char     dummy[10] = "";

    /* Find the delimeter */
    p = strchr(Str, '.');
    if (p == NULL)
        return ERROR;

    /* Fetch VPI.VPI */
    if (sscanf(Str, "%u.%u%s", pStartVpi, pEndVpi, dummy) != 2)
        return ERROR;

    /* Some sanity checking */
    if ((*pStartVpi > 4095) || (*pEndVpi > 4095))
        return ERROR;

    return OK;
}

/* Convert ASCII string to a LAG port ID and encap value */
PUBLIC RLSTATUS strToLagPortIdAndEncVal(const char *Str, tPortId *pPortId, tUint32 *pEncVal)
{
    tUint32 lagId;
    tPortId lagPortId;
    tUint32 EncVal = 0;
    char *p = NULL;

    /* Find the delimeter and terminate the LAG ID 
     * portion of the string.
     */
    if ((p = strchr(Str, ':')) != NULL)
        *p = EOS;

    /* Convert LAG ID */
    if (strchr(Str, '.'))
        return ERROR;
    lagId = atol(Str);
    if (!VALID_LAG_ID(lagId)) {
        if (p)
            *p = ':';
        return ERROR;
    }
    lagPortId = BUILD_PORTID_AGGREGATE(lagId);
 
    /* If an encap value was specified, validate its
     * format.
     */
    if (p) {
        if (sscanf((p + 1), "%u", &EncVal) != 1) {
            *p = ':';
            return ERROR;
        }
        *p = ':';
    }
    
    *pPortId = lagPortId;
    *pEncVal = EncVal;
 
    return SUCCESS;
}


/* Convert ASCII string to a SDP Bind ID  (<d>[:<d>])*/
PUBLIC RLSTATUS strToSdpBndId(const char *Str, tUint16 *pSdpId, tUint32 *pVcId)
{
    RLSTATUS s = ERROR;
    char delimiter;
    char trailer;
    tUint32 count;

    count = sscanf(Str, "%hu%c%u%c", pSdpId, &delimiter, pVcId, &trailer);
    switch (count)
    {
        case 1:               // sdpId only
            *pVcId = 0;
            s = OK;
            break;
        case 3:               // sdpId + delimiter + vcId
            if (delimiter == ':')
                s = OK;
            break;
        case 2:               // sdpId + delimiter
        case 4:               // sdpId + to delimiter + vcId + trailer?
        default:              // nothing entered?
            break;

    }

    if (s != OK)
    {
        pSdpId = 0;
        pVcId  = 0;
    }
    return s;
}

/* Convert ASCII string to a service ID and Isid */
PUBLIC RLSTATUS strToSvcIdOptIsid(const char *Str, tServId *pSvcId, tUint32 *pIsid)
{
    RLSTATUS s = ERROR;
    char *p;
    char c;

    /* Find the delimeter */
    p = strchr(Str, ':');
    if (p) {
        /* Convert ISID value */
        if (sscanf((p + 1), "%u", pIsid) == 1) {
             c = *p;
            *p = EOS;

            /* Convert Svc ID */
            if (sscanf(Str, "%u", pSvcId) == 1) {
                /* OK */
                s = OK;
            }

            *p = c;
        }
    } else {
        /* Assume default ISID */
        if (sscanf(Str, "%u", pSvcId) == 1) {
            /* OK */
            *pIsid = DEFVAL_svcTlsBackboneVplsSvcISID;
            s = OK;
        }
    }

    return s;
}

/* Convert ASCII string to a service ID, Mac and Isid */
PUBLIC RLSTATUS strToSvcIdMacIsid(const char *Str, tServId *pSvcId, tMacAddr *mac, tUint32 *pIsid)
{
    RLSTATUS s = ERROR;
    char *p;
    char *pMac;
    char c=EOS;
    char d=EOS;

    /* Find the delimeter */
    p = strchr(Str, ':');
    if (p) {
        pMac = p;
        /* Find the next delimeter */
        p = strchr(pMac+MAC_STRING_LEN, ':');
        if (p) {
            /* Convert ISID value */
            if (sscanf((p + 1), "%u", pIsid) == 1) {
                c = *p;
                *p = EOS;
                /* Convert MacAddr */
                if ((s = strToMacAddr(pMac+1, mac)) == OK) {
                    d = *pMac;
                    *pMac = EOS;
                    /* Convert Svc ID */
                    if (sscanf(Str, "%u", pSvcId) == 1) {
                        /* OK */
                        s = OK;
                    }
                    *pMac = d;
                }
                *p = c;
            }
        }
    }
    return s;
}

PUBLIC int
strToVplsType(const char *Str)
{
    if (Str != NULL) {
        if ( strcmp(Str, "b-vpls") == 0) 
            return VAL_svcVplsType_bVpls;
        else if (strcmp(Str, "i-vpls") == 0)
            return VAL_svcVplsType_iVpls;
    }
    
    return VAL_svcVplsType_none;
}

/* Convert ASCII string to a service ID */
PUBLIC RLSTATUS strToSvcId(const char *Str, tServId *pSvcId)
{
    RLSTATUS s = OK;

    if (sscanf(Str, "%u", pSvcId) != 1)
        s = ERROR;

    return s;
}

/* Convert ASCII string to Isis system Id. */
PUBLIC RLSTATUS strToIsisSystemId(tUint32 instanceId, const char *Str, char *sysId)
{
    RLSTATUS s = OK;
    tInt32   cntr, index;
    char    buffer[CLI_CONSOLE_WIDTH];

    snprintf (buffer, sizeof (buffer), "%s", Str);

    // If this is a system name, try translating to system-id
    if(isisApiNameToSysId(instanceId, buffer, sysId) == OK)
        return OK;

    if (strlen (Str) != 14) /* Format xxxx.xxxx.xxxx */
        return ERROR;

    // If it plain system Id in ascii string.
    for (cntr = 0, index = 0; cntr < 14; cntr++) {
        if (((cntr + 1) % 5) == 0) { // Make sure 4th 9th are dots.
            if (Str[cntr] != '.') {
                s = ERROR;
                break;
            }
            continue;
        }
        // validate hex digit
        if (isxdigit(Str[cntr]) == 0) {
            s = ERROR;
            break;
        }

        if ((index % 2) == 0)
            sysId[index/2] = hexCharToVal(Str[cntr]);
        else
            sysId[index/2] = (sysId[index/2] << 4) | hexCharToVal(Str[cntr]);
        index++;
    }
    return s;
}

/* Convert ASCII string to Isis Lsp Id. */
PUBLIC tStatus strToIsisLSPId(tUint32 instanceId, const char *Str, char *sysId)
{
    RLSTATUS s = OK;
    tUint8   buffer[PUTILS_BUFFER_40];
    tInt32   len;

    if (strToIsisSystemId (instanceId, Str, sysId) == OK)
        return OK;

    // Resolving name.lanid-lsp-number
    len = strlen(Str) - 5; // not including lan-id or lsp-number

    if (len <= 0)
        return ERROR;
        
    memcpy(buffer, Str, (len - 1));
    buffer[len - 1] = '\0';

    if ((s = strToIsisSystemId (instanceId, buffer, sysId)) != OK)
        return s;

    sysId[6] = hexCharToVal(Str[len++]);
    sysId[6] = (sysId[6] << 4) | hexCharToVal(Str[len++]);
    if (Str[len++] != '-')
        return ERROR;

    sysId[7] = hexCharToVal(Str[len++]);
    sysId[7] = (sysId[7] << 4) | hexCharToVal(Str[len++]);

    return s;
}

/* Convert ASCII string to LDP Id. */
PUBLIC RLSTATUS strToLdpId(const char *pStr, tUint8 *ldpId)
{
    char   *p = NULL;
    tIpAddr  peerIp, routerId;
    tUint16  labelSpace = 0, labelSpc;
    
    if (OK != strToIpAddr(pStr, &peerIp))
        return ERROR;

    if (NULL != (p = strchr(pStr, ':')))
        labelSpace = (tUint16)(atoi(p+1));

    routerId = htonl(peerIp);
    memcpy(&ldpId[0], &routerId, sizeof(tIpAddr));
    labelSpc = htons(labelSpace);
    memcpy(&ldpId[4], &labelSpc, sizeof(tUint16));

    return OK;
}


/* ASCII hex char to value */
PUBLIC char hexCharToVal(unsigned char hex)
{
    if ( (hex >= '0') && (hex <= '9') )
        return (hex - '0');

    hex = toupper(hex);

    if ( (hex >= 'A') && (hex <= 'F') )
        return (hex - 'A' + 10);

    return 0;
}

/* Convert ASCII string to an SDP ID */
PUBLIC RLSTATUS strToSdpId(const char *Str, tSdpId *pSdpId)
{

    RLSTATUS s = OK;

    if (sscanf(Str, "%hu", pSdpId) != 1)
        s = ERROR;

    return s;

}

tNamedIpv4AddrType cliGlobalNamedIpv4Addresses[] = {
    { &runtime_feature_ptp_daemon,  "ptp",       {127, 127,   1,   0} },
    { NULL,                         "",          {                  } },
};

PUBLIC void initNamedIpv4Addresses(void)
{
    globalNamedIpv4Addresses = &cliGlobalNamedIpv4Addresses[0];
}

// Returns Val in host order
PUBLIC RLSTATUS strToIpAddr(const char *Str, tIpAddr *Val)
{
    tUint32 A, B, C, D;
    tIpAddr ipAddr;
    tResolveResult result;

    if (sscanf(Str, "%u.%u.%u.%u", &A, &B, &C, &D) == 4) {
        /* Looks like it's an IP address */
        if (A <= 255) {
            ipAddr = (A << 24);
            if (B <= 255) {
                ipAddr |= (B << 16);
                if (C <= 255) {
                    ipAddr |= (C << 8);
                    if (D <= 255) {
                        ipAddr |= D;
                        *Val = ipAddr;

                        return OK;
                    }
                }
            }
        }

        return ERROR;
    }

    /* Try DNS... */
    result = resolveNameToIpAddr(Str, &ipAddr, eResolveOther, NULL);
    if (result != eResolveFound)
        return ERROR;

    *Val = ipAddr;

    return OK;
}


// Returns Val in host order
PUBLIC RLSTATUS ipStrToIpAddr(const char *Str, tIpAddr *Val)
{
    tUint32 A, B, C, D;
    tIpAddr ipAddr;

    if (NamedIpAddressStrToIpAddr(Str, Val) == OK)
        return OK;

    if (validDottedQuad(Str) != OK)
        return ERROR;
    
    if (sscanf(Str, "%u.%u.%u.%u", &A, &B, &C, &D) == 4) {
        /* Looks like it's an IP address */
        if (A <= 255) {
            ipAddr = (A << 24);
            if (B <= 255) {
                ipAddr |= (B << 16);
                if (C <= 255) {
                    ipAddr |= (C << 8);
                    if (D <= 255) {
                        ipAddr |= D;
                        *Val = ipAddr;

                        return OK;
                    }
                }
            }
        }
    }

    return ERROR;
}

//wrapper around str2n6 that returns OK or ERROR not TRUE or !TRUE
PUBLIC RLSTATUS ipStrToIp6Addr(const char *Str, tIp6Addr *Val)
{
    if (str2n6(Str, Val))
        return OK;
    return ERROR;
}
//Interprets ipv6str-interfacename
PRIVATE RLSTATUS strToIp6zAddr(const char *inputStr, tIp6Addr *ipVal, 
                               tUint32 *ifIndex, tUint32 *vrId,
                               tBoolean LinkLocalRequired)
{
    //token is '-' DASH
    SIA_ESAS_VRTRIF_ENTRY ifEntry;
    char *dashPosition;
    char *ifName;
    char Str[CLI_CONSOLE_WIDTH];
    //copy string, leave original intact
    strcpyn(Str, sizeof(Str), inputStr);
    
    *ifIndex = 0;
    if ((dashPosition = strchr(Str, '-')) != NULL) {
        ifName = dashPosition + 1;
        *dashPosition = '\0'; //null terminate the ip string;
        if (ipStrToIp6Addr(Str, ipVal) != OK) //fill the tIp6Addr
            return ERROR;
        if ((LinkLocalRequired) && (!TIP_ADDR_LNKLCL(ipVal)))
            return ERROR;
        //get the If Index - no vRtr ID so can't use mapping table
        if (*ifName == '"') //interface name was quoted ...fe80::-\"abc d
        {
            int endQuotePos; 
            ifName++;
            endQuotePos = strlen(ifName) - 1;
            if ((endQuotePos >=0) && (ifName[endQuotePos] == '"')) 
                ifName[endQuotePos] = '\0';
        }
        ZERO_STRUCT(ifEntry);
        while(siaEsasVRtrIfEntryGet(SIA_NEXT_VALUE, &ifEntry) == OK){
            if (!strcmp(ifName, ifEntry.vRtrIfName)) {
                *ifIndex = ifEntry.vRtrIfIndex;
                if (vrId)
                    *vrId = ifEntry.vRtrID;
                break;
            }               
        }
        if (*ifIndex == 0) //no interface was found
            return STR_TO_LNKLCLADDR_IF_NOT_FOUND;
    }
    else {
        //no DASH --> no interface
        if(ipStrToIp6Addr(Str, ipVal)!= OK)
            return ERROR;
        if ((LinkLocalRequired) && (TIP_ADDR_LNKLCL(ipVal)))
            return ERROR;
    } 
    return OK;
}

//Interprets ipv6str-interfacename for link local addresses
PUBLIC RLSTATUS strToIp6AddrAndIfIndex(const char *inputStr, tIp6Addr *ipVal, 
                                       tUint32 *ifIndex, tUint32 *vrId)
{
    return strToIp6zAddr(inputStr, ipVal, ifIndex, vrId, TRUE );
}

//Interprets ipv6str-interfacename for link local addresses
PUBLIC RLSTATUS strToIp6AddrAndIfIndex_VrId(tUint32    VrId, const char *inputStr,
                                            tIp6Addr *ipVal, tUint32 *ifIndex)
{
    tIpAnyAddr anyAddr;
    tStatus status;

    *ifIndex = 0;
    if (strchr(inputStr, '-')) // DASH --> itf-name given
    {
        status = str2IpAnyAddr_VrId(VrId, inputStr, &anyAddr);
        if (status == OK)
            status = ipAnyAddr2LinkLclAddrAndIfIdx(&anyAddr, ipVal, ifIndex);

        if (status != OK)
            return status==IP_LNKLCLADDR_IF_NOT_FOUND? STR_TO_LNKLCLADDR_IF_NOT_FOUND : ERROR;
    }
    else 
    {
        //no DASH --> no itf-name
        if (!str2n6(inputStr, ipVal))
            return ERROR;
        // Need itf-name for link-local address
        if (TIP_ADDR_LNKLCL(ipVal))
            return ERROR;
    } 

    return OK;
}

//Interprets ipv6str-interfacename for link local addresses
PUBLIC RLSTATUS strToIp6AddrAndIfName(const char *inputStr,
                                            tIp6Addr *ipVal, char **pIfName)
{
    char *ifName=NULL;
    char buf[CLI_CONSOLE_WIDTH];

    snprintf(buf,sizeof(buf), "%s", inputStr);
    ifName=strchr(inputStr, '-');  // DASH --> itf-name given
    if (ifName)
    {
        buf[ifName-inputStr] = EOS;
        if (!str2n6(buf, ipVal))
            return ERROR;

        // Need itf-name for link-local address
        if (!TIP_ADDR_LNKLCL(ipVal))
            return ERROR;

        if (pIfName) {
            *pIfName = ++ifName;
            if (ifName[0] == '"') {
                int len=strlen(ifName);
                if (ifName[len-1] == '"')
                    ifName[len-1] = EOS;
                *pIfName = ++ifName;
            }
        }
    }
    else 
    {
        //no DASH --> no itf-name
        if (!str2n6(inputStr, ipVal))
            return ERROR;
        // Need itf-name for link-local address
        if (TIP_ADDR_LNKLCL(ipVal))
            return ERROR;
    } 

    return OK;
}

//Interprets ipv6str-interfacename without checking on link local address
PUBLIC RLSTATUS strToIp6AddrAndOptIfIndex(const char *inputStr, tIp6Addr *ipVal, 
                                          tUint32 *ifIndex, tUint32 *vrId)
{
    return strToIp6zAddr(inputStr, ipVal, ifIndex, vrId, FALSE );
}

PUBLIC RLSTATUS strToIpPrefix(const char *IpAddrStr, const char *MaskStr,
                              tIpAddr *IpAddr, tIpAddr *Mask)
{
    tUint32 A, B, C, D, M;
    tIpAddr ipAddr;
    tIpAddr subnetMask;
    tBoolean bitSet = FALSE;
    int n;

    if (MaskStr) {
        /* Looks like we have an old-fashioned subnet mask */
        if (sscanf(MaskStr, "%u.%u.%u.%u", &A, &B, &C, &D) != 4)
            return ERROR;

        if ((A > 255) || (B > 255) || (C > 255) || (D > 255))
            return ERROR;

        subnetMask = ((A << 24) | (B << 16) | (C << 8) | D);

        /* Check that the mask is contiguos */
        for (n = 0; n < 32; n++)  {
            if (((subnetMask >> n) & 0x1) == 0x0) {
                if (bitSet == TRUE)
                    return ERROR;
            } else {
                bitSet = TRUE;
            }
        }

        /* Now do the IPv4 address */
        /* Check that the IPv4 address is not in the a.b.c.d/n format */
        n = sscanf(IpAddrStr, "%u.%u.%u.%u/%u", &A, &B, &C, &D, &M);
        if(n != 4)
            return ERROR;

        /* Check that the mask is null only if address is 0.0.0.0 */
        if (!bitSet)
        {
            if ((A != 0) || (B != 0) || (C != 0) || (D !=0))
                return ERROR;
        }

        if ((A > 255) || (B > 255) || (C > 255) || (D > 255))
            return ERROR;

        ipAddr = ((A << 24) | (B << 16) | (C << 8) | D);
    } else  {
        /* It must be a CIDR prefix */
        if(OK != strToIpAndMask(IpAddrStr, &ipAddr, &M))
           return ERROR;
        subnetMask = maskLenToValue(M);
    }

    *IpAddr = ipAddr;
    *Mask = subnetMask;

    return OK;
}

/* Convert ASCII string which is of the form a.b.c.d/n to IPv4 address
 * in host byte order and mask length.
 */
PUBLIC RLSTATUS strToIpAndMask(const char *IpPrefixStr,
                               tIpAddr *IpAddr, tUint32 *Mask)
{
    tUint32 A, B, C, D, M;
    if (sscanf(IpPrefixStr, "%u.%u.%u.%u/%d", &A, &B, &C, &D, &M) != 5)
        return ERROR;

    if ( M == 0 )
    {
        if ((A != 0) || (B != 0) || (C != 0) || (D !=0))
            return ERROR;
    }
    else
    {
        if ((A > 255) || (B > 255) || (C > 255) || (D > 255) ||
            (M < 1) || (M > 32))
            return ERROR;
    }

    *IpAddr = ((A << 24) | (B << 16) | (C << 8) | D);
    *Mask = M;

    return OK;
}

/* convert ASCII string to an IPv4 address and port number
 * expected string is in the following formats:
 *  <ipv4-address> [ :<port-number> ]
 *  \[<ipv6-address>\] [ :<port-number> ]
 *
 *  Where \[ and \] are user-typed square-brackets
 *  
 * if <port-number> is omitted then the default port number is returned
 */
tStatus str2MibAddrAndPort(const char *ipAddrStr, tUint32 defaultPortNumber,
                            tInt32 *pMibAddrType, tUint8 *pMibAddr, tUint32 mibAddrBufSize,
                            tUint32 *portNumber)
{
    char tmpIpAddrStr[255+1];
    char *portnum     = NULL;

    // IPv6 Addresses will consist of at least 2 colons(:)
    portnum = strchr(ipAddrStr, ':');
    if (portnum && strchr(portnum+1, ':'))
    {
        // IPv6 Address
        if (ipAddrStr[0] == '[')
        {
            strlcpy(tmpIpAddrStr, ipAddrStr+1, sizeof(tmpIpAddrStr));
            portnum = strchr(tmpIpAddrStr, ']');
            if (!portnum)
                return ERROR;
            *portnum = ASCII_NUL; // clear the closing bracket
            portnum ++; // Skip the closing bracket.
        }
        else
        {
            strlcpy(tmpIpAddrStr, ipAddrStr, sizeof(tmpIpAddrStr));
            portnum = NULL;
        }
    }
    else 
    {   // IPv4 Address
        strlcpy(tmpIpAddrStr, ipAddrStr, sizeof(tmpIpAddrStr));
        portnum = strchr(tmpIpAddrStr, ':');
    }

    if (portnum)
    {
        if (*portnum != ':')
            return ERROR;

        *portnum = ASCII_NUL;
        portnum++;
    }

    if (str2MibAddr(tmpIpAddrStr, pMibAddrType, pMibAddr, mibAddrBufSize) != OK)
        return ERROR;

    if (portnum) {
        if (strToUint32(portnum, portNumber) != OK)
            return ERROR;
    } else {
        *portNumber = defaultPortNumber;
    }
    
    return OK;
}

const char *
formatMibAddrWithOptionalPort(tInt32 ipAddrType, tUint8 * ipAddr, tUint32 portNumber,
                              tBoolean displayPort, char * buffer, size_t bufferSize)
{
    char ipBuffer[255];
    formatMibAddr(ipAddrType, ipAddr, ipBuffer, sizeof(ipBuffer));
    if (displayPort)
    {
        if (ipAddrType == VAL_VAR_inetAddressType_ipv6)
            snprintf(buffer, bufferSize, "[%s]:%u", ipBuffer, portNumber);
        else
            snprintf(buffer, bufferSize, "%s:%u", ipBuffer, portNumber);
    }
    else
        snprintf(buffer, bufferSize, "%s", ipBuffer);
    return buffer;
}

/* convert ASCII string to an IPv4 address and port number
 * expected string is <ip-address> [ :<port-number> ]
 * if <port-number> is omitted then the default port number is returned
 */
tStatus strToIpAndPort(const char *IpAddrStr, tUint16 defaultPortNumber,
                              tIpAddr *IpAddr, tUint16 *portNumber)
{
    char *portnum;

    if (OK != strToIpAddr(IpAddrStr, IpAddr))
        return ERROR;

    portnum = strchr(IpAddrStr, ':');
    if (portnum != NULL) {
        *portNumber = atol(portnum+1);
    } else {
        *portNumber = defaultPortNumber;
    }
    
    return OK;
}

PUBLIC tStatus strToNodeId(const char *nodeIdStr, tUint32 *pNodeId)
{
    tUint32 nodeId = 0; // Only update the output param when returning OK.
    tStatus status = ERROR;

    status = ipStrToIpAddr(nodeIdStr, &nodeId);

    if ((status == OK) && (nodeId != 0)) {
        *pNodeId = nodeId;
        return OK;
    }

    status = strToUint32(nodeIdStr, &nodeId);

    if ((status == OK) && (nodeId != 0)) {
        *pNodeId = nodeId;
        return OK;
    }

    return ERROR;
}

/* Convert ASCII string to an IPv4/IPv6 address array.
 * The string can be an IP address in "decimal-dot" notation
 * or IPv6.
 */
RLSTATUS strToInetAddress(const char *Str, tUint8 *pInetAddrBuf, tUint32 bufsize, tUint32 *addrLength)
{
    tUint32     ipv4address = 0;
    tIp6Addr    ipv6address;
    tUint32     ifIndex = 0;

    /* Removed check on runtime_feature_ip6
     * Reason: ipv6 addresses can be valid even if the feature flag is not set.
     *         (e.g. ipv6 addresses on the management itf of 7450).
     * If a check on runtime_feature_ip6 is needed it should be placed at the level of the caller
     * of this function.
     */

    /* Check if ipv6 neighbor */
    if (strToIp6AddrAndIfIndex(Str, &ipv6address, &ifIndex, 0) == OK)
    {
        if (bufsize < IPV6_ADDR_LEN)
        {
#if !TIMOS_BUILD_TYPE(BETA)
            BTRACE_ERROR(MOD_CLI, NOCLASS, "Buffer overflow on '%s', bufsize %u", Str, bufsize);
#endif
            return ERROR;
        }

        TIP_ADDR_COPY(pInetAddrBuf, &ipv6address);
        if (ifIndex == 0)      
        {              
            *addrLength = IPV6_ADDR_LEN;
        }
        else
        {
            if (bufsize < IPV6Z_ADDR_LEN)
            {
#if !TIMOS_BUILD_TYPE(BETA)
                BTRACE_ERROR(MOD_CLI, NOCLASS, "Buffer overflow on '%s', bufsize %u", Str, bufsize);
#endif
                return ERROR;
            }
            ifIndex = htonl(ifIndex);
            memcpy(pInetAddrBuf + IPV6_ADDR_LEN, &ifIndex, IPV6Z_ADDR_LEN - IPV6_ADDR_LEN);
            *addrLength = IPV6Z_ADDR_LEN;
        }
    }
    else
    {
        /* Get IP Address */
        if ((Str) && (ipStrToIpAddr(Str, &ipv4address) != OK)){
            return ERROR;
        }
        
        if (bufsize < IPV4_ADDR_LEN)
        {
#if !TIMOS_BUILD_TYPE(BETA)
            BTRACE_ERROR(MOD_CLI, NOCLASS, "Buffer overflow on '%s', bufsize %u", Str, bufsize);
#endif
            return ERROR;
        }
        IPV4_HTON_BUFFER(ipv4address, pInetAddrBuf);
        *addrLength = IPV4_ADDR_LEN;
    } 
    return OK;
}

/* Convert ASCII IPv4/mask or IPv6/mask string to an Inet address array and mask.
 * The string can be an IP address in "decimal-dot" notation with /mask
 * or in IPv6 notation with /mask .
 */
RLSTATUS strToInetPrefixAndLength(const char *Str, tUint8 *pInetAddrBuf, tUint32 InetAddrSize, 
                                  tUint32 *addrLength, tUint32 *prefixLen)
{
    tUint32     ipv4address = 0;

    tIp6PfxLen  ipv6PfxLen;
    tIp6Addr    ipv6Prefix;
    sbyte       ipv6PrefixStr[IPV6STRLEN] = {0};    
    
    if (InetAddrSize < IP_ADDR_MAX_LEN)
    {
#if !TIMOS_BUILD_TYPE(BETA)
        BTRACE_ERROR(MOD_CLI, NOCLASS, "Buffer overflow on '%s' into %u bytes", Str, InetAddrSize);
#endif
        return ERROR;
    }
        
    if(OK != strToIpAndMask(Str, &ipv4address, prefixLen)) 
    {
        /* Check if the given route is an ipv6-address */
        if ((OK == tokenizeIpv6Address(Str, ipv6PrefixStr, sizeof(ipv6PrefixStr), &ipv6PfxLen)))
        {
            *addrLength = IPV6_ADDR_LEN;
            *prefixLen = ipv6PfxLen;
            if (str2n6(ipv6PrefixStr, &ipv6Prefix) == 1) 
                TIP_ADDR_COPY(pInetAddrBuf, &ipv6Prefix);
            else                
                return ERROR;
        }
        else
        {
            return ERROR;
        }
    }
    else
    {
        *addrLength = IPV4_ADDR_LEN;
        IPV4_HTON_BUFFER(ipv4address, pInetAddrBuf);
    }
    
    return OK;
}

////////////////////////////////////////////////////////////////////////////////
// FmtInetPrefixAndLength()
//
// For example, given
//     inetPrefixType == 2 == VAL_VAR_inetAddressType_ipv6,
//     inetPrefix == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
//     inetPrefixLenInBits == 128
// return the string
//     "102:304:506:708:90A:B0C:D0E:F10/128".
//
// Similarly, IPv4 addresses.
//
// The input parameters match the following TEXTUAL-CONVENTIONs:   
//     INET-ADDRESS-MIB::InetAddressType,
//     INET-ADDRESS-MIB::InetAddress, and 
//     INET-ADDRESS-MIB::InetAddressPrefixLength.
////////////////////////////////////////////////////////////////////////////////
char *FmtInetPrefixAndLength(tInt32 inetPrefixType, tUint8 *inetPrefix,
                             tUint32 inetPrefixLenInBits,
                             char *outString, tUint32 sizeofOutString)
{
    tUint32 strLenWithoutSuffix = 0;

    if (outString == NULL) {
        TRACE_ERROR(MOD_CLI, NOCLASS, "outString is NULL");
        return NULL;
    }

    if (inetPrefix == NULL) {
        TRACE_ERROR(MOD_CLI, NOCLASS, "inetPrefix is NULL");
        snprintf(outString, sizeofOutString, "(NULL address)");
        return outString;
    }

    switch (inetPrefixType) {
    case VAL_VAR_inetAddressType_ipv4:
        snprintf(outString, sizeofOutString, "%u.%u.%u.%u", inetPrefix[0], inetPrefix[1], inetPrefix[2], inetPrefix[3]);
        break;
    case VAL_VAR_inetAddressType_ipv6:
        (void)FmtIp6Addr((tIp6Addr*)inetPrefix, outString, sizeofOutString);
        break;
    default:
        snprintf(outString, sizeofOutString, "(unsupported address type)");
        TRACE_ERROR(MOD_CLI, NOCLASS, "Unsupported address type = %d", inetPrefixType);
        return outString;
    }

    // Concatenate "/32", for example.
    strLenWithoutSuffix = strlen(outString);
    snprintf(outString+strLenWithoutSuffix, sizeofOutString-strLenWithoutSuffix, "/%u", inetPrefixLenInBits);

    return outString;
}

/* Convert ASCII string to 48-bit MAC address. The string can be in
 * the IEEE cannonical format (00-11- ...) or in the common SunOS
 * format (00:11: ...)
 */
PUBLIC RLSTATUS strToMacAddr(const char *Str, tMacAddr *Val)
{
    int B0, B1, B2, B3, B4, B5;
    int i;

    if (Str == NULL || Val == NULL)
        return ERROR;
    
    /* enforce the length:  must be 12 hex digits, 5 separators (: or -) */
    if (MAC_STRING_LEN != strlen(Str))
        return ERROR;
       
    /* 
     * all characters must be valid Hexadecimal values:
     * - 00:00:c8:02:01:-1     '-1' is a valid number but not valid as Mac address
     * - 00:00:c8:02:01:+a     '+a' is a valid number but not valid as Mac address
     * - 00:32:23:53:5d:2g     '2g' is invalid but gets through the sscanf's trailing char issue 
     */
    for(i = 0; i < MAC_STRING_LEN; i++)
    {
        // do not check separators
        if (((i+1) % 3) == 0)         
            continue; 
        //check numbers
        if (!isxdigit(Str[i]))
            return ERROR;
    }

    /* First try the IEEE cannonical format */
    if (sscanf(Str, "%02x-%02x-%02x-%02x-%02x-%02x",
               &B0, &B1, &B2, &B3, &B4, &B5) != 6) {
        /* OK, try the SunOS format... */
        if (sscanf(Str, "%02x:%02x:%02x:%02x:%02x:%02x",
                   &B0, &B1, &B2, &B3, &B4, &B5) != 6) {
            /* Syntax error! */
            return ERROR;
        }
    }

    if ((B0 > 255) || (B1 > 255) || (B2 > 255) ||
        (B3 > 255) || (B4 > 255) || (B5 > 255)) {
        /* Syntax error! */
        return ERROR;
    }

    Val->MacAddrByte[0] = B0;
    Val->MacAddrByte[1] = B1;
    Val->MacAddrByte[2] = B2;
    Val->MacAddrByte[3] = B3;
    Val->MacAddrByte[4] = B4;
    Val->MacAddrByte[5] = B5;

    return OK;
}

PRIVATE RLSTATUS divideIpString(const char *scrAddrStr,
                               char *dstBuf, tUint32 dstBufSize,
                               tIp6PfxLen *ip6PfxLen, tBoolean *maskPresent)
{
    char *pToken;
    tUint32 prefixLen;
    size_t addrLen;

    if (scrAddrStr== NULL || scrAddrStr[0] == '\0' ||
        dstBuf == NULL || dstBufSize == 0)
        return ERROR;

    // finding the token
    pToken = strchr(scrAddrStr, '/');

    // token has been found -> obtain the prefixLen
    if (pToken != NULL)
    {
        addrLen = (pToken - scrAddrStr);
        if (addrLen > dstBufSize - 1)
        {
            TRACE_ERROR(MOD_CLI, NOCLASS, "Destination buffer too small.");
            return ERROR;
        }

        if (cliParseDecimal((pToken+1), &prefixLen) != OK)
            return ERROR;

        if (prefixLen < 0 || prefixLen > IPV6MAXPFXLEN)
            return ERROR;

        *ip6PfxLen  =  (tIp6PfxLen)prefixLen;
        *maskPresent = TRUE;

        memcpy(dstBuf, scrAddrStr, addrLen);
        dstBuf[addrLen] = '\0';
    }
    else
    {
        // There was no mask, so simply copy the address
        strlcpy(dstBuf, scrAddrStr, dstBufSize);
        *maskPresent = FALSE;
    }
    return OK;
}

PRIVATE tStatus checkIpMaskValidity(tInt32     mibAddrType,
                                    tUint8     *mibAddr,
                                    tIp6PfxLen pfxLen)
{
    if ((mibAddrType == VAL_ipAddressAddrType_ipv6  && pfxLen > IPV6MAXPFXLEN) ||
        (mibAddrType == VAL_ipAddressAddrType_ipv4  && pfxLen > IPV4MAXPFXLEN))
        return ERROR;

    if (pfxLen == 0 &&
        !mibIsAddrZero(mibAddrType, mibAddr))
        return ERROR;

    return OK;
}

PRIVATE tStatus str2MibAddrAndPrefix(const char *addrStr,
                                     tInt32     *mibAddrType,
                                     tUint8     *mibAddr,
                                     size_t      mibAddrBufSize,
                                     tUint32    *prefixLen,
                                     tBoolean   *maskPresent)
{
    char       tmpBuf[FMT_IP6_BUF_SIZE];
    tIp6PfxLen pfxLen; // MIB uses tUint32, but the tokenize function requires tUint8

    if (divideIpString(addrStr, tmpBuf, sizeof(tmpBuf), &pfxLen, maskPresent) != OK)
        return ERROR;

    if (str2MibAddr(tmpBuf, mibAddrType, mibAddr, mibAddrBufSize) != OK)
        return ERROR;

    if (*maskPresent)
    {
        if (checkIpMaskValidity(*mibAddrType, mibAddr, pfxLen) != OK)
            return ERROR;

        *prefixLen = pfxLen;
    }

    return OK;
}

PUBLIC tStatus str2MibAddrMask(const char *prefixAndMask,
                               tInt32     *mibAddrType,
                               tUint8     *mibAddr,
                               size_t      mibAddrBufSize,
                               tUint32    *prefixLen)
{
    tBoolean maskPresent;

    if (str2MibAddrAndPrefix(prefixAndMask, mibAddrType, mibAddr, mibAddrBufSize, prefixLen, &maskPresent) != OK)
        return ERROR;

    if (!maskPresent)
        // if there is no prefix specified, return ERROR
        return ERROR;

    return OK;
}

PUBLIC tStatus str2MibAddrMask4(const char *prefixAndMask,
                                tInt32     *mibAddrType,
                                tUint8     *mibAddr,
                                size_t      mibAddrBufSize,
                                tUint32    *prefixLen)
{
    if (str2MibAddrMask(prefixAndMask, mibAddrType, mibAddr, mibAddrBufSize, prefixLen) != OK)
        return ERROR;

    return (*mibAddrType == VAL_ipAddressAddrType_ipv4) ? OK : ERROR;
}

PUBLIC tStatus str2MibAddrOptMask(const char *prefixAndMask,
                                  tInt32     *mibAddrType,
                                  tUint8     *mibAddr,
                                  size_t      mibAddrBufSize,
                                  tUint32    *prefixLen)
{
    tBoolean maskPresent;

    if (str2MibAddrAndPrefix(prefixAndMask, mibAddrType, mibAddr, mibAddrBufSize, prefixLen, &maskPresent) != OK)
        return ERROR;

    if (!maskPresent)
    {
        if (*mibAddrType == VAL_ipAddressAddrType_ipv4)
            *prefixLen = IPV4MAXPFXLEN;
        else
            *prefixLen = IPV6MAXPFXLEN;
    }

    return OK;
}

/*
 * Convert 32-bit unsigned decimal string to binary. Does absolutely
 * no error checking, so use only in cases you know string to be a number
 */
PUBLIC tUint32 atou(const char *p)
{
    tUint32 val = 0;
    while (isdigit(*p))
    {
        val = (val * 10) + ((*p++) - '0');
    }
    return val;
}

/*  
 * Evaluate a string for a regular expression match.
 * CAUTION: Test has not verified this regexp match works correctly in all
 *          cases.  Until it has been verified it should not be used in any
 *          released code.  This function uses the regexp syntax from the 
 *          library of Henry Spencer from the University of Toronto.  
 *  -- revab 09/25/2006
 */
PUBLIC
tBoolean strHsRegexpMatch(const char *exp, const char *str)
{
    // Use regular expression match
    tStatus rc;
    regex_t matchRegexp;
    tBoolean match = FALSE;
    tUint32 compFlags = REG_EXTENDED|REG_NOSUB;

    if ((rc = hsRegcomp(&matchRegexp, exp, compFlags)) != 0)
    {   // Invalid regular expression
        // Fill in hsRegerror message???
        char err[40];
        char msg[80];
        hsRegerror(rc, &matchRegexp, err, sizeof(err));
        snprintf(msg, sizeof (msg), "Invalid regular expression : %s", err);
        //RCC_TASK_MatchCommandError(pCliEnv, msg);
        return FALSE;
    }

    match = (hsRegexec(&matchRegexp, str, 0, NULL, 0) == 0) ? TRUE : FALSE;

    hsRegfree(&matchRegexp);
    return match;
} 

/*
 * Output a formatted error message to the device embedded within the pCliEnv.
 */
PUBLIC void cliErrorMesgSpecific(cli_env *pCliEnv, tUint32 errorCode, tUint32 severityLevel, const char *fmt, ...)
{
    char extraText[MAX_MESG_LENGTH];
    char msgBuf   [MAX_MESG_LENGTH];
    tSnmpModuleErr *errorInfo;
    va_list args;

    va_start(args, fmt);
    vsnprintf(extraText, sizeof(extraText), fmt, args);
    va_end(args);

    if ( errorCode )
    {
        errorInfo = getSnmpSetErrInfo(MOD_CLI, errorCode);
        if (errorInfo == NULL)
            return;

        if(0 == strcmp(fmt, " "))
        {
            snprintf(msgBuf, sizeof(msgBuf), "\n%s: %s #%u %s.\a",
                    severityLevelName[severityLevel-1].Name,
                    Module[MOD_CLI].Name,
                    errorCode,
                    errorInfo->ErrorMesg);
        }
        else
        {
            snprintf(msgBuf, sizeof(msgBuf), "\n%s: %s #%u %s - %s.\a",
                    severityLevelName[severityLevel-1].Name,
                    Module[MOD_CLI].Name,
                    errorCode,
                    errorInfo->ErrorMesg,
                    extraText);
        }
        cliAddMesg(pCliEnv, msgBuf);
        RCC_LOG_Output(msgBuf);
    }
}

/*
 * cliFindExtraPeriod() checks for an extra period at the end of 
 * a message. cliWarnMesg, cliErrorMsg and cliInfoMsg add a period
 * at the end already. The message passed in should not have one.
 */
PRIVATE void cliFindExtraPeriod(char *msg)
{
    if (msg[strlen(msg)-1] == '.')
    {
        TRACE_ERROR(MOD_CLI, NOCLASS,
        "Cli message has extra period at end:  %s", msg);
    }
}

/*
 * Output a formatted error message to the device embedded within the pCliEnv.
 */
PUBLIC void cliErrorMesg(cli_env *pCliEnv, const char *fmt, ...)
{
    char msg    [MAX_MESG_LENGTH];
    char tempMsg[MAX_MESG_LENGTH];
    va_list args;

    va_start(args, fmt);
    vsnprintf(msg, sizeof(msg), fmt, args);
    va_end(args);

    snprintf(tempMsg, sizeof(tempMsg), "MINOR: CLI %s.\a", msg);
    cliAddMesg(pCliEnv, tempMsg);
    RCC_LOG_Output(tempMsg);

#if !TIMOS_BUILD_TYPE(BETA)
    cliFindExtraPeriod(msg);
#endif
}

/*
 * Output a formatted warning message to the device embedded within the pCliEnv.
 */
PUBLIC void cliWarnMesg(cli_env *pCliEnv, const char *fmt, ...)
{
    char msg    [MAX_MESG_LENGTH];
    char tempMsg[MAX_MESG_LENGTH];
    va_list args;

    va_start(args, fmt);
    vsnprintf(msg, sizeof(msg), fmt, args);
    va_end(args);

    snprintf(tempMsg, sizeof(tempMsg), "WARNING: CLI %s.\a", msg);
    cliAddMesg(pCliEnv, tempMsg);

#if !TIMOS_BUILD_TYPE(BETA)
    cliFindExtraPeriod(msg);
#endif
}

/*
 * Output a formatted warning message to the device embedded within the pCliEnv.
 */
PUBLIC void cliInfoMesg(cli_env *pCliEnv, const char *fmt, ...)
{
    char msg    [MAX_MESG_LENGTH];
    char tempMsg[MAX_MESG_LENGTH];
    va_list args;

    va_start(args, fmt);
    vsnprintf(msg, sizeof(msg), fmt, args);
    va_end(args);

    snprintf(tempMsg, sizeof(tempMsg), "INFO: CLI %s.\a", msg);
    cliAddMesg(pCliEnv, tempMsg);

#if !TIMOS_BUILD_TYPE(BETA)
    cliFindExtraPeriod(msg);
#endif
}



/*
 *  Queue for output, a formatted error message with detailed SNMP SET failure info
 */
PUBLIC void cliSnmpSetInfoMesg(cli_env *pCliEnv)
{
    SIA_ERROR_T *setErrPtr = siaGetLastSnmpSetError();

    if (setErrPtr->extraTextIsInformationalOnly)
    {
        cliSnmpSetErrorMesg(pCliEnv);
        // Clear info message as soon as it is printed.
        cliSnmpClearErrorMesg(pCliEnv);
    }
}

PUBLIC void cliSnmpSetErrorMesg(cli_env *pCliEnv)
{
    char msgBuf[MAX_MESG_LENGTH];
    SIA_ERROR_T *setErrPtr = siaGetLastSnmpSetError();
    tModuleId moduleID = setErrPtr->moduleId;
    tUint32 errorCode = setErrPtr->errorCode;
    tSnmpModuleErr *errorInfo;

    errorInfo = getSnmpSetErrInfo(moduleID, errorCode);

#if !TIMOS_BUILD_TYPE(BETA)
    /* If the error code does not have a valid tSnmpModuleErr entry,
    the error code has to be added in agent/sia_err_msgs.c
    Let the developer know about it by using a Trace Message */
    if ((errorCode != 0) &&
        (errorInfo->ErrorCode == SIA_COMMON_INDETERMINATE_ERROR_CODE))
    {
        TRACE_ERROR(MOD_CLI, NOCLASS,
            "Module %u(%s), missing entry in sia_err_msgs.c for the error #%u",
            moduleID, Module[moduleID].Name, errorCode);
    }
#endif

    if (pCliEnv == NULL)
        pCliEnv = ConsoleCliEnv;

    if (setErrPtr->errorCode)
    {
        if((setErrPtr->extraText[0] == 0) || (0 == strcmp(setErrPtr->extraText, " ")) )
        {
            snprintf(msgBuf, sizeof(msgBuf), "%s: %s #%d %s",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg);
        }
        else
        {
            snprintf(msgBuf, sizeof(msgBuf), "%s: %s #%d %s - %s",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg,
                    setErrPtr->extraText);
        }
        cliAddMesg(pCliEnv, msgBuf);
        RCC_LOG_Output(msgBuf);
    }
}

#if 0 /* Not used (anymore) */
/*
 *  Output immediately a formatted error message with detailed SNMP SET failure info
 *  This has been added to support error mesgs during booting when we cannot wait
 *  for RCC_TASK_Readline to output the error mesg queued by the above cmd
 *  and is also useful because we may not have a valid clienv during booting.
 */
PUBLIC void cliSnmpPrintErrorMesg(cli_env *pCliEnv)
{
    SIA_ERROR_T *setErrPtr = siaGetLastSnmpSetError();
    tModuleId moduleID;
    tUint32 errorCode;
    tSnmpModuleErr *errorInfo;

    if (!setErrPtr)
    {
        if (pCliEnv)
            cliPrintf(pCliEnv, "Major:  Cannot retrieve SNMP Set error ptr");
        else
            printf("Major:  Cannot retrieve SNMP Set error ptr");
        return;
    }

    moduleID = setErrPtr->moduleId;
    errorCode = setErrPtr->errorCode;

    errorInfo = getSnmpSetErrInfo(moduleID, errorCode);
    if (!errorInfo)
    {
        if (pCliEnv)
            cliPrintf(pCliEnv, "Major:  Cannot retrieve SNMP Set error info");
        else
            printf("Major:  Cannot retrieve SNMP Set error info");
        return;
    }


    if (setErrPtr->errorCode)
    {
        if(0 == strcmp(setErrPtr->extraText, " "))
        {
            if (pCliEnv)
                cliPrintf(pCliEnv, "%s: %s #%d %s\n",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg);
            else
                printf("%s: %s #%d %s\n",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg);

        }
        else
        {
            if (pCliEnv)
                cliPrintf(pCliEnv, "%s: %s #%d %s - %s\n",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg,
                    setErrPtr->extraText);
            else
                printf("%s: %s #%d %s - %s\n",
                    severityLevelName[setErrPtr->severityLevel-1].Name,
                    Module[moduleID].Name,
                    errorCode,
                    errorInfo->ErrorMesg,
                    setErrPtr->extraText);
        }
    }

    /* For want of a more logical place to clear the last snmp error
     * structure, we will do it here for now. There is currently a CLI
     * bug that causes this function to sometimes be called twice.
     * It is called after every command handler (a recent change) and
     * again at the end of a string of commands (the old behavior, which
     * should now be removed.  The actual clearing is done in the
     * Epilogue custom hook function called before the SET PDU is
     * processed --revab
     */
     siaClearLastSnmpSetError();
}
#endif
/*
 *  SNMP Message clearing mechanism for CLI. Wrapper around the SIA
 */
PUBLIC void cliSnmpClearErrorMesg(cli_env *pCliEnv)
{
     siaClearLastSnmpSetError();
}

/*
 * DB_ExecuteHandlers() will only print the error message for CLI commands if
 * their handler returned ERROR. This function is used to report
 * such inconsistencies.
 */
PUBLIC void cliSnmpCheckErrorMesg(cli_env *pCliEnv, tBoolean viaRcbBackplane)
{
    SIA_ERROR_T *setErrPtr = siaGetLastSnmpSetError();

#if !TIMOS_BUILD_TYPE(BETA)
    /*
     * Before actually printing the error message, we verify here that
     * siaSnmpSetError() stored the error message in this tasks own buffer,
     * either the error buffer belonging to a configuration task, or one that
     * was explicitly registered by calling siaRegisterCurrentTaskForLastSnmpSetError().
     */
    if (!siaSnmpIstaskSpecificLastSnmpSetError(setErrPtr))
    {
        BTRACE_ERROR(MOD_CLI, NOCLASS, "Error buffer used by siaSnmpSetError() is not task specific");
        return;
    }
#endif

    /* Skip messages set with siaSnmpSetInfo() */
    if (setErrPtr->extraTextIsInformationalOnly)
    {
        return;
    }

    /* Trace messages set with siaSnmpSetError() */
    if (setErrPtr->errorCode)
    {
#if !TIMOS_BUILD_TYPE(BETA)
        tModuleId moduleID     = setErrPtr->moduleId;
        tUint32 errorCode      = setErrPtr->errorCode;
        tSnmpModuleErr *errorInfo;
        char msgBuf[MAX_MESG_LENGTH];
        char cliBuf[kRCC_MAX_CMD_LEN];

        RCC_DB_PWCommand(pCliEnv, cliBuf, sizeof(cliBuf), TRUE);

        errorInfo = getSnmpSetErrInfo(moduleID, errorCode);
        if((setErrPtr->extraText[0] == 0) || (0 == strcmp(setErrPtr->extraText, " ")) )
        {
            snprintf(msgBuf, sizeof(msgBuf), "%s: %s #%d %s",
                     severityLevelName[setErrPtr->severityLevel-1].Name,
                     Module[moduleID].Name,
                     errorCode,
                     errorInfo->ErrorMesg);
        }
        else
        {
            snprintf(msgBuf, sizeof(msgBuf), "%s: %s #%d %s - %s",
                     severityLevelName[setErrPtr->severityLevel-1].Name,
                     Module[moduleID].Name,
                     errorCode,
                     errorInfo->ErrorMesg,
                     setErrPtr->extraText);
        }

        BTRACE_ERROR(MOD_CLI, NOCLASS, "This CLI command (%s) returns OK so error message set by siaSnmpSetError (\"%s\") will be ignored", cliBuf, msgBuf);
#endif

        // If the call used the RCB Backplane, a bug ensured the error message
        // was printed even when the return status was OK.
        // As a courtesy we'll ensure we keep that behavior in place, but
        // we do add the trace above as well.
        // Once every occurrence has been fixed this code we should be able to remove these lines
        if (viaRcbBackplane)
            cliSnmpSetErrorMesg(pCliEnv);
    }
}

/*
 * Output text to the device embedded within the pCliEnv. If you pass NULL,
 * output goes to the front panel console. This does "more" processing.
 * If you want to avoid "more" processing, use console Printf();
 */
PUBLIC int cliPrintf(cli_env *pCliEnv, const char *fmt, ...)
{
    va_list     args;
    int         result = 0;

    va_start(args, fmt);
    result = cliVprintf(pCliEnv, fmt, args);
    va_end(args);

    return result;
}

PRIVATE int cliOutChar(void * outch_ptr, int * currlen, int maxlen, char ch)
{
    char * last_ch_ptr = (char*) outch_ptr;
    
    if (ch != '\0')
    {
        // avoid doing an extra \r if we've already done one.
        if (ch == '\n' && *last_ch_ptr != '\r')
        {
            char cr = '\r';
            write (STD_OUT, &cr, 1);
        }
        write (STD_OUT, &ch, 1);
    }
    *last_ch_ptr = ch;
    return 1;
}

PUBLIC int cliVprintfHook(cli_env *pCliEnv, const char *fmt, va_list args)
{
    char last_ch = 0;

    // just do the cr/lf substitution
    return(sprintf_dopr(cliOutChar, &last_ch, 0, fmt, args));
}

PUBLIC int cliVprintf(cli_env *pCliEnv, const char *fmt, va_list args)
{
    char        buffer[MAX_MESG_LENGTH];
    RLSTATUS    status = OK;
    int         result = 0;
    int         size=0;
    char       *msg=buffer;

    if (pCliEnv == NULL)
        pCliEnv = ConsoleCliEnv;

    // Don't bother if the output on the console is stopped.
    if (timosCLIOutputStopped(pCliEnv, TRUE))
        return -1;

    PRINTSEM_LOCK(pCliEnv);

    size = vsnprintfTruncate(msg, sizeof(buffer), fmt, args);

    if (size >= MAX_MESG_LENGTH) {
         msg = (char *) RC_MALLOC( size+1 );
         if (msg == NULL)
         {
             PRINTSEM_UNLOCK(pCliEnv);
             return -1;
         }
         vsnprintf(msg, size+1, fmt, args);
    }
    if (pCliEnv)
    {
        char *p = msg;
        char *n;

        while (*p && (n = strchr(p, '\n')))
        {
            *n = '\0';
            status = RCC_EXT_WriteStrLine(pCliEnv, p);
            if (status != 0)
                result = -1;
            p = n + 1;
        }
        if (*p)
        {
            status = RCC_EXT_WriteStr(pCliEnv, p);
            if (status != 0)
                result = -1;
        }
    }
    else
    {
        fputs(msg, stdout);
    }

    PRINTSEM_UNLOCK(pCliEnv);

    if (msg != buffer)
        RC_FREE(msg);

    return result;
}

/*
 * Reset the more counter of the device embedded within the pCliEnv.
 * If you pass NULL, reset counter associated with the the console.
 */
PUBLIC void cliResetOutput(cli_env *pCliEnv)
{
    if (pCliEnv)
    {
        RCC_EXT_ResetOutput(pCliEnv);
    }
    else
    {
        RCC_EXT_ResetOutput(ConsoleCliEnv);
    }
}

/*
 *  loggerPrintf() - Write a message for session type logs only
 *
 *  Assumes this function is called only from a TiMOS LOGGER task.
 *  Assumes message is formatted using LOGGER_TIMOSLOG_FORMAT.
 *  Assumes message ends with '\n' character.
 *
 *  Hardwraps lines at 80 chars.
 */
PUBLIC tStatus loggerPrintf( cli_env *pCliEnv, const char *fmt, ...)
{

#define LOGGER_PRINTF_LINE_WIDTH CLI_CONSOLE_WIDTH

    va_list      args;
    char         msgBuf[MAX_MESG_LENGTH];
    char        *bufPtr = msgBuf;
    char        *nlPtr;
    int          copyLen = 0;
    int          result;
    WriteHandle *Writer;
    sbyte        printBuf[LOGGER_PRINTF_LINE_WIDTH + 3];    

    PRINTSEM_LOCK(pCliEnv);

    Writer = MCONN_GetWriteHandle(pCliEnv);

    va_start(args, fmt);
    result = vsnprintf(msgBuf, sizeof(msgBuf), fmt, args);
    va_end(args);

    while ( result > 0 )
    {   // Find the next '\n' character
        if ( (nlPtr = strchr(bufPtr, '\n')) != NULL )
        {
            if ( (copyLen = (nlPtr - bufPtr)) > LOGGER_PRINTF_LINE_WIDTH )
            {
                // Wrap line
                copyLen = LOGGER_PRINTF_LINE_WIDTH;
            }
        }
        else
        {
            // Something is wrong because the formatted string should
            // end with '\n'.  Oh well, wrap it if needed.
            copyLen = (result <= LOGGER_PRINTF_LINE_WIDTH) ?
                                    result : (LOGGER_PRINTF_LINE_WIDTH);
        }

        memcpy(printBuf, bufPtr, copyLen);
        printBuf[copyLen] = '\r';
        printBuf[copyLen + 1] = '\n';
        printBuf[copyLen + 2] = '\0';

        result -= copyLen;
        bufPtr += copyLen;
        if ( bufPtr[0] == '\n' )
        {
            bufPtr++;
            result--;
        }

        if (RCC_TELNET_SocketIsNowWritable(pCliEnv) == FALSE)
        {
            /* If the send-q on this socket is full (user does a ctrl + ] on the
             * telnet client where the logger is printing, the telnet client 
             * does not send a ack back), vxworks send() called by writer() 
             * blocks. This means the debug event collector task will get 
             * blocked and it will stop writing to all other telnet sessions.
             * Use a select() call on the socket of this telnet session to see
             * if it is a writable socket. If select() times out, the socket
             * is not ready for a write.
             */
            PRINTSEM_UNLOCK(pCliEnv);
            return ERROR;
        }

        if ( Writer(pCliEnv, printBuf, copyLen + 2 ) < 0 ) {
            PRINTSEM_UNLOCK(pCliEnv);
            return ERROR;
        }
    }

    PRINTSEM_UNLOCK(pCliEnv);
    return OK;
}

/*
 *  Convert from router name string to virtual router ID to identify
 *  router context. Searched entries int the vRtrTable of ESAS-VRTR-MIB.
 *
 *      Input   ->routerName
 *
 *      Output  virtual router id
 *              or 0 if no match is found
 */
PUBLIC tUint32 getVRtrId(cli_env *pCliEnv, const char *routerName)
{
    RLSTATUS    status;
    SIA_ESAS_VRTR_ENTRY vRtrEntry;

    status = siaEsasVRtrEntryGet(SIA_FIRST_VALUE, &vRtrEntry);
    while(status == OK)
    {
        if ( 0 == strcmp(vRtrEntry.vRtrName, routerName))
            return(vRtrEntry.vRtrID);
        status = siaEsasVRtrEntryGet(SIA_NEXT_VALUE, &vRtrEntry);
    }
    if(status == SIA_RESOURCE_UNAVAILABLE)
        cliErrorMesg(pCliEnv, "Resources busy - try again later");
    else
        cliErrorMesg(pCliEnv, "Invalid router name: %s", routerName);
    return(0);
}

PUBLIC void strToRtrName (const char *Str, rtrStrType type, char *Name, tInt32 NameSize)
{  
    Name[0] = '\0';
    if (type == RTR_SVC_ID)
    {
        tServId servId=0;

        if (cliParseServId(NULL, Str, &servId) == OK)
            snprintf (Name, NameSize, "%s%d", SVC_VPRN_RTR_NAME_PREFIX, servId);
    }
    else if (type == RTR_NAME)
    {
        strlcpy (Name, Str, NameSize);
    }
    else
    {
        ASSERT (0);
    }

    return;
}

PUBLIC void strToAnyRtrName (const char *Str, rtrStrType type, char *Name, tInt32 NameSize)
{  
    Name[0] = '\0';
    if (type == RTR_SVC_ID)
    {
        tServId servId=0;

        if (cliParseServId(NULL, Str, &servId) == OK) {
            tSIA_SVC_BASE_INFO_ENTRY entry;
            entry.svcId = servId;
            if (siaSvcBaseInfoEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                if (entry.svcType == VAL_svcType_vprn)
                    snprintf (Name, NameSize, "%s%d", SVC_VPRN_RTR_NAME_PREFIX, servId);
                else if (entry.svcType == VAL_svcType_ies)
                    snprintf (Name, NameSize, DEF_VR_NAME);
            }
        }
    }
    else if (type == RTR_NAME)
    {
        strlcpy (Name, Str, NameSize);
    }
    else
    {
        ASSERT (0);
    }

    return;
}

PUBLIC tInt32 strToRtrId (const char *Str, rtrStrType type)
{
    char    buf [SIA_TIMETRA_NAME_LEN + 1];
    tUint32  vRtrID;

    strToRtrName (Str, type, buf, sizeof (buf));

    vRtrID = pipDbObjIdGet (buf);

    if (vRtrID != 0)
        return vRtrID;
    else
        return ERROR;
}

PUBLIC tInt32 rtrIdToSvcId(tInt32 vRtrId)
{
    SIA_ESAS_VRTR_ENTRY vRtrEntry;

    ZERO_STRUCT(vRtrEntry);

    vRtrEntry.vRtrID = vRtrId;

    siaEsasVRtrEntryGet(SIA_EXACT_VALUE, &vRtrEntry);

    /* Svc Id is 0 if the get doesnt succeed */
    return vRtrEntry.vRtrServiceId;
}

PUBLIC void rtrIdGetName(tInt32 vRtrId, char *vRtrName)
{
    SIA_ESAS_VRTR_ENTRY vRtrEntry;

    ZERO_STRUCT(vRtrEntry);

    vRtrEntry.vRtrID = vRtrId;

    siaEsasVRtrEntryGet(SIA_EXACT_VALUE, &vRtrEntry);

    strlcpy (vRtrName, vRtrEntry.vRtrName, sizeof(vRtrEntry.vRtrName));

    return;
}

PUBLIC tInt32 svcIdToRtrId(tInt32 svcId)
{
    tSIA_SVC_BASE_INFO_ENTRY entry;

    ZERO_STRUCT(entry);

    entry.svcId = svcId;

    siaSvcBaseInfoEntryGet(SIA_EXACT_VALUE, &entry);

    /* Svc Id is 0 if the get doesnt succeed */
    return entry.svcVRouterId;
}

/*
 *  snmpRowExists
 *
 *      Input:  ->oidString
 *
 *      Output: TRUE = row exists
 *              FALSE = row does not exist
 *
 */
PUBLIC tBoolean snmpRowExists(cli_env *pCliEnv, sbyte *oidString)
{
    RLSTATUS    status;
    sbyte      *pOutputBuf;
    Length      outputLen;
    tUint32     viewContext = CONTEXT_NULL;

    if (RCC_DB_IsConfigLiCommand(pCliEnv))
        viewContext = CONTEXT_LI;

    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignGetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignSetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
    }
    pOutputBuf = (sbyte*)RC_MALLOC( kOUTPUT_BUFFER_SIZE );
    if ( NULL == pOutputBuf ) 
    {
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        return FALSE;
    }

    /* See if a row entry exists for this oidString */
    status = RCC_RCB_ReadValueFromRCB(pCliEnv, oidString, NULL, pOutputBuf,
                                            &outputLen );
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, "");
        OCSNMP_AssignGetCommunityString(pCliEnv, "");
        OCSNMP_AssignSetCommunityString(pCliEnv, "");
    }
    if ( OK == status )
    {
        if (outputLen == 0 || 0 == strcmp(pOutputBuf, "Bad Type."))
        {
            /* Row does not exist */
            RC_FREE( pOutputBuf );
            return FALSE;
        }
        else
        {
            RC_FREE( pOutputBuf );
            return(TRUE);
        }
    }
    else
    {
        cliErrorMesg(pCliEnv, "Could not get entry for \"%s\"", oidString);
        RC_FREE( pOutputBuf );
        return(FALSE);
    }
}

/* this util creates (and commits) a row given an oidstring
 * note that return values are a little different
 * returns 0 if row already existed
 * returns 1 if row successfully created
 * returns FAIL is unsuccessful
 * a normal check on status < OK for failure should work
 * for create mode prompt, further check on status == 0 or > 0
 */

tInt32
createSnmpRow(cli_env *pCliEnv, sbyte *oidBuf)
{
    tUint32 viewContext = CONTEXT_NULL;

    if (RCC_DB_IsConfigLiCommand(pCliEnv))
        viewContext = CONTEXT_LI;

    /* does this statement already exist? */
    if (snmpRowExists(pCliEnv, oidBuf))
        return 0;

    /* Disable SNMP (delayed) automatic set */
    RCC_CMD_Snmp_Auto(pCliEnv);
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignGetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignSetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
    }

    /* else create a new row entry using createAndGo*/
    if (OK > RCC_RCB_WriteValueToRCB(pCliEnv, oidBuf, NULL, "4"))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Force the SNMP set now */
    if (OK > RCC_CMD_Snmp_Commit(pCliEnv))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Enable SNMP (delayed) automatic set */
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, "");
        OCSNMP_AssignGetCommunityString(pCliEnv, "");
        OCSNMP_AssignSetCommunityString(pCliEnv, "");
    }
    RCC_CMD_Snmp_Auto(pCliEnv);
    return 1;
}

/* this util deletes a row
 * returns 0 if the row didnt exist - to allow warnings
 * returns 1 on success
 * returns FAIL on failure
 */

tInt32
deleteSnmpRow(cli_env *pCliEnv, sbyte *oidBuf)
{
    tUint32 viewContext = CONTEXT_NULL;

    if (RCC_DB_IsConfigLiCommand(pCliEnv))
        viewContext = CONTEXT_LI;

    /* does this statement really exist? */
    if (!snmpRowExists(pCliEnv, oidBuf))
        return 0;

    /* Disable SNMP (delayed) automatic set */
    RCC_CMD_Snmp_Auto(pCliEnv);
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignGetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignSetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
    }

    /* else delete the row entry using destroy */
    if (OK > RCC_RCB_WriteValueToRCB(pCliEnv, oidBuf, NULL, "6"))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Force the SNMP set now */
    if (OK > RCC_CMD_Snmp_Commit(pCliEnv))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Enable SNMP (delayed) automatic set */
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, "");
        OCSNMP_AssignGetCommunityString(pCliEnv, "");
        OCSNMP_AssignSetCommunityString(pCliEnv, "");
    }
    RCC_CMD_Snmp_Auto(pCliEnv);
    return 1;
}

/* Set the value of the object idenfied by 'oidBuf' to 'value'*/
tInt32
setSnmpObjectNow(cli_env *pCliEnv, sbyte *oidBuf, sbyte *args, 
                 sbyte *value)
{
    tUint32 viewContext = CONTEXT_NULL;

    if (RCC_DB_IsConfigLiCommand(pCliEnv))
        viewContext = CONTEXT_LI;

    /* Disable SNMP (delayed) automatic set */
    RCC_CMD_Snmp_Auto(pCliEnv);
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignGetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
        OCSNMP_AssignSetCommunityString(pCliEnv, TIMOS_RCC_LI_COMMUNITY_STRING);
    }

    /* else create a new row entry using createAndGo*/
    if (OK > RCC_RCB_WriteValueToRCB(pCliEnv, oidBuf, args, value))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Force the SNMP set now */
    if (OK > RCC_CMD_Snmp_Commit(pCliEnv))
    {
        /* Enable SNMP (delayed) automatic set */
        if (viewContext == CONTEXT_LI) {
            //OCSNMP_SetCommunityString(pCliEnv, "");
            OCSNMP_AssignGetCommunityString(pCliEnv, "");
            OCSNMP_AssignSetCommunityString(pCliEnv, "");
        }
        RCC_CMD_Snmp_Auto(pCliEnv);
        return FAIL;
    }
    /* Enable SNMP (delayed) automatic set */
    if (viewContext == CONTEXT_LI) {
        //OCSNMP_SetCommunityString(pCliEnv, "");
        OCSNMP_AssignGetCommunityString(pCliEnv, "");
        OCSNMP_AssignSetCommunityString(pCliEnv, "");
    }
    RCC_CMD_Snmp_Auto(pCliEnv);
    return OK;    
}


/* This function converts an ip prefix and mask length string into its
 * constituent parts.
 */
tStatus
getPrefixAndLenFromString(const sbyte *prefixAndLen, sbyte *prefix, sbyte4 prefixLen,
                          sbyte *len, sbyte4 lenLen)
{
    /* validation of the string is done in a custom validator */
    tUint32 a, b, c, d, e;

    sscanf(prefixAndLen, "%u.%u.%u.%u/%u", &a, &b, &c, &d, &e);
    snprintf(prefix, prefixLen, "%u.%u.%u.%u", a, b, c, d);
    snprintf(len, lenLen, "%u", e);
    return OK;
}

/* This function converts an as number and ip address string into its
 * constituent parts.
 */
tStatus
getAsNoAndIpFromString(const sbyte *asNoAndIp, sbyte *asNo, sbyte4 asNoLen,
                       sbyte *ip, sbyte4 ipLen)
{

    // validation of the string is done in a custom validator
    tUint32 a1, b, c, d, e;

    #if 0
    //Disabled as we support ASPLAIN notation only
    //Needs to be enabled for ASDOT notation

    count = sscanf(asNoAndIp, "%u.%u:%u.%u.%u.%u", &a1, &a2, &b, &c, &d, &e);
    
    if (count == 6)
    {
        a1 = (a1 << 16) | a2;        
    }
    else
    {
    #endif

    sscanf(asNoAndIp, "%u:%u.%u.%u.%u", &a1, &b, &c, &d, &e);
    
    if ( (a1 == 0) || ((b ==0) && (c==0) && (d==0) && (e==0)) )
        return (FAIL);        

    snprintf(asNo, asNoLen, "%u", a1);
    snprintf(ip, ipLen, "%u.%u.%u.%u", b, c, d, e);
    return OK;
}

/* this utility creates a valid (explicit) SNMP index from a string
 * i.e. length.ascii(char).ascii(char)... if 'implied' is FALSE &
 * .ascii(char).ascii(char)...            if 'implied' is TRUE (without length)
 * Note: in the second case the index starts with a "."
 */
tStatus getStringIndex(const char *string, char *index, tInt32 indexLen,
                       tBoolean implied)
{
    tInt32 i = 0, len = 0;

    if (index == NULL)
        return ERROR;

    *index = 0;

    if(!implied)
        len += snprintf(index, indexLen, "%zd", strlen(string));
    for(i = 0; ((i < strlen(string)) && (indexLen > len)); i++)
    {
        len += snprintf(index + len, indexLen - len, ".%d", string[i]);
    }
    return OK;
}

/* This utility will use the tableIdxRange and a SIA Structure to build the 
 * index string for RCB calls
 */
const char * buildRCBIndexString(const char   *objectName,
                         struct tAgentInfo    *pAgentInfo,    // Index information for a specific table
                         void                 *pInfo,         // STRUCT_<entry> pointer
                         char                 *string,
                         tUint32               stringSize)
{
    SIA_OIDC_T tlist[SIA_MAX_OID_LEN] = { 0 };
    int        cur_element            = 0;
    int        num_elements           = 0;
    int        string_length          = 0;

    num_elements = trapperSIAtoOID(pAgentInfo->numIdx, pAgentInfo->pIdx,
                                   NELEMENTS(tlist), tlist, pInfo);

    string_length = snprintf(string, stringSize, "%s", objectName);
    for (cur_element = 0; cur_element < num_elements; cur_element++)
    {
        string_length += snprintf(string + string_length, stringSize - string_length,
                                  ".%u", tlist[cur_element]);
    }
    return string;
}

/* This utility is used in conjunction with buildRCBIndexString to easily swap 
 * object names but maintain the same 'index'. This is used in 'multi-varbind' 
 * CLI commands.
 */
const char * buildRCBIndexSwapObjectName(const char * newObjectName,
                                     char * string,
                                     tUint32 stringSize)
{
    if (!string)
        return NULL;

    char   tmpStr[OID_BUF_SIZE] = { 0 };
    char * index_string         = strchr(string, '.');
    if (!*string)
        strlcpy(string, "OBJECT_NOT_INITIALIZED", stringSize);
    else {
        if (index_string)
        {
            snprintf(tmpStr, sizeof(tmpStr), "%s", index_string);
        }
        snprintf(string, stringSize, "%s%s", newObjectName, tmpStr);
    }
    return string;
}
                                 


//
// Convert hex string into byte array
//
unsigned char* cnvHexStrToBytes(const char *pSrc, int cbSrc, tUint8 *pDst, tUint32 *cbDst)
{
    unsigned int   i;
    const char     *p = pSrc;
    unsigned int   digit;
    
    if (*cbDst < cbSrc / 2) {
        *cbDst = 0;
        return NULL;
    }

    *cbDst = cbSrc / 2;
    for (i = 0; i < *cbDst; i++, p+=2) {
        sscanf(p, "%02x", &digit);
        pDst[i] = (tUint8) (digit & 0xff);
    }
    
    return pDst;
} // cnvHexStrToBytes

//
// Convert hex string into a valid SNMP index
//
tStatus getHexStringIndex(const char *pHexStr, char *pIndex, tInt32 indexLen)
{
    tUint8  byBuf[64];
    tUint32 cbBuf = sizeof(byBuf), i = 0, len = 0;

    // exit if no index buffer provided
    if (pIndex == NULL)
        return ERROR;

    *pIndex = 0;

    // exit if bad hex string
    if (!cnvHexStrToBytes(pHexStr, strlen(pHexStr), byBuf, &cbBuf)) 
        return ERROR;
        
    for (i = 0; ((i < cbBuf) && (indexLen > len)); i++)
        len += snprintf(pIndex + len, indexLen - len, ".%d", byBuf[i]);

    return OK;
} // getHexStringIndex


PUBLIC tStatus cliParseCustId(cli_env *pCliEnv, const char *CustId,
                                tCustId *pCustId)
{
    if (pCustId == NULL)
        return ERROR;

    if (CustId) {
        if (strToUint32(CustId, pCustId) != OK) {
            cliErrorMesg(pCliEnv, "Syntax error in argument \"%s\"", CustId);
            return ERROR;
        }
    } else {
        *pCustId = NULL_CUST_ID;
    }

    return OK;
}

/*
 * Convert the cli input (= the string the user entered) to a service-id.
 * If the user entered the service-name, we still return the corresponding
 * (numerical) serviceID. 
 */
PUBLIC tStatus cliParseServId(cli_env *pCliEnv, const char *ServId,
                                tServId *pServId)
{
    if (pServId == NULL) {
        return ERROR;
    }

    if (ServId) {
        if (strToUint32(ServId, pServId) != OK) {
            STRUCT_svcNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.svcName, ServId, strlen(ServId));
            if (sia_svcNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pServId = entry.svcNameId;
                return OK;
            }
            if (pCliEnv)
                cliErrorMesg(pCliEnv, "Invalid service-id \"%s\"", ServId);
            return ERROR;
        }
    } else {
        *pServId = NULL_SERV_ID;
    }

    return OK;
}


PUBLIC tStatus cliParseVpnId(cli_env *pCliEnv, const char *VpnId,
                                tVpnId *pVpnId)
{
    if (pVpnId == NULL)
        return ERROR;

    if (VpnId) {
        if (strToUint32(VpnId, pVpnId) != OK) {
            cliErrorMesg(pCliEnv, "Syntax error in argument \"%s\"", VpnId);
            return ERROR;
        }
    } else {
        *pVpnId = NULL_VPN_ID;
    }

    return OK;
}


PUBLIC tStatus cliParseSapId(cli_env *pCliEnv, const char *SapId,
                             tPortId *pPortId, tUint32 *pEncapValue)
{
    if (strToSapIdCliEnv(pCliEnv, SapId, pPortId, pEncapValue) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "SAP-id has an invalid port number or encapsulation value");
        return ERROR;
    }

    return OK;
}


PUBLIC tStatus cliParseSdpId(cli_env *pCliEnv, const char *SdpId,
                               tSdpId *pSdpId)
{
    if (pSdpId == NULL)
        return ERROR;

    if (SdpId) {
        if (strToUint16(SdpId, pSdpId) != OK) {
            cliErrorMesg(pCliEnv, "Syntax error in argument \"%s\"", SdpId);
            return ERROR;
        }
    } else {
        *pSdpId = NULL_SDP_ID;
    }

    return OK;
}


PUBLIC tStatus cliParseMacAddr(cli_env *pCliEnv, const char *MacAddr,
                                 tMacAddr *pMacAddr)
{
    if (pMacAddr == NULL)
        return ERROR;

    if (MacAddr) {
        if (strToMacAddr(MacAddr, pMacAddr) != OK) {
            cliErrorMesg(pCliEnv, "Syntax error in argument \"%s\"", MacAddr);
            return ERROR;
        }
    } else {
        memset(pMacAddr, 0, sizeof (tMacAddr));
    }

    return OK;
}

PUBLIC tStatus cliParseMacAddrToStr(cli_env *pCliEnv, const char *MacAddr,
                                 sbyte *pMacAddrStr)
{
    tMacAddr  pMacAddr;
    int       tMacAddrLen = sizeof(tMacAddr);


    if (pMacAddrStr == NULL)
        return ERROR;

    if (MacAddr) {
        if (strToMacAddr(MacAddr, &pMacAddr) != OK) {
            cliErrorMesg(pCliEnv, "Syntax error in argument \"%s\"", MacAddr);
            return ERROR;
        }
        memcpy(pMacAddrStr, &pMacAddr, tMacAddrLen);
        pMacAddrStr[tMacAddrLen] = 0;
    } else {
        memset(pMacAddrStr, 0, tMacAddrLen + 1);
    }

    return OK;
}

PUBLIC tStatus
cliParseHex(const char *pParam, tUint32 *retValue)
{

    tInt32   length;
    tUint32  val;
    char    *tempParam = (char *) pParam;


    if(NULL == pParam)
        return FAIL;

    length = strlen(pParam);

    if(length > PREFIX_DIGITS + (sizeof(tUint32) * 2))
        return FAIL;

    if(!memcmp(tempParam, "0x", PREFIX_DIGITS))
       tempParam = tempParam + PREFIX_DIGITS;
    else
        return FAIL;

    *retValue = 0;
    while(*tempParam != '\0')
    {
        if ( !( (*tempParam <= '9' && *tempParam >= '0') ||
                (*tempParam <= 'f' && *tempParam >= 'a') ||
                (*tempParam <= 'F' && *tempParam >= 'A') ) )
            return FAIL;

        val = 0;
        switch(*tempParam)
            {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                val = *tempParam - '0';
                (*retValue) = (*retValue) << 4;
                (*retValue) |= val;
                break;

            case 'a':
            case 'b':
            case 'c':
            case 'd':
            case 'e':
            case 'f':
                val = *tempParam - 'a' + 10;
                (*retValue) = (*retValue) << 4;
                (*retValue) |= val;
                break;

            case 'A' :
            case 'B':
            case 'C':
            case 'D':
            case 'E':
            case 'F':
                val = *tempParam - 'A' + 10;
                (*retValue) = (*retValue) << 4;
                (*retValue) |= val;
                break;

            default :
                break;
        }

        tempParam++;
    }

    return OK;
}

PUBLIC tStatus
cliParseHexString(const unsigned char *input, tUint8 *output, tUint32 outputMaxLen, tUint32 *outputLen)
{
    int i = 2;
    int j = 0;
    tUint32 maxLenInput = (outputMaxLen * 2) + 2; /* the input string must contain at most (2 * number of bytes in output buffer) hex values + '0x'*/

    if ((!input) || (!output) || (!outputLen))
    {
        return ERROR;
    }
    *outputLen = 0;
    output[0]  = '0';  

    /* a string must be present, and be a string with format 0xa1a2a3... */
    /* Note: "0x" is a valid input string, it returns outputLen = 0 */
    if ((strlen(input) < 2) ||
        (input[0] != '0') ||
        (input[1] != 'x') ||
        (strlen(input) > maxLenInput) )
    {
        return ERROR;
    }

    /* the parameter does not need to contain an even number of digits */
    if ((strlen(input) % 2) != 0)
    {
        tUint32 val;
        if (sscanf(&input[i], "%1x", &val) != 1)
        {
            return ERROR;
        }
        output[j] = val;
        i++;
        j++;
    }

    for(; i <= (strlen(input) - 2) ; i += 2, j++)
    {
        tUint32 val;
        if (sscanf(&input[i], "%1x", &val) != 1)
        {
            return ERROR;
        }
        output[j] = (val << 4);
        if (sscanf(&input[i+1], "%1x", &val) != 1)
        {
            return ERROR;
        }
        output[j] |= val;
    }

    *outputLen = j;
    return OK;
}

PUBLIC tStatus
cliParseBinary(const char *pParam, tUint32 *retValue)
{

    tInt32 length;
    char *tempParam = (char *) pParam;

    if(NULL == pParam)
        return FAIL;

    length = strlen(pParam);

    if(length <= PREFIX_DIGITS || length > PREFIX_DIGITS + (sizeof(tUint32) * 8) )
        return FAIL;

    if(!memcmp(tempParam, "0b", PREFIX_DIGITS))
        tempParam = tempParam + PREFIX_DIGITS;
    else
        return FAIL;


    *retValue = 0;
    while(*tempParam != '\0')
    {
        if(*tempParam != '0' && *tempParam != '1')
            return FAIL;
        (*retValue) = (*retValue) << 1;
        if(*tempParam == '1')
            (*retValue |= 0x00000001);
        tempParam++;
    }

    return OK;

}

PUBLIC tStatus
cliParseDecimal(const char *pParam, tUint32 *retValue)
{
    char *tempParam = (char *) pParam;
    tStatus s;

    if(NULL == pParam)
        return FAIL;

    while(*tempParam != '\0')
    {
        if(*tempParam > '9' || *tempParam < '0')
            return FAIL;
        tempParam++;
    }

    // Validated, Now Parse.
    s = strToUint32(pParam, retValue);

    return s;
}

PUBLIC tStatus
cliParseHexOrBinary(const char *pParam, tUint32 *retValue)
{

    if(OK != cliParseHex(pParam, retValue))
        if(OK != cliParseBinary(pParam, retValue))
            return FAIL;

    return OK;
}

PUBLIC tStatus
cliParseHexOrDecimal(const char *pParam, tUint32 *retValue)
{

    if(OK != cliParseHex(pParam, retValue))
        if(OK != cliParseDecimal(pParam, retValue))
            return FAIL;

    return OK;
}

PUBLIC tStatus
cliParseHexOrBinaryOrDecimal(const char *pParam, tUint32 *retValue)
{
    if(OK != cliParseHex(pParam, retValue))
        if(OK != cliParseDecimal(pParam, retValue))
            if(OK != cliParseBinary(pParam, retValue))
                return FAIL;

    return OK;
}

////////////////////////////////////////////////////////////////////////////////
// Parse a string containing
//   <numericSet> | "all", where
//   <numericSet> == <i|j-k> {,i|j-k}*   (with i>=0, j>=0, and k>=0).
// For example, parse "3,0,5-7,9-15,33", where  "5-7" specifies 5,6,7.
// Return SUCCESS if the string is syntactically valid, and all the elements are
// in the range lowerBound..upperBound inclusive.  When SUCCESS is returned, the 
// set is encoded in bitMap, in SNMP BITS format.
////////////////////////////////////////////////////////////////////////////////
tStatus cliParseNumericSet (char *str, tUint32 lowerBound, tUint32 upperBound,
                            tUint8 *bitMap, tUint32 sizeofBitMap)
{
    tUint32 loopGuard = 0;
    char *strPos = str;

    if (str == NULL) {
        TRACE_ERROR(MOD_CLI, CFG, "str is NULL");
        return FAIL;
    }

    if (bitMap == NULL) {
        TRACE_ERROR(MOD_CLI, CFG, "bitMap = NULL.  sizeofBitMap = %u.  str=\"%s\"", sizeofBitMap, str);
        return FAIL;
    }

    if (str[0] == 0)
        // The empty string is not syntactically valid.
        return FAIL;

    // bitMap must have enough bytes to allow the upperBound bit to be set.
    if (sizeofBitMap < (upperBound/8 + 1)) {
        TRACE_ERROR(MOD_CLI, CFG, "bitMap is too small:  %u %u \"%s\"", sizeofBitMap, upperBound, str);
        return FAIL;
    }

    if (lowerBound > upperBound) {
        // The caller has lost track of the (normally compile-time) 
        // lowest-numbered and/or highest-numbered bit allowed in the bitMap.
        TRACE_ERROR(MOD_CLI, CFG, "lowerBound (%u) is greater than upperBound (%u).  str = \"%s\"", lowerBound, upperBound, str);
        return FAIL;
    }

    bzero(bitMap, sizeofBitMap);

    if (strcmp(str, "all") == 0) {
        return agentSetRangeOfBits(lowerBound, upperBound, lowerBound, upperBound, bitMap, sizeofBitMap);
    }

    // Parse "3,0,5-7,9-15,33"
    // The loop is intended to run once, plus once for each comma in the string.  
    // Use a loop guard to avoid an infinite loop should the expected loop exit 
    // fail.
    for (loopGuard = lowerBound; loopGuard <= upperBound; loopGuard++) { 
        tInt32 count = 0;
        tUint32 lower = 0;
        tUint32 upper = 0;
        char hyphenChar = 0;
        char trailingChar = 0;
        char *posComma = strchr(strPos, ',');

        // Null-terminate the string at the next comma, if any.
        if (posComma != NULL) 
            *posComma = NULL;

        // The sscanf includes trailingChar to detect unwanted trailing 
        // characters (e.g. the 'q' in "11-13q").
        count = sscanf (strPos, "%u%c%u%c", &lower, &hyphenChar, &upper, &trailingChar);
        // Note the following quirk:  the sscanf() call above will happily 
        // accept strPos="-3" (or other negative numbers).  That yields count==1 
        // and lower==4294967293.  That will be rejected by a subsequent range 
        // check on 'lower'.  Similarly, 'upper'.

        if (posComma != NULL)
            // Put the comma back, to ensure the input value (str) is not 
            // permanently changed by this function.
            *posComma = ',';

        switch (count) {
        case 1:   
            if (agentSetRangeOfBits(lower, lower, lowerBound, upperBound, bitMap, sizeofBitMap) == SUCCESS)
                // Accepted  "11" (for example)
                break;
            return FAIL; 
        case 3:  
            if (hyphenChar == '-') 
                if (agentSetRangeOfBits(lower, upper, lowerBound, upperBound, bitMap, sizeofBitMap) == SUCCESS)
                    // Accepted  "11-13" (for example)
                    break;
            return FAIL;
        default:
            // Includes count == 0:  the first %u could not be read.
            // Includes count == 2:  e.g. "11-".
            // Includes count == 4:  e.g. "11-13q".
            return FAIL;
        }

        if (posComma == NULL) 
            // Successfully parsed all of str.
            return SUCCESS;

        // The following assignment is safe because posComma currently points 
        // within the body of str.  So, in the worst case, after the assignment, 
        // strPos points at the original null termination of str.
        strPos = posComma + 1; 
    }

    // The loop guard expired.  Example occurrence:  the user entered 
    // "0,0,1,2,3,4,5,6,7" to fill an 8-bit bitmap.
    TRACE_EVENT(MOD_CLI, CFG, "Loop guard expired.  str=\"%s\".  lowerBound=%u.  upperBound=%u", str, lowerBound, upperBound);
    return FAIL;
}

///////////////////////////////////////////////////////////////////////////////
// For example, assume the caller provides lowestBitNum=0, highestBitNum=33,
// and a bitMap (in SNMP BITS format) with the following bits set:  0,1,2,33.
// Result:  "0-2,33" is copied into numericSetStr.
///////////////////////////////////////////////////////////////////////////////
tStatus cliFormatNumericSet(tUint32 lowestBitNum, tUint32 highestBitNum, 
                         tUint8 *bitMap, char *numericSetStr, tUint32 sizeofNumericSetStr)
{
    const tUint32 INVALID_BIT_NUM = 4294967295ULL;
    tUint32 bitNum     = lowestBitNum;
    tUint32 lowBitNum  = INVALID_BIT_NUM;
    tUint32 highBitNum = INVALID_BIT_NUM;
    int strLen = 0;
    tBoolean bitSet = FALSE;

    if ((bitMap == NULL) || (numericSetStr == NULL) || (sizeofNumericSetStr == 0))
        return FAIL;

    numericSetStr[0] = 0;
    
    for (bitNum = lowestBitNum; bitNum <= highestBitNum; bitNum++)
    {
        bitSet = TST_SNMP_BIT(bitMap, bitNum);

        if (bitSet)
        {
            if (lowBitNum == INVALID_BIT_NUM)
                lowBitNum  = bitNum;
            else
                highBitNum = bitNum;
        }

        if ((bitSet == FALSE) || (bitNum == highestBitNum))
        {
            if (lowBitNum != INVALID_BIT_NUM)
            {
                if (highBitNum == INVALID_BIT_NUM)
                    strLen += snprintf(numericSetStr + strLen, sizeofNumericSetStr - strLen, "%u,", lowBitNum);
                else
                    strLen += snprintf(numericSetStr + strLen, sizeofNumericSetStr - strLen, "%u-%u,", lowBitNum, highBitNum);

                // In the buffer overflow case, snprintf() returns the number of 
                // characters which would have been written, if space had been 
                // available.
                if (strLen >= sizeofNumericSetStr)
                    return FAIL;
            }

            lowBitNum  = INVALID_BIT_NUM;
            highBitNum = INVALID_BIT_NUM;
        }
    } 

    if (strLen > 0)
        numericSetStr[strLen-1] = 0; // Remove the trailing ','

    return SUCCESS;
}

/**************************************************************************
* DNS Stuff
***************************************************************************/

#define NI_MAXHOST 1025

typedef struct
{
    tUint8             useCount;
    char               dnsNameBuf[NI_MAXHOST];
    tTimNetAddr        dnsIpAddr;
    tResolveProtocol   protocol;
    tResolveOptions    options;
    tUint32            vRtrId;
    tResolveResult     result;
    tBoolean           resolved;
    struct __res_state resolverBuffer;
} tdnsLookupEntry;


PRIVATE tdnsLookupEntry *dnsGetLookupEntry(const char            *dnsName,
                                           const tTimNetAddr     *pAddr,
                                           tResolveProtocol       protocol,
                                           const tResolveOptions *pOptions,
                                           tUint32               *pVRtrId)
{
    tdnsLookupEntry     *pEntry;
    pEntry = (tdnsLookupEntry *) RC_MALLOC(sizeof(*pEntry));
    if (pEntry != NULL)
    {
        pEntry->useCount = 2;
        if (dnsName == NULL)
        {
            dnsName = "";
        }
        snprintf(pEntry->dnsNameBuf, sizeof(pEntry->dnsNameBuf), "%s", dnsName);
        if (pAddr == NULL)
        {
            TIM_NET_ADDR_INIT(&pEntry->dnsIpAddr, TRUE);
        }
        else
        {
            TIM_NET_ADDR_COPY(&pEntry->dnsIpAddr, pAddr);
        }
        pEntry->protocol = protocol;
        pEntry->vRtrId = pVRtrId ? *pVRtrId : RESOLVE_ANY_VRTR;
        resolvePrepareOptions(pOptions, &pEntry->options, &pEntry->resolverBuffer, pEntry->vRtrId);
        pEntry->result = eResolveInterrupted;
        pEntry->resolved = FALSE;
    }
    return pEntry;
}


PRIVATE void dnsReturnLookupEntry(tdnsLookupEntry *pEntry)
{
    semTake(dnsLookupMutex, WAIT_FOREVER);
    if (--pEntry->useCount == 0)
    {
        RC_FREE(pEntry);
    }
    semGive (dnsLookupMutex);
}


PRIVATE void dnsNameToTimNetAddr(void              *pCookie,
                                 const char        *addressString,
                                 tResolveResult     result,
                                 const tResolveTimNetAddrs *pAddrs,
                                 tUint32            vRtrId)
{
    tdnsLookupEntry        *pEntry = (tdnsLookupEntry *)pCookie;
    if (pEntry != NULL)
    {
        if (pAddrs == NULL)
        {
            TIM_NET_ADDR_INIT(&pEntry->dnsIpAddr, TRUE);
        }
        else
        {
            TIM_NET_ADDR_COPY(&pEntry->dnsIpAddr, &pAddrs->addr[0]);
        }
        pEntry->result = result;
        pEntry->vRtrId = vRtrId;
        /* should be the last action on the entry */
        pEntry->resolved = TRUE;
        dnsReturnLookupEntry(pEntry);
    }
}


PRIVATE void dnsTimNetAddrToName(void              *pCookie,
                                 const tTimNetAddr *pAddr,
                                 tResolveResult     result,
                                 const char        *name)
{
    tdnsLookupEntry        *pEntry = (tdnsLookupEntry *)pCookie;
    if (pEntry != NULL)
    {
        if (name == NULL)
        {
            name = "";
        }
        snprintf(pEntry->dnsNameBuf, sizeof(pEntry->dnsNameBuf), "%s", name);
        pEntry->result = result;
        /* should be the last action on the entry */
        pEntry->resolved = TRUE;
        dnsReturnLookupEntry(pEntry);
    }
}


/**************************************************************************
* Name: resolveNameToTimNetAddrWithBreak
*
*
***************************************************************************/
tResolveResult resolveNameToTimNetAddrWithBreak(const char               *name,
                                                tTimNetAddr              *pAddr,
                                                tResolveProtocol          protocol,
                                                tUint32                  *pVRtrId,
                                                const tResolveOptions    *pOptions,
                                                cli_env                  *pCliEnv)
{
    tdnsLookupEntry *pEntry = NULL;
    tResolveResult   result = eResolveInterrupted;
    tBoolean         allOk = 0;
    pEntry = dnsGetLookupEntry(name, NULL, protocol, pOptions, pVRtrId);
    if (pEntry != NULL)
    {
        if (resolveNameToTimNetAddrAsync(pEntry->dnsNameBuf,
                                         pEntry->protocol,
                                         pEntry->vRtrId,
                                         &pEntry->options,
                                         dnsNameToTimNetAddr,
                                         (void *)pEntry) == SUCCESS) {
            allOk = 1;
        }
        else
        {
            dnsReturnLookupEntry(pEntry);
        }
    }
    while (allOk)
    {
        /* poll for 2 events - 1. DNS resolved, 2. user hit a ^C while lookup is being performed */

        /* event 1. */
        if (pEntry->resolved)
        {
            if (pAddr != NULL) {
                TIM_NET_ADDR_COPY(pAddr, &pEntry->dnsIpAddr);
            }
            if (pVRtrId != NULL) {
                *pVRtrId = pEntry->vRtrId;
            }
            result = pEntry->result;
            break;
        }
        
        /* event 2. */
        if (RCC_Sleep(pCliEnv, 20))
        {
            allOk = 0;
            break;
        }
    }

    if (!allOk)
    {
        if (pAddr != NULL) {
            TIM_NET_ADDR_INIT(pAddr, TRUE);
        }
    }

    if (pEntry != NULL)
    {
        dnsReturnLookupEntry(pEntry);
    }

    return result;
}


/**************************************************************************
* Name: resolveNameToIpAddrWithBreak
*
*
***************************************************************************/
tResolveResult resolveNameToIpAddrWithBreak(const char            *name,
                                            tIpAddr               *pAddr,
                                            tResolveProtocol       protocol,
                                            const tResolveOptions *pOptions,
                                            cli_env               *pCliEnv)
{
    tResolveResult         result;
    tResolveOptions        options;
    tTimNetAddr            timNetAddr;
    resolvePrepareOptions(pOptions, &options, NULL, DEF_VR_INSTANCE);
    options.preference = eResolveIpv4Only;
    result = resolveNameToTimNetAddrWithBreak(name,
                                              &timNetAddr,
                                              protocol,
                                              NULL,
                                              &options,
                                              pCliEnv);
    if (result == eResolveFound)
    {
        TIM_NET_ADDR_GET_V4(*pAddr, &timNetAddr);
    }
    return result;
}


/**************************************************************************
* Name: resolveTimNetAddrToNameWithBreak
*
***************************************************************************/
tResolveResult resolveTimNetAddrToNameWithBreak(const tTimNetAddr       *pAddr,
                                                char                    *name,
                                                size_t                   nameLen,
                                                tUint32                  vRtrId,
                                                const tResolveOptions   *pOptions,
                                                cli_env                 *pCliEnv)
{
    tdnsLookupEntry *pEntry = NULL;
    tResolveResult   result = eResolveInterrupted;
    tBoolean         allOk = 0;
    pEntry = dnsGetLookupEntry(NULL, pAddr, eResolveOther, pOptions, &vRtrId);
    if (pEntry != NULL)
    {
        if (resolveTimNetAddrToNameAsync(&pEntry->dnsIpAddr,
                                         pEntry->dnsNameBuf,
                                         sizeof(pEntry->dnsNameBuf),
                                         pEntry->vRtrId,
                                         &pEntry->options,
                                         dnsTimNetAddrToName,
                                         (void *)pEntry) == SUCCESS) {
            allOk = 1;
        }
        else
        {
            dnsReturnLookupEntry(pEntry);
        }
    }
    while (allOk)
    {
        /* poll for 2 events - 1. DNS resolved, 2. user hit a ^C while lookup is being performed */

        /* event 1. */
        if (pEntry->resolved)
        {
            if (name != NULL) {
                snprintf(name, nameLen, "%s", pEntry->dnsNameBuf);
            }
            result = pEntry->result;
            break;
        }
        
        /* event 2. */
        if (RCC_Sleep(pCliEnv, 20))
        {
            allOk = 0;
            break;
        }
    }

    if (!allOk)
    {
        if ((name != NULL) && (nameLen != 0)) {
            name[0] = '\000';
        }
    }

    if (pEntry != NULL)
    {
        dnsReturnLookupEntry(pEntry);
    }

    return result;
}


/**************************************************************************
* Name: resolveIpAddrToNameWithBreak
*
*
***************************************************************************/
tResolveResult resolveIpAddrToNameWithBreak(tIpAddr                address,
                                            char                  *name,
                                            size_t                 nameLen,
                                            const tResolveOptions *pOptions,
                                            cli_env               *pCliEnv) {
    tTimNetAddr           timNetAddr;
    tResolveResult        result;
    TIM_NET_ADDR_SET_V4(&timNetAddr, address);
    result = resolveTimNetAddrToNameWithBreak(&timNetAddr,
                                              name,
                                              nameLen,
                                              RESOLVE_ANY_VRTR,
                                              pOptions,
                                              pCliEnv);
    return result;
}

PUBLIC void cliPrintDNSResolveResult(cli_env        *pCliEnv,
                                     tResolveResult  resolveResult,
                                     const char     *pDestination,
                                     const char     *pAppName)
{
    switch (resolveResult) {
        case eResolveFound:
        case eResolveIpv4NotAllowed:
        case eResolveIpv6NotAllowed:
            break;
        case eResolveDnsRecordNotFound:
            cliErrorMesg(pCliEnv, "No DNS record found for '%s'", pDestination);
            break;
        case eResolveCouldNotContactDnsServers:
            cliErrorMesg(pCliEnv, "Could not contact any DNS server to resolve '%s'", pDestination);
            break;
        case eResolveLinkLocalInterfaceNotFound:
            cliErrorMesg(pCliEnv, "Link local address '%s' does not exist", pDestination);
            break;
        case eResolveInterrupted:
            cliErrorMesg(pCliEnv, "%s aborted by user", pAppName);
            break;
        case eResolveCouldNotTransmitRequest:
            cliErrorMesg(pCliEnv, "Could not transmit request to resolve '%s'", pDestination);
            break;
        case eResolveUnexpectedResponse:
        case eResolveServerResponseFormErr:
        case eResolveServerResponseServFail:
        case eResolveServerResponseNotImp:
        case eResolveServerResponseRefused:
            cliErrorMesg(pCliEnv, "Unexpected response received from the DNS server when resolving '%s'", pDestination);
            break;
        default:
            cliErrorMesg(pCliEnv, "DNS lookup failed");
            break;
    }
}

/* given <vRtrID, addr> return the vRtrID if reachable,
 * otherwise return 0.
 * if vRtrID is 0, match management VR followed by DEF_VR_INSTANCE
 */

PUBLIC tUint32 cliValidateIp(cli_env *pCliEnv, tUint32 vRtrID, tIpAddr addr)
{
    char buf[PUTILS_BUFFER_40];
    struct sockaddr_in  addr_sin = {0};

    addr_sin.sin_len = sizeof (addr_sin);
    addr_sin.sin_family = AF_INET;
    addr_sin.sin_addr.s_addr = htonl (addr);

    if (!(vRtrID = pipCheckIpReachability(vRtrID, (struct sockaddr *) &addr_sin, 0, 0, FALSE)))
    {
        cliErrorMesg(pCliEnv, "No route to destination \"%s\" or egressing interface not found", FmtIpAddr(addr, buf, sizeof(buf)));
        return 0;
    }
    return vRtrID;
}

PUBLIC tUint32 cliValidateIp6(cli_env *pCliEnv, tUint32 vRtrID, tIp6Addr *pAddr)
{
    struct sockaddr_in6 addr6_sin = {0};

    /* Removed check on runtime_feature_ip6
     * Reason: ipv6 addresses can be valid even if the feature flag is not set.
     *         (e.g. ipv6 addresses on the management itf of 7450).
     * If a check on runtime_feature_ip6 is needed it should be placed at the level of the caller
     * of this function.
     */

    addr6_sin.sin6_len = sizeof(addr6_sin);
    addr6_sin.sin6_family = AF_INET6;
    memcpy(&addr6_sin.sin6_addr, pAddr, sizeof(tIp6Addr));

    if (!(vRtrID = pipCheckIpReachability(vRtrID, (struct sockaddr*)&addr6_sin, 0, 0, FALSE)))
    {
        return 0;
    }
    return vRtrID;
}

PUBLIC tUint32 cliValidateHost(cli_env *pCliEnv, tUint32 vRtrID, char * host, tResolveProtocol protocol)
{
    tSockAddr SockAddr;
    char buf[IP_ADDR_MAX_LEN];
    
    if ( hostGetSockAddr(&SockAddr, host, 0, protocol) == OK )
    {
        if (!(vRtrID = pipCheckIpReachability(vRtrID, (struct sockaddr *) &SockAddr, 0, 0, FALSE))) 
        {
            if (SockAddr.sa.sa_family == AF_INET) 
            {
                FmtIpAddr((tIpAddr)ntohl(SockAddr.sa_in.sin_addr.s_addr), buf, sizeof(buf));
            } 
            else 
            {
                FmtIp6Addr((tIp6Addr *)&SockAddr.sa_in6.sin6_addr, buf, sizeof(buf));
            }
            cliErrorMesg(pCliEnv, "No route to destination \"%s\" or egressing interface not found", buf);
            return 0; 
        }         
    }

    cliErrorMesg(pCliEnv, "Invalid host name: %s", host);
    return 0;

}

PUBLIC tBoolean checkIpAddrLocalOrMgmtPort(tUint32 vrId, tIpAddr ipAddr)
{
    char BootDevAddrStr[PUTILS_BUFFER_40];
    tIpAddr BootDevIpAddr = 0; 
    
    /* Check if the given address is local to the ESR. */
    if (pipIsIpAddrLocal(vrId, ipAddr, FALSE, NULL)) 
        return TRUE;
        
    /* Check if it's mgmr port ip */
    if (ifAddrGet(sysMgmtPortName(), BootDevAddrStr) == OK) {
        if (ipStrToIpAddr(BootDevAddrStr, &BootDevIpAddr) == OK) {
            if ( ipAddr ==  BootDevIpAddr)
                return TRUE;
        }
    }
    return FALSE;
}

PUBLIC tBoolean checkIpAddrLocalOrVRRPOrMgmtPort(tUint32 vrId, tIpAddr ipAddr)
{
    char            BootDevAddrStr[PUTILS_BUFFER_40];
    tIpAddr         BootDevIpAddr = 0; 
    tTimNetAddr     ipAnyAddr;

    /* Check if the given address is local to the ESR. */
    if (pipIsIpAddrLocal(vrId, ipAddr, FALSE, NULL)) 
        return TRUE;
        
    /* Check if it's mgmr port ip */
    if (ifAddrGet(sysMgmtPortName(), BootDevAddrStr) == OK) {
        if (ipStrToIpAddr(BootDevAddrStr, &BootDevIpAddr) == OK) {
            if ( ipAddr ==  BootDevIpAddr)
                return TRUE;
        }
    }

    TIM_NET_ADDR_SET_V4 (&ipAnyAddr, ipAddr);
    if (pipDbAddrIsVRRP(vrId, &ipAnyAddr, NULL) == TRUE)
        return TRUE;

    return FALSE;
}

PUBLIC tBoolean checkIp6AddrLocal(tUint32 vrId, tIp6Addr *pIpAddr,
                                  tUint32 ifIndex)
{
    tTimNetAddr          ipAnyAddr;
    
    TIM_NET_ADDR_SET_V6 (&ipAnyAddr, pIpAddr);
    if (pipDbAddrIsLocal(vrId, ifIndex, &ipAnyAddr, 0, 0, 0, 0) == SUCCESS)
        return TRUE;
        
    return FALSE;
}

PUBLIC tBoolean checkIp6AddrLocalOrMgmtPort(tUint32   vrId, 
                                            tIp6Addr *pIp6Addr,
                                            tUint32   ifIndex)
{
    tTimNetAddr ipAnyAddr;
    char        buffer[sizeof(struct in6_ifreq)*10]; 
    caddr_t     buf     = buffer;
    int         bufLen  = sizeof(struct in6_ifreq)*10;
    char       *mgtItf  = sysMgmtPortName();

    TIM_NET_ADDR_SET_V6 (&ipAnyAddr, pIp6Addr);
    if (pipDbAddrIsLocal(vrId, ifIndex, &ipAnyAddr, 0, 0, 0, 0) == SUCCESS)
        return TRUE;

    /* Removed check on runtime_feature_ip6
     * Reason: ipv6 addresses can be valid even if the feature flag is not set.
     *         (e.g. ipv6 addresses on the management itf of 7450).
     * If a check on runtime_feature_ip6 is needed it should be placed at the level of the caller
     * of this function.
     */
    /* Check if it's mgmt port ip */
    if (ifConf6(mgtItf, buf, &bufLen) == OK)
    {
        struct in6_ifreq *p_in6_ifreq; 
        tIp6Addr         *pIp6AddrMgtItf;
        int               nrOfAddrsOnItf;
        int               i;

        p_in6_ifreq = (struct in6_ifreq *)buf; 
        nrOfAddrsOnItf = bufLen / sizeof(struct in6_ifreq);
    
        for (i=0 ; i < nrOfAddrsOnItf ; i++, p_in6_ifreq++) {

            pIp6AddrMgtItf = (tIp6Addr*)(&p_in6_ifreq->ifr_ifru.ifru_addr.sin6_addr.__u6_addr.__u6_addr8[0]);

            if (netAddrCmp(pIp6Addr, pIp6AddrMgtItf, sizeof(tIp6Addr)) == 0 )
                return TRUE;
            else 
                continue;
        }
    }
    return FALSE;
}    

void
createBlankBuffer(char *buf, tInt32 numSpaces)
{
    memset( buf, ' ', numSpaces );
    buf[numSpaces] = '\0';
    return;
}

PUBLIC char *
FmtPortRange (char *buf, size_t bufLen, tUint32 operator, tInt32 val1,
              tInt32 val2)
{
    switch (operator)
        {
        case OPERATOR_EQ :
            snprintf(buf, bufLen,  "eq %d", val1);
            break;
        case OPERATOR_LT :
            snprintf(buf, bufLen,  "lt %d", val1);
            break;
        case OPERATOR_GT :
            snprintf(buf, bufLen,  "gt %d", val1);
            break;
        case OPERATOR_RANGE :
            snprintf(buf, bufLen,  "%d..%d", val1, val2);
            break;
        default :
            snprintf(buf, bufLen,  "None");
            break;
        }

     return buf;
}

PUBLIC tInt32
strToFrameType(const char *Str)
{

    if ( (NULL == Str) ||
         (strcmp(Str, "802dot3") == 0) )
        return 0;
    else if (strcmp(Str, "802dot2-llc") == 0)
        return 1;
    else if (strcmp(Str, "802dot2-snap") == 0)
        return 2;
    else if (strcmp(Str, "802dot1ag") == 0)
        return 4;
    else if (strcmp(Str, "atm") == 0)
        return 5;
    else if (strcmp(Str, "none") == 0)
        return -1;

    return 3;
}

PUBLIC char *cliFmtSapIdGivenEncapType(tPortId PortId, tInt32 EncapType, tUint32 EncapValue, char *pStr, size_t bufSize)
{
    tSapId sapId;
    
    sapId.PortId = PortId;
    sapId.EncapValue.u32 = EncapValue;
    return FmtSapId(EncapType, &sapId, pStr, bufSize);
}

// WARNING:  limited support see .h file
PUBLIC char *cliFmtRemoteSapIdGivenEncapType(tPortId PortId, tInt32 EncapType, tUint32 EncapValue, char *pStr, size_t bufSize)
{
    char *position;
    tUint32 portLen = 0;
    FmtRemotePortId(PortId, pStr, bufSize);
    portLen = strlen(pStr);
    position = pStr + portLen;
    tEncapValue encapVal;
    encapVal.u32 = EncapValue;

    FmtEncVal(EncapType, encapVal, position, (bufSize - portLen));
    return pStr;
}

PUBLIC char *cliFmtSapId(tPortId PortId, tUint32 EncapValue, char *pStr, size_t bufSize)
{
    return cliFmtSapIdGivenEncapType(PortId, pMgrGetEncapType(PortId), EncapValue, pStr, bufSize);
}

PUBLIC char *cliFmtSdpBndId(const tSdpBndId *pSdpBndId, char *str, int len)
{
    snprintf(str, len, "%u:%u", pSdpBndId->SdpId, pSdpBndId->VcId);
    return str;
}

PUBLIC char *cliFmtEthTunnelMemberCtlTag(tPortId PortId, tUint32 EncapValue,
                                         char *pStr, size_t bufSize)
{
#define MIN_PORT_LEN (9)
    int len = 0;

    snprintf(pStr, bufSize, "%*s", MIN_PORT_LEN, " ");

    if (PortId != 0)
    {
        FmtPortId(PortId, pStr, bufSize);
        len = strlen(pStr);
    }
    else
        len = snprintf(pStr, bufSize, "(N/A)");

    pStr[len] = ' ';
    len = MAX(len, MIN_PORT_LEN);
    if (EncapValue == DEFVAL_tmnxEthTunnelMemberIfCtlTag)
        snprintf(pStr + len, bufSize - len, "(N/A)");
    else
        FmtSapEncapValue(EncapValue, pStr + len, bufSize - len);
    return pStr;
}
                                         
/* 
 * Returns ERROR if the passed string is not in ipv6 address format
 * or if the passed string doesnt contain a prefix length(mask)
 */
PUBLIC RLSTATUS 
tokenizeIpv6Address(const char *ipv6AddrPfxStr,
                    char *ipv6AddrStr, tUint32 AddrStrSize,
                    tIp6PfxLen *ip6PfxLen)
{
    RLSTATUS status = OK;
    tBoolean mask;

    status = divideIpString(ipv6AddrPfxStr, ipv6AddrStr, AddrStrSize, ip6PfxLen, &mask);

    if (status == OK && mask == FALSE)
        return ERROR;

    return status;
}

/* 
 * Returns ERROR only if the passed string is not in ipv6 address format
 * If the passed string doesnt contain a prefix length(mask), set the 
 * ip6PfxLen to '0' and returns OK
 */
PUBLIC RLSTATUS 
tokenizeIpv6AddressAndOptionalMask(const char *ipv6AddrPfxStr,
                                   char *ipv6AddrStr, tUint32 AddrStrSize,
                                   tIp6PfxLen *pIp6PfxLen)
{   
    RLSTATUS status = OK;
    tBoolean mask;

    status = divideIpString(ipv6AddrPfxStr, ipv6AddrStr, AddrStrSize, pIp6PfxLen, &mask);

    if (status == OK && mask == FALSE)
        *pIp6PfxLen = 0;
        
    return status;
}

/* This function converts an ipv4/mask or ipv6-prefix/mask-length string into 
 * OID string format including the dots as follows:
   "InetAddressType.inetAddressLength.inetAddress.prefixLength"
   InetAddressType is either 1 or 2 refer to InetAddressType TC
   inetAddressLength is buf size for inetAddress (v4 size is 4. v6 size is 16) 
   inetAddress: if v4 : 1.2.3.4 if v6 1.2.3.4.5.6...16
   prefixLength : is an integer
 */
tStatus constructInetAddrAndTypeAndPfxLenOID(const sbyte *prefixAndLen, 
                                    sbyte *inetTypeAndPrefixOid, 
                                    sbyte4 inetTypeAndPrefixOidSize)
{
    sbyte       prefixOid[FMT_NET_BUF_SIZE];
    tUint32     prefixLen;
    tUint32     prefixAddLen; 
    
    if ( OK != getPrefixOIDAndLenFromV4OrV6String(prefixAndLen, 
                                                  prefixOid, 
                                                  sizeof(prefixOid), 
                                                  &prefixLen, 
                                                  &prefixAddLen)
        )
            return ERROR;

    if (inetTypeAndPrefixOidSize < INDEX_BUF_SIZE)
        return ERROR;
        
    if (prefixAddLen == IPV6_ADDR_LEN)
    {
        snprintf(inetTypeAndPrefixOid, inetTypeAndPrefixOidSize,"%d.%d.%s.%d",
                    VAL_ipAddressAddrType_ipv6,
                    IPV6_ADDR_LEN,
                    prefixOid,
                    prefixLen);
    }
    else
    {
        snprintf(inetTypeAndPrefixOid, inetTypeAndPrefixOidSize,"%d.%d.%s.%d",
                    VAL_ipAddressAddrType_ipv4,
                    IPV4_ADDR_LEN,
                    prefixOid,
                    prefixLen);
    }            

    return OK;                                      
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// constructInetAddrAndTypeAndPfxLenCompleteOID()
// Produce a complete OID string for an object in a table with three indices.  The indices match the
// INET-ADDRESS-MIB TEXTUAL-CONVENTIONs InetAddressType, InetAddress, and InetAddressPrefixLength.
// InetAddressType values supoorted:  ipv4(1) and ipv6(2).
//    
// Examples:
// 1.  Given
//       oidNameStr = "tmnxTwampSrvPrefixRowStatus"
//       prefixStr  = "138.120.141.173/32"
//     return with
//       outputStr = "tmnxTwampSrvPrefixRowStatus.1.4.138.120.141.173.32"
//     where '1' is the InetAddressType 'ipv4(1)', and '4' is the length of the IPv4 address.
//
// 2.  Given
//       oidNameStr = "tmnxTwampSrvPrefixRowStatus"
//       prefixStr  = "0304:0506:0708:090a:0b0c:0d0e:255.254.253.252/128"
//     return with
//       outputStr  = "tmnxTwampSrvPrefixRowStatus.2.16.3.4.5.6.7.8.9.10.11.12.13.14.255.254.253.252.128"
//     where '2' is the InetAddressType 'ipv6(2)', and '16' is the length of the IPv6 address.
//
// Similarly, handle the IPv6 prefixStr format "0102:0304:0506:0708:090a:0b0c:0d0e:0f00/120".
/////////////////////////////////////////////////////////////////////////////////////////////////////////
tStatus constructInetAddrAndTypeAndPfxLenCompleteOID(cli_env *pCliEnv, const char *oidNameStr,
                                                     const char *prefixStr, 
                                                     char *outputStr, tUint32 sizeofOutputStr)
{
    tStatus status = ERROR;
    int charsWritten = 0;

    if ((oidNameStr == NULL) || (prefixStr == NULL) || (outputStr == NULL)) {
        TRACE_ERROR(MOD_CLI, CFG, "NULL string given");
        cliErrorMesg(pCliEnv, "Unexpected error while parsing the IP address");
        return ERROR;
    }

    charsWritten = snprintf(outputStr, sizeofOutputStr, "%s.", oidNameStr);

    status = constructInetAddrAndTypeAndPfxLenOID(prefixStr, outputStr+charsWritten, sizeofOutputStr-charsWritten);

    if (status != OK) {
        TRACE_ERROR(MOD_CLI, CFG, "Could not parse prefix and mask string '%s'; status = %d", prefixStr, status);
        cliErrorMesg(pCliEnv, "Could not parse prefix and mask string '%s'", prefixStr);
        return ERROR;
    }

    return OK;
}

/* This function converts an ipv4/mask or ipv6-prefix/mask-length string into 
 * OID string format.
 */
tStatus
getPrefixOIDAndLenFromV4OrV6String(const sbyte *prefixAndLen,
                          char *prefixOID, tUint32 prefixOIDSize, 
                          sbyte4 *prefixLen, sbyte4 *prefixAddLen)
{
    tIpAddr     ipv4Prefix;

    tIp6PfxLen  ipv6PfxLen;
    tIp6Addr    ipv6Prefix;
    char        ipv6PrefixStr[IPV6STRLEN];
    char        ipv6StrOid[IPV6STRLEN];

    // in case we error out and someone ignores error code.
    if (prefixOIDSize > 0)
        prefixOID[0] = '\0';
    
    if (prefixOIDSize < FMT_NET_BUF_SIZE)
        return ERROR;

    if(OK != strToIpAndMask(prefixAndLen, &ipv4Prefix, prefixLen)) 
    {
        /* Check if the given route is an ipv6-address */
        if ((OK == tokenizeIpv6Address(prefixAndLen, ipv6PrefixStr, sizeof(ipv6PrefixStr), &ipv6PfxLen)))
        {
            *prefixAddLen = IPV6_ADDR_LEN;
            *prefixLen = ipv6PfxLen;
            if (str2n6(ipv6PrefixStr, &ipv6Prefix) == 1) 
            {
                IPV6_TO_OID(ipv6Prefix.s6_addr8, ipv6StrOid, sizeof(ipv6StrOid));
                snprintf(prefixOID, prefixOIDSize, "%s", ipv6StrOid);
            }
            else
            {
                return ERROR;
            }
        }
        else
        {
            return ERROR;
        }
    }
    else
    {
        *prefixAddLen = IPV4_ADDR_LEN;
        snprintf(prefixOID, prefixOIDSize, "%d.%d.%d.%d", PRINT_IP(ipv4Prefix));
    }
    
    return OK;
}

/*------------------------------------------------------------------
* ROUTINE: getInetAddressType
*
* DESCRIPTION: 
* To return address type for the passes IPv4/IPv6 string.
*
* ARGUMENTS:
*   char*:        pointer to ipv4/ipv6 address
*   tUint32*:     pointer to address type to be updated
* RETURN:
*   OK if the passed string is ipv4/ipv6, ERROR otherwise.
*------------------------------------------------------------------*/

PUBLIC tStatus
getInetAddressType(const char *inetAddress, tUint32  *addrType)
{
    tIp6Addr    ipv6address;
    tUint32     ipv4address = 0;
    tUint32     ifIndex = 0;

    if (!inetAddress)
        return ERROR;

    if( strToIp6AddrAndIfIndex(inetAddress, &ipv6address, &ifIndex, 0) == OK)
    {
        if (ifIndex == 0)
            *addrType = VAL_ipAddressAddrType_ipv6;
        else 
            *addrType = VAL_ipAddressAddrType_ipv6z;
    }
    else if (ipStrToIpAddr(inetAddress, &ipv4address) == OK)
        *addrType = VAL_ipAddressAddrType_ipv4;
    else
        return ERROR;

    return OK;        
}

/*------------------------------------------------------------------
* ROUTINE: strToAnyAddressAndType
*
* DESCRIPTION: 
* To return tIpAnyAddr structure from an ipaddress string.
*
* ARGUMENTS:
*   ipaddress:        pointer to ipv4/ipv6 string address
*   ip_addr_p:        pointer to tIpAnyAddr structure(return)
* RETURN:
*   OK if the passed string is ipv4/ipv6, ERROR otherwise.
*------------------------------------------------------------------*/
tInt32 strToAnyAddressAndType(const char *ipaddress, tIpAnyAddr *ip_addr_p)
{
    tUint32     ipv4address = 0;
    tIp6Addr    ipv6address;
    int         ifIndex;

    /* Check if ipv6 neighbor */
    /* Removed check on runtime_feature_ip6
     * Reason: ipv6 addresses can be valid even if the feature flag is not set.
     *         (e.g. ipv6 addresses on the management itf of 7450).
     * If a check on runtime_feature_ip6 is needed it should be placed at the level of the caller
     * of this function.
     */
    if (strToIp6AddrAndIfIndex(ipaddress, &ipv6address, &ifIndex, 0) == OK)
    {
        if( ifIndex != 0)
            linkLclAddrAndIfIdx2IpAnyAddr( &ipv6address, ifIndex, ip_addr_p);
        else
            baseIp2IpAnyAddr(E_IPV6_ADDR, &ipv6address, ip_addr_p);

        return OK;
    }
    else
    {
        /* Get IP Address */
        if ((ipaddress) && (ipStrToIpAddr(ipaddress, &ipv4address) != OK)){
            return ERROR;
        }
        
        baseIp2IpAnyAddr(E_IPV4_ADDR, &ipv4address, ip_addr_p);
        return OK;
    } 
    return ERROR;
}

/*------------------------------------------------------------------
* ROUTINE: getSNMPValString
*
* DESCRIPTION: 
* Convert cli string to snmp values for integer enumeration types
*
* ARGUMENTS:
*   cliStrings:        pointer to an array of strings as represented in cli
*   numElements:       number of elements in this array 
*   valBuf:            contains the snmpvalue
* RETURN:
*   OK if the passed string is ipv4/ipv6, ERROR otherwise.
*------------------------------------------------------------------*/


RLSTATUS getSNMPValString(cli_env *pCliEnv, 
                                  char **cliStrings, int numElements, 
                                  char *matchString, 
                                  char *valBuf, size_t valBufSize)
{
    int i = 0;

    for (i = 0; i < numElements; i++)
    {
        if (strncmp(cliStrings[i], matchString, strlen(matchString)) == 0)
        {
            snprintf(valBuf, valBufSize, "%d", i);
            return OK;
        }
    }

    cliErrorMesg(pCliEnv, "Invalid input: %s", matchString);
    return ERROR;
}


/*------------------------------------------------------------------
* ROUTINE: ldpAgiStrToTlv
*
* DESCRIPTION: 
* Convert cli string to ldp TLV
*
* ARGUMENTS:
*   agi:  char string xx-xx-xx-xx-xx-xx-xx-xx or xx:xx:xx:xx:xx:xx:xx:xx      
          or ipaddr:number or as-number:number or asn1.asn2:number
          or null
*   tlv:  contains the tlv type-byte, length-byte, value (length-bytes)
* RETURNS:
*   OK on success, ERROR on failure
*------------------------------------------------------------------*/

#define LDP_AGI_STRLEN  16+7
PUBLIC RLSTATUS ldpAgiStrToTlv(const char *agi, char tlv[])
{
    int i = 0;
    int len = 8;
    
    memset(tlv, 0, LDP_AGI_TLV_LEN);
    tlv[0] = 1;
    tlv[1] = 8;
    if (strcmp(agi,"null") == 0)
        return OK;
    tlv[0] = 1;
    tlv[1] = 8;
    if (strToExtComm(agi, &tlv[2], 8) == OK)
        return OK;
    if (strlen(agi) != LDP_AGI_STRLEN)
        return ERROR;
    for (i=0;i<len;i++)
    {
        int temp=0;
        sscanf(agi,"%02X", &temp);
        tlv[i+2] = temp & 0xFF;
        agi += 2;
        if ((i+1) >= len)
           break;
        if (*agi != ':' && *agi != '-')
           return ERROR;
        agi++;
    }
    return OK;
}

PUBLIC RLSTATUS ldpAiiToTlv (const tUint32 globalId, 
        const tUint32 prefix, const tUint32 acId, char tlv[])
{
    tStatus status = ERROR;
    tUint32 temp;

    // Check if it is type 1
    if (prefix > 0 && globalId == 0 && acId == 0)
    {
        tlv[0] = 1; // type 1
        tlv[1] = 4; // length of prefix is 4 bytes
        temp = htonl (prefix);
        memcpy (&tlv[2], &temp, 4);
        status = OK;
    }
    else if (prefix > 0 && globalId > 0 && acId > 0)
    {
        tlv[0] = 2; // type 2
        tlv[1] = 12; // 4 bytes global + 4 byte prefix + 4 byte acId
        temp = htonl (globalId);
        memcpy (&tlv[2],  &temp, 4);
        temp = htonl (prefix);
        memcpy (&tlv[6],  &temp, 4); // 2 + 4
        temp = htonl (acId);
        memcpy (&tlv[10], &temp, 4); // 6 + 4
        status = OK;
    }
    return status;
}
/*------------------------------------------------------------------
* ROUTINE: ldpMatchAgiTlv
*
* DESCRIPTION: 
* Matches AgiTlv with the given Agi String
*
* ARGUMENTS:
*   agi:  char string xx-xx-xx-xx-xx-xx-xx-xx or xx:xx:xx:xx:xx:xx:xx:xx      
          or ipaddr:number or as-number:number
*   tlv:  contains the tlv type-byte, length-byte, value (length-bytes)
* RETURNS:
*    TRUE on successful match else FALSE
*------------------------------------------------------------------ */
PUBLIC tBoolean ldpMatchAgiTlv(const char *agi, const char *tlv)
{
    int i = 0;
    int len = tlv[1];
    char tlv2[LDP_AGI_TLV_LEN];
    
    memset(tlv2,0,sizeof(tlv2));
    tlv2[0] = 1;
    tlv2[1] = 8;
    if (strcmp(agi,"null") == 0) {
        return (memcmp(tlv,tlv2,sizeof(tlv2)) == 0);
    }
    if (strToExtComm(agi, &tlv2[2], 8) == OK) {
        return (memcmp(tlv,tlv2,sizeof(tlv2)) == 0);
    }
    for (i=0;i<len;i++)
    {
        int temp=0;
        sscanf(agi,"%02X", &temp);
        if (tlv[i+2] != (temp & 0xFF))
           return FALSE;
        agi += 2;
        if ((i+1) >= len)
           break;
        if (*agi != ':' && *agi != '-')
           return FALSE;
        agi++;
    }
    return TRUE;
}

/*--------------------------------------------------------------------
 * ROUTINE     : ldpMatchAiiTlv
 *
 * DESCRIPTION : This routine matches an AII TLV with the input
 *             : parameters.
 *
 * ARGUMENTS   : typeIn     - AII Type.
 *             : globalIdIn - Global ID if AII Type 2.
 *             : prefixIn   - Prefix.
 *             : acId       - AC ID if AII Type 2.
 *
 * RETURNS     : TRUE if match found, else FALSE.
 *-----------------------------------------------------------------*/
PUBLIC tBoolean ldpMatchAiiTlv(tUint32     typeIn,
                               tUint32     globalIdIn,
                               tUint32     prefixIn,
                               tUint32     acIdIn,
                               const char *tlv)
{
    tUint32    type, length, globalId, prefix, acId;

    // Decode tlv.
    ldpSnmpDecodeAiiTlv(&type, &length, &globalId, &prefix, &acId, tlv);

    // Type mismatch.
    if (type != typeIn) {
        return FALSE;
    }

    // Type matched, so match tlv value.
    switch (type) {

    case 1:
        if (prefix == prefixIn) {
            return TRUE;
        }    
        break;
        
    case 2:
        if ((globalId == globalIdIn) &&
                (prefix == prefixIn) &&
                    (acId == acIdIn)) {
            
            return TRUE;
        }
        break;
        
    default:
        break;
    }    

    return FALSE;
}    


/*---------------------------------------------------------------------------
 * CLI_GetRowStatus
 *     determines what the proper rowStatus should be:
 * 
 * This function behaves as follows:
 *  1. If the object exists, we 'enter' the mode (using the current value of the 
 *  object we read, or 'destroy' the entry.
 *  2. When the object doesn't exist, we error, if we don't want to 'create'.
 *
 * NOTE: only 'RowStatus' objects can be 'destroyed' or 'created' using this 
 * routine, however 'entering' a mode may call this on any numerical type, as we 
 * return the current value.
 *
 * Returns: RowStatus or FAIL if failed.
 *-------------------------------------------------------------------------*/
PUBLIC tInt8 CLI_GetRowStatus(cli_env * pCliEnv, CLI_RowStatusType create, 
                               char * oid,        char * value, 
                               tUint32 valLength, char * object,
                               tBoolean createMandatory)
{
    tUint32 tmpLen = valLength;
    tUint8  returnValue = SIA_RowStatus_active;
    tStatus status = RCC_RCB_ReadValueFromRCB(pCliEnv, oid, NULL, value, &tmpLen);
    if (status != OK || 0 == strncmp(value, "Bad Type.", tmpLen))
    {
        // oid doesn't exist, ensure we are creating it:
        if (create != CLI_RowStatus_Create)
        {
            if (object != NULL)
            {
                if (createMandatory && create == CLI_RowStatus_Enter_Only)
                    cliErrorMesg(pCliEnv, CREATE_ERROR, object);
                else
                    cliErrorMesg(pCliEnv, "%s doesn't exist", object);
            }
            returnValue = FAIL;
        }
        else
            returnValue = SIA_RowStatus_createAndGo;
    } else if (create == CLI_RowStatus_Destroy)
        returnValue = SIA_RowStatus_destroy;

    snprintf(value, valLength, "%u", returnValue);
    return returnValue;
}

/*---------------------------------------------------------------------------
 * CLI_RCB_ReadValue
 * 
 * This function builds an OID string using the objectName and agent-information 
 * to retrieve a value from the backend. This function is requires the 'index' 
 * to be filled out in the pInfo structure.
 *
 *
 *-------------------------------------------------------------------------*/
tBoolean CLI_RCB_ReadValue(cli_env * pCliEnv, const char * objectName,
                                  tAgentInfo * pAgentInfo, void * pInfo,
                                  tUint8 * outStr, tUint32 outStrSize)
{
    char     oid[OID_BUF_SIZE];
    char     buffer[kOUTPUT_BUFFER_SIZE];
    tUint32  buffer_size;

    buildRCBIndexString(objectName, pAgentInfo, pInfo, oid, sizeof(oid));
    if (RCC_RCB_ReadValueFromRCB(pCliEnv, oid, NULL, buffer, &buffer_size) != OK
            || !strcmp(buffer, "Bad Type."))
        return FALSE;

    if (buffer_size > outStrSize)
        buffer_size = outStrSize;
    memset(outStr, 0x00,   outStrSize);     // Initialize
    memcpy(outStr, buffer, buffer_size); // Set
    return TRUE;
}

/* Convert ASCII string to OSPF vpn-domain id. */
PUBLIC RLSTATUS strToOspfVpnDomainId(const char *Str, char *vpnDomainId)
{
    tInt32  cntr, index;
    char    buffer[CLI_CONSOLE_WIDTH];

    snprintf (buffer, sizeof (buffer), "%s", Str);

    if (strlen (Str) != 14) /* Format xxxx.xxxx.xxxx */
        return ERROR;

    // If it plain Id in ascii string.
    for (cntr = 0, index = 0; cntr < 14; cntr++) {
        if (((cntr + 1) % 5) == 0) { // Make sure 4th 9th are dots.
            if (Str[cntr] != '.') {
                return ERROR;
                break;
            }
            continue;
        }
        // validate hex digit
        if (isxdigit(Str[cntr]) == 0) {
            return ERROR;
            break;
        }

        vpnDomainId[index] = Str[cntr];
        index++;
    }

    vpnDomainId[index] = NULL;

    return OK;
}

PUBLIC RLSTATUS strToBurstSizeBytesOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TBurstSizeBytes) || (val > MAX_TBurstSizeBytes))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TBurstSize) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TBurstSizeBytes;
    }

    return status;
}

PUBLIC RLSTATUS strToBurstLimitBytesOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TBurstLimitBytes) || (val > MAX_TBurstLimitBytes))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TBurstLimit) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TBurstLimitBytes;
    }

    return status;
}

PUBLIC RLSTATUS strToPlcrBurstSizeBytesOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TPlcrBurstSizeBytes) || (val > MAX_TPlcrBurstSizeBytes))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TPlcrBurstSize) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TPlcrBurstSizeBytes;
    }

    return status;
}

PUBLIC RLSTATUS strToHSMDABurstSizeBytesOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_THSMDABurstSizeBytes) || (val > MAX_THSMDABurstSizeBytes))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_THSMDABurstSize) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_THSMDABurstSizeBytes;
    }

    return status;
}

PUBLIC RLSTATUS strToHSMDAHiBurstLimitOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TClassHiBurstLimit) || (val > MAX_TClassBurstLimit))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TClassBurstLimitKB) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TClassBurstLimit;
    }

    return status;
}

PUBLIC RLSTATUS strToHSMDABurstLimitOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TClassBurstLimit) || (val > MAX_TClassBurstLimit))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TClassBurstLimitKB) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TClassBurstLimit;
    }

    return status;
}


PUBLIC RLSTATUS strToHSMDAQueueBurstLimitOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TQueueBurstLimit) || (val > MAX_TQueueBurstLimit))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TQueueBurstLimitKB) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TQueueBurstLimit;
    }

    return status;
}

/* Only for Signed */
int validAnyRange(cli_env    *pCliEnv,
                                const char *pRange,
                                tBoolean    acceptZero,
                                int        *anyLow,
                                int        *anyHigh,
                                int low,
                                int high)
{
    /*
     * pRange should point to a string, containing <any-id>-<any-id>
     * with <any-id> : [low:high]
     */
    char *p;

    //a dash (-) should be present in the string.
    if((p = strchr(pRange, '-')) == NULL) {
        return ERROR;
    }

    //get the low any range
    if (  (sscanf(pRange, "%u", anyLow) == 0)
        ||(acceptZero?(*anyLow != 0 && *anyLow < low):(*anyLow < low))
        ||(*anyLow > high)) {

        return ERROR;
    }

    //get the high any range
    if (  (sscanf(p+1, "%u", anyHigh) == 0)
        || (acceptZero?(*anyHigh != 0 && *anyHigh < low):(*anyHigh < low))
        ||(*anyHigh > high)) {

        return ERROR;

    }

    // check if range is valid
    if(*anyLow > *anyHigh) {
        return ERROR;
    }

    return OK;
}

int validSvcRange(cli_env *pCliEnv,
                  const char *pRange,
                  tBoolean    acceptZero,
                  int        *svcLow,
                  int        *svcHigh)
{
    /*
     * pRange should point to a string, containing <svc-id>-<svc-Id>
     * with <svc-d> : [0|1:MAX_VAR_svcId]
     */
    char *p;

    //a dash (-) should be present in the string.
    if((p = strchr(pRange, '-')) == NULL) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Service range wrongly formatted: missing '-'");
        return ERROR;
    }

    //get the low svc range
    if (  (sscanf(pRange, "%u", svcLow) == 0)
        ||(*svcLow < (acceptZero ? 0 : 1))
        ||(*svcLow > MAX_VAR_svcId)) {

        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Service range wrongly formatted: invalid low bound value");
        return ERROR;
    }

    //get the low svc range
    if (  (sscanf(p+1, "%u", svcHigh) == 0)
        ||(*svcHigh < (acceptZero ? 0 :1))
        ||(*svcHigh > MAX_VAR_svcId)) {

        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Service range wrongly formatted: invalid high bound value");
        return ERROR;

    }

    // check if range is valid
    if(*svcLow > *svcHigh) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Service range wrongly formatted: low bound bigger than high bound");
        return ERROR;
    }

    return OK;
}

#define VISIT_100US_STR "100us"
#define VISIT_500US_STR "500us"
#define VISIT_1MS_STR "1ms"
#define VISIT_5MS_STR "5ms"
#define VISIT_10MS_STR "10ms"
#define VISIT_20MS_STR "20ms"
#define VISIT_40MS_STR "40ms"
#define VISIT_1S_STR "1s"

#define VISIT_100US 100 // in microsecs
#define VISIT_500US 500
#define VISIT_1MS 1000
#define VISIT_5MS 5000
#define VISIT_10MS 10000
#define VISIT_20MS 20000
#define VISIT_40MS 40000
#define VISIT_1S 1000000

char *getVisitTimeStr(tUint32 visitTime)
{
    switch (visitTime) {
    case VISIT_100US: return VISIT_100US_STR;
    case VISIT_500US: return VISIT_500US_STR;
    case VISIT_1MS: return VISIT_1MS_STR;
    case VISIT_5MS: return VISIT_5MS_STR;
    case VISIT_10MS: return VISIT_10MS_STR;
    case VISIT_20MS: return VISIT_20MS_STR;
    case VISIT_40MS: return VISIT_40MS_STR;
    case VISIT_1S: return VISIT_1S_STR;
    default: return NULL; 
    }
}
tStatus
printBcgStr(cli_env *pCliEnv, int slot, int fp, tUint32 visitTime, int dir, char *bcg, int len)
{
    char *visitTimeStr=getVisitTimeStr(visitTime);
    if (visitTimeStr == NULL)
        return ERROR;
    if (dir == QOS_DIRECTION_INGRESS)
        snprintf(bcg, len, "%d/%d-%s (ingress)", slot, fp, visitTimeStr);
    else if (dir == QOS_DIRECTION_EGRESS)
        snprintf(bcg, len, "%d/%d-%s (egress)", slot, fp, visitTimeStr);
    else
        snprintf(bcg, len, "%d/%d-%s", slot, fp, visitTimeStr);
    return OK;
}

tStatus parseVisitTimeStr(char *pVisitTimeStr, tUint32 *pVisitTime)
{
    if (strcmp(pVisitTimeStr, VISIT_100US_STR) == 0)
        *pVisitTime = VISIT_100US;
    else if (strcmp(pVisitTimeStr, VISIT_500US_STR) == 0)
        *pVisitTime = VISIT_500US;
    else if (strcmp(pVisitTimeStr, VISIT_1MS_STR) == 0)
        *pVisitTime = VISIT_1MS;
    else if (strcmp(pVisitTimeStr, VISIT_5MS_STR) == 0)
        *pVisitTime = VISIT_5MS;
    else if (strcmp(pVisitTimeStr, VISIT_10MS_STR) == 0)
        *pVisitTime = VISIT_10MS;
    else if (strcmp(pVisitTimeStr, VISIT_20MS_STR) == 0)
        *pVisitTime = VISIT_20MS;
    else if (strcmp(pVisitTimeStr, VISIT_40MS_STR) == 0)
        *pVisitTime = VISIT_40MS;
    else if (strcmp(pVisitTimeStr, VISIT_1S_STR) == 0)
        *pVisitTime = VISIT_1S;
    else
        return ERROR;
    return OK;
}

tStatus
scanBcgStr(cli_env *pCliEnv, sbyte *bcg, int *pSlot, int *pFp, tUint32 *pVisitTime, int *pDir)
{
    char *p, *q;
    char visitTimeStr[10];
    char dir=0;
    if ((p=strchr(bcg, '/')) == NULL) {
        cliErrorMesg(pCliEnv, "Invalid Slot %s. Does not exist in this system", bcg);
        return ERROR;
    }
    *p=EOS;
    if (sscanf(bcg, "%d", pSlot) == 0 || *pSlot <1 || *pSlot > 10) {
        cliErrorMesg(pCliEnv, "Burst-Control-Group name is wrongly formatted: invalid slot");
        return ERROR;
    }
    if ((q=strchr(p+1, '-')) == NULL) {
        cliErrorMesg(pCliEnv, "Burst-Control-Group name is wrongly formatted: missing '-'");
        return ERROR;
    }
    *q=EOS;
    if (sscanf(p+1, "%d", pFp) == 0 || *pFp < 1 || *pFp > 2) {
        cliErrorMesg(pCliEnv, "Burst-Control-Group name is wrongly formatted: invalid FP");
        return ERROR;
    }
    p=strchr(q+1, '-');
    if (p != NULL)
        *p = EOS;
    if (sscanf(q+1, "%s", visitTimeStr) == 0 || parseVisitTimeStr(visitTimeStr, pVisitTime) != 0) {
        cliErrorMesg(pCliEnv, "Burst-Control-Group name is wrongly formatted: invalid Visitation time");
        return ERROR;
    }
    if (p == NULL) {
        *pDir=0;
        return OK;
    }
    q=strchr(p+1, '-');
    if (sscanf(p+1, "%c", &dir) == 0 || (dir != 'i' && dir != 'e') || strlen(p+1) != 1) {
        cliErrorMesg(pCliEnv, "Burst-Control-Group name is wrongly formatted: invalid direction");
        return ERROR;
    }
    *pDir=dir;
    return OK;
}


RLSTATUS parseIpStrToAgent(cli_env *pCliEnv, sbyte *ipAddress, tInt32 *pType, 
tUint32 *pLength, tUint8 *pAddr, int size)
{
    eIpAddrType addrType;
    tIpAnyAddr ipAddr;
    
    /*fill ipaddr/addrtype */
    if (str2IpAnyAddr(ipAddress, &ipAddr) != OK){
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Invalid IP address: %s", ipAddress);
        return ERROR;
    }
    /*copy address into string*/
    if (ipAnyAddr2BaseIp(&ipAddr, &addrType, pAddr, size) != OK)
        return ERROR;
    /*change from internal address types to MIB types*/
    *pType = (addrType == E_IPV4_ADDR)? VAL_VAR_inetAddressType_ipv4 : VAL_VAR_inetAddressType_ipv6;
    *pLength = IPADDR_LEN(addrType);
    if (*pType == VAL_VAR_inetAddressType_ipv4) {
        //do htonl on the IP address if v4
        *(int*)(pAddr)= htonl(*(int*)(pAddr));
    }
    return OK;
}

RLSTATUS checkUint32(char *str)
{
    char *p = str;
    
    while(*p)
    {
        if(!isdigit(*p++))
            return ERROR;
    }
    if(strlen(str) > 10)
        return ERROR;

    if(strlen(str) == 10 && strcmp(str, "4294967295") > 0)
        return ERROR;

    return OK;
}
RLSTATUS str2Agi(cli_env *pCliEnv, const sbyte *agiStrIn, sbyte *pAgi, int len)
{
    tUint32 value;
    tUint32 *agi=(tUint32*) pAgi;
    char *p=NULL;
    char agiStr[256];
    if (len < SIZE_svcMSPwPeAgi) {
        cliErrorMesg(pCliEnv, "Invalid length of AGI");
        return ERROR;
    }
    // No CLI handler should modify its input parameters, so make a local copy
    strlcpy(agiStr, agiStrIn, sizeof(agiStr));
    if ((p=strchr(agiStr, ':')) == NULL) {
        cliErrorMesg(pCliEnv, "AGI value is wrongly formatted: missing ':'");
        return ERROR;
    }
    *p=EOS;
    if (checkUint32(agiStr) != OK || sscanf(agiStr, "%d", &value) == 0) {
        cliErrorMesg(pCliEnv, "AGI value is incorrect. Should be <0..4294967295>:<0..4294967295>");
        return ERROR;
    }
    agi[0] = htonl(value);
    if (checkUint32(p+1) != OK || sscanf(p+1, "%d", &value) == 0) {
        cliErrorMesg(pCliEnv, "AGI value is incorrect. Should be <0..4294967295>:<0..4294967295>");
        return ERROR;
    }
    agi[1] = htonl(value);
    return OK;
}

RLSTATUS str2AiiType(cli_env *pCliEnv, const sbyte *aiiIn, tUint32 *globalId, tUint32 *prefix, tUint32 *acId)
{
    char *p=NULL;
    char *q=NULL;
    char  aii[256];
    // No CLI handler should modify its input parameters, so make a local copy
    strlcpy(aii, aiiIn, sizeof(aii));
    if ((p=strchr(aii, ':')) == NULL) {
        if (pCliEnv) {
            cliErrorMesg(pCliEnv, "AII value is wrongly formatted: missing ':'");
            return ERROR;
         }
         if (checkUint32(aii) != OK)
             return ERROR;
         strToUint32(aii, globalId);
         return OK;
    }
    *p=EOS;
    if (checkUint32(aii) != OK || strToUint32(aii, globalId) != OK || *globalId == 0) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Global-Id should be a non-zero number");
        return ERROR;
    }
    if ((q=strchr(p+1, ':')) == NULL) {
        if (pCliEnv) {
            cliErrorMesg(pCliEnv, "AII value is wrongly formatted: missing ':'");
            return ERROR;
        }
        if (OK == ipStrToIpAddr(p+1, prefix))
            return OK;
        if (checkUint32(p+1) != OK)
            return ERROR;
        strToUint32(p+1, prefix);
        return OK;
    }
    *q=EOS;
    if ((OK != ipStrToIpAddr(p+1, prefix) && 
         (checkUint32(p+1) != OK || strToUint32(p+1, prefix) != OK)
        ) || *prefix == 0) {
        if (pCliEnv)
             cliErrorMesg(pCliEnv, "Prefix should be a non-zero number or an ipv4-address");
        return ERROR;
    }
    if (checkUint32(q+1) != OK || strToUint32(q+1, acId) != OK || *acId == 0) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "AC-ID should be a non-zero number");
        return ERROR;
    }
    return OK;
}

RLSTATUS str2MplsTpAiiType(cli_env *pCliEnv, const sbyte *aiiIn, tUint32 *globalId, tUint32 *prefix, tUint32 *acId)
{
    char *p=NULL;
    char *q=NULL;
    char  aii[256];

    // No CLI handler should ever modify an input parameter, so make a local coppy
    strlcpy(aii, aiiIn, sizeof(aii));

    if ((p=strchr(aii, ':')) == NULL) {
        if (pCliEnv) {
            cliErrorMesg(pCliEnv, "AII value is wrongly formatted: missing ':'");
            return ERROR;
         }
         if (checkUint32(aii) != OK)
             return ERROR;
         strToUint32(aii, globalId);
         return OK;
    }
    *p=EOS;
    if (checkUint32(aii) != OK || strToUint32(aii, globalId) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Global-Id should be a number");
        return ERROR;
    }
    if ((q=strchr(p+1, ':')) == NULL) {
        if (pCliEnv) {
            cliErrorMesg(pCliEnv, "AII value is wrongly formatted: missing ':'");
            return ERROR;
        }
        if (OK == ipStrToIpAddr(p+1, prefix))
            return OK;
        if (checkUint32(p+1) != OK)
            return ERROR;
        strToUint32(p+1, prefix);
        return OK;
    }
    *q=EOS;
    if ((OK != ipStrToIpAddr(p+1, prefix) && 
         (checkUint32(p+1) != OK || strToUint32(p+1, prefix) != OK)
        ) || *prefix == 0) {
        if (pCliEnv)
             cliErrorMesg(pCliEnv, "Prefix should be a non-zero number or an ipv4-address");
        return ERROR;
    }
    if (checkUint32(q+1) != OK || strToUint32(q+1, acId) != OK || *acId == 0) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "AC-ID should be a non-zero number");
        return ERROR;
    }
    return OK;
}

RLSTATUS checkUnsigned32GreaterThanOrEqualsOne(char *str)
{
    char *p = str;
    
    while(*p)
    {
        if(!isdigit(*p++))
            return ERROR;
    }
    if(strlen(str) > 10)
        return ERROR;

    if(strcmp(str, "1") < 0)
        return ERROR;
    
    if(strlen(str) == 10 && strcmp(str, "4294967295") > 0)
        return ERROR;

    return OK;
}

RLSTATUS parseStrArray(cli_env *pCliEnv, sbyte *str, char sep, char **array, int size)
{
    char *p=str;
    char *q=str;
    int i=0;
    for (i=0; i<(size-1);i++) {
        if ((q=strchr(p, sep)) == NULL) {
            if (pCliEnv)
                cliErrorMesg(pCliEnv, "String is wrongly formatted: missing \"%c\"", sep);
            return ERROR;
        }
        array[i] = p;
        *q=EOS;
        p = q+1;
    }
    array[i] = p;
    return OK;
}
 
PUBLIC tStatus
cliParseSapIngPolicyId(cli_env *pCliEnv, const char *SapIngPolicyId, tUint32 *pSapIngPolicyId)
{
    if (pSapIngPolicyId == NULL)
        return ERROR;
    if (SapIngPolicyId) {
        if (strToUint32(SapIngPolicyId, pSapIngPolicyId) != OK) {
            STRUCT_tSapIngPolicyNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.tSapIngressPolicyName, SapIngPolicyId, strlen(SapIngPolicyId));
            if (sia_tSapIngPolicyNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pSapIngPolicyId = entry.tSapIngPolicyNameId;
                return OK;
            }
            if (pCliEnv)
                cliErrorMesg(pCliEnv, "Invalid sap-ingress policy-id \"%s\"", SapIngPolicyId);
            return ERROR;
        }
    } else {
        *pSapIngPolicyId = 0;
    }
    return OK;
}

PUBLIC tStatus
cliParseSapEgrPolicyId(cli_env *pCliEnv, const char *SapEgrPolicyId, tUint32 *pSapEgrPolicyId)
{
    if (pSapEgrPolicyId == NULL)
        return ERROR;
    if (SapEgrPolicyId) {
        if (strToUint32(SapEgrPolicyId, pSapEgrPolicyId) != OK) {
            STRUCT_tSapEgrPolicyNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.tSapEgressPolicyName, SapEgrPolicyId, strlen(SapEgrPolicyId));
            if (sia_tSapEgrPolicyNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pSapEgrPolicyId = entry.tSapEgrPolicyNameId;
                return OK;
            }
            if (pCliEnv)
                cliErrorMesg(pCliEnv, "Invalid sap-egress policy-id \"%s\"", SapEgrPolicyId);
            return ERROR;
        }
    } else {
        *pSapEgrPolicyId = 0;
    }
    return OK;
}

PUBLIC tStatus
cliParseMacFilterId(cli_env *pCliEnv, const char *MacFilterId, tUint32 *pMacFilterId)
{
    if (pMacFilterId == NULL)
        return ERROR;
    if (MacFilterId) {
        if (strToUint32(MacFilterId, pMacFilterId) != OK) {
            STRUCT_tMacFilterNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.tMacFilterName, MacFilterId, strlen(MacFilterId));
            if (sia_tMacFilterNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pMacFilterId = entry.tMacFilterNameId;
                return OK;
            }
            if (pCliEnv)
                cliErrorMesg(pCliEnv, "Invalid mac filter-id \"%s\"", MacFilterId);
            return ERROR;
        }
    } else {
        *pMacFilterId = 0;
    }
    return OK;
}

PUBLIC tStatus
cliParseIpFilterId(cli_env *pCliEnv, const char *IpFilterId, tUint32 *pIpFilterId)
{
    tUint32 fltrId;

    if (pIpFilterId == NULL)
        return ERROR;
    if (IpFilterId) {
        if (strToUint32(IpFilterId, pIpFilterId) != OK) {
            STRUCT_tIpFilterNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.tIpFilterName, IpFilterId, strlen(IpFilterId));
            if (sia_tIpFilterNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pIpFilterId = entry.tIpFilterNameId;
                return OK;
            }

            if (fltrAutoGenNameToFilterId((char*)IpFilterId, &fltrId) == OK)
            {
                *pIpFilterId = fltrId;
                return OK;
            }

            if (pCliEnv) {
                cliErrorMesg(pCliEnv, "Invalid ip filter-id \"%s\"", IpFilterId);
            }
            return ERROR;
        }
    } else {
        *pIpFilterId = 0;
    }
    return OK;
}

PUBLIC tStatus
cliParseIpv6FilterId(cli_env *pCliEnv, const char *Ipv6FilterId, tUint32 *pIpv6FilterId)
{
    tUint32 fltrId;

    if (pIpv6FilterId == NULL)
        return ERROR;
    if (Ipv6FilterId) {
        if (strToUint32(Ipv6FilterId, pIpv6FilterId) != OK) {
            STRUCT_tIpv6FilterNameEntry entry;
            ZERO_STRUCT(entry);
            STRCPY_TLNamedItem(&entry.tIpv6FilterName, Ipv6FilterId, strlen(Ipv6FilterId));
            if (sia_tIpv6FilterNameEntryGet(SIA_EXACT_VALUE, &entry) == OK) {
                *pIpv6FilterId = entry.tIpv6FilterNameId;
                return OK;
            }

            if (fltrAutoGenNameToFilterId((char*)Ipv6FilterId, &fltrId) == OK)
            {
                *pIpv6FilterId = fltrId;
                return OK;
            }

            if (pCliEnv)
                cliErrorMesg(pCliEnv, "Invalid ipv6 filter-id \"%s\"", Ipv6FilterId);
            return ERROR;
        }
    } else {
        *pIpv6FilterId = 0;
    }
    return OK;
}

/*
 * Converts binary string src ("ABC") to dest ("414243") and returns strlen of dest.
 * dest will always be a NULL-terminated ASCII string containing hexadecimal characters.
 */
tUint32 cliStrToHex(const char *src, tUint32 srcLen, char *dest, size_t dstSize)
{
    tUint32 destLen = 0;
    tUint32 i;

    dest[0] = '\0';

    for (i = 0; i < srcLen; i++)
    {
        destLen += snprintf(dest + destLen, dstSize - destLen, "%02x", src[i]);
    }

    return destLen;
}

/* return isisInstance if spb is configured on the service */
RLSTATUS svcGetIsisInstance(cli_env *pCliEnv, sbyte *ServId, tUint32 *instance)
{
    STRUCT_svcTlsSpbEntry entry;
    if (cliParseServId(pCliEnv, ServId, &entry.svcId) != OK)
        return ERROR;
    if (sia_svcTlsSpbEntryGet(SIA_EXACT_VALUE, &entry) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "SPB not configured on this service");
        return ERROR;
    }
    *instance = entry.svcTlsSpbIsisInstance;
    return OK;
}
/* return isisInterfaceId if spb is configured on the sap */
RLSTATUS sapGetIsisInstance(cli_env *pCliEnv, sbyte *ServId, sbyte *SapId, tUint32 *instance)
{
    STRUCT_sapTlsSpbEntry entry;
    if (cliParseServId(pCliEnv, ServId, &entry.svcId) != OK)
        return ERROR;
    if (cliParseSapId(pCliEnv, SapId, &entry.sapPortId, &entry.sapEncapValue) != OK)
        return ERROR;
    if (sia_sapTlsSpbEntryGet(SIA_EXACT_VALUE, &entry) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "SPB not configured on this sap");
        return ERROR;
    }
    *instance = entry.sapTlsSpbIfIndex;
    return OK;
}
RLSTATUS
spbGetNameGivenIndex(tUint32 vRtrId, tUint32 ifIndex, char *name, tUint32 bufLen)
{
    STRUCT_sapTlsSpbEntry entry;
    char buf[80];
    ZERO_STRUCT(entry);
    while (sia_sapTlsSpbEntryGet(SIA_NEXT_VALUE, &entry) == OK) {
        if (entry.sapTlsSpbIfIndex == ifIndex) {
            cliFmtSapId(entry.sapPortId, entry.sapEncapValue, buf, sizeof(buf));
            snprintf(name, bufLen, "sap:%s", buf);
            return OK;
        }
    }
    STRUCT_sdpBindTlsSpbEntry sdpBindEntry;
    ZERO_STRUCT(sdpBindEntry);
    while (sia_sdpBindTlsSpbEntryGet(SIA_NEXT_VALUE, &sdpBindEntry) == OK) {
        if (sdpBindEntry.sdpBindTlsSpbIfIndex == ifIndex) {
            cliFmtSdpBndId(&sdpBindEntry.sdpBindId, buf, sizeof(buf));
            snprintf(name, bufLen, "sdp:%s", buf);
            return OK;
        }
    }
    if (name)
        *name = 0;
    return ERROR;
}
/* return isisInterfaceId if spb is configured on the sdp-bind */
RLSTATUS sdpBindGetIsisInstance(cli_env *pCliEnv, sbyte *ServId, sbyte *SdpBndId, tUint32 *instance)
{
    STRUCT_sdpBindTlsSpbEntry entry;
    tUint16 sdpId;
    if (cliParseServId(pCliEnv, ServId, &entry.svcId) != OK)
        return ERROR;
    if (strToSdpBndId(SdpBndId, &sdpId, &entry.sdpBindId.VcId) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "Invalid sdp-bind");
        return ERROR;
    }
    entry.sdpBindId.SdpId = sdpId;
    if (sia_sdpBindTlsSpbEntryGet(SIA_EXACT_VALUE, &entry) != OK) {
        if (pCliEnv)
            cliErrorMesg(pCliEnv, "SPB not configured on this sdp-bind");
        return ERROR;
    }
    *instance = entry.sdpBindTlsSpbIfIndex;
    return OK;
}
/* Convert ASCII string to a ECT-Algoirthm Fid range */
PUBLIC RLSTATUS strToFidRange(const char *Str, tUint32 *pStartFid, tUint32 *pEndFid)
{
    char    *p = NULL;
    char     dummy[10] = "";

    /* Find the delimeter */
    p = strchr(Str, '-');
    if (p == NULL)
        return ERROR;

    /* Fetch Fid.Fid */
    if (sscanf(Str, "%u-%u%s", pStartFid, pEndFid, dummy) != 2)
        return ERROR;

    /* Some sanity checking */
    if ((*pStartFid > 4095) || (*pEndFid > 4095))
        return ERROR;
    if (*pEndFid < *pStartFid)
        return ERROR;
    if (*pStartFid == 0)
        return ERROR;

    return OK;
}
PUBLIC RLSTATUS strToHSMDAHiBurstIncOrNull(const char *Str, tInt32 *rmult, const char *units)
{
    RLSTATUS status = OK;
    tInt32 val;

    if (isdigit(Str[0])) {
        val = atol(Str);
        if ((val < MIN_TClassHiBurstInc) || (val > MAX_TClassHiBurstInc))
            status = ERROR;
        else
            *rmult = val;
        if (status == OK &&
            (units == NULL || units[0] == 'k')) { // kilobytes
            if (*rmult > MAX_TClassHiBurstIncKB) {
                status = ERROR;
            }
            else 
                *rmult *= 1024; // bytes
        }
    } else {
        if (strstr("default", Str) == NULL)
            status = ERROR;
        else
            *rmult = NULL_TClassHiBurstInc;
    }

    return status;
}

PUBLIC sbyte *sdpBndIdToOid(tUint16 sdpId, tUint32 vcId, sbyte *idxBuf, int idxBufLen)
{
    snprintf(idxBuf, idxBufLen, "0.0.%d.%d.%d.%d.%d.%d",
                         ((((tUint32)(sdpId)) >>  8) & 0xff), 
                         (((tUint32)(sdpId))        & 0xff),
                         ((((tUint32)(vcId)) >> 24) & 0xff), 
                         ((((tUint32)(vcId)) >> 16) & 0xff), 
                         ((((tUint32)(vcId)) >>  8) & 0xff), 
                          (((tUint32)(vcId))        & 0xff));
    return idxBuf;
}

/* Convert ASCII string to 64-bit long identifier. The string can be in
 * the IEEE cannonical format (00-11- ...) or in the common SunOS
 * format (00:11: ...)
 */

PUBLIC RLSTATUS strToLongId(sbyte *Str, tUint8 *buf, int buflen)
{
    int B0, B1, B2, B3, B4, B5, B6, B7;
    int i;

    if (Str == NULL || buf == NULL || buflen != LONG_ID_LEN)
        return ERROR;
    
    /* enforce the length:  must be 16 hex digits, 7 separators (: or -) */
    if (LONG_ID_STR_LEN != strlen(Str))
        return ERROR;
       
    /* 
     * all characters must be valid Hexadecimal values:
     * - 00:00:c8:02:01:-1     '-1' is a valid number but not valid as Mac address
     * - 00:00:c8:02:01:+a     '+a' is a valid number but not valid as Mac address
     * - 00:32:23:53:5d:2g     '2g' is invalid but gets through the sscanf's trailing char issue 
     */
    for(i = 0; i < LONG_ID_STR_LEN; i++)
    {
        // do not check separators
        if (((i+1) % 3) == 0)         
            continue; 
        //check numbers
        if (!isxdigit(Str[i]))
            return ERROR;
    }

    /* First try the IEEE cannonical format */
    if (sscanf(Str, "%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x",
               &B0, &B1, &B2, &B3, &B4, &B5, &B6, &B7) != 8) {
        /* OK, try the SunOS format... */
        if (sscanf(Str, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
                   &B0, &B1, &B2, &B3, &B4, &B5, &B6, &B7) != 8) {
            /* Syntax error! */
            return ERROR;
        }
    }

    if ((B0 > 255) || (B1 > 255) || (B2 > 255) ||
        (B3 > 255) || (B4 > 255) || (B5 > 255) ||
        (B6 > 255) || (B7 > 255)
        ) {
        /* Syntax error! */
        return ERROR;
    }

    buf[0] = B0;
    buf[1] = B1;
    buf[2] = B2;
    buf[3] = B3;
    buf[4] = B4;
    buf[5] = B5;
    buf[6] = B6;
    buf[7] = B7;

    return OK;
}

/*-------------------------------------------------------
 * macAddrStrForRccRcbSet
 *     Takes a display-string and converts it to a valid SNMP OID. The OID must 
 *     be in hexadecimal format for numerical values, and is null-terminated for 
 *     ASCII strings.
 *     This function removes the separators of a mac-address, and confirms that
 *     each hexidecimal value is exactly 2 digits.
 */
PUBLIC tBoolean macAddrStrForRccRcbSet(const char *macStr, char *outMac)
{
    int count = 0;
    while (*macStr)
    {
        if (*macStr != ':' && *macStr != '-') // separator
        {
            count ++;
            if (!isxdigit(*macStr) || !isxdigit(*(macStr+1)))
                return FALSE;

            *outMac = *macStr;
            outMac++; macStr++;
            *outMac = *macStr;
            outMac++;
        }
        macStr++;
    }

    if (count != 6)
        return FALSE;

    *outMac = '\0'; // null-terminate
    return TRUE;
}

