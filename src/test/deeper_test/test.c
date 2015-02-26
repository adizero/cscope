
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

RLSTATUS timConfigureServiceIesSubscriber_interfaceGroup_interfaceSapIngressScheduler_overrideInfoPtr(cli_env *pCliEnv, cfgPrintf pf, void *fp, tBoolean detail) {return OK;}
#if 0
{
    tUint32      portId, encapVal;
    tUint32      svcId;
    RLSTATUS     status;

    if ( (getServiceId (pCliEnv, &svcId, IES_SVC_TYPE) == OK ) &&
         (getServiceGrpSapId(pCliEnv, &portId, &encapVal) == OK))
    {
        status = smgrGenerateConfigSvcIesGrpInterfaceIngressSOverrideInfo ( pf, fp,
                                                                         svcId, portId, encapVal,
                                                                         detail);
        if (status < 0) return status;
        return OK;
    }

    return ERROR;
}
#endif

int foobar()
{
    return 0;
}


PRIVATE tStatus devEraseSector(tUint32 romPhysAddr, tUint32 startSector, tBoolean isSerial, 
                                tUint32 sectorSize, tUint32 numSectors)
{
//    volatile tUint8 * sector;
    tUint32  now, cnt, rphys;
//    volatile tUint8   byte;
    tBoolean failed = FALSE;
    tUint32  sectorNum = 0;

    cnt = numSectors * sectorSize;
    rphys = romPhysAddr + (startSector * sectorSize);
    while (cnt && !failed)
    {
        printf("Sector %d\r", sectorNum+startSector);
        if (isSerial)
        {
            // Can take as long as 3 seconds; probably at least 500msec
            sflashEraseSector((tUint32 *)rphys, FALSE, NULL, SFLASH_FLAG_ERASE);
            now = vxTicks;
            do
            {
                taskDelay(TIMOS_TICKS_PER_SEC/2);
                if (sflashEraseSector((tUint32 *)rphys, FALSE, NULL, (SFLASH_FLAG_VERIFY | SFLASH_FLAG_ONCE)) == OK) 
                    break;
            } while (((vxTicks-now) < TIMOS_TICKS_PER_SEC*4));
        }
        else
        {
            if (diagParEraseSector(TM_HW_MY_CARD_TYPE, rphys, TRUE) != OK)
                return(ERROR);
        }

#if 0
            sector = (tUint8 *)PHYS_TO_K1(rphys);  
            *(sector + 0x555) = 0xaa;
            *(sector + 0x2aa) = 0x55;
            *(sector + 0x555) = 0x80;
            *(sector + 0x555) = 0xaa;
            *(sector + 0x2aa) = 0x55;
            *(sector + 0x000) = 0x30;
        }

        now = vxTicks;
        do
        {
            taskDelay(1); // let somebody else run
            byte = *((tUint8 *)(PHYS_TO_K1(rphys)));
        } while ((byte != 0xFF) && ((vxTicks-now) < TIMOS_TICKS_PER_SEC*5));

        if (byte != 0xFF)
        {
            diagFail("Failed erasure at %X!", PHYS_TO_K1(rphys));
            failed = TRUE;
            break;
        }

#endif
        cnt   -= sectorSize;
        rphys += sectorSize;
        sectorNum++;
    }
    return(OK);
}

int barfoo()
{
    return 1;
}

PRIVATE tStatus
pppoeRedScanAllTlvs(tUint8                  **src,
                    tUint8                   *end /* comment test */,
                    tSbmEsmInfo             **ppEsmInfo,
                    char                     *serviceName, //comment 2
                    tUint32                   serviceNameLen,
                    char                     *pppUserName,
                    tUint32                   pppUserNameLen,
                    tSbmSubProf             **ppSubProf,
                    tSbmSLAProf             **ppSLAProf,
                    tDpiSmgrAppProf         **ppAppProf,
                    char                      subIntDestId[MAX_LEN_INT_DEST_ID + 1], 
                    char                      subAncpStr[MAX_LEN_ANCP_STR1], 
                    tSbmMngdRoutes           *pMngdRoutes,
                    tSbmBgpPrng              *pBgpPrng,
                    char                     *addressPool,
                    tUint32                   addressPoolLen,
                    char                     *authPolName,
                    tUint32                   authPolNameLen,
                    char                     *userDbName,
                    tUint32                   userDbNameLen,
                    tSbmIpFltrRuleInfo       *pIpFltrRuleInfo,
                    tSbmIpFltrRuleInfoShared *pIpFltrRuleInfoShared,
                    tSbmAuthProtAttrs        *pAuthProtAttrs,
                    tBoolean                 *hasPapChap,
                    tPppoeRedLnsTlvs         *pLnsTlvs,
                    tSbmSubQosOvrList        *pSubQosOvrList,
                    tSbmSubQosOvrList        *pSubQosOvrListSPI,
                    tBoolean                 *pForceSqoSPI,
                    tPppoeTermReason         *pTermReason,
                    char                      termText[SBM_MAX_TLV_SIZE1], 
                    tPppoeRedAtmTlvs         *pAtmTlvs,
                    tPppoeRedAleAdjust       *pRedAleAdjust,
                    tUint32                  *pUpdateSbmObjects,
                    tSbmSubscrFilterInfo     *pSubscrFilterInfo,
                    tBoolean                 *pForceIpv6cp,
                    tBoolean                 *pMcStdbyLac,
                    tUint32                  *pRadLiMirrSrcId,
                    tPppoeRedIp6NodeAddrInfo *pIp6NodeAddrInfo)
{
    //body
}
