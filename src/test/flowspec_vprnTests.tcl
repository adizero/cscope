proc flowspec.basicVprn { args } { 
  global masterlog testdir ixia_port logdir
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  set option(verbose) false
  set option(bugxxxxx) false
  set option(returnResult) false
  set option(sbgpDebug) false
  set option(dumpDebugLog) false
  set option(cliTimeout) 600
  set option(maxRetryCnt) 3
  set option(interRetryTimeSec) 60
  set option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected) true
  set option(addDefFilterInLastVprnAfterFlowroutesAreInjected) true
  set option(nbrVprns) 3
  set option(nbrFlowroutesPerVprn) 4
  set option(bgpNlriBufMax_specialDistribution) false
  set option(actionListPerVprn) [list drop log accept redirectVrf]
  set option(enableFilterTrace) false
  set option(enableBgpFlowspecTrace) false
  set option(sendBgpPrefixUpd_v4) false
  set option(sendBgpPrefixUpd_v6) false
  set option(sendBgpFlowrouteUpd_v4) true
  set option(sendBgpFlowrouteUpd_v6) true
  set option(sendTraffic_v4) true
  set option(sendTraffic_v6) true
  set option(enableIngressFlowspec_v4) true
  set option(enableIngressFlowspec_v6) true
  set option(vrfTargetDirectUnderVprn_noImportPolicy) true
  set option(enableFlowspecBeforeFlowroutesAreInjected) false
  set option(actionExpectedBehaviorList) [list "none" "defaultBehavior" \
                                                                    "adminTech" "none" \
                                                                    "doubleSwo" "defaultBehavior" \
                                                                    "shutFirstVprn" "noFilterEntriesExpInVprn" \
                                                                    "noShutFirstVprn" "defaultBehavior" \
                                                                    "shutNextVprn" "noFilterEntriesExpInVprn" \
                                                                    "noShutNextVprn" "defaultBehavior" \
                                                                    "withdrawAllIpv4v6Flowroutes" "noIpv4v6FilterEntriesExpInDut" \
                                                                    "announceAllIpv4v6FlowroutesAgain" "defaultBehavior" \
                                                                    "clearBgpNeighbor" "defaultBehavior" \
                                                                    "clearBgpProtocol" "defaultBehavior" \
                                                                    "shutNoShutBgpNeighbor_waitOnZeroAndOnAllFlowroutes" "defaultBehavior" \
                                                                    "shutNoShutBgpProtocol_waitOnZeroAndOnAllFlowroutes" "defaultBehavior" \
                                                                    "none" "negTest_fSpecAndUsrDefFilterOnItfInDiffVprns" \
                                                                    "stopTrafficAndClearFilters" "zeroIngMatchesExpInDut" \
                                                                    "startTraffic" "defaultBehavior" \
                                                                    "rollback" "defaultBehavior" \
                                                            ]
  #                                                                
  # spoke
  set option(itfType_dut1dut2) ""
  set option(addFlowroutesInBase) true
  set option(skipCheckFilterLog) true
  
  # maxNbrIterations | maxDuration [hours] | ifFileExists
  set option(iterationMethod) maxNbrIterations
  set option(maxNbrIterations) 1
  set option(maxDurationHrs) 5
  set option(fileExistsName) "/tmp/fspecVprn_running.txt"
  set option(neverDisableDutLogging) false
  set option(withdrawAnnounceFlowroutesDuringSwoDurationMinutes) 5
  set option(redTestModuleId) 14
  set option(redTestTableId) 15
  set option(redTestMaxRedUpd) 5
  set option(redTestNbIter) 20
  set option(maxStandbySynchroTimeSec) [expr 10 * 60]
  set option(reannounceRemainingWithdrawnFlowroutesDuringReconcile) false
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecNbrVprns] != "ERROR"} {
    set nbrVprns [GGV fspecNbrVprns]
  } else {
    set nbrVprns $option(nbrVprns)
  }
  if {[GGV fspecNbrFlowroutesPerVprn] != "ERROR"} {
    set nbrFlowroutesPerVprn [GGV fspecNbrFlowroutesPerVprn]
  } else {
    set nbrFlowroutesPerVprn $option(nbrFlowroutesPerVprn)
  }
  if {[GGV fspecEnableFilterTrace] != "ERROR"} {
    set enableFilterTrace [GGV fspecEnableFilterTrace]
  } else {
    set enableFilterTrace $option(enableFilterTrace)
  }
  if {[GGV fspecEnableBgpFlowspecTrace] != "ERROR"} {
    set enableBgpFlowspecTrace [GGV fspecEnableBgpFlowspecTrace]
  } else {
    set enableBgpFlowspecTrace $option(enableBgpFlowspecTrace)
  }
  if {[GGV fspecSendBgpPrefixUpd_v4] != "ERROR"} {
    set sendBgpPrefixUpd_v4 [GGV fspecSendBgpPrefixUpd_v4]
  } else {
    set sendBgpPrefixUpd_v4 $option(sendBgpPrefixUpd_v4)
  }
  if {[GGV fspecSendBgpPrefixUpd_v6] != "ERROR"} {
    set sendBgpPrefixUpd_v6 [GGV fspecSendBgpPrefixUpd_v6]
  } else {
    set sendBgpPrefixUpd_v6 $option(sendBgpPrefixUpd_v6)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v4] != "ERROR"} {
    set sendBgpFlowrouteUpd_v4 [GGV fspecSendBgpFlowrouteUpd_v4]
  } else {
    set sendBgpFlowrouteUpd_v4 $option(sendBgpFlowrouteUpd_v4)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v6] != "ERROR"} {
    set sendBgpFlowrouteUpd_v6 [GGV fspecSendBgpFlowrouteUpd_v6]
  } else {
    set sendBgpFlowrouteUpd_v6 $option(sendBgpFlowrouteUpd_v6)
  }
  if {[GGV fspecActionListPerVprn] != "ERROR"} {
    set actionListPerVprn [GGV fspecActionListPerVprn]
  } else {
    set actionListPerVprn $option(actionListPerVprn)
  }
  if {[GGV fspecDumpDebugLog] != "ERROR"} {
    set dumpDebugLog [GGV fspecDumpDebugLog]
  } else {
    set dumpDebugLog $option(dumpDebugLog)
  }
  if {[GGV fspecSendTraffic_v4] != "ERROR"} {
    set sendTraffic_v4 [GGV fspecSendTraffic_v4]
  } else {
    set sendTraffic_v4 $option(sendTraffic_v4)
  }
  if {[GGV fspecSendTraffic_v6] != "ERROR"} {
    set sendTraffic_v6 [GGV fspecSendTraffic_v6]
  } else {
    set sendTraffic_v6 $option(sendTraffic_v6)
  }
  if {[GGV fspecEnableIngressFlowspec_v4] != "ERROR"} {
    set enableIngressFlowspec_v4 [GGV fspecEnableIngressFlowspec_v4]
  } else {
    set enableIngressFlowspec_v4 $option(enableIngressFlowspec_v4)
  }
  if {[GGV fspecEnableIngressFlowspec_v6] != "ERROR"} {
    set enableIngressFlowspec_v6 [GGV fspecEnableIngressFlowspec_v6]
  } else {
    set enableIngressFlowspec_v6 $option(enableIngressFlowspec_v6)
  }
  if {[GGV fspecVrfTargetDirectUnderVprn_noImportPolicy] != "ERROR"} {
    set vrfTargetDirectUnderVprn_noImportPolicy [GGV fspecVrfTargetDirectUnderVprn_noImportPolicy]
  } else {
    set vrfTargetDirectUnderVprn_noImportPolicy $option(vrfTargetDirectUnderVprn_noImportPolicy)
  }
  if {[GGV fspecItfType_dut1dut2] != "ERROR"} {
    set itfType_dut1dut2 [GGV fspecItfType_dut1dut2]
  } else {
    set itfType_dut1dut2 $option(itfType_dut1dut2)
  } 
  if {[GGV fspecActionExpectedBehaviorList] != "ERROR"} {
    set actionExpectedBehaviorList [GGV fspecActionExpectedBehaviorList]
  } else {
    set actionExpectedBehaviorList $option(actionExpectedBehaviorList)
  }
  if {[GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected [GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected]
  } else {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected $option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected)
  }
  if {[GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected [GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected]
  } else {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected $option(addDefFilterInLastVprnAfterFlowroutesAreInjected)
  }
  if {[GGV fspecAddFlowroutesInBase] != "ERROR"} {
    set addFlowroutesInBase [GGV fspecAddFlowroutesInBase]
  } else {
    set addFlowroutesInBase $option(addFlowroutesInBase)
  }
  if {[GGV fspecSkipCheckFilterLog] != "ERROR"} {
    set skipCheckFilterLog [GGV fspecSkipCheckFilterLog]
  } else {
    set skipCheckFilterLog $option(skipCheckFilterLog)
  }
  if {[GGV fspecIterationMethod] != "ERROR"} {
    set iterationMethod [GGV fspecIterationMethod]
  } else {
    set iterationMethod $option(iterationMethod)
  }
  if {[GGV fspecMaxNbrIterations] != "ERROR"} {
    set maxNbrIterations [GGV fspecMaxNbrIterations]
  } else {
    set maxNbrIterations $option(maxNbrIterations)
  }
  if {[GGV fspecMaxDurationHrs] != "ERROR"} {
    set maxDurationHrs [GGV fspecMaxDurationHrs]
  } else {
    set maxDurationHrs $option(maxDurationHrs)
  }
  if {[GGV fspecBgpNlriBufMax_specialDistribution] != "ERROR"} {
    set bgpNlriBufMax_specialDistribution [GGV fspecBgpNlriBufMax_specialDistribution]
  } else {
    set bgpNlriBufMax_specialDistribution $option(bgpNlriBufMax_specialDistribution)
  }
  if {[GGV fspecNeverDisableDutLogging] != "ERROR"} {
    set neverDisableDutLogging [GGV fspecNeverDisableDutLogging]
  } else {
    set neverDisableDutLogging $option(neverDisableDutLogging)
  }
  if {[GGV fspecEnableFlowspecBeforeFlowroutesAreInjected] != "ERROR"} {
    set enableFlowspecBeforeFlowroutesAreInjected [GGV fspecEnableFlowspecBeforeFlowroutesAreInjected]
  } else {
    set enableFlowspecBeforeFlowroutesAreInjected $option(enableFlowspecBeforeFlowroutesAreInjected)
  }
  if {[GGV withdrawAnnounceFlowroutesDuringSwoDurationMinutes] != "ERROR"} {
    set withdrawAnnounceFlowroutesDuringSwoDurationMinutes [GGV withdrawAnnounceFlowroutesDuringSwoDurationMinutes]
  } else {
    set withdrawAnnounceFlowroutesDuringSwoDurationMinutes $option(withdrawAnnounceFlowroutesDuringSwoDurationMinutes)
  }
  if {[GGV fSpecRedTestModuleId] != "ERROR"} {
    set redTestModuleId [GGV fSpecRedTestModuleId]
  } else {
    set redTestModuleId $option(redTestModuleId)
  }
  if {[GGV fSpecRedTestTableId] != "ERROR"} {
    set redTestTableId [GGV fSpecRedTestTableId]
  } else {
    set redTestTableId $option(redTestTableId)
  }
  if {[GGV fSpecRedTestMaxRedUpd] != "ERROR"} {
    set redTestMaxRedUpd [GGV fSpecRedTestMaxRedUpd]
  } else {
    set redTestMaxRedUpd $option(redTestMaxRedUpd)
  }
  if {[GGV fSpecRedTestNbIter] != "ERROR"} {
    set redTestNbIter [GGV fSpecRedTestNbIter]
  } else {
    set redTestNbIter $option(redTestNbIter)
  }
  if {[GGV fSpecReannounceRemainingWithdrawnFlowroutesDuringReconcile] != "ERROR"} {
    set reannounceRemainingWithdrawnFlowroutesDuringReconcile [GGV fSpecReannounceRemainingWithdrawnFlowroutesDuringReconcile]
  } else {
    set reannounceRemainingWithdrawnFlowroutesDuringReconcile $option(reannounceRemainingWithdrawnFlowroutesDuringReconcile)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]

  if {$bgpNlriBufMax_specialDistribution} {
    # vprnIdList => thisVprnId | thisNbrFlowroutesPerVprn | thisActionListPerVprn
    # vprnIdOnlyList => has only the vprnId's
    # Use a specialDistribution to stress the reshuffle mechanism
    set vprnIdList "" ; set vprnIdOnlyList "" ; set nbrVprns 0
    lappend vprnIdList [expr $minVprnId + 0] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 0] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 1] 8 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 1] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 2] 24 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 2] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 3] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 3] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 4] 3 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 4] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 5] 29 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 5] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 6] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 6] ; incr nbrVprns
  } else {
    # vprnIdList => thisVprnId | thisNbrFlowroutesPerVprn | thisActionListPerVprn
    # vprnIdOnlyList => has only the vprnId's
    set vprnIdList "" ; set vprnIdOnlyList ""
    for {set vprnId 1} {$vprnId <= $nbrVprns} {incr vprnId} {
      lappend vprnIdList [expr $minVprnId - 1 + $vprnId] ; lappend vprnIdOnlyList [expr $minVprnId - 1 + $vprnId]
      lappend vprnIdList $nbrFlowroutesPerVprn
      lappend vprnIdList $actionListPerVprn
    }
  }
  # Use the next dot1q tag for the Base
  set baseDot1qTag [expr [lindex $vprnIdOnlyList end] + 1]
  
  set nbrStreamsFamilies 0 ; if {$sendTraffic_v4} {incr nbrStreamsFamilies} ; if {$sendTraffic_v6} {incr nbrStreamsFamilies}
  if {$addFlowroutesInBase} {
    set nbrStreamsUsed [expr [expr $nbrVprns + 1] * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  } else {
    set nbrStreamsUsed [expr $nbrVprns * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  }
  
  # Check the testcase limitations (begin)
  if {$nbrVprns > 250 || $nbrVprns < 3} {
    log_msg ERROR "id18234 Testcase couldn't handle > 250 vprn's (ip addr limitation) and not < 3 vprn's" ; set Result FAIL
  }
  
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
    if {$thisNbrFlowroutesPerVprn > 221} {
      log_msg ERROR "id3780 Testcase couldn't handle >221 (223-2 ; \"-2\" because dot1q=1 is reserved on Linux & one dot1q reserved for Base) flowroutes per vprn because of ip address limitation" ; set Result FAIL ; break
    }
  }
  # Check the testcase limitations (end)
  
  set pktRatePerStream 2 ; set pktSize 128 ; set streamData_ISATMS "49 53 41 54 4D 53" ; set rawProtocol 253
  set trafficDurationSecsDuringPrecondition 30
  
  # the vprn (to redirect) is between dut2/dut4
  set thisRT "target:42:1"
   
  set enableTraceDutList [list $dut2 $dut3]
  
  # spokeSdp case
  set spokeIesId 5000 ; set spokeSdpId 1 ; set spokeSdpVcId 1
  
  if {$sendBgpFlowrouteUpd_v4 && $sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv4 ipv6]
  } elseif {$sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv6]
  } else {
    set thisFilterFamilyList [list ipv4]
  }
  set groupName "onegroup"
  
  # 101..199 => always 101 for flowspec
  set filterLogId 101
  
  set rollbackLocation "ftp://$::TestDB::thisTestBed:tigris@$::TestDB::thisHostIpAddr/$logdir/device_logs/saved_configs"
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : Check basic BGP flowspec VPRN behavior"
  log_msg INFO "# Setup:"
  log_msg INFO "# "
  log_msg INFO "#                              PE($dut4)----------> scrubber (Ixia)"
  log_msg INFO "#                               dut4 (dest for redirect actions)"
  log_msg INFO "#                                |"
  log_msg INFO "#                                |"
  log_msg INFO "#                                |       +-- Base-Base(dut2-dut3): BGP to exchange IPv4, IPv6 & flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): BGP in the VPRN to exchange flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): L3-VPN to exchange IPv4 & IPv6 routes"
  log_msg INFO "#                                |       |"
  log_msg INFO "#                                |       v"
  log_msg INFO "#   Ixia----------dut1----------dut2----------dut3----------dut6"
  log_msg INFO "#                CE1($dut1)    PE($dut2)     PE($dut3)     CE2($dut6)"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                             Linux (In VPRN & Base: Injects flowroutes via sbgp)"
  log_msg INFO "# "
  log_msg INFO "# Important testcase parameters:"
  log_msg INFO "#   vprnIdOnlyList: $vprnIdOnlyList"
  log_msg INFO "#   vprnIdList: vprnId | nbrFlowroutesPerVprn | thisActionListPerVprn"
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
  set actionPrefixAString ""
  foreach thisAction $thisActionListPerVprn {
    append actionPrefixAString "$thisAction\([set a_[set thisAction]].x.x.x\) "
  }
  log_msg INFO [format "%1s %13s %6s | %20s | \"%30s\" " "#" " "  $thisVprnId $thisNbrFlowroutesPerVprn $actionPrefixAString]
  }
  if {$addFlowroutesInBase} {set fTxt "(baseDot1qTag: $baseDot1qTag)"} else {set fTxt ""}
  log_msg INFO "#   addFlowroutesInBase: $addFlowroutesInBase $fTxt"
  log_msg INFO "#   sendBgpPrefixUpd_v4: $sendBgpPrefixUpd_v4 sendBgpPrefixUpd_v6: $sendBgpPrefixUpd_v6"
  log_msg INFO "#   sendBgpFlowrouteUpd_v4: $sendBgpFlowrouteUpd_v4 sendBgpFlowrouteUpd_v6: $sendBgpFlowrouteUpd_v6"
  log_msg INFO "#   sendTraffic_v4: $sendTraffic_v4 sendTraffic_v6: $sendTraffic_v6 (nbrStreamsFamilies: $nbrStreamsFamilies nbrStreamsUsed: $nbrStreamsUsed)"
  log_msg INFO "#   enableIngressFlowspec_v4: $enableIngressFlowspec_v4 enableIngressFlowspec_v6: $enableIngressFlowspec_v6"
  log_msg INFO "#   enableFlowspecBeforeFlowroutesAreInjected: $enableFlowspecBeforeFlowroutesAreInjected"
  log_msg INFO "#   vrfTargetDirectUnderVprn_noImportPolicy: $vrfTargetDirectUnderVprn_noImportPolicy"
  log_msg INFO "#   itfType_dut1dut2: $itfType_dut1dut2"
  log_msg INFO "#   addDefFilterInFirstVprnBeforeFlowroutesAreInjected: $addDefFilterInFirstVprnBeforeFlowroutesAreInjected (filter-id: $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId)"
  log_msg INFO "#   addDefFilterInLastVprnAfterFlowroutesAreInjected: $addDefFilterInLastVprnAfterFlowroutesAreInjected (filter-id: $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId)"
  switch $iterationMethod {
    "maxNbrIterations" {set iMethTxt "maxNbrIterations: $maxNbrIterations"}
    "maxDuration" {set iMethTxt "maxDurationHrs: $maxDurationHrs"}
    "ifFileExists" {set iMethTxt "fileExistsName: $option(fileExistsName)"}
  }
  log_msg INFO "#   iterationMethod: $iterationMethod => $iMethTxt"
  log_msg INFO "#   actionExpectedBehaviorList:"
  log_msg INFO [format "%1s %5s %50s | %45s " "#" " " action expectedBehavior] ; log_msg INFO [format "%1s %5s %50s + %45s " "#" " " "--------------------------------------------------" "--------------------------------------------"]
  foreach {action expectedBehavior} $actionExpectedBehaviorList {
  log_msg INFO [format "%1s %5s %50s | %45s " "#" " " $action $expectedBehavior]
  }
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  set dutLoggingDisabled false
  if {([expr $nbrVprns * $nbrFlowroutesPerVprn] > 16)} {
    if {$neverDisableDutLogging} {
      log_msg WARNING "Disable logging in dut-logs NOT done because neverDisableDutLogging: $neverDisableDutLogging"
    } else {
      log_msg WARNING "Disable logging in dut-logs because scale is too high"
      set dutLoggingDisabled true
      foreach dut $dutList {
        $dut configure -logging false
      }
    }
  }

  log_msg DEBUG "handlePacket -action reset -portList all ..."
  handlePacket -action reset -portList all
  log_msg DEBUG "handlePacket -action reset -portList all done!"
  CLN.reset
  set cliTimeoutOrig [$dut2 cget -cli_timeout]
  $dut2 configure -cli_timeout $option(cliTimeout)

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as [set [set dut1]_AS]"
    CLN "dut $dut2 systemip [set [set dut2]_ifsystem_ip] isisarea $isisAreaId as [set [set dut2]_AS]"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as [set [set dut3]_AS]"
    CLN "dut $dut4 systemip [set [set dut4]_ifsystem_ip] isisarea $isisAreaId as [set [set dut4]_AS]"
    CLN "dut $dut5 systemip [set [set dut5]_ifsystem_ip] isisarea $isisAreaId as [set [set dut5]_AS]"
    CLN "dut $dut6 systemip [set [set dut6]_ifsystem_ip] isisarea $isisAreaId as [set [set dut6]_AS]"
    
    set a 30 ; set b [expr 20 + [lindex $vprnIdOnlyList 0]] ; set c 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn } $vprnIdList {
      CLN "dut $dut2 vprnid $thisVprnId systemip $a.$b.$c.2 as [set [set dut2]_AS]"
      CLN "dut $dut3 vprnid $thisVprnId systemip $a.$b.$c.3 as [set [set dut3]_AS]"
      incr b ; if {$b > 255} {set b 0 ; incr a}
    }
    
    # used for spokes dut1/dut2
    CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q 1 ip 1.1.1.1 ldp true mpls true"
    CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q 1 ip 1.1.1.2 ldp true mpls true" 
    
    # In the CE's, bgp routes are learned from different peers (the neighbor end point is in different vprn).
    # The learned bgp routes are installed in the Base routing-table and exported again to all neighbors (default ebgp behavior).
    # To avoid that the neigbor end points (in different vprn's) receive the exported bgp routes (CE's Base instance) a reject policy should be installed.
    CLN "dut $dut1 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    CLN "dut $dut6 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    
    # Exchange flowroutes via BGP peer in the VPRN, because SAFI=134 (exchange flowroutes via L3-VPN) is not supported 
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut3 tonode $dut2 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut3 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'flow-ipv4 flow-ipv6' " 
    }

    # redistribute bgp-vpn in ospf
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 to 'protocol ospf' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 to 'protocol ospf3' action accept"

    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      #
      if {$itfType_dut1dut2 == "spoke"} {
        CLN "dut $dut1 tonode $dut2 porttype hybrid iesid $spokeIesId iftype spoke sdpid '$spokeSdpId gre [set [set dut2]_ifsystem_ip]' dot1q $thisVprnId ip $thisVprnId.$dataip(id.$dut1).$dataip(id.$dut2).$dataip(id.$dut1) ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid iftype spoke sdpid '$spokeSdpId gre [set [set dut1]_ifsystem_ip]' vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      } else {      
        CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      }
   
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut6]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut6]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
      CLN "dut $dut3 tonode $dut6 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut3]_ifsystem_ip] as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      
      CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut2 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
      CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
    }
    
    if {$addFlowroutesInBase} {
      CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut2]_ifsystem_ip]  bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true"
      CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut3]_ifsystem_ip] bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true" 
      #
      CLN "dut $dut3 tonode $dut6 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      #
      CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      #
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    # Ixia connections
    set filterEntryId 1
    foreach thisAction $actionListPerVprn {
      CLN "dut $dut1 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut6 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut1 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      CLN "dut $dut6 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      incr filterEntryId
    }
    CLN "dut $dut1 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut $dut6 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut Ixia tonode $dut1"
    CLN "dut Ixia tonode $dut6"
    
    # CE2: static routes and policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 to 'protocol ospf' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 to 'protocol ospf3' action accept"
        CLN "dut $dut6 ospf 'export fromStaticToVprns_v4' "
        CLN "dut $dut6 ospf3 'export fromStaticToVprns_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    # policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v4 prefix $thisDstPrefixMask_v4 longer' "
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v6 prefix $thisDstPrefixMask_v6 longer' "
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v4 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v4' action accept"
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v6 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v6' action accept"
        CLN "dut $dut3 vprnid $thisVprnId ospf 'import fromStaticToVprn[set thisVprnId]_v4' "
        CLN "dut $dut3 vprnid $thisVprnId ospf3 'import fromStaticToVprn[set thisVprnId]_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    if {$addFlowroutesInBase} {
      # - Don't reset b, c and d because they point to the next values to be used
      # - Use isis in the Base instance
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v4 prefix $thisDstPrefixMask_v4 longer' "
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v6 prefix $thisDstPrefixMask_v6 longer' "
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v4' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v6' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 isis 'export fromStaticToBase[set baseDot1qTag]_v4 fromStaticToBase[set baseDot1qTag]_v6'"
      }
    }
    
    # used in redirectToVrf
    CLN "dut $dut2 tonode $dut4 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut4 tonode $dut2 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut2 bgpneighbor [set [set dut4]_ifsystem_ip] bgppeeras [set [set dut4]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"   
    CLN "dut $dut4 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras [set [set dut2]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"
    
    CLN.exec
    CLN.reset
    
    set thisPePeList [list $dut2 $dut3]
    foreach dut $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        docli $dut "configure router"
        docli $dut "         policy-options"
        docli $dut "            begin"
        docli $dut "            community vprn_[set thisVprnId]_exportRouteTarget members target:1982:$thisVprnId"
        docli $dut "            community vprn_[set thisVprnId]_importRouteTarget members target:1982:$thisVprnId"
        docli $dut "            policy-statement vprn_[set thisVprnId]_exportPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol ospf"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "                entry 2"
        docli $dut "                    from"
        docli $dut "                        protocol ospf3"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            policy-statement vprn_[set thisVprnId]_importPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                        community vprn_[set thisVprnId]_importRouteTarget"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            commit"
        docli $dut "        exit all"
      }
    }
    foreach dut $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        docli $dut "configure service vprn $thisVprnId" 
        docli $dut "no vrf-target"
        docli $dut "vrf-import vprn_[set thisVprnId]_importPol"
        docli $dut "vrf-export vprn_[set thisVprnId]_exportPol"
        docli $dut "exit all"
      }
    }

    # used in redirectToVrf
    set redirectVprnId 400 ; set customerId 1 ; set nbrRedirectVprn 4 
    set firstRedirectVprnId $redirectVprnId
    set maxRedirectVprnId [expr $firstRedirectVprnId + $nbrRedirectVprn - 1]
    set minRedirectVprnId $redirectVprnId
    #                                           dut       thisDutId            ngbrDutId                 itfToNgbr
    set redirectVprnDutList [list $dut2 $dataip(id.$dut2) $dataip(id.$dut4) $dataip(ip.1.$dut2.$dut4) $dut4 $dataip(id.$dut4) $dataip(id.$dut2) $dataip(ip.1.$dut4.$dut2)]
    #
    # Also needed is a path from Dut-D to Ixia2 (scrubber).
    #   - In Dut-D: add port to Dut-E in vprn
    #   - In Dut-E: epipe between port to Dut-D and port to Dut-C
    #   - In Dut-C: epipe between port to Dut-E and port to Ixia2
    #                                         dut  epipeId fromPort toPort
    set epipeListToScrubber [list $dut5 666 $portA($dut5.$dut4) $portA($dut5.$dut3) \
                                                $dut3 667 $portA($dut3.$dut5) $portA($dut3.Ixia)]
    # Redirect is done in Dut-B
    set checkIpFlowspecFilterDutList [list $dut2]
  
    foreach {dut thisDutId ngbrDutId itfToNgbr} $redirectVprnDutList {
      docli $dut "configure router"
      docli $dut "         policy-options"
      docli $dut "            begin"
      docli $dut "            community \"vprn1_exportRouteTarget\" members \"target:[set thisDutId][set ngbrDutId]:1\" "
      docli $dut "            community \"vprn1_importRouteTarget_[set ngbrDutId]\" members \"target:[set ngbrDutId][set thisDutId]:1\" "
      docli $dut "            policy-statement vprn_exportPol_[set thisDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol direct"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "                entry 2"
      docli $dut "                    from"
      docli $dut "                        protocol static"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                        community vprn1_importRouteTarget_[set ngbrDutId]"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            commit"
      docli $dut "        exit all"
    }
    foreach {dut thisDutId ngbrDutId itfToNgbr} $redirectVprnDutList {
      docli $dut "configure service" -verbose $option(verbose)
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
        docli $dut "        vprn $thisRedirectVprnId customer 1 create" -verbose $option(verbose)
        docli $dut "            no shutdown" -verbose $option(verbose)
        if {$vCnt == [expr $nbrRedirectVprn - 1] && $vrfTargetDirectUnderVprn_noImportPolicy} {
          log_msg INFO "Don't use vrf-import policy for the last vprn $thisRedirectVprnId"
          docli $dut "            vrf-target target:[set ngbrDutId][set thisDutId]:1" -verbose $option(verbose)
        } else {
          docli $dut "            vrf-import vprn_importPol_[set thisDutId]_[set ngbrDutId]" -verbose $option(verbose)
        }
        docli $dut "            vrf-export vprn_exportPol_[set thisDutId]" -verbose $option(verbose)
        docli $dut "            route-distinguisher $thisRedirectVprnId:1" -verbose $option(verbose)
        docli $dut "            auto-bind gre" -verbose $option(verbose)
        docli $dut "        exit"  -verbose $option(verbose)
      }
      docli $dut "exit all" -verbose $option(verbose)
    }
    #
    if {$epipeListToScrubber != ""} {
      foreach {epipeDut epipeId epipeFromPort epipeToPort} $epipeListToScrubber {
        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
          set thisVlanId [expr $vCnt + 1] ; set thisEpipeId [expr $epipeId + $vCnt]
          flowspec_createEpipe $epipeDut $thisEpipeId $epipeFromPort $epipeToPort -fromEncapType dot1q -fromSap "$epipeFromPort:$thisVlanId" -toEncapType dot1q -toSap "$epipeToPort:$thisVlanId"
        }
      }
    }
    #
    log_msg INFO "$dut4: Create dot1q itfs (#$nbrRedirectVprn) via $portA($dut4.$dut5) and default-route (in vprn) to scrubber (Ixia $portA(Ixia.$dut3))"
    # create itf to scrubber (Ixia2)
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) shut"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet mode access"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet encap-type dot1q"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) no shut"] ; log_msg INFO "$rCli"
    for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
      set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
      set thisVlanId [expr $vCnt + 1]
      set rCli [$dut4 sendCliCommand "exit all"]
      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "sap $portA($dut4.$dut5):$thisVlanId create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.$dataip(id.$dut3)" "."] {break} ; set thisB [expr $thisB + $vCnt]
      set rCli [$dut4 sendCliCommand "address $thisA.$thisB.$thisC.$thisD/$clnItfMask_v4"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 address [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]/$clnItfMask_v6"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.9" "."] {break} ; set thisB [expr $thisB + $vCnt]
      set rCli [$dut4 sendCliCommand "static-route 0.0.0.0/0 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "static-route 0::0/0 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
      # Add here static-routes for the redirectToVrf vprn
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      if {$addFlowroutesInBase} {
        # - Don't reset b, c and d because they point to the next values to be used
        # - Use isis in the Base instance
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
      }
      #
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "static-arp $thisA.$thisB.$thisC.$thisD 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 neighbor [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD] 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
    }
    
    if {$enableFilterTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"FILTER\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
      }
    }
    if {$enableBgpFlowspecTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"BGP\" " -verbose $option(verbose)
        docli $dut "debug trace trace-point module \"BGP_VPRN\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
        # enableBgpFlowspecTrace $dut
        # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        #  enableBgpFlowspecTrace $dut2 -vprnId $thisVprnId
        # }
      }
    }
    
    if {$enableFlowspecBeforeFlowroutesAreInjected} {
      if {$enableIngressFlowspec_v4 || $enableIngressFlowspec_v6} {
        if {$enableIngressFlowspec_v4 && $enableIngressFlowspec_v6} {set thisTxt "flowspec/flowspec-ipv6"} elseif {$enableIngressFlowspec_v4} {set thisTxt "flowspec"} else {set thisTxt "flowspec-ipv6"}
        log_msg INFO "$dut2: Apply now ingress $thisTxt (on itf $dut1 => $dut2)"
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$itfType_dut1dut2 == "spoke"} {
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec-ipv6"] ; log_msg INFO $rCli
          } else {
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec-ipv6"] ; log_msg INFO $rCli
          }
        }
        #
        if {$addFlowroutesInBase} {
          set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec"] ; log_msg INFO $rCli
          set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec-ipv6"] ; log_msg INFO $rCli
        }
      }
    }
    if {[lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesDuringSwo"] != -1 || \
        [lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesSystematicHA"] != -1} {
      foreach dut $dutList {
        # set BGP min-route-advertisement delay to 1 second
        set rCli [$dut sendCliCommand "/configure router bgp min-route-advertisement 1"]
      }
    }
  } ; # config
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # Ixia part
    handlePacket -port $portA(Ixia.$dut1) -action stop
    set thisDA 00:00:00:00:00:[int2Hex1 $dataip(id.$dut1)]
    set totalNbrOfFlowroutes 0
    set startStreamId 1
    set streamId $startStreamId 
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }
    if {$addFlowroutesInBase} {
      # - Don't reset b, c and d because they point to the next values to be used
      # - Use isis in the Base instance
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
    }
    
    # scrubber
    handlePacket -port $portA(Ixia.$dut3) -action capture
    
    log_msg INFO "Wait till all vprn's are operational before inject flowspec"
    set nbrRedirectVprnOperStateUp 0
    foreach {dut} $checkIpFlowspecFilterDutList {break}
    for {set rCnt 1} {$rCnt <= $option(maxRetryCnt)} {incr rCnt} {
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
        set rCli [$dut sendCliCommand "show service id $thisRedirectVprnId all | match \"Oper State\" "]
        # Admin State       : Up                  Oper State        : Up
        if {[regexp {.*Oper State[ ]+:[ ]+([A-Za-z]+).*} $rCli match vprnOperState]} {
          if {$vprnOperState == "Up"} {
            incr nbrRedirectVprnOperStateUp
          }
        }
      }
      if {$nbrRedirectVprnOperStateUp == $nbrRedirectVprn} {
        log_msg INFO "All redirectVprn are Up ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn)"
        break
      } else {
        log_msg INFO "Waiting $option(interRetryTimeSec) sec ($rCnt/$option(maxRetryCnt)) till all redirectVprn ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn) are Up ..." ; after [expr $option(interRetryTimeSec) * 1000]
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "Precondition: Waiting 20secs and check that traffic flows from $dut1 to $dut6" ; after 20000
      log_msg INFO "$mySubtest"
      if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
        log_msg INFO "Traffic from $dut1 to $dut6 ok"
      } else {
        log_msg ERROR "id802 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
      }
      subtest "$mySubtest"
    }
  
    if {! [testFailed] && $Result == "OK"} {
      if {$addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
        $dut2 createIpFilterPolicy $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId -Def_Act forward
        $dut2 createIpv6FilterPolicy $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId -Def_Act forward
        log_msg INFO "$dut2: Apply ingress filter (ip/ipv6) $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (on itf $dut1 => $dut2)"
        set vprnCnt 1
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$vprnCnt == 1} {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ip $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ipv6 $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ip $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ipv6 $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            }
          }
          incr vprnCnt
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      # sbgp part
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$thisVprnId -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$baseDot1qTag -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
          }
        }
      }
      #
      set b 1 ; set c [lindex $vprnIdOnlyList 0] 
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 1
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
              if {[lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesSystematicHA"] != -1} {
                keylset thisFlowroute dstPrefix_v4 $thisDstPrefix_v4
                keylset thisFlowroute vprnId $thisVprnId
                keylset thisFlowroute ipVer 4
                keylset thisFlowroute base false
                keylset thisFlowroute flow1_v4 $flow1_v4
                keylset thisFlowroute comm1_v4 $comm1_v4
                keylset thisFlowroute nlriAs $nlriAs
                keylset thisFlowroute mpAfi $mpAfi
                keylset thisFlowroute mpSafi $mpSafi
                lappend flowrouteList $thisFlowroute
              }
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
              if {[lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesSystematicHA"] != -1} {
                keylset thisFlowroute dstPrefix_v4 $thisDstPrefix_v4
                keylset thisFlowroute vprnId $thisVprnId
                keylset thisFlowroute ipVer 6
                keylset thisFlowroute base false
                keylset thisFlowroute flow1_v6 $flow1_v6
                keylset thisFlowroute comm1_v6 $comm1_v6
                keylset thisFlowroute nlriAs $nlriAs
                keylset thisFlowroute mpAfi $mpAfi
                keylset thisFlowroute mpSafi $mpSafi
                lappend flowrouteList $thisFlowroute
              }
            }
            incr d
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 1
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
              if {[lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesSystematicHA"] != -1} {
                keylset thisFlowroute dstPrefix_v4 $thisDstPrefix_v4
                keylset thisFlowroute baseDot1qTag $baseDot1qTag
                keylset thisFlowroute ipVer 4
                keylset thisFlowroute base true
                keylset thisFlowroute flow1_v4 $flow1_v4
                keylset thisFlowroute comm1_v4 $comm1_v4
                keylset thisFlowroute nlriAs $nlriAs
                keylset thisFlowroute mpAfi $mpAfi
                keylset thisFlowroute mpSafi $mpSafi
                lappend flowrouteList $thisFlowroute
              }
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
              if {[lsearch $actionExpectedBehaviorList "withdrawAnnounceFlowroutesSystematicHA"] != -1} {
                keylset thisFlowroute dstPrefix_v4 $thisDstPrefix_v4
                keylset thisFlowroute baseDot1qTag $baseDot1qTag
                keylset thisFlowroute ipVer 6
                keylset thisFlowroute base true
                keylset thisFlowroute flow1_v6 $flow1_v6
                keylset thisFlowroute comm1_v6 $comm1_v6
                keylset thisFlowroute nlriAs $nlriAs
                keylset thisFlowroute mpAfi $mpAfi
                keylset thisFlowroute mpSafi $mpSafi
                lappend flowrouteList $thisFlowroute
              }
            }
            incr d
          }
        }
      }
      #
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        sbgp.run -id peer$thisVprnId
      }
      if {$addFlowroutesInBase} {
        sbgp.run -id peer$baseDot1qTag
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Check that debug log has no unexpected \"Optional Attribute Error\""
      log_msg INFO "$mySubtest"
      set rCli [$dut3 sendCliCommand "show log log-id $debugLog count 200 descending" -bufferedMode true] ; if {$dumpDebugLog} {log_msg INFO "$rCli"}
      if {[regexp {.*Optional Attribute Error.*} $rCli match]} {
        log_msg ERROR "id15002 Found unexpected \"Optional Attribute Error\""
      } else {
        log_msg INFO "No unexpected \"Optional Attribute Error\" found"
      }
      subtest "$mySubtest"
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {[expr $nbrVprns * $nbrFlowroutesPerVprn] > 16} {
        log_msg WARNING "Skip debug log check because scale is too high"
      } else {
        set mySubtest "$dut3: Check that debug log has all expected vprn's ($vprnIdOnlyList)"
        log_msg INFO "$mySubtest"
        if {[flowspec_checkBgpDebugLogForVprnId $dut3 $debugLog $vprnIdOnlyList]} {
          log_msg INFO "$dut3: Found all expected vprn's ($vprnIdOnlyList) in debug log (log-id: $debugLog)"
        } else {
          log_msg ERROR "id10731 $dut3: Couldn't find all expected vprn's ($vprnIdOnlyList) in debug log (log-id: $debugLog)"
        }
        subtest "$mySubtest"
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$enableFlowspecBeforeFlowroutesAreInjected} {
        # skip traffic check
      } else {
        set mySubtest "Check that traffic still flows from $dut1 to $dut6, because ingress flowspec/flowspec-ipv6 is not yet applied"
        log_msg INFO "$mySubtest"
        if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
          log_msg INFO "Traffic from $dut1 to $dut6 ok"
        } else {
          log_msg ERROR "id5147 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
        }
        subtest "$mySubtest"
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$enableFlowspecBeforeFlowroutesAreInjected} {
        # already done earlier
      } else {
        if {$enableIngressFlowspec_v4 || $enableIngressFlowspec_v6} {
          if {$enableIngressFlowspec_v4 && $enableIngressFlowspec_v6} {set thisTxt "flowspec/flowspec-ipv6"} elseif {$enableIngressFlowspec_v4} {set thisTxt "flowspec"} else {set thisTxt "flowspec-ipv6"}
          set mySubtest "$dut2: Apply now ingress $thisTxt (on itf $dut1 => $dut2)"
          log_msg INFO "$mySubtest"
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec-ipv6"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec-ipv6"] ; log_msg INFO $rCli
            }
          }
          #
          if {$addFlowroutesInBase} {
            set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec-ipv6"] ; log_msg INFO $rCli
          }
          subtest "$mySubtest"
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$addDefFilterInLastVprnAfterFlowroutesAreInjected} {
        $dut2 createIpFilterPolicy $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId -Def_Act forward
        $dut2 createIpv6FilterPolicy $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId -Def_Act forward
        log_msg INFO "$dut2: Apply ingress filter (ip/ipv6) $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (on itf $dut1 => $dut2)"
        set vprnCnt 1 
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$vprnCnt == $nbrVprns} {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ip $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ipv6 $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ip $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ipv6 $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            }
          }
          incr vprnCnt
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set startTimeStampSec [clock seconds]
      set whileContinue 1 ; set iterationCnt 0
      while {$whileContinue} {
        incr iterationCnt
        foreach {action expectedBehavior} $actionExpectedBehaviorList {
          log_msg INFO "" ; log_msg INFO "======================================================================"
          log_msg INFO "iteration: $iterationCnt | action: \"$action\" => expectedBehavior: \"$expectedBehavior\" "
          log_msg INFO "======================================================================" ; log_msg INFO ""
          # These are the different actions
          switch $action {
            "none" {
              # no action needed
            }
            
            "swo" - "doubleSwo" {
              #
              log_msg INFO "$dut2: Show fSpec-x BEFORE switchover"
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  log_msg INFO "" 
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                  log_msg INFO ""
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  log_msg INFO ""
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                  log_msg INFO ""
                }
                #
                log_msg INFO "$dut2: Show filter $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId) BEFORE switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                log_msg INFO "$dut2: Show filter $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId) BEFORE switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                #
              } ; #thisFilterFamilyList 
                
              
              #
              set actionTodo doubleSwo
              if {$actionTodo == "swo"} {set  nbrSwoToDo 1} else {set nbrSwoToDo 2}
              for {set swoNbr 1} {$swoNbr <= $nbrSwoToDo} {incr swoNbr} {
                set activitySwitchMethod [lindex $fspecSwoMethodList [random $fspecSwoMethodListLen]]
                log_msg INFO "$dut2: Switchover $swoNbr/$nbrSwoToDo activitySwitchMethod: $activitySwitchMethod"
                if {[$dut2 activitySwitch -inSyncTime1 11 -skipCheck true -inSyncTime3 2000 -Method $activitySwitchMethod] == "OK"} {
                  # nop
                } else {
                  log_msg ERROR "id838 $dut2: Switchover failed" ; set Result FAIL ; break
                }
                after 1000 ; $dut2 closeExpectSession ; after 1000 ; $dut2 openExpectSession ; after 1000
                log_msg INFO "$dut2: Wait until standby is synchronized"
                if {[$dut2 CnWSecInSync] == "OK"} {
                  log_msg INFO "$dut2: Standby is in sync now - a new switchover is allowed"
                  after 5000
                  $dut2 closeExpectSession ; after 1000 ; $dut2 openExpectSession ; after 1000
                } else {
                  log_msg ERROR "id31871 $dut2: Standby not yet in sync" ; set Result FAIL ; break
                }
              }
              #
              log_msg INFO "$dut2: Show fSpec-x AFTER switchover"
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli" 
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                }
                #
                log_msg INFO "$dut2: Show filter $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId) AFTER switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                log_msg INFO "$dut2: Show filter $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId) AFTER switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                #
              } ; #thisFilterFamilyList 
              #
            }
            
            "shutFirstVprn" - "noShutFirstVprn" {
              if {[regexp {noShut} $action match]} {set shutNoShutTxt "no shut"} else {set shutNoShutTxt "shut"}
              # The first vprn is one with merged fSpec entries into addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
              set vprnCnt 1
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                if {$vprnCnt == 1} {
                  set shutVprnId $thisVprnId
                  if {! [regexp {noShut} $action match]} {
                    # get the active filter-id before the shut
                    if {$itfType_dut1dut2 == "spoke"} {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dataip(id.$dut1))
                    } else {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dut1)
                    }
                    flowspec_getActiveFilterIdFromService $dut2 $shutVprnId $sdpOrSap igIpv4FltrIdActiveBeforeShut igIpv6FltrIdActiveBeforeShut
                  }
                  set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId $shutNoShutTxt"] ; log_msg INFO "$rCli"
                  break
                }
                incr vprnCnt
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "shutNextVprn" - "noShutNextVprn" {
              if {[regexp {noShut} $action match]} {set shutNoShutTxt "no shut"} else {set shutNoShutTxt "shut"}
              # The next vprn is one with non merged fSpec entries
              set vprnCnt 1
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                if {$vprnCnt > 1} {
                  set shutVprnId $thisVprnId
                  if {! [regexp {noShut} $action match]} {
                    # get the active filter-id before the shut
                    if {$itfType_dut1dut2 == "spoke"} {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dataip(id.$dut1))
                    } else {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dut1)
                    }
                    flowspec_getActiveFilterIdFromService $dut2 $shutVprnId $sdpOrSap igIpv4FltrIdActiveBeforeShut igIpv6FltrIdActiveBeforeShut
                  }
                  set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId $shutNoShutTxt"] ; log_msg INFO "$rCli"
                  break
                }
                incr vprnCnt
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
                      
            "withdrawAllIpv4v6Flowroutes" {
              set b 1 ; set c [lindex $vprnIdOnlyList 0] 
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 1
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                    }
                    incr d
                  }
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                sbgp.run -id peer$thisVprnId
              }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 1
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                    }
                    incr d
                  }
                }
                sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "announceAllIpv4v6FlowroutesAgain" {
              set b 1 ; set c [lindex $vprnIdOnlyList 0] 
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 1
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {$thisAction == "redirectVrf"} {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    } else {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                    }
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
                    }
                    incr d
                  }
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                sbgp.run -id peer$thisVprnId
              }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 1
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {$thisAction == "redirectVrf"} {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    } else {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                    }
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
                    }
                    incr d
                  }
                }
                sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "stopTrafficAndClearFilters" {
              handlePacket -port $portA(Ixia.$dut1) -action stop ; after 5000
              #
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                set vprnCnt 1 
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                  } else {
                    set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  }
                  incr vprnCnt

                  set rCli [$dut2 sendCliCommand "clear filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli" 
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  set rCli [$dut2 sendCliCommand "clear filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                }
                #
              } ; #thisFilterFamilyList 
              # 
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "startTraffic" {
              handlePacket -port $portA(Ixia.$dut1) -action start ; after 5000
            }
            
            "rollback" {
              log_msg INFO "Create rollback checkpoint, remove configuration and restore via rollback revert"
              #
              log_msg DEBUG "##### vvvvv Extra info to catch bug201941 (before rollback) vvvvv #####"
              set rShell [$dut2 sendCliCommand "shell pipVrIdDump"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell pipVrfShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell smgrRedSvcShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ip"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ipv6"] ; log_msg DEBUG "$rShell"
              log_msg DEBUG "##### ^^^^^ Extra info to catch bug201941 (before rollback) ^^^^^ #####"
              #
              set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
              #
              after 1000
              saveOrRestore delete -dut $dut2
              after 5000
              log_msg DEBUG "##### vvvvv Extra info to catch bug201941 (after delete all config - via rollback to clean config) vvvvv #####"
              set rShell [$dut2 sendCliCommand "shell pipVrIdDump"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell pipVrfShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell smgrRedSvcShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ip"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ipv6"] ; log_msg DEBUG "$rShell"
              log_msg DEBUG "##### ^^^^^ Extra info to catch bug201941 (after delete all config - via rollback to clean config) ^^^^^ #####"
              # configure rollback-location again because it was removed during saveOrRestore delete
              set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
              log_msg DEBUG "##### vvvvv Extra info to catch bug201941 (after rollback) vvvvv #####"
              set rShell [$dut2 sendCliCommand "shell pipVrIdDump"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell pipVrfShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell smgrRedSvcShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ip"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ipv6"] ; log_msg DEBUG "$rShell"
              log_msg DEBUG "##### ^^^^^ Extra info to catch bug201941 (after rollback) ^^^^^ #####"
              log_msg INFO "Waiting 20secs ...." ; after 20000
              log_msg DEBUG "##### vvvvv Extra info to catch bug201941 (after rollback - 20 seconds later) vvvvv #####"
              set rShell [$dut2 sendCliCommand "shell pipVrIdDump"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell pipVrfShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "shell smgrRedSvcShow"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ip"] ; log_msg DEBUG "$rShell"
              set rShell [$dut2 sendCliCommand "show filter ipv6"] ; log_msg DEBUG "$rShell"
              log_msg DEBUG "##### ^^^^^ Extra info to catch bug201941 (after rollback - 20 seconds later) ^^^^^ #####"
              #
            }
            
            "clearBgpNeighbor" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3)"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "clear router bgp neighbor [set [set dut3]_ifsystem_ip]"] ; log_msg INFO "$rCli"
              }
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "clearBgpProtocol" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "clear router $thisVprnId bgp protocol"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "clear router bgp protocol"] ; log_msg INFO "$rCli"
              }
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "shutNoShutBgpNeighbor_waitOnZeroAndOnAllFlowroutes" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3) shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp group $groupName neighbor [set [set dut3]_ifsystem_ip] shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id22306 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3) no shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp group $groupName neighbor [set [set dut3]_ifsystem_ip] no shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id8448 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
            }
            
            "shutNoShutBgpProtocol_waitOnZeroAndOnAllFlowroutes" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id29847 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp no shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp no shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id1515 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
            }
            
            "adminTech" {
              set rCli [$dut2 sendCliCommand "admin tech-support ftp://$::TestDB::thisTestBed:tigris@$::TestDB::thisHostIpAddr/$logdir/device_logs/saved_configs/thisAT_[tms_uptimeSecs $dut2]"] ; log_msg INFO "$rCli"
            }
            
            "announceWithdrawTooMuchIpv4v6Flowroutes" {
              log_msg INFO "First announce tooMuch IPv4/IPv6 flowroutes in Base & vprn context"
              set tooMuch_v4 0 ; set tooMuch_v6 0
              set tooMuchContextList_v4 "" ; set tooMuchContextList_v6 ""
              set rCli [$dut2 sendCliCommand "clear log 99" -verbose true] ; log_msg INFO "$rCli"

              set b 1 ; set c [lindex $vprnIdOnlyList 0]
              # The events are throttled, so generate only a flowroute in first vprn and for one action
              set thisVprnCnt 0
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                incr thisVprnCnt
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisVprnCnt == 1 && $thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action/one vprn (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "vprn$thisVprnId"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "vprn$thisVprnId"
              waitDampeningTime
                    }
                  }
                # 
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
              #   sbgp.run -id peer$thisVprnId
              # }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                # the events are trottled, so generate only a flowroute for one action
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]

                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "Base"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "Base"
              waitDampeningTime
                    }
                  }
                  #
                }
                #sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
              #
              log_msg INFO "" ; log_msg INFO "Expecting tooMuch_v4: $tooMuch_v4 and  tooMuch_v6: $tooMuch_v6" ; log_msg INFO ""
              set rShell [$dut2 sendCliCommand "shell fltrAutoGen_ShowNlriStoreCounts"] ; log_msg INFO "$rShell"
              set rCli [$dut2 sendCliCommand "show log log-id 99 application \"filter\""] ; log_msg INFO "$rCli"
              if {$tooMuch_v4 > 0} {
                foreach tooMuchContext $tooMuchContextList_v4 {
                  set pat ".*fltrtypeselIp Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg INFO "Found \"$pat\""
                  } else {
                    log_msg ERROR "id19808 Couldn't find \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  }
                }
              }
              if {$tooMuch_v6} {
                foreach tooMuchContext $tooMuchContextList_v6 {
                  set pat ".*fltrtypeselIpv6 Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg INFO "Found \"$pat\""
                  } else {
                    log_msg ERROR "id26960 Couldn't find \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  }
                }
              }
              #
              log_msg INFO "Now withdraw tooMuch IPv4/IPv6 flowroutes in Base & vprn context"
              set tooMuch_v4 0 ; set tooMuch_v6 0
              set tooMuchContextList_v4 "" ; set tooMuchContextList_v6 ""
              set rCli [$dut2 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
              set b 1 ; set c [lindex $vprnIdOnlyList 0]
              # The events are throttled, so generate only a flowroute in first vprn and for one action
              set thisVprnCnt 0
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                incr thisVprnCnt
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisVprnCnt == 1 && $thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action/one vprn (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "vprn$thisVprnId"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "vprn$thisVprnId"
              waitDampeningTime
                    }
                  }
                # 
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
              #   sbgp.run -id peer$thisVprnId
              # }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                # the events are trottled, so generate only a flowroute for one action
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "Base"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "Base"
              waitDampeningTime
                    }
                  }
                  #
                }
                #sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
              #
              log_msg INFO "" ; log_msg INFO "Expecting tooMuch_v4: $tooMuch_v4 and  tooMuch_v6: $tooMuch_v6" ; log_msg INFO ""
              set rShell [$dut2 sendCliCommand "shell fltrAutoGen_ShowNlriStoreCounts"] ; log_msg INFO "$rShell"
              set rCli [$dut2 sendCliCommand "show log log-id 99 application \"filter\""] ; log_msg INFO "$rCli"
              if {$tooMuch_v4 > 0} {
                foreach tooMuchContext $tooMuchContextList_v4 {
                  set pat ".*fltrtypeselIp Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg ERROR "id9704 Found unexpected \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  } else {
                    log_msg INFO "Couldn't find (exp behavior) \"$pat\""
                  }
                }
              }
              if {$tooMuch_v6} {
                foreach tooMuchContext $tooMuchContextList_v6 {
                  set pat ".*fltrtypeselIpv6 Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg ERROR "id4969 Found unexpected \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  } else {
                    log_msg INFO "Couldn't find (exp behavior) \"$pat\""
                  }
                }
              }
              #
            }
            
            "withdrawAnnounceFlowroutesDuringSwo" {
              # Admin reboot active (non-blocking) of dut2
              set rCli [$dut2 sendCliCommand "/admin reboot active now" -nonBlockingMode true] ; log_msg INFO "$rCli"
              after 500 ; $dut2 closeExpectSession ; after 500 ; $dut2 openExpectSession
              
              # During > 5 min withdraw/announce the flowroutes continously
              set actionLoopStartTimestampSec [clock seconds]
              set actionLoopMinEndTimestampSec [expr $actionLoopStartTimestampSec + 60 * $withdrawAnnounceFlowroutesDuringSwoDurationMinutes]
              set iterationCounter 1
              
              while {[clock seconds] < $actionLoopMinEndTimestampSec} {
                log_msg INFO "withdraw/announce: iteration #$iterationCounter"
                # BEGIN copy body of action "withdrawAllIpv4v6Flowroutes"
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set d 1
                    for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                      if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                        log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      }
                      if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                        log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      }
                      incr d
                    }
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  sbgp.run -id peer$thisVprnId
                }
                #
                if {$addFlowroutesInBase} {
                  # - Don't reset b and c because they point to the next values to be used
                  foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set d 1
                    for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                      if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                        log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      }
                      if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                        log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      }
                      incr d
                    }
                  }
                  sbgp.run -id peer$baseDot1qTag
                }
                #
                # log_msg INFO "Waiting 30secs..." ; after 30000
                # END copy body of action "withdrawAllIpv4v6Flowroutes"
                # BEGIN copy body of action "announceAllIpv4v6FlowroutesAgain"
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set d 1
                    for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                      if {$thisAction == "redirectVrf"} {
                        set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                        set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      } else {
                        set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                        set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                      }
                      if {$sendBgpFlowrouteUpd_v4} {
                        log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      }
                      if {$sendBgpFlowrouteUpd_v6} {
                        log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                        sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
                      }
                      incr d
                    }
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  sbgp.run -id peer$thisVprnId
                }
                #
                if {$addFlowroutesInBase} {
                  # - Don't reset b and c because they point to the next values to be used
                  foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set d 1
                    for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                      if {$thisAction == "redirectVrf"} {
                        set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                        set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      } else {
                        set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                        set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                      }
                      if {$sendBgpFlowrouteUpd_v4} {
                        log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                        sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      }
                      if {$sendBgpFlowrouteUpd_v6} {
                        log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                        sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
                      }
                      incr d
                      
                    }
                  }
                  sbgp.run -id peer$baseDot1qTag
                }
                #
                # log_msg INFO "Waiting 30secs..." ; after 30000
                # END copy body of action "announceAllIpv4v6FlowroutesAgain"
              }
            }
            
            "withdrawAnnounceFlowroutesSystematicHA" {
              # NOTE: Make sure the events are a (random) mixture of add and deletes. Also: send the BGP events 
              # “fast” enough (if that is possible) so that each (some) event(s) is (are) not yet fully 
              # processed by the filter and downloaded to the IOMs.
              
              proc callSbgpAdd {action flowroute} {
                upvar dut3 dut3; upvar dataip dataip
                set sbgpCall [list "sbgp.add"]
                
                if {[keylget flowroute ipVer] == 4} {
                  set flow1 [keylget flowroute flow1_v4]
                  set comm1 [keylget flowroute comm1_v4]
                } else {
                  set flow1 [keylget flowroute flow1_v6]
                  set comm1 [keylget flowroute comm1_v6]
                }
                
                if {[keylget flowroute base] == false} {
                  set vprnIdOrbaseDot1qTag [keylget flowroute vprnId]
                } else {
                  set vprnIdOrbaseDot1qTag [keylget flowroute baseDot1qTag]
                }
                
                set sbgpCall [concat $sbgpCall "-id \"peer$vprnIdOrbaseDot1qTag\""]
                
                if {$action == "announce"} {
                  set sbgpCall [concat $sbgpCall "-mpReachRaw \"$flow1\""]
                } else { ;# withdraw
                  set sbgpCall [concat $sbgpCall "-mpUnReachRaw \"$flow1\""]
                }
                
                if {$action == "announce"} {
                  set sbgpCall [concat $sbgpCall "-community \"$comm1\""]
                  set sbgpCall [concat $sbgpCall "-nlriAs \"[keylget flowroute nlriAs]\""]
                }
                
                set sbgpCall [concat $sbgpCall "-mpAfi \"[keylget flowroute mpAfi]\" -mpSafi \"[keylget flowroute mpSafi]\""]
                
                if {$action == "announce" && [keylget flowroute ipVer] == 6} {
                  set sbgpCall [concat $sbgpCall "-mpNHop \"[ipv4ToIpv6 $dataip(ip.$vprnIdOrbaseDot1qTag.Linux.$dut3)]\""]
                }
                
                puts $sbgpCall
                eval $sbgpCall
              }
              
              proc addToPeerIdList {peerIdListVar flowroute} {
                upvar $peerIdListVar peerIdList
                
                if {[keylget flowroute base] == false} {
                  set vprnIdOrbaseDot1qTag [keylget flowroute vprnId]
                } else {
                  set vprnIdOrbaseDot1qTag [keylget flowroute baseDot1qTag]
                }
                
                if {[lsearch $peerIdList $vprnIdOrbaseDot1qTag] == -1} {
                  lappend peerIdList $vprnIdOrbaseDot1qTag
                }
              }
              
              proc callSbgpRun {peerIdList} {
                foreach peerId $peerIdList {
                  set sbgpRunCall "sbgp.run -id \"peer$peerId\""
                  puts $sbgpRunCall
                  eval $sbgpRunCall
                }
              }
              
              set subtestCounter 1
              
              for {set maxRedUpd $redTestMaxRedUpd} {$maxRedUpd < $redTestMaxRedUpd + $redTestNbIter} {incr maxRedUpd} {
                
                # different scenario at each iteration, but reproducible across test executions
                global randomSeed
                set randomSeed $maxRedUpd
                
                # Start scenario and wait for switch-over
                # =======================================
                
                set announcedFlowrouteList $flowrouteList
                set withdrawnFlowrouteList [list]
                
                # First withdraw some half of the flowroutes
                log_msg DEBUG "First withdraw half of the flowroutes"
                set peerIdList [list]
                for {set i 0} {$i < [llength $flowrouteList]/2} {incr i} {
                  set randomIdx [random [llength $announcedFlowrouteList]]
                  set flowroute [lindex $announcedFlowrouteList $randomIdx]
                  callSbgpAdd withdraw $flowroute
                  lappend withdrawnFlowrouteList $flowroute
                  set announcedFlowrouteList [lreplace $announcedFlowrouteList $randomIdx $randomIdx]
                  addToPeerIdList peerIdList $flowroute
                }
                callSbgpRun $peerIdList
                
                # Set HA monitoring parameters
                puts [$dut2 sendCliCommand "shell redTestStartCountModule $redTestModuleId $redTestTableId"]
                puts [$dut2 sendCliCommand "shell redTestSetMaxUpdates $maxRedUpd"]

                set lastStatusCheck [clock seconds]
                set redCardStatus [$dut2 checkRedCardStatus]
                set newStandbyOnline false
                
                # Randomly withdraw/reannounce flouwroutes
                log_msg DEBUG "Randomly withdraw/reannounce flouwroutes"
                set peerIdList [list]
                for {set i 0} {$i < $maxRedUpd} {incr i} {
                  set actionId [random 2]
                  if {($actionId == 0 && [llength $withdrawnFlowrouteList] > 0) || [llength $announcedFlowrouteList] == 0} { ;# announce
                    set randomIdx [random [llength $withdrawnFlowrouteList]]
                    set flowroute [lindex $withdrawnFlowrouteList $randomIdx]
                    callSbgpAdd announce $flowroute
                    lappend announcedFlowrouteList $flowroute
                    set withdrawnFlowrouteList [lreplace $withdrawnFlowrouteList $randomIdx $randomIdx]
                    addToPeerIdList peerIdList $flowroute
                  } else { ;# withdraw
                    set randomIdx [random [llength $announcedFlowrouteList]]
                    set flowroute [lindex $announcedFlowrouteList $randomIdx]
                    callSbgpAdd withdraw $flowroute
                    lappend withdrawnFlowrouteList $flowroute
                    set announcedFlowrouteList [lreplace $announcedFlowrouteList $randomIdx $randomIdx]
                    addToPeerIdList peerIdList $flowroute
                  }
                }
                callSbgpRun $peerIdList
                
                # Wait for new standby to come online
                # Assumption : ERROR->OK did not occur during flowroutes advertisement
                log_msg DEBUG "Wait for new standby to come online"
                set stanbyOnlineTimeout [expr [clock seconds] + 300]
                while {$newStandbyOnline == false} {
                  if {[clock seconds] > $stanbyOnlineTimeout} {
                    log_msg ERROR "id18079 Could not observe standby CPM coming online (timeout)"
                    break
                  }
                  set newRedCardStatus [$dut2 checkRedCardStatus]
                  if {$redCardStatus == "ERROR" && $newRedCardStatus == "OK"} {
                    set newStandbyOnline true
                  }
                  set redCardStatus $newRedCardStatus
                  sleep 10
                }
                
                # restore Expect session
                $dut2 closeExpectSession ; after 1000 ; $dut2 openExpectSession; after 1000
                
                proc reannounceRemainingWithdrawnFlowroutes {} {
                  upvar withdrawnFlowrouteList withdrawnFlowrouteList
                  upvar dut3 dut3
                  upvar dataip dataip
                  set peerIdList [list]
                  log_msg DEBUG "Reannounce remaining withdrawn flowroutes"
                  foreach withdrawnFlowroute $withdrawnFlowrouteList {
                    callSbgpAdd announce $withdrawnFlowroute
                    addToPeerIdList peerIdList $withdrawnFlowroute
                  }
                  callSbgpRun $peerIdList
                }
                
                if {$reannounceRemainingWithdrawnFlowroutesDuringReconcile} {
                  reannounceRemainingWithdrawnFlowroutes
                }
                
                # Wait for end of reconciliation
                log_msg INFO "Wait for end of reconciliation"
                if {[$dut2 CnWSecInSync -Time $option(maxStandbySynchroTimeSec)] != "OK"} {
                  log_msg ERROR "id9378 \"\$dut2 CnWSecInSync\" failed"
                }
                
                subtest "successful end of reconcilation #$subtestCounter"
                incr subtestCounter
                
                if {!$reannounceRemainingWithdrawnFlowroutesDuringReconcile} {
                  reannounceRemainingWithdrawnFlowroutes
                }
                
                # Verify consistency (TODO: redifine as an expected behavior)
                set nbrInstalledExp $totalNbrOfFlowroutes
                if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                  log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
                } else {
                  log_msg ERROR "id26527 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL
                  break
                }
              }
            }
          }
          
          # And here the expected behavior
          switch $expectedBehavior {
            "none" {
              # nothing expected
            }
            "defaultBehavior" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut6: Check that only \"action drop\" traffic is dropped and \"action redirectVrf\" traffic is redirected"
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id5461 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
              log_msg INFO "$mySubtest"
              if {$option(sendTraffic_v4)} {
                $dut1 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"
                $dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"
              }
              if {$option(sendTraffic_v6)} {
                $dut1 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"
                $dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"
              }
              log_msg INFO "Wait 5secs and display egress counters before traffic start" ; after 5000
              if {$option(sendTraffic_v4)} {
                getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
              }
              if {$option(sendTraffic_v6)} {
                getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
              }
              handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
              log_msg INFO "Waiting 20secs and check that not all traffic is dropped" ; after 20000
              for {set rCnt 1} {$rCnt <= $option(maxRetryCnt)} {incr rCnt} {
                set retryNeeded 0
                if {$option(sendTraffic_v4)} {
                  set zeroCnt_v4 0 ; set zeroCntExp_v4 2
                  set egressTrafficList_v4 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  foreach eEntry $egressTrafficList_v4 {
                    if {$eEntry == 0} {incr  zeroCnt_v4}
                  }
                  if {$zeroCnt_v4 == $zeroCntExp_v4} {
                    log_msg INFO "Traffic dropped/redirected like expected (zeroCnt_v4: $zeroCnt_v4 ; zeroCntExp_v4: $zeroCntExp_v4)"
                  } else {
                    if {$rCnt == $option(maxRetryCnt)} {
                      flowspec_dumpVprnFlowspecDebugInfo $dut2 $vprnIdList
                      log_msg ERROR "id25528 More/less traffic than expected is dropped/redirected (zeroCnt_v4: $zeroCnt_v4 ; zeroCntExp_v4: $zeroCntExp_v4)"
                    } else {
                      set retryNeeded 1
                    }
                  }
                }
                if {$option(sendTraffic_v6)} {
                  set zeroCnt_v6 0 ; set zeroCntExp_v6 2
                  set egressTrafficList_v6 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  foreach eEntry $egressTrafficList_v6 {
                    if {$eEntry == 0} {incr  zeroCnt_v6}
                  }
                  if {$zeroCnt_v6 == $zeroCntExp_v6} {
                    log_msg INFO "Traffic dropped/redirected like expected (zeroCnt_v6: $zeroCnt_v6 ; zeroCntExp_v6: $zeroCntExp_v6)"
                  } else {
                    if {$rCnt == $option(maxRetryCnt)} {
                      flowspec_dumpVprnFlowspecDebugInfo $dut2 $vprnIdList
                      log_msg ERROR "id27644 More/less traffic than expected is dropped/redirected (zeroCnt_v6: $zeroCnt_v6 ; zeroCntExp_v6: $zeroCntExp_v6)"
                    } else {
                      set retryNeeded 1
                    }
                  }
                }
                if {$retryNeeded} {
                  log_msg INFO "Waiting $option(interRetryTimeSec) sec ($rCnt/$option(maxRetryCnt)) before retry ..." ; after [expr $option(interRetryTimeSec) * 1000]
                }
              }
              subtest "$mySubtest"
              
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter for \"Ing. Matches\" - \"Dest. IP\" - \"Fwd Rtr\""
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1 
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                    } else {
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                    }
                    incr vprnCnt
                    
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 1
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $firstRedirectVprnId} else {set findFwdRtr ""}
                        log_msg INFO "flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false]} {
                          log_msg ERROR "id21039 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                    if {[testFailed] || $Result == "FAIL"} {break}
                    incr c ; if {$c > 255} {set c 0 ; incr b}
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b and c because they point to the next values to be used
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 1
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $firstRedirectVprnId} else {set findFwdRtr ""}
                        set thisFilterId "fSpec-0"
                        log_msg INFO "getIpFlowspecFilter for Base ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -showFilter false]} {
                          log_msg ERROR "id13133 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                  }
                  #
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                subtest "$mySubtest"
              }
              
              if {! [testFailed] && $Result == "OK"} {
                if {$skipCheckFilterLog} {
                  log_msg WARNING "skipCheckFilterLog"
                } else {
                  set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter log $filterLogId for \"Ip*: *fSpec-*\" entries"
                  log_msg INFO "$mySubtest"
                  set rCli [$dut sendCliCommand "show filter log $filterLogId" -bufferedMode true] 
                  # 2012/09/05 09:59:13  Ipv6 Filter: fSpec-45:61893  Desc: 
                  # 2012/09/05 09:59:13  Ip Filter: 1:fSpec-44-64715  Desc: 
                  # 2012/09/05 09:59:13  Ip Filter: 65535:fSpec-46-59388  Desc:
                  foreach thisFamily $thisFilterFamilyList {
                    set vprnCnt 1
                    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                      switch $thisFamily {
                        "ipv4" {set fTxt "Ip Filter: "}
                        "ipv6" {set fTxt "Ipv6 Filter: "}
                      }
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                      if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                        append fTxt "$addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId:$thisFilterId"
                      } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                        append fTxt "$addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId:$thisFilterId"
                      } else {
                        append fTxt "$thisFilterId"
                      }
                      set pat ".*$fTxt.*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg INFO "Found \"$fTxt\" in filter log $filterLogId"
                      } else {
                        log_msg ERROR "id107 Couldn't find \"$fTxt\" in filter log $filterLogId" ; set Result FAIL ; break
                      }
                      incr vprnCnt
                    } ; # vprnIdList
                    if {[testFailed] || $Result == "FAIL"} {break}
                  } ; # thisFilterFamilyList
                  subtest "$mySubtest"
                }
              }
              
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check if systemCreatedFilterId are in tIP(v6)FilterDescription"
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  if {[flowspec_validateSystemCreatedFilterId $dut2 -family $thisFamily]} {
                    log_msg INFO "$dut2: Successful verified systemCreatedFilterId"
                  } else {
                    log_msg ERROR "id4069 $dut2: Not successful verified systemCreatedFilterId"
                  }
                }
                subtest "$mySubtest"
              }

            } 
            
            "noFilterEntriesExpInVprn" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: No filter entries expected in the vprn"
              log_msg INFO "$mySubtest"
              if {$sendBgpFlowrouteUpd_v4} {
                if {[flowspec_filterHasNoMatchCriteria $dut2 $igIpv4FltrIdActiveBeforeShut -family ipv4]} {
                  log_msg INFO "$dut2: Filter $igIpv4FltrIdActiveBeforeShut has no match criteria (expected behavior)"
                } else {
                  log_msg ERROR "id4637 $dut2: Filter $igIpv4FltrIdActiveBeforeShut has unexpected match criteria" ; set Result FAIL ; break
                }
              }
              if {$sendBgpFlowrouteUpd_v6} {
                if {[flowspec_filterHasNoMatchCriteria $dut2 $igIpv6FltrIdActiveBeforeShut -family ipv6]} {
                  log_msg INFO "Filter $igIpv4FltrIdActiveBeforeShut has no match criteria (expected behavior)"
                } else {
                  log_msg ERROR "id3875 Filter $igIpv4FltrIdActiveBeforeShut has unexpected match criteria" ; set Result FAIL ; break
                }
              }
              subtest "$mySubtest"
            }
            
            "noIpv4v6FilterEntriesExpInDut" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: No filter entries expected in the dut"
              log_msg INFO "$mySubtest"
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id16618 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              if {! [testFailed] && $Result == "OK"} {
                if {[flowspec_getNoIpFlowspecFilterEntries $dut2 -family ipv4] && \
                      [flowspec_getNoIpFlowspecFilterEntries $dut2 -family ipv6]} {
                  log_msg INFO "$dut2: No unexpected filter entries found"
                } else {
                  log_msg ERROR "id19782 $dut2: Unexpected filter entries found" ; set Result FAIL ; break
                }
              }
              subtest "$mySubtest"
            }
            
            "negTest_fSpecAndUsrDefFilterOnItfInDiffVprns" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" "
              log_msg INFO "$mySubtest"
              log_msg INFO ""
              log_msg INFO "This is a negative test to cover following restriction (copied from PRD):"
              log_msg INFO "  IPv4 flow-spec cannot be enabled on a \"vprn sap\" or \"spoke sdp\"  itf if"
              log_msg INFO "  a user-defined IPv4 filter policy has been applied to the ingress context of the"
              log_msg INFO "  interface and that same user-defined IPv4 filter policy has also been applied to itfs"
              log_msg INFO "  to other vprn's.  The same applies for IPv6 flow-spec."
              log_msg INFO ""
              foreach thisFamily $thisFilterFamilyList {
                set vprnCnt 1
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  switch $thisFamily {
                    "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                    "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                  }
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    # this is a vprn with a user-defined filter on it
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    # this is a vprn with a user-defined filter on it"
                  } else {
                    if {$itfType_dut1dut2 == "spoke"} {
                      set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                    } else {
                      set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                    }
                    set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                    if {[regexp -- $pat $rCli match]} {
                      log_msg INFO "Found \"$pat\""
                    } else {
                      log_msg ERROR "id4601 Couldn't find \"$pat\"" ; set Result FAIL ; break
                    }
                  }
                  incr vprnCnt
                } ; # vprnIdList

              } ; # thisFilterFamilyList
              
              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Remove now the flowspec/flowspec-ipv6 from the interface and check that the user-defined filter could be applied now"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress no $fSpecTxt"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress no $fSpecTxt"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                      }
                      set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg ERROR "id20551 Found \"$pat\"" ; set Result FAIL ; break
                      } else {
                        log_msg INFO "Couldn't find (expected behavior) \"$pat\""
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }

              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Enable now the flowspec/flowspec-ipv6 again on the interface and check that this is rejected"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      }
                      set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg INFO "Found \"$pat\""
                      } else {
                        log_msg ERROR "id14994 Couldn't find \"$pat\"" ; set Result FAIL ; break
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }
              
              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Remove now ip/ipv6 filter from the interface and enable flowspec/flowspec-ipv6 again"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress no filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress no filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      }
                      # set pat ".*Feature not supported on this SAP - a [set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                       set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg ERROR "id18309 Found \"$pat\"" ; set Result FAIL ; break
                      } else {
                        log_msg INFO "Couldn't find (expected behavior) \"$pat\""
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }
              
              subtest "$mySubtest"
            }
            
            "zeroIngMatchesExpInDut" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: All filter entries should have \"Ing. Matches\" with 0 pkts & bytes"
              log_msg INFO "$mySubtest"
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                set vprnCnt 1 
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                  } else {
                    set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  }
                  incr vprnCnt

                  if {[flowspec_zeroCountersInFilterId $dut2 $thisFilterId]} {
                    log_msg INFO "$dut2: Found zeroCounters in filterId: $thisFilterId"
                  } else {
                    log_msg ERROR "id32436 $dut2: Found unexpected non zeroCounters in filterId: $thisFilterId" ; set Result FAIL ; break
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  if {[flowspec_zeroCountersInFilterId $dut2 $thisFilterId]} {
                    log_msg INFO "$dut2: Found zeroCounters in filterId: $thisFilterId"
                  } else {
                    log_msg ERROR "id25984 $dut2: Found unexpected non zeroCounters in filterId: $thisFilterId" ; set Result FAIL ; break
                  }
                }
                #
              } ; #thisFilterFamilyList 
              subtest "$mySubtest"
            }
            
          }

          if {[testFailed] || $Result == "FAIL"} {break}
        }
        if {[testFailed] || $Result == "FAIL"} {break}
        #
        # Check if a new iteration should start
        switch $iterationMethod {
          "maxNbrIterations" {
            if {$iterationCnt == $maxNbrIterations} {set whileContinue 0}
          }
          "maxDuration" {
            set stopTimeStampSec [clock seconds]
            set deltaTimeHrs [exec echo "($stopTimeStampSec  - $startTimeStampSec) / 3600"  | bc]
            if {$deltaTimeHrs >= $maxDurationHrs } {set whileContinue 0}
          }
          "ifFileExists" {
            if {! [file exists $option(fileExistsName)]} {set whileContinue 0}
          }
        }
        #
      }

    }

    
  }
  
  if {$option(deconfig)} {
    saveOrRestore delete
    sbgp.closeall
  } 
  
  testcaseTrailer
  $dut2 configure -cli_timeout $cliTimeoutOrig
  if {$dutLoggingDisabled} {
    log_msg WARNING "Logging in dut-logs was disabled, enable it again"
    foreach dut $dutList {
      $dut configure -logging logging
    }
  }
}
###
proc flowspec.vprnUseCase_PRD_Internet_access_using_VPRNs_Figure2 { args } { 
  global masterlog testdir ixia_port
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  
  set option(dumpDebugLog) true
  set option(bgpVprnPeerIpv4) true
  set option(bgpVprnPeerIpv6) false
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecBgpVprnPeerIpv4] != "ERROR"} {
    set bgpVprnPeerIpv4 [GGV fspecBgpVprnPeerIpv4]
  } else {
    set bgpVprnPeerIpv4 $option(bgpVprnPeerIpv4)
  }
  if {[GGV fspecBgpVprnPeerIpv6] != "ERROR"} {
    set bgpVprnPeerIpv6 [GGV fspecBgpVprnPeerIpv6]
  } else {
    set bgpVprnPeerIpv6 $option(bgpVprnPeerIpv6)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]
  set ibgp_AS 100 ; set ebgp_AS 200
  set Linux_AS 107
  set dot1qTag 2
  set clusterId 2.2.2.2
  
  set spokeIesId 5000 ; set spokeSdpId 1 ; set spokeSdpVcId 1
  set filterFamilyList [list ipv4 ipv6]
  set filterFamilyTxtList [list ip ipv6]
  
  set vprnId_[set dut3] 3
  set vprnId_[set dut4] 4
  set vprnId_[set dut6] 6
  
  #                          dut thisDutId ngbrDutIdList
  set vprnDutList [list $dut3 3 [list 4 6] \
                                 $dut4 4 [list 3 6] \
                                 $dut6 6 [list 3 4] \
                                 ]
                                 
  set lpbk_a 82 ; set lpbk_b 82 ; set lpbk_c 82 ; set lpbkMsk_v4 32 ; set lpbkMsk_v6 128
  foreach {dut thisDutId ngbrDutIdList} $vprnDutList {
    set thisLpbkPfx_[set vprnId_[set dut]]_v4 $lpbk_a.$lpbk_b.$lpbk_c.[set vprnId_[set dut]]
    set thisLpbkPfx_[set vprnId_[set dut]]_v6 [ipv4ToIpv6 [set thisLpbkPfx_[set vprnId_[set dut]]_v4]]
    set thisLpbkPfxMsk_[set vprnId_[set dut]]_v4 [set thisLpbkPfx_[set vprnId_[set dut]]_v4]/$lpbkMsk_v4
    set thisLpbkPfxMsk_[set vprnId_[set dut]]_v6 [set thisLpbkPfx_[set vprnId_[set dut]]_v6]/$lpbkMsk_v6
  }
  
  set trafficDstPrefix_v4 200.200.1.1 ; set trafficDstPrefix_v6 [ipv4ToIpv6 $trafficDstPrefix_v4]
  set trafficDstPrefixMask_v4 $trafficDstPrefix_v4/$srMask_v4 ; set trafficDstPrefixMask_v6 $trafficDstPrefix_v6/$srMask_v6
  foreach {thisA thisB thisC thisD} [split $trafficDstPrefix_v4 "."] {break}
  set cntPktsViaFilterPrefix_v4 $thisA.0.0.0 ; set cntPktsViaFilterPrefix_v6 [ipv4ToIpv6 $cntPktsViaFilterPrefix_v4]
  set cntPktsViaFilterMask_v4 8 ; set cntPktsViaFilterMask_v6 [ipv4MaskToIpv4Ipv6 $cntPktsViaFilterMask_v4 -family ipv6]
  set cntPktsViaFilterPrefixMask_v4 $cntPktsViaFilterPrefix_v4/$cntPktsViaFilterMask_v4 ; set cntPktsViaFilterPrefixMask_v6 $cntPktsViaFilterPrefix_v6/$cntPktsViaFilterMask_v6
  set cntPktsViaFilter_entryId 1
  set pktRatePerStream 10 ; set pktSize 128 ; set streamData_ISATMS "49 53 41 54 4D 53" ; set rawProtocol 253
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : PRD use case \"Internet access using VPRNs\" (Figure2)"
  log_msg INFO "#"
  log_msg INFO "# Setup: "
  log_msg INFO "# "
  log_msg INFO "#                                 lpbk <----IBGP\[vprn\]--->lpbk"
  log_msg INFO "#                   $dut5  EBGP   $dut4                   $dut6"
  log_msg INFO "#   Linux(sbgp)-----dut5----------dut4--------------------dut6-----Ixia"
  log_msg INFO "#                               ^  |  \\                    :"
  log_msg INFO "#                               |  |   \\                   :"
  log_msg INFO "#                               |  |    \\IBGP\[Base\]        :IBGP\[Base\]"
  log_msg INFO "#                               |  |     \\                 :"
  log_msg INFO "#                               |  |      \\                :"
  log_msg INFO "#                     IBGP\[vprn\]|  |      dut2($dut2 RR)...+"
  log_msg INFO "#                               |  |      /"
  log_msg INFO "#                               |  |     /"
  log_msg INFO "#                               |  |    /IBGP\[Base\]"
  log_msg INFO "#                               v  |   /"
  log_msg INFO "#                             lpbk |  /"
  log_msg INFO "#                  Ixia-----------dut3"
  log_msg INFO "#                               /  | $dut3"
  log_msg INFO "#                            sap   |"
  log_msg INFO "#                          spoke ->|"
  log_msg INFO "#                                  |"
  log_msg INFO "#                  Ixia----dut1----+"
  log_msg INFO "#                          $dut1"
  log_msg INFO "#"
  log_msg INFO "#   lpbk addresses: 1) Advertised via L3-VPN ; 2) Endpoint of IBGP\[vprn\] sessions"
  foreach {dut thisDutId ngbrDutIdList} $vprnDutList {
    log_msg INFO "#     $dut vprnId [set vprnId_[set dut]] [set thisLpbkPfxMsk_[set vprnId_[set dut]]_v4]" 
    log_msg INFO "#                    [set thisLpbkPfxMsk_[set vprnId_[set dut]]_v6]"
  }
  log_msg INFO "#   .) The Internet VPRN in dut4($dut4 & connected to flowroute controller) is configured as RR"
  log_msg INFO "#     with client IBGP sessions (SAFI=133) to other PEs having an Internet VPRN instance (dut3($dut3) & dut6($dut6))."
  log_msg INFO "#     The endpoints of these IBGP sessions are loopback addresses belonging to the Internet VPRNs"
  log_msg INFO "#     and these loopback addresses are exported and advertised to other PEs as VPN-IPV4 routes."
  log_msg INFO "#     With this configuration the VPRN-to-VPRN BGP sessions are setup in-band between the PEs"
  log_msg INFO "#     and use the same MPLS/SDP tunnels as the Internet data traffic."
  log_msg INFO "#   .) IPv4/IPv6 flowroutes are originated by sbgp and advertised to the connected dut4($dut4) over"
  log_msg INFO "#     an EBGP session with the Internet VPRN."
  log_msg INFO "#   .) The IPV4/IPv6 flowroutes are reflected to the Internet VPRNs in other PEs over the"
  log_msg INFO "#     direct VPRN-to-VPRN BGP sessions."
  log_msg INFO "#   .) In each VPRN that has received flowroutes the derived filter entries are applied"
  log_msg INFO "#     on all of the VPRNs IP interfaces (SAP or spoke-SDP)."
  log_msg INFO "# "
  log_msg INFO "# "
  log_msg INFO "#   \[Adam\] The reference to supporting flow-ipv4 and flow-ipv6 on PE-PE IBGP sessions needs more explanation. "
  log_msg INFO "#   When I say PE-PE IBGP I really mean an IBGP session supporting AFI1/2+SAFI133 that is setup between a VPRNx/PE-1"
  log_msg INFO "#   and a VPRNy/PE-2" 
  log_msg INFO "#   in such a way that the BGP session itself is transported inside the MPLS/SDP/auto-bind tunnel between PE-1 and PE-2. "
  log_msg INFO "#   The endpoints of the IBGP session will be a loopback interface of VPRNx and a loopback interface of VPRNy. "
  log_msg INFO "#   The BGP team expects this to work without explicit code effort. I have added more details (and a diagram) in" 
  log_msg INFO "#   the new version of the PRD."
  log_msg INFO "# "
  log_msg INFO "# Important testcase parameters:"
  log_msg INFO "#   bgpVprnPeerIpv4: $bgpVprnPeerIpv4 bgpVprnPeerIpv6: $bgpVprnPeerIpv6"
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut2 systemip [set [set dut2]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut4 systemip [set [set dut4]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut5 systemip [set [set dut5]_ifsystem_ip] isisarea $isisAreaId as $ebgp_AS"
    CLN "dut $dut6 systemip [set [set dut6]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut4 tonode $dut3 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut3 tonode $dut4 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut4 tonode $dut6 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut6 tonode $dut4 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut4 tonode $dut2 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut2 tonode $dut4 porttype hybrid dot1q $dot1qTag ldp true isisarea $isisAreaId"
    CLN "dut $dut2 bgpneighbor [set [set dut3]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6' bgpcluster $clusterId" 
    CLN "dut $dut2 bgpneighbor [set [set dut4]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6' bgpcluster $clusterId" 
    CLN "dut $dut2 bgpneighbor [set [set dut6]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6' bgpcluster $clusterId" 
    CLN "dut $dut3 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6'" 
    CLN "dut $dut4 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6'"
    CLN "dut $dut6 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6'"
    CLN "dut $dut4 tonode $dut5 porttype hybrid dot1q $dot1qTag vprnid [set vprnId_[set dut4]] bgpneighbor interface4 bgppeeras $ebgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut $dut5 tonode $dut4 porttype hybrid dot1q $dot1qTag bgpneighbor interface4 bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    # used for spokes dut1/dut3
    CLN "dut $dut3 policy fromBgpVpnToOspf_v4 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut3 policy fromBgpVpnToOspf_v4 entry 1 to 'protocol ospf' action accept"
    CLN "dut $dut3 policy fromBgpVpnToOspf_v6 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut3 policy fromBgpVpnToOspf_v6 entry 1 to 'protocol ospf3' action accept"
    CLN "dut $dut3 tonode $dut1 porttype hybrid dot1q 1 ip 1.1.1.3 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut1 tonode $dut3 porttype hybrid dot1q 1 ip 1.1.1.1 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut1 tonode $dut3 porttype hybrid iesid $spokeIesId iftype spoke sdpid '$spokeSdpId gre [set [set dut3]_ifsystem_ip]' dot1q $dot1qTag ip $dot1qTag.$dataip(id.$dut1).$dataip(id.$dut3).$dataip(id.$dut1) ospfarea $ospfAreaId ospf3area $ospfAreaId"
    CLN "dut $dut3 tonode $dut1 porttype hybrid iftype spoke sdpid '$spokeSdpId gre [set [set dut1]_ifsystem_ip]' vprnid [set vprnId_[set dut3]] dot1q $dot1qTag ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6" 
    # Linux connection
    CLN "dut $dut5 tonode Linux porttype hybrid dot1q $dot1qTag bgpneighbor interface4 bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut Linux tonode $dut5 dot1q $dot1qTag"
    # Ixia connections
    CLN "dut $dut6 filter $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dstip $cntPktsViaFilterPrefixMask_v4"
    CLN "dut $dut6 filterv6 $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dstip $cntPktsViaFilterPrefixMask_v6"
    CLN "dut $dut3 tonode Ixia porttype hybrid dot1q $dot1qTag vprnid [set vprnId_[set dut3]]"
    CLN "dut Ixia tonode $dut3 dot1q $dot1qTag"
    CLN "dut $dut1 tonode Ixia porttype hybrid dot1q $dot1qTag"
    CLN "dut Ixia tonode $dut1 dot1q $dot1qTag"
    CLN "dut $dut6 tonode Ixia porttype hybrid dot1q $dot1qTag vprnid [set vprnId_[set dut6]] inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut Ixia tonode $dut6 dot1q $dot1qTag"
    CLN "dut $dut6 vprnid [set vprnId_[set dut6]] staticroute '$trafficDstPrefixMask_v4 next-hop $dataip(ip.$dot1qTag.Ixia.$dut6)'"
    CLN "dut $dut6 vprnid [set vprnId_[set dut6]] staticroute '$trafficDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.$dot1qTag.Ixia.$dut6)]'"
    #
    # Add here the loopback addresses
    foreach {dut thisDutId ngbrDutIdList} $vprnDutList {
      CLN "dut $dut vprnid [set vprnId_[set dut]] loopbackip [set thisLpbkPfxMsk_[set vprnId_[set dut]]_v4]"
      # IPv6 address is configured automatically
      #CLN "dut $dut vprnid [set vprnId_[set dut]] loopbackip [set thisLpbkPfxMsk_[set vprnId_[set dut]]_v6]"
    }
    #
    # Add here the vprn bgp sessions to the loopback addresses
    if {$bgpVprnPeerIpv4} {
      CLN "dut $dut4 vprnid [set vprnId_[set dut4]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut3]]_v4] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      CLN "dut $dut4 vprnid [set vprnId_[set dut4]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut6]]_v4] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      CLN "dut $dut3 vprnid [set vprnId_[set dut3]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut4]]_v4] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
      CLN "dut $dut6 vprnid [set vprnId_[set dut6]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut4]]_v4] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    }
    if {$bgpVprnPeerIpv6} {
      CLN "dut $dut4 vprnid [set vprnId_[set dut4]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut3]]_v6] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      CLN "dut $dut4 vprnid [set vprnId_[set dut4]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut6]]_v6] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      CLN "dut $dut3 vprnid [set vprnId_[set dut3]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut4]]_v6] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
      CLN "dut $dut6 vprnid [set vprnId_[set dut6]] as $ibgp_AS bgpneighbor [set thisLpbkPfx_[set vprnId_[set dut4]]_v6] bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    }
    #
    CLN.exec
    CLN.reset

    foreach {dut thisDutId ngbrDutIdList} $vprnDutList {
      docli $dut "configure router"
      docli $dut "         policy-options"
      docli $dut "            begin"
      docli $dut "            community vprn_exportRouteTarget members target:1982:2891"
      docli $dut "            community vprn_importRouteTarget members target:1982:2891"
      docli $dut "            policy-statement vprn_exportPol"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol direct"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "                entry 2"
      docli $dut "                    from"
      docli $dut "                        protocol static"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            policy-statement vprn_importPol"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                        community vprn_importRouteTarget"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            commit"
      docli $dut "        exit all"
    }
    foreach {dut thisDutId ngbrDutIdList} $vprnDutList {
      docli $dut "configure service vprn [set vprnId_[set dut]]" 
      docli $dut "no vrf-target"
      docli $dut "vrf-import vprn_importPol"
      docli $dut "vrf-export vprn_exportPol"
      docli $dut "exit all"
    }
    
    docli $dut3 "configure service vprn [set vprnId_[set dut3]] interface to_Ixia[set dot1qTag] sap $dataip(sap.$dot1qTag.$dut3.Ixia) ingress flowspec"
    docli $dut3 "configure service vprn [set vprnId_[set dut3]] interface to_Ixia[set dot1qTag] sap $dataip(sap.$dot1qTag.$dut3.Ixia) ingress flowspec-ipv6"
    docli $dut3 "configure service vprn [set vprnId_[set dut3]] interface to_[set dut1][set dot1qTag] spoke-sdp $dataip(sap.$dot1qTag.$dut3.$dataip(id.$dut1)) ingress flowspec"
    docli $dut3 "configure service vprn [set vprnId_[set dut3]] interface to_[set dut1][set dot1qTag] spoke-sdp $dataip(sap.$dot1qTag.$dut3.$dataip(id.$dut1)) ingress flowspec-ipv6"

  }
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # Ixia part (connected to dut3)
    handlePacket -port $portA(Ixia.$dut3) -action stop
    set thisDA 00:00:00:00:00:[int2Hex1 $dataip(id.$dut3)]
    set streamId 1 ; set thisHandlePacketAction create 
    handlePacket -port $portA(Ixia.$dut3) -dot1qtag $dot1qTag -dst $trafficDstPrefix_v4 -numDest 1 -src $dataip(ip.$dot1qTag.Ixia.$dut3) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
    incr streamId
    # this is the last stream 
    set thisHandlePacketAction ""
    handlePacket -port $portA(Ixia.$dut3) -dot1qtag $dot1qTag -dst $trafficDstPrefix_v6 -numDest 1 -src [ipv4ToIpv6  $dataip(ip.$dot1qTag.Ixia.$dut3)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
    handlePacket -port $portA(Ixia.$dut3) -action stop ; after 2000
    #
    # Ixia part (connected to dut1)
    handlePacket -port $portA(Ixia.$dut1) -action stop
    set thisDA 00:00:00:00:00:[int2Hex1 $dataip(id.$dut1)]
    set streamId 1 ; set thisHandlePacketAction create 
    handlePacket -port $portA(Ixia.$dut1) -dot1qtag $dot1qTag -dst $trafficDstPrefix_v4 -numDest 1 -src $dataip(ip.$dot1qTag.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
    incr streamId
    # this is the last stream 
    set thisHandlePacketAction ""
    handlePacket -port $portA(Ixia.$dut1) -dot1qtag $dot1qTag -dst $trafficDstPrefix_v6 -numDest 1 -src [ipv4ToIpv6  $dataip(ip.$dot1qTag.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
    handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
    #
    $dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"
    $dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"
    after 2000
    #
    log_msg INFO "Start IPv4/IPv6 traffic on port $portA(Ixia.$dut3) & $portA(Ixia.$dut1) for 10secs"
    handlePacket -port $portA(Ixia.$dut3) -action start ; handlePacket -port $portA(Ixia.$dut1) -action start ; after 10000
    #
    handlePacket -port $portA(Ixia.$dut3) -action stop ; handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
    #
    log_msg INFO "Check filters BEFORE IPv4/IPv6 flowroutes are injected"
    getFilter -print true
    set out_v4 [getFilter -print true -dut $dut6 -match "id $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dir egress version ipv4" -return count]
    set out_v6 [getFilter -print true -dut $dut6 -match "id $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dir egress version ipv6" -return count]
    if {$out_v4 != 0 && $out_v6 != 0} {
      log_msg INFO "Successful verified IPv4/IPv6 traffic (out_v4: $out_v4 ; out_v6: $out_v6)"
    } else {
      log_msg ERROR "id10459 Not successful verified IPv4/IPv6 traffic (out_v4: $out_v4 ; out_v6: $out_v6)" ; set Result FAIL
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      log_msg INFO "Start IPv4/IPv6 traffic on port $portA(Ixia.$dut3) & $portA(Ixia.$dut1) continously"
      handlePacket -port $portA(Ixia.$dut3) -action start ; handlePacket -port $portA(Ixia.$dut1) -action start 
      #
      sbgp.init -linuxItf $portA(Linux.$dut5) -id peer1 -linuxIp $dataip(ip.$dot1qTag.Linux.$dut5) -linuxAs $Linux_AS -dutIp $dataip(ip.$dot1qTag.$dut5.Linux) -dutAs $ebgp_AS \
              -capability $sbgpDefCapabilityList \
              -linuxDot1q $dot1qTag
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $trafficDstPrefixMask_v4]
      set comm1_v4 [createFlowSpecExtCommunityAttr drop]
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      sbgp.add -id peer1 -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $trafficDstPrefixMask_v6]
      set comm1_v6 [createFlowSpecExtCommunityAttr drop]
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      sbgp.add -id peer1 -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$dot1qTag.Linux.$dut5)]
      sbgp.run -id peer1
      #
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      log_msg INFO "Check filters AFTER IPv4/IPv6 flowroutes are injected"
      $dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"
      $dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"
      waitDampeningTime
      #
      getFilter -print true
      set out_v4 [getFilter -print true -dut $dut6 -match "id $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dir egress version ipv4" -return count]
      set out_v6 [getFilter -print true -dut $dut6 -match "id $cntPktsViaFilter_filterId entry $cntPktsViaFilter_entryId dir egress version ipv6" -return count]
      if {$out_v4 == 0 && $out_v6 == 0} {
        log_msg INFO "Successful verified IPv4/IPv6 traffic (out_v4: $out_v4 ; out_v6: $out_v6)"
      } else {
        log_msg ERROR "id3590 Not successful verified IPv4/IPv6 traffic (out_v4: $out_v4 ; out_v6: $out_v6)" ; set Result FAIL
      }
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      log_msg INFO "Check filter counters AFTER IPv4/IPv6 flowroutes are injected"
      foreach thisFamily $filterFamilyList {
        switch $thisFamily {
          "ipv4" {set findDestPrefixMsk $trafficDstPrefixMask_v4}
          "ipv6" {set findDestPrefixMsk $trafficDstPrefixMask_v6}
        }
        set thisFilterId [flowspec_getfSpecFilterId $dut3 [set vprnId_[set dut3]] -family $thisFamily]
        if {! [flowspec_getIpFlowspecFilter $dut3 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -svcId [set vprnId_[set dut3]]]} {
          log_msg ERROR "id25519 $dut3: Filter not found" ; set Result FAIL ; break
        }
      }
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      log_msg INFO "Check filter associations for SAP/SDP AFTER IPv4/IPv6 flowroutes are injected"
      foreach thisFamilyTxt $filterFamilyTxtList {
        set thisFilterId [flowspec_getfSpecFilterId $dut3 [set vprnId_[set dut3]] -family $thisFamilyTxt]
        set rCli [$dut3 sendCliCommand "show filter $thisFamilyTxt $thisFilterId associations"] ; log_msg INFO "$rCli"
        if {[regexp {.*SAP.*} $rCli match] && [regexp {.*SDP.*} $rCli match]} {
          log_msg INFO "$dut3: Found SAP/SDP associations for $thisFamilyTxt"
        } else {
          log_msg ERROR "id7387 $dut3: Couldn't find SAP/SDP associations for $thisFamilyTxt" ; set Result FAIL ; break
        }
      }
    }
  }
  
  if {$option(deconfig) == "true" } {
     saveOrRestore delete
     sbgp.closeall
  }
  testcaseTrailer

}

proc flowspec.vprnValidation { args } { 
  global masterlog testdir ixia_port
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  
  set option(dumpDebugLog) true
  set option(nbrVprns) 3
  # node | group | neighbor
  set option(validateLevel) "node"
  # cli | snmp
  set option(method) "cli"
  set option(RR) true
  set option(wrongAsWithoutDstPfx) false
  set option(invalidAsPath) true
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecNbrVprns] != "ERROR"} {
    set nbrVprns [GGV fspecNbrVprns]
  } else {
    set nbrVprns $option(nbrVprns)
  }
  if {[GGV fspecValidateLevel] != "ERROR"} {
    set validateLevel [GGV fspecValidateLevel]
  } else {
    set validateLevel $option(validateLevel)
  }
  if {[GGV fspecMethod] != "ERROR"} {
    set method [GGV fspecMethod]
  } else {
    set method $option(method)
  }
  if {[GGV fspecRR] != "ERROR"} {
    set RR [GGV fspecRR]
  } else {
    set RR $option(RR)
  }
  if {[GGV fspecWrongAsWithoutDstPfx] != "ERROR"} {
    set wrongAsWithoutDstPfx [GGV fspecWrongAsWithoutDstPfx]
  } else {
    set wrongAsWithoutDstPfx $option(wrongAsWithoutDstPfx)
  }
  if {[GGV fspecInvalidAsPath] != "ERROR"} {
    set invalidAsPath [GGV fspecInvalidAsPath]
  } else {
    set invalidAsPath $option(invalidAsPath)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]
  set bgpDutList_addIpv6Nhop [list $dut1 $dut2 $dut3]
  set ibgp_AS 100 ; set ebgp_AS 200
  set Linux_AS 107 ; set Linux_wrongAS 108
  set dot1qTag 2
  set clusterId 3.3.3.3

  set filterFamilyList [list ipv4 ipv6]
  set filterFamilyTxtList [list ip ipv6]
  set groupName "onegroup"
  
  set vprnIdList "" ; set vprnIdOnlyList ""
  for {set vprnId 1} {$vprnId <= $nbrVprns} {incr vprnId} {
    lappend vprnIdList [expr $minVprnId - 1 + $vprnId] ; lappend vprnIdOnlyList [expr $minVprnId - 1 + $vprnId]
  }
  
  set aV 44 ; set bV 44 ; set cV 44 ; set dV 1

  # Use the next dot1q tag for the Base
  set baseDot1qTag [expr [lindex $vprnIdOnlyList end] + 1]
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : Validation, when enabled, should be done in the context of the VPRN"
  log_msg INFO "#"
  log_msg INFO "# Setup: "
  log_msg INFO "# "
  log_msg INFO "#      AS$ebgp_AS                 AS$ibgp_AS"
  log_msg INFO "#      dut1($dut1)           dut2($dut2)"
  log_msg INFO "#       |                     |"
  log_msg INFO "#       |                     |"
  log_msg INFO "#       |                     |"
  log_msg INFO "#       |                     |"
  log_msg INFO "#       |Base & #[set nbrVprns]vprns       |Base & #[set nbrVprns]vprns"
  log_msg INFO "#       +------------------- dut3($dut3) AS$ibgp_AS RR($RR)"
  log_msg INFO "#                             |Base & #[set nbrVprns]vprns"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                           Linux AS$Linux_AS (sbgp)"
  log_msg INFO "# "
  log_msg INFO "# "
  log_msg INFO "# Important testcase parameters:"
  log_msg INFO "#   vprnIdList: $vprnIdList"
  log_msg INFO "#   validateLevel: $validateLevel"
  log_msg INFO "#   method: $method"
  log_msg INFO "#   RR: $RR"
  log_msg INFO "#   wrongAsWithoutDstPfx: $wrongAsWithoutDstPfx"
  log_msg INFO "#   invalidAsPath: $invalidAsPath"
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as $ebgp_AS"
    CLN "dut $dut2 systemip [set [set dut2]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    #
    CLN "dut $dut1 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut $dut3 tonode $dut1 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ebgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut1 tonode $dut3 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ebgp_AS bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 tonode $dut1 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ibgp_AS bgppeeras $ebgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
    }
    #
    CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router bgp update}"
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ibgp_AS bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ibgp_AS bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
    }
    # Linux
    if {$RR} {
      foreach thisVprnId $vprnIdList {
        CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true bgpneighbor interface4 as $ibgp_AS bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      }
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true bgpneighbor interface4 bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
    } else {
      foreach thisVprnId $vprnIdList {
        CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true bgpneighbor interface4 as $ibgp_AS bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
      }
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true bgpneighbor interface4 bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
    }
    # Also loopback/system itf in vprn
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut1 vprnid $thisVprnId loopbackip [set [set dut1]_ifsystem_ip] ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut2 vprnid $thisVprnId loopbackip [set [set dut2]_ifsystem_ip] ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 vprnid $thisVprnId loopbackip [set [set dut3]_ifsystem_ip] ospfarea $ospfAreaId ospf3area $ospfAreaId"
    }
    CLN.exec
    CLN.reset
    # The nhop in the update msg is a \"Constructied Next Hop\""
    # Example: \"::A14:103\" iso \"3FFE::A14:103\""
    # So add a policy to set the correct IPv6 next-hop in $bgpDutList_addIpv6Nhop"
    foreach dut $bgpDutList_addIpv6Nhop {
      docli $dut "configure router policy-options"
      docli $dut "begin"
      docli $dut "policy-statement addIpv6Nhop"
      docli $dut "    entry 1"
      docli $dut "        from"
      docli $dut "            family ipv6"
      docli $dut "        exit"
      docli $dut "        action accept"
      docli $dut "            next-hop [ipv4ToIpv6 [set [set dut]_ifsystem_ip]]"
      docli $dut "        exit"
      docli $dut "    exit"
      docli $dut "exit"
      docli $dut "commit"
      docli $dut "exit all"
      docli $dut "conf router bgp export addIpv6Nhop"
      foreach thisVprnId $vprnIdList {
        docli $dut "conf service vprn $thisVprnId bgp export addIpv6Nhop"
      }
    }
  }
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # sbgp Base
    set thisDstPrefix_v4 $dummyNetw ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
    sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs $ibgp_AS \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag
    sbgp.add -id peer$baseDot1qTag -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
    sbgp.run -id peer$baseDot1qTag
    # sbgp vprn
    foreach thisVprnId $vprnIdList {
      set thisDstPrefix_v4 $dummyNetw ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
      sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs $ibgp_AS \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId
      sbgp.add -id peer$thisVprnId -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
      sbgp.run -id peer$thisVprnId
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Enable flowspec-validate ($method) on \"$validateLevel\" level ; Inject IPv4/IPv6 flowroute ; No best IPv4/IPv6 route advertised => Validation should fail (Check trap, bgp summary, bgp routes flow-ipv4/flow-ipv6 flag \"?\")"
      log_msg INFO "" ; log_msg INFO "$mySubtest" ; log_msg INFO ""
      switch $validateLevel {
        "node" {
          switch $method {
            "cli" {
              set rCli [$dut3 sendCliCommand "configure router bgp flowspec-validate"] ; log_msg INFO "$rCli"
              foreach thisVprnId $vprnIdList {
                set rCli [$dut3 sendCliCommand "configure service vprn $thisVprnId bgp flowspec-validate"] ; log_msg INFO "$rCli"
              }
            }
            "snmp" {
              set vRtrId 1
              set setSnmpResult [$dut3 setTBgpInstanceFlowspecValidate $vRtrId true] ; after 1000
              set getSnmpResult [$dut3 getTBgpInstanceFlowspecValidate $vRtrId]
              foreach thisVprnId $vprnIdList {
                set vRtrId [$dut3 getVRtrInstanceId $thisVprnId]
                set setSnmpResult [$dut3 setTBgpInstanceFlowspecValidate $vRtrId true] ; after 1000
                set getSnmpResult [$dut3 getTBgpInstanceFlowspecValidate $vRtrId]
              }
            }
          }
        }
        "group" {
          switch $method {
            "cli" {
              set rCli [$dut3 sendCliCommand "configure router bgp group $groupName flowspec-validate"] ; log_msg INFO "$rCli"
              foreach thisVprnId $vprnIdList {
                set rCli [$dut3 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName flowspec-validate"] ; log_msg INFO "$rCli"
              }
            }
            "snmp" {
              set vRtrId 1
              set setSnmpResult [$dut3 setTBgpPGFlowspecValidate $vRtrId $groupName true] ; after 1000
              set getSnmpResult [$dut3 getTBgpPGFlowspecValidate $vRtrId $groupName]
              foreach thisVprnId $vprnIdList {
                set vRtrId [$dut3 getVRtrInstanceId $thisVprnId]
                set setSnmpResult [$dut3 setTBgpPGFlowspecValidate $vRtrId $groupName true] ; after 1000
                set getSnmpResult [$dut3 getTBgpPGFlowspecValidate $vRtrId $groupName]
              }
            }
          }
        }
        "neighbor" {
          switch $method {
            "cli" {
              set rCli [$dut3 sendCliCommand "configure router bgp group $groupName neighbor $dataip(ip.$baseDot1qTag.Linux.$dut3) flowspec-validate"] ; log_msg INFO "$rCli"
              foreach thisVprnId $vprnIdList {
                set rCli [$dut3 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName neighbor $dataip(ip.$thisVprnId.Linux.$dut3) flowspec-validate"] ; log_msg INFO "$rCli"
              }
            }
            "snmp" {
              set vRtrId 1 
              set setSnmpResult [$dut3 setSPTBgpPeerFlowspecValidate $vRtrId $dataip(ip.$baseDot1qTag.Linux.$dut3) true] ; after 1000
              set getSnmpResult [$dut3 getSPTBgpPeerFlowspecValidate $vRtrId $dataip(ip.$baseDot1qTag.Linux.$dut3)]
              foreach thisVprnId $vprnIdList {
                set vRtrId [$dut3 getVRtrInstanceId $thisVprnId]
                set setSnmpResult [$dut3 setSPTBgpPeerFlowspecValidate $vRtrId $dataip(ip.$thisVprnId.Linux.$dut3) true] ; after 1000
                set getSnmpResult [$dut3 getSPTBgpPeerFlowspecValidate $vRtrId $dataip(ip.$thisVprnId.Linux.$dut3)]
              }
            }
          }
        }
      }
      #
      set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
      #
      set trap2023CheckList ""
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
      set comm1_v4 [createFlowSpecExtCommunityAttr drop]
      set comm1_v6 [createFlowSpecExtCommunityAttr drop]
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v4
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v6
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set comm1_v4 [createFlowSpecExtCommunityAttr drop]
        set comm1_v6 [createFlowSpecExtCommunityAttr drop]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v4
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v6
      }
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      if {[flowspec_analyseTrap_2023tBgpFlowRouteInvalid $dut3 destPfx $trap2023CheckList]} {
        log_msg INFO "Successful analysed trap 2023 ($trap2023CheckList)"
        set rCli [$dut3 sendCliCommand "show log log-id 99 subject \"Flow route validation failed\""] ; log_msg INFO "$rCli"
      } else {
        log_msg ERROR "id4809 Not successful analysed trap 2023 ($trap2023CheckList)" ; set Result FAIL
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisCheckFlowTxt "Ipv6"} else {set thisCheckFlowTxt "Ipv4"}
          if {[flowspec_checkFlow[set thisCheckFlowTxt]RemAndActRts $dut3 1 0 -svcId $thisContext]} {
            log_msg INFO "$dut3: checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt) passed"
          } else {
            log_msg ERROR "id31489 $dut3: Failed checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt)" ; set Result FAIL ; break
          }
        }
      }  
      #
      if {! [testFailed] && $Result == "OK"} {
        # Check invalid in show router bgp routes flow-ipv4/ipv6
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisFamily "ipv6"} else {set thisFamily "ipv4"}
          set thisLegend  [flowspec_getFlowroutesLegend $dut3 "?" -svcId $thisContext -family $thisFamily]
          if {$thisLegend} {
            log_msg INFO "$dut3: Invalid route check passed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)"
          } else {
            log_msg ERROR "id17749 $dut3: Invalid route check failed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)" ; set Result FAIL ; break
          }
        }
      }
      subtest "$mySubtest"
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Advertise best IPv4/IPv6 route => Already received flowroute doesn't comes active (Check trap, bgp summary, bgp routes flow-ipv4/flow-ipv6 flag \"?\")"
      log_msg INFO "" ; log_msg INFO "$mySubtest" ; log_msg INFO ""
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4"
      sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4"
        sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4
      }
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      if {! [testFailed] && $Result == "OK"} {
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisCheckFlowTxt "Ipv6"} else {set thisCheckFlowTxt "Ipv4"}
          if {[flowspec_checkFlow[set thisCheckFlowTxt]RemAndActRts $dut3 1 0 -svcId $thisContext]} {
            log_msg INFO "$dut3: checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt) passed"
          } else {
            log_msg ERROR "id7241 $dut3: Failed checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt)" ; set Result FAIL ; break
          }
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        # Check invalid in show router bgp routes flow-ipv4/ipv6
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisFamily "ipv6"} else {set thisFamily "ipv4"}
          set thisLegend  [flowspec_getFlowroutesLegend $dut3 "?" -svcId $thisContext -family $thisFamily]
          if {$thisLegend} {
            log_msg INFO "$dut3: Invalid route check passed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)"
          } else {
            log_msg ERROR "id30227 $dut3: Invalid route check failed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)" ; set Result FAIL ; break
          }
        }
      }
      subtest "$mySubtest"
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Best IPv4/IPv6 route advertised in WRONG context ; Inject IPv4/IPv6 flowroute => Validation should fail (Check trap, bgp summary, bgp routes flow-ipv4/flow-ipv6 flag \"?\")"
      log_msg INFO "" ; log_msg INFO "$mySubtest" ; log_msg INFO ""
      #
      log_msg INFO "First WITHDRAW IPv4/IPv6 routes and flowroutes"
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
      #
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4"
      sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4
      #
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      #
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
      #
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        #
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4"
        sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4
        #
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        #
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
        #
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
      }
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      log_msg INFO "Advertise IPv4/IPv6 route in WRONG context"
      set thisDstPrefix_v4 $aV.$bV.$cV.$minVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4"
      sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.[expr $thisVprnId + 1] ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4"
        sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4
      }
      #
      set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
      #
      set trap2023CheckList ""
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
      set comm1_v4 [createFlowSpecExtCommunityAttr drop]
      set comm1_v6 [createFlowSpecExtCommunityAttr drop]
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v4
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v6
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set comm1_v4 [createFlowSpecExtCommunityAttr drop]
        set comm1_v6 [createFlowSpecExtCommunityAttr drop]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v4
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v6
      }
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      if {[flowspec_analyseTrap_2023tBgpFlowRouteInvalid $dut3 destPfx $trap2023CheckList]} {
        log_msg INFO "Successful analysed trap 2023 ($trap2023CheckList)"
      } else {
        log_msg ERROR "id12748 Not successful analysed trap 2023 ($trap2023CheckList)" ; set Result FAIL
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          log_msg INFO "vvvvv Dump useful info to compare different (dest prefix* & AS_PATH) validation behavior (BEGIN) vvvvv"
          set rCli [$dut3 sendCliCommand "show router $thisContext bgp summary"] ; log_msg INFO "$rCli"
          set rCli [$dut3 sendCliCommand "show router $thisContext bgp routes flow-ipv4 hunt"] ; log_msg INFO "$rCli"
          set rCli [$dut3 sendCliCommand "show router $thisContext bgp routes flow-ipv6 hunt"] ; log_msg INFO "$rCli"
          log_msg INFO "^^^^^ Dump useful info to compare different (dest prefix* & AS_PATH) validation behavior (END) ^^^^^"
        }
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisCheckFlowTxt "Ipv6"} else {set thisCheckFlowTxt "Ipv4"}
          if {[flowspec_checkFlow[set thisCheckFlowTxt]RemAndActRts $dut3 1 0 -svcId $thisContext]} {
            log_msg INFO "$dut3: checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt) passed"
          } else {
            log_msg ERROR "id9531 $dut3: Failed checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt)" ; set Result FAIL ; break
          }
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        # Check invalid in show router bgp routes flow-ipv4/ipv6
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisFamily "ipv6"} else {set thisFamily "ipv4"}
          set thisLegend  [flowspec_getFlowroutesLegend $dut3 "?" -svcId $thisContext -family $thisFamily]
          if {$thisLegend} {
            log_msg INFO "$dut3: Invalid route check passed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)"
          } else {
            log_msg ERROR "id27087 $dut3: Invalid route check failed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)" ; set Result FAIL ; break
          }
        }
      }
      subtest "$mySubtest"
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Best IPv4/IPv6 route advertised in correct context ; Inject IPv4/IPv6 flowroute => Validation should pass (Check trap, bgp summary, bgp routes flow-ipv4/flow-ipv6 flag \"u*>?\")"
      log_msg INFO "" ; log_msg INFO "$mySubtest" ; log_msg INFO ""
      #
      log_msg INFO "First WITHDRAW (WRONG) IPv4/IPv6 routes and (CORRECT) flowroutes"
      set thisDstPrefix_v4 $aV.$bV.$cV.$minVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      #
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4"
      sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4
      #
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      #
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
      #
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.[expr $thisVprnId + 1] ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        #
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4"
        sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4
        #
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        #
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
        #
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
      }
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      log_msg INFO "Advertise IPv4/IPv6 route in correct context"
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4"
      sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4"
        sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4
      }
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      #
      set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
      set tBgpFlowRouteInvalid_[set dut3]_BEFORE [flowspec_getTrapCnt_2023tBgpFlowRouteInvalid $dut3]
      set rCli [$dut3 sendCliCommand "show log log-id 99 subject \"Flow route validation failed\""] ; log_msg INFO "$rCli"
      set rCli [$dut3 sendCliCommand "show router bgp summary"] ; log_msg INFO "$rCli"
      foreach thisVprnId $vprnIdList {
        set rCli [$dut3 sendCliCommand "show router $thisVprnId bgp summary"] ; log_msg INFO "$rCli"
      }
      #
      log_msg INFO "Advertise IPv4/IPv6 flowroutes in correct context"
      set trap2023CheckList ""
      set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
      set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
      set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
      set comm1_v4 [createFlowSpecExtCommunityAttr drop]
      set comm1_v6 [createFlowSpecExtCommunityAttr drop]
      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v4
      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
      lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v6
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set comm1_v4 [createFlowSpecExtCommunityAttr drop]
        set comm1_v6 [createFlowSpecExtCommunityAttr drop]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v4
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
        lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v6
      }
      after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
      #
      set tBgpFlowRouteInvalid_[set dut3]_AFTER [flowspec_getTrapCnt_2023tBgpFlowRouteInvalid $dut3]
      if {[set tBgpFlowRouteInvalid_[set dut3]_BEFORE] == [set tBgpFlowRouteInvalid_[set dut3]_AFTER]} {
        log_msg INFO "Found no (expected behavior) \"2023 tBgpFlowRouteInvalid\" traps"
      } else {
        foreach thisFlowTxt $sbgpDefCapabilityList {
          set rCli [$dut3 sendCliCommand "show router bgp routes $thisFlowTxt"] ; log_msg DEBUG "$rCli"
          foreach thisVprnId $vprnIdList {
            set rCli [$dut3 sendCliCommand "show router $thisVprnId bgp routes $thisFlowTxt"] ; log_msg DEBUG "$rCli"
          }
        }
        set rCli [$dut3 sendCliCommand "show log log-id 99 subject \"Flow route validation failed\""] ; log_msg DEBUG "$rCli"
        log_msg ERROR "id8906 Found unexpected nbr of \"2023 tBgpFlowRouteInvalid\" traps (tBgpFlowRouteInvalid_[set dut3]_BEFORE: [set tBgpFlowRouteInvalid_[set dut3]_BEFORE] => tBgpFlowRouteInvalid_[set dut3]_AFTER: [set tBgpFlowRouteInvalid_[set dut3]_AFTER])" ; set Result FAIL
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisCheckFlowTxt "Ipv6"} else {set thisCheckFlowTxt "Ipv4"}
          if {[flowspec_checkFlow[set thisCheckFlowTxt]RemAndActRts $dut3 2 1 -svcId $thisContext]} {
            log_msg INFO "$dut3: checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt) passed"
          } else {
            log_msg ERROR "id3218 $dut3: Failed checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt)" ; set Result FAIL ; break
          }
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        # Check invalid in show router bgp routes flow-ipv4/ipv6
        foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
          if {[isIpv6Address $thisPrefixMask]} {set thisFamily "ipv6"} else {set thisFamily "ipv4"}
          set thisLegend  [flowspec_getFlowroutesLegend $dut3 "u*>?" -svcId $thisContext -family $thisFamily]
          if {$thisLegend} {
            log_msg INFO "$dut3: Invalid route check passed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)"
          } else {
            log_msg ERROR "id19773 $dut3: Invalid route check failed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)" ; set Result FAIL ; break
          }
        }
      }
      subtest "$mySubtest"
    }
    #
    if {$invalidAsPath} {
      if {! [testFailed] && $Result == "OK"} {
        set mySubtest "$dut3: Best IPv4/IPv6 route advertised in correct context ; Inject IPv4/IPv6 flowroute with not peer's (EBGP) AS number in the leftmost AS number of the AS_PATH attribute => Validation should fail (Check trap, bgp summary, bgp routes flow-ipv4/flow-ipv6 flag \"?\")"
        log_msg INFO "" ; log_msg INFO "$mySubtest" ; log_msg INFO ""
        #
        log_msg INFO "First WITHDRAW IPv4/IPv6 routes and flowroutes"
        set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        #
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4"
        sbgp.run -id peer$baseDot1qTag -withdraw $thisDstPrefixMask_v4
        #
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
        sbgp.run -id peer$baseDot1qTag -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
        #
        set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
        #
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
        sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
        foreach thisVprnId $vprnIdList {
          set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
          #
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4"
          sbgp.run -id peer$thisVprnId -withdraw $thisDstPrefixMask_v4
          #
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
          sbgp.run -id peer$thisVprnId -mpUnReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          #
          set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
          set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
          set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
          set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
          sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
          #
          set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
          sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
        log_msg INFO "Advertise IPv4/IPv6 route in correct context"
        set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
        sbgp.run -id peer$baseDot1qTag -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4"
        sbgp.run -id peer$baseDot1qTag -announce $thisDstPrefixMask_v4
        foreach thisVprnId $vprnIdList {
          set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
          # The "-announce" doesn't work for IPv6, so use mpReach & mpNHop
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReach \"prefix {$thisDstPrefixMask_v6}\" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
          sbgp.run -id peer$thisVprnId -mpReach "prefix {$thisDstPrefixMask_v6}" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4"
          sbgp.run -id peer$thisVprnId -announce $thisDstPrefixMask_v4
        }
        after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
        #
        set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
        set tBgpFlowRouteInvalid_[set dut3]_BEFORE [flowspec_getTrapCnt_2023tBgpFlowRouteInvalid $dut3]
        set rCli [$dut3 sendCliCommand "show log log-id 99 subject \"Flow route validation failed\""] ; log_msg INFO "$rCli"
        set rCli [$dut3 sendCliCommand "show router bgp summary"] ; log_msg INFO "$rCli"
        foreach thisVprnId $vprnIdList {
          set rCli [$dut3 sendCliCommand "show router $thisVprnId bgp summary"] ; log_msg INFO "$rCli"
        }
        #
        log_msg INFO "Advertise IPv4/IPv6 flowroutes in correct context with not peer's (EBGP) AS number ($Linux_wrongAS iso $Linux_AS) in the leftmost AS number of the AS_PATH attribute"
        set trap2023CheckList ""
        #
        # The trap2023CheckList is needed in the flowspec_checkFlow... and flowspec_getFlowroutesLegend checks
        # So add here an extra trap2023CheckList_asPath to be used in the call flowspec_analyseTrap_2023tBgpFlowRouteInvalid
        # with validationType asPath
        set trap2023CheckList_asPath ""
        set thisDstPrefix_v4 $aV.$bV.$cV.$baseDot1qTag ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set comm1_v4 [createFlowSpecExtCommunityAttr drop]
        set comm1_v6 [createFlowSpecExtCommunityAttr drop]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_wrongAS $Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
        sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
        lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v4
        lappend trap2023CheckList_asPath Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $Linux_AS $Linux_wrongAS
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_wrongAS $Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
        sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
        lappend trap2023CheckList Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $thisDstPrefixMask_v6
        lappend trap2023CheckList_asPath Base $dataip(ip.$baseDot1qTag.Linux.$dut3) $Linux_AS $Linux_wrongAS
        foreach thisVprnId $vprnIdList {
          set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
          if {$wrongAsWithoutDstPfx} {
            set flow1_v4 [createFlowSpecNLRIType -proto TCP -dstPort 25]
            set flow1_v6 [createFlowSpecNLRIType -proto TCP -dstPort 25]
          } else {
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
          }
          set comm1_v4 [createFlowSpecExtCommunityAttr drop]
          set comm1_v6 [createFlowSpecExtCommunityAttr drop]
          set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_wrongAS $Linux_AS 65001 65002"
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
          sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
          lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v4
          lappend trap2023CheckList_asPath vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $Linux_AS $Linux_wrongAS
          set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_wrongAS $Linux_AS 65001 65002"
          log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
          sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          lappend trap2023CheckList vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $thisDstPrefixMask_v6
          lappend trap2023CheckList_asPath vprn$thisVprnId $dataip(ip.$thisVprnId.Linux.$dut3) $Linux_AS $Linux_wrongAS
        }
        after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
        #
        if {[flowspec_analyseTrap_2023tBgpFlowRouteInvalid $dut3 asPath $trap2023CheckList_asPath]} {
          log_msg INFO "Successful analysed trap 2023 ($trap2023CheckList_asPath)"
        } else {
          set rCli [$dut3 sendCliCommand "show log log-id $debugLog count 300 descending" -bufferedMode true] ; log_msg DEBUG "$rCli"
          log_msg ERROR "id29315 Not successful analysed trap 2023 ($trap2023CheckList_asPath)" ; set Result FAIL
        }
        #
        if {! [testFailed] && $Result == "OK"} {
          foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
            log_msg INFO "vvvvv Dump useful info to compare different (dest prefix & AS_PATH*) validation behavior (BEGIN) vvvvv"
            set rCli [$dut3 sendCliCommand "show router $thisContext bgp summary"] ; log_msg INFO "$rCli"
            set rCli [$dut3 sendCliCommand "show router $thisContext bgp routes flow-ipv4 hunt"] ; log_msg INFO "$rCli"
            set rCli [$dut3 sendCliCommand "show router $thisContext bgp routes flow-ipv6 hunt"] ; log_msg INFO "$rCli"
            log_msg INFO "^^^^^ Dump useful info to compare different (dest prefix & AS_PATH*) validation behavior (END) ^^^^^"
          }
          foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
            if {[isIpv6Address $thisPrefixMask]} {set thisCheckFlowTxt "Ipv6"} else {set thisCheckFlowTxt "Ipv4"}
            if {[flowspec_checkFlow[set thisCheckFlowTxt]RemAndActRts $dut3 1 0 -svcId $thisContext]} {
              log_msg INFO "$dut3: checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt) passed"
            } else {
              log_msg ERROR "id21133 $dut3: Failed checkFlow[set thisCheckFlowTxt]RemAndActRts (svcId: $thisContext ; $thisCheckFlowTxt)" ; set Result FAIL ; break
            }
          }
        }
        #
        if {! [testFailed] && $Result == "OK"} {
          # Check invalid in show router bgp routes flow-ipv4/ipv6
          foreach {thisContext thisPeer thisPrefixMask} $trap2023CheckList {
            if {[isIpv6Address $thisPrefixMask]} {set thisFamily "ipv6"} else {set thisFamily "ipv4"}
            set thisLegend [flowspec_getFlowroutesLegend $dut3 "?" -svcId $thisContext -family $thisFamily]
            if {$thisLegend} {
              log_msg INFO "$dut3: Invalid route check passed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)"
            } else {
              log_msg ERROR "id15522 $dut3: Invalid route check failed (thisLegend: \"$thisLegend\" ; svcId: $thisContext ; $thisFamily)" ; set Result FAIL ; break
            }
          }
        }
        subtest "$mySubtest"
      }
    }
    #
    if {! [testFailed] && $Result == "OK"} {
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "test"
      log_msg INFO "$mySubtest"
      subtest "$mySubtest"
    }
  }
  
  if {$option(deconfig) == "true" } {
     saveOrRestore delete
     sbgp.closeall
  }
  testcaseTrailer

}

proc flowspec.reproduceBug153413 { args } { 
  global masterlog testdir ixia_port logdir
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  set option(verbose) false
  set option(bugxxxxx) false
  set option(returnResult) false
  set option(sbgpDebug) false
  set option(dumpDebugLog) false
  set option(cliTimeout) 600
  set option(maxRetryCnt) 3
  set option(interRetryTimeSec) 60
  set option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected) false
  set option(addDefFilterInLastVprnAfterFlowroutesAreInjected) false
  set option(nbrVprns) 6
  set option(nbrFlowroutesPerVprn) 2
  set option(bgpNlriBufMax_specialDistribution) false
  set option(actionListPerVprn) [list drop log accept redirectVrf]
  set option(enableFilterTrace) false
  set option(enableBgpFlowspecTrace) false
  set option(sendBgpPrefixUpd_v4) false
  set option(sendBgpPrefixUpd_v6) false
  set option(sendBgpFlowrouteUpd_v4) true
  set option(sendBgpFlowrouteUpd_v6) true
  set option(sendTraffic_v4) true
  set option(sendTraffic_v6) true
  set option(enableIngressFlowspec_v4) false
  set option(enableIngressFlowspec_v6) false
  set option(vrfTargetDirectUnderVprn_noImportPolicy) true
  set option(actionExpectedBehaviorList) ""
  set option(scenarioNbr) 2

  #                                                                
  # spoke
  set option(itfType_dut1dut2) ""
  set option(addFlowroutesInBase) true
  set option(skipCheckFilterLog) true
  
  # maxNbrIterations | maxDuration [hours] | ifFileExists
  set option(iterationMethod) maxNbrIterations
  set option(maxNbrIterations) 1
  set option(maxDurationHrs) 5
  set option(fileExistsName) "/tmp/fspecVprn_running.txt"
  set option(neverDisableDutLogging) false
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecNbrVprns] != "ERROR"} {
    set nbrVprns [GGV fspecNbrVprns]
  } else {
    set nbrVprns $option(nbrVprns)
  }
  if {[GGV fspecNbrFlowroutesPerVprn] != "ERROR"} {
    set nbrFlowroutesPerVprn [GGV fspecNbrFlowroutesPerVprn]
  } else {
    set nbrFlowroutesPerVprn $option(nbrFlowroutesPerVprn)
  }
  if {[GGV fspecEnableFilterTrace] != "ERROR"} {
    set enableFilterTrace [GGV fspecEnableFilterTrace]
  } else {
    set enableFilterTrace $option(enableFilterTrace)
  }
  if {[GGV fspecEnableBgpFlowspecTrace] != "ERROR"} {
    set enableBgpFlowspecTrace [GGV fspecEnableBgpFlowspecTrace]
  } else {
    set enableBgpFlowspecTrace $option(enableBgpFlowspecTrace)
  }
  if {[GGV fspecSendBgpPrefixUpd_v4] != "ERROR"} {
    set sendBgpPrefixUpd_v4 [GGV fspecSendBgpPrefixUpd_v4]
  } else {
    set sendBgpPrefixUpd_v4 $option(sendBgpPrefixUpd_v4)
  }
  if {[GGV fspecSendBgpPrefixUpd_v6] != "ERROR"} {
    set sendBgpPrefixUpd_v6 [GGV fspecSendBgpPrefixUpd_v6]
  } else {
    set sendBgpPrefixUpd_v6 $option(sendBgpPrefixUpd_v6)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v4] != "ERROR"} {
    set sendBgpFlowrouteUpd_v4 [GGV fspecSendBgpFlowrouteUpd_v4]
  } else {
    set sendBgpFlowrouteUpd_v4 $option(sendBgpFlowrouteUpd_v4)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v6] != "ERROR"} {
    set sendBgpFlowrouteUpd_v6 [GGV fspecSendBgpFlowrouteUpd_v6]
  } else {
    set sendBgpFlowrouteUpd_v6 $option(sendBgpFlowrouteUpd_v6)
  }
  if {[GGV fspecActionListPerVprn] != "ERROR"} {
    set actionListPerVprn [GGV fspecActionListPerVprn]
  } else {
    set actionListPerVprn $option(actionListPerVprn)
  }
  if {[GGV fspecDumpDebugLog] != "ERROR"} {
    set dumpDebugLog [GGV fspecDumpDebugLog]
  } else {
    set dumpDebugLog $option(dumpDebugLog)
  }
  if {[GGV fspecSendTraffic_v4] != "ERROR"} {
    set sendTraffic_v4 [GGV fspecSendTraffic_v4]
  } else {
    set sendTraffic_v4 $option(sendTraffic_v4)
  }
  if {[GGV fspecSendTraffic_v6] != "ERROR"} {
    set sendTraffic_v6 [GGV fspecSendTraffic_v6]
  } else {
    set sendTraffic_v6 $option(sendTraffic_v6)
  }
  if {[GGV fspecEnableIngressFlowspec_v4] != "ERROR"} {
    set enableIngressFlowspec_v4 [GGV fspecEnableIngressFlowspec_v4]
  } else {
    set enableIngressFlowspec_v4 $option(enableIngressFlowspec_v4)
  }
  if {[GGV fspecEnableIngressFlowspec_v6] != "ERROR"} {
    set enableIngressFlowspec_v6 [GGV fspecEnableIngressFlowspec_v6]
  } else {
    set enableIngressFlowspec_v6 $option(enableIngressFlowspec_v6)
  }
  if {[GGV fspecVrfTargetDirectUnderVprn_noImportPolicy] != "ERROR"} {
    set vrfTargetDirectUnderVprn_noImportPolicy [GGV fspecVrfTargetDirectUnderVprn_noImportPolicy]
  } else {
    set vrfTargetDirectUnderVprn_noImportPolicy $option(vrfTargetDirectUnderVprn_noImportPolicy)
  }
  if {[GGV fspecItfType_dut1dut2] != "ERROR"} {
    set itfType_dut1dut2 [GGV fspecItfType_dut1dut2]
  } else {
    set itfType_dut1dut2 $option(itfType_dut1dut2)
  } 
  if {[GGV fspecActionExpectedBehaviorList] != "ERROR"} {
    set actionExpectedBehaviorList [GGV fspecActionExpectedBehaviorList]
  } else {
    set actionExpectedBehaviorList $option(actionExpectedBehaviorList)
  }
  if {[GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected [GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected]
  } else {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected $option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected)
  }
  if {[GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected [GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected]
  } else {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected $option(addDefFilterInLastVprnAfterFlowroutesAreInjected)
  }
  if {[GGV fspecAddFlowroutesInBase] != "ERROR"} {
    set addFlowroutesInBase [GGV fspecAddFlowroutesInBase]
  } else {
    set addFlowroutesInBase $option(addFlowroutesInBase)
  }
  if {[GGV fspecSkipCheckFilterLog] != "ERROR"} {
    set skipCheckFilterLog [GGV fspecSkipCheckFilterLog]
  } else {
    set skipCheckFilterLog $option(skipCheckFilterLog)
  }
  if {[GGV fspecIterationMethod] != "ERROR"} {
    set iterationMethod [GGV fspecIterationMethod]
  } else {
    set iterationMethod $option(iterationMethod)
  }
  if {[GGV fspecMaxNbrIterations] != "ERROR"} {
    set maxNbrIterations [GGV fspecMaxNbrIterations]
  } else {
    set maxNbrIterations $option(maxNbrIterations)
  }
  if {[GGV fspecMaxDurationHrs] != "ERROR"} {
    set maxDurationHrs [GGV fspecMaxDurationHrs]
  } else {
    set maxDurationHrs $option(maxDurationHrs)
  }
  if {[GGV fspecBgpNlriBufMax_specialDistribution] != "ERROR"} {
    set bgpNlriBufMax_specialDistribution [GGV fspecBgpNlriBufMax_specialDistribution]
  } else {
    set bgpNlriBufMax_specialDistribution $option(bgpNlriBufMax_specialDistribution)
  }
  if {[GGV fspecNeverDisableDutLogging] != "ERROR"} {
    set neverDisableDutLogging [GGV fspecNeverDisableDutLogging]
  } else {
    set neverDisableDutLogging $option(neverDisableDutLogging)
  }
  if {[GGV fspecScenarioNbr] != "ERROR"} {
    set scenarioNbr [GGV fspecScenarioNbr]
  } else {
    set scenarioNbr $option(scenarioNbr)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]

  if {$bgpNlriBufMax_specialDistribution} {
    # vprnIdList => thisVprnId | thisNbrFlowroutesPerVprn | thisActionListPerVprn
    # vprnIdOnlyList => has only the vprnId's
    # Use a specialDistribution to stress the reshuffle mechanism
    set vprnIdList "" ; set vprnIdOnlyList "" ; set nbrVprns 0
    lappend vprnIdList [expr $minVprnId + 0] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 0] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 1] 8 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 1] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 2] 24 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 2] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 3] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 3] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 4] 3 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 4] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 5] 29 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 5] ; incr nbrVprns
    lappend vprnIdList [expr $minVprnId + 6] 16 $actionListPerVprn ; lappend vprnIdOnlyList [expr $minVprnId + 6] ; incr nbrVprns
  } else {
    # vprnIdList => thisVprnId | thisNbrFlowroutesPerVprn | thisActionListPerVprn
    # vprnIdOnlyList => has only the vprnId's
    set vprnIdList "" ; set vprnIdOnlyList ""
    for {set vprnId 1} {$vprnId <= $nbrVprns} {incr vprnId} {
      lappend vprnIdList [expr $minVprnId - 1 + $vprnId] ; lappend vprnIdOnlyList [expr $minVprnId - 1 + $vprnId]
      lappend vprnIdList $nbrFlowroutesPerVprn
      lappend vprnIdList $actionListPerVprn
    }
  }
  # Use the next dot1q tag for the Base
  set baseDot1qTag [expr [lindex $vprnIdOnlyList end] + 1]
  
  set nbrStreamsFamilies 0 ; if {$sendTraffic_v4} {incr nbrStreamsFamilies} ; if {$sendTraffic_v6} {incr nbrStreamsFamilies}
  if {$addFlowroutesInBase} {
    set nbrStreamsUsed [expr [expr $nbrVprns + 1] * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  } else {
    set nbrStreamsUsed [expr $nbrVprns * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  }
  
  # Check the testcase limitations (begin)
  if {$nbrVprns > 250} {
    log_msg ERROR "id1648 Testcase couldn't handle >250 vprn's because of ip address limitation" ; set Result FAIL
  }
  
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
    if {$thisNbrFlowroutesPerVprn > 221} {
      log_msg ERROR "id5789 Testcase couldn't handle >221 (223-2 ; \"-2\" because dot1q=1 is reserved on Linux & one dot1q reserved for Base) flowroutes per vprn because of ip address limitation" ; set Result FAIL ; break
    }
  }
  # Check the testcase limitations (end)
  
  set pktRatePerStream 2 ; set pktSize 128 ; set streamData_ISATMS "49 53 41 54 4D 53" ; set rawProtocol 253
  set trafficDurationSecsDuringPrecondition 30
  
  # the vprn (to redirect) is between dut2/dut4
  set thisRT "target:42:1"
   
  set enableTraceDutList [list $dut2 $dut3]
  
  # spokeSdp case
  set spokeIesId 5000 ; set spokeSdpId 1 ; set spokeSdpVcId 1
  
  if {$sendBgpFlowrouteUpd_v4 && $sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv4 ipv6]
  } elseif {$sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv6]
  } else {
    set thisFilterFamilyList [list ipv4]
  }
  set groupName "onegroup"
  
  # 101..199 => always 101 for flowspec
  set filterLogId 101
  
  set rollbackLocation "ftp://$::TestDB::thisTestBed:tigris@$::TestDB::thisHostIpAddr/$logdir/device_logs/saved_configs"
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : Try to reproduce bug153413"
  log_msg INFO "#         Inject flowroues in vprn while flowspec is not yet applied on itf.  Then rollback"
  log_msg INFO "# Setup:"
  log_msg INFO "# "
  log_msg INFO "#                              PE($dut4)----------> scrubber (Ixia)"
  log_msg INFO "#                               dut4 (dest for redirect actions)"
  log_msg INFO "#                                |"
  log_msg INFO "#                                |"
  log_msg INFO "#                                |       +-- Base-Base(dut2-dut3): BGP to exchange IPv4, IPv6 & flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): BGP in the VPRN to exchange flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): L3-VPN to exchange IPv4 & IPv6 routes"
  log_msg INFO "#                                |       |"
  log_msg INFO "#                                |       v"
  log_msg INFO "#   Ixia----------dut1----------dut2----------dut3----------dut6"
  log_msg INFO "#                CE1($dut1)    PE($dut2)     PE($dut3)     CE2($dut6)"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                             Linux (In VPRN & Base: Injects flowroutes via sbgp)"
  log_msg INFO "# "
  log_msg INFO "# Important testcase parameters:"
  log_msg INFO "#   vprnIdOnlyList: $vprnIdOnlyList"
  log_msg INFO "#   vprnIdList: vprnId | nbrFlowroutesPerVprn | thisActionListPerVprn"
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
  set actionPrefixAString ""
  foreach thisAction $thisActionListPerVprn {
    append actionPrefixAString "$thisAction\([set a_[set thisAction]].x.x.x\) "
  }
  log_msg INFO [format "%1s %13s %6s | %20s | \"%30s\" " "#" " "  $thisVprnId $thisNbrFlowroutesPerVprn $actionPrefixAString]
  }
  log_msg INFO "# "
  log_msg INFO "#      scenarioNbr: $scenarioNbr"
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  set dutLoggingDisabled false
  if {([expr $nbrVprns * $nbrFlowroutesPerVprn] > 16)} {
    if {$neverDisableDutLogging} {
      log_msg WARNING "Disable logging in dut-logs NOT done because neverDisableDutLogging: $neverDisableDutLogging"
    } else {
      log_msg WARNING "Disable logging in dut-logs because scale is too high"
      set dutLoggingDisabled true
      foreach dut $dutList {
        $dut configure -logging false
      }
    }
  }

  # handlePacket -action reset -portList all
  CLN.reset
  set cliTimeoutOrig [$dut2 cget -cli_timeout]
  $dut2 configure -cli_timeout $option(cliTimeout)

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as [set [set dut1]_AS]"
    CLN "dut $dut2 systemip [set [set dut2]_ifsystem_ip] isisarea $isisAreaId as [set [set dut2]_AS]"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as [set [set dut3]_AS]"
    CLN "dut $dut4 systemip [set [set dut4]_ifsystem_ip] isisarea $isisAreaId as [set [set dut4]_AS]"
    CLN "dut $dut5 systemip [set [set dut5]_ifsystem_ip] isisarea $isisAreaId as [set [set dut5]_AS]"
    CLN "dut $dut6 systemip [set [set dut6]_ifsystem_ip] isisarea $isisAreaId as [set [set dut6]_AS]"
    
    set a 30 ; set b [expr 20 + [lindex $vprnIdOnlyList 0]] ; set c 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn } $vprnIdList {
      CLN "dut $dut2 vprnid $thisVprnId systemip $a.$b.$c.2 as [set [set dut2]_AS]"
      CLN "dut $dut3 vprnid $thisVprnId systemip $a.$b.$c.3 as [set [set dut3]_AS]"
      incr b ; if {$b > 255} {set b 0 ; incr a}
    }
    
    # used for spokes dut1/dut2
    CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q 1 ip 1.1.1.1 ldp true mpls true"
    CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q 1 ip 1.1.1.2 ldp true mpls true" 
    
    # In the CE's, bgp routes are learned from different peers (the neighbor end point is in different vprn).
    # The learned bgp routes are installed in the Base routing-table and exported again to all neighbors (default ebgp behavior).
    # To avoid that the neigbor end points (in different vprn's) receive the exported bgp routes (CE's Base instance) a reject policy should be installed.
    CLN "dut $dut1 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    CLN "dut $dut6 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    
    # Exchange flowroutes via BGP peer in the VPRN, because SAFI=134 (exchange flowroutes via L3-VPN) is not supported 
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut3 tonode $dut2 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut3 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'flow-ipv4 flow-ipv6' " 
    }

    # redistribute bgp-vpn in ospf
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 to 'protocol ospf' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 to 'protocol ospf3' action accept"

    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      #
      if {$itfType_dut1dut2 == "spoke"} {
        CLN "dut $dut1 tonode $dut2 porttype hybrid iesid $spokeIesId iftype spoke sdpid '$spokeSdpId gre [set [set dut2]_ifsystem_ip]' dot1q $thisVprnId ip $thisVprnId.$dataip(id.$dut1).$dataip(id.$dut2).$dataip(id.$dut1) ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid iftype spoke sdpid '$spokeSdpId gre [set [set dut1]_ifsystem_ip]' vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      } else {      
        CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      }
   
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut6]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut6]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
      CLN "dut $dut3 tonode $dut6 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut3]_ifsystem_ip] as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      
      CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut2 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
      CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
    }
    
    if {$addFlowroutesInBase} {
      CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut2]_ifsystem_ip]  bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true"
      CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut3]_ifsystem_ip] bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true" 
      #
      CLN "dut $dut3 tonode $dut6 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      #
      CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      #
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    # Ixia connections
    set filterEntryId 1
    foreach thisAction $actionListPerVprn {
      CLN "dut $dut1 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut6 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut1 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      CLN "dut $dut6 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      incr filterEntryId
    }
    CLN "dut $dut1 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut $dut6 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut Ixia tonode $dut1"
    CLN "dut Ixia tonode $dut6"
    
    # CE2: static routes and policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 to 'protocol ospf' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 to 'protocol ospf3' action accept"
        CLN "dut $dut6 ospf 'export fromStaticToVprns_v4' "
        CLN "dut $dut6 ospf3 'export fromStaticToVprns_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    # policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v4 prefix $thisDstPrefixMask_v4 longer' "
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v6 prefix $thisDstPrefixMask_v6 longer' "
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v4 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v4' action accept"
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v6 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v6' action accept"
        CLN "dut $dut3 vprnid $thisVprnId ospf 'import fromStaticToVprn[set thisVprnId]_v4' "
        CLN "dut $dut3 vprnid $thisVprnId ospf3 'import fromStaticToVprn[set thisVprnId]_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    if {$addFlowroutesInBase} {
      # - Don't reset b, c and d because they point to the next values to be used
      # - Use isis in the Base instance
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v4 prefix $thisDstPrefixMask_v4 longer' "
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v6 prefix $thisDstPrefixMask_v6 longer' "
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v4' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v6' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 isis 'export fromStaticToBase[set baseDot1qTag]_v4 fromStaticToBase[set baseDot1qTag]_v6'"
      }
    }
    
    # used in redirectToVrf
    CLN "dut $dut2 tonode $dut4 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut4 tonode $dut2 ldp true mpls true isisarea $isisAreaId"
    CLN "dut $dut2 bgpneighbor [set [set dut4]_ifsystem_ip] bgppeeras [set [set dut4]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"   
    CLN "dut $dut4 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras [set [set dut2]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"
    
    CLN.exec
    CLN.reset
    
    set thisPePeList [list $dut2 $dut3]
    foreach dut $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        docli $dut "configure router"
        docli $dut "         policy-options"
        docli $dut "            begin"
        docli $dut "            community vprn_[set thisVprnId]_exportRouteTarget members target:1982:$thisVprnId"
        docli $dut "            community vprn_[set thisVprnId]_importRouteTarget members target:1982:$thisVprnId"
        docli $dut "            policy-statement vprn_[set thisVprnId]_exportPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol ospf"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "                entry 2"
        docli $dut "                    from"
        docli $dut "                        protocol ospf3"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            policy-statement vprn_[set thisVprnId]_importPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                        community vprn_[set thisVprnId]_importRouteTarget"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            commit"
        docli $dut "        exit all"
      }
    }
    foreach dut $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        docli $dut "configure service vprn $thisVprnId" 
        docli $dut "no vrf-target"
        docli $dut "vrf-import vprn_[set thisVprnId]_importPol"
        docli $dut "vrf-export vprn_[set thisVprnId]_exportPol"
        docli $dut "exit all"
      }
    }

    # used in redirectToVrf
    set redirectVprnId 400 ; set customerId 1 ; set nbrRedirectVprn 4 
    set firstRedirectVprnId $redirectVprnId
    set maxRedirectVprnId [expr $firstRedirectVprnId + $nbrRedirectVprn - 1]
    set minRedirectVprnId $redirectVprnId
    #                                           dut       thisDutId            ngbrDutId                 itfToNgbr
    set redirectVprnDutList [list $dut2 $dataip(id.$dut2) $dataip(id.$dut4) $dataip(ip.1.$dut2.$dut4) $dut4 $dataip(id.$dut4) $dataip(id.$dut2) $dataip(ip.1.$dut4.$dut2)]
    #
    # Also needed is a path from Dut-D to Ixia2 (scrubber).
    #   - In Dut-D: add port to Dut-E in vprn
    #   - In Dut-E: epipe between port to Dut-D and port to Dut-C
    #   - In Dut-C: epipe between port to Dut-E and port to Ixia2
    #                                         dut  epipeId fromPort toPort
    set epipeListToScrubber [list $dut5 666 $portA($dut5.$dut4) $portA($dut5.$dut3) \
                                                $dut3 667 $portA($dut3.$dut5) $portA($dut3.Ixia)]
    # Redirect is done in Dut-B
    set checkIpFlowspecFilterDutList [list $dut2]
  
    foreach {dut thisDutId ngbrDutId itfToNgbr} $redirectVprnDutList {
      docli $dut "configure router"
      docli $dut "         policy-options"
      docli $dut "            begin"
      docli $dut "            community \"vprn1_exportRouteTarget\" members \"target:[set thisDutId][set ngbrDutId]:1\" "
      docli $dut "            community \"vprn1_importRouteTarget_[set ngbrDutId]\" members \"target:[set ngbrDutId][set thisDutId]:1\" "
      docli $dut "            policy-statement vprn_exportPol_[set thisDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol direct"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "                entry 2"
      docli $dut "                    from"
      docli $dut "                        protocol static"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                        community vprn1_importRouteTarget_[set ngbrDutId]"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            commit"
      docli $dut "        exit all"
    }
    foreach {dut thisDutId ngbrDutId itfToNgbr} $redirectVprnDutList {
      docli $dut "configure service" -verbose $option(verbose)
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
        docli $dut "        vprn $thisRedirectVprnId customer 1 create" -verbose $option(verbose)
        docli $dut "            no shutdown" -verbose $option(verbose)
        if {$vCnt == [expr $nbrRedirectVprn - 1] && $vrfTargetDirectUnderVprn_noImportPolicy} {
          log_msg INFO "Don't use vrf-import policy for the last vprn $thisRedirectVprnId"
          docli $dut "            vrf-target target:[set ngbrDutId][set thisDutId]:1" -verbose $option(verbose)
        } else {
          docli $dut "            vrf-import vprn_importPol_[set thisDutId]_[set ngbrDutId]" -verbose $option(verbose)
        }
        docli $dut "            vrf-export vprn_exportPol_[set thisDutId]" -verbose $option(verbose)
        docli $dut "            route-distinguisher $thisRedirectVprnId:1" -verbose $option(verbose)
        docli $dut "            auto-bind gre" -verbose $option(verbose)
        docli $dut "        exit"  -verbose $option(verbose)
      }
      docli $dut "exit all" -verbose $option(verbose)
    }
            

    if {$epipeListToScrubber != ""} {
      foreach {epipeDut epipeId epipeFromPort epipeToPort} $epipeListToScrubber {
        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
          set thisVlanId [expr $vCnt + 1] ; set thisEpipeId [expr $epipeId + $vCnt]
          flowspec_createEpipe $epipeDut $thisEpipeId $epipeFromPort $epipeToPort -fromEncapType dot1q -fromSap "$epipeFromPort:$thisVlanId" -toEncapType dot1q -toSap "$epipeToPort:$thisVlanId"
        }
      }
    }
    log_msg INFO "$dut4: Create dot1q itfs (#$nbrRedirectVprn) via $portA($dut4.$dut5) and default-route (in vprn) to scrubber (Ixia $portA(Ixia.$dut3))"
    # create itf to scrubber (Ixia2)
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) shut"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet mode access"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet encap-type dot1q"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) no shut"] ; log_msg INFO "$rCli"
    for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
      set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
      set thisVlanId [expr $vCnt + 1]
      set rCli [$dut4 sendCliCommand "exit all"]
      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "sap $portA($dut4.$dut5):$thisVlanId create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.$dataip(id.$dut3)" "."] {break} ; set thisB [expr $thisB + $vCnt]
      set rCli [$dut4 sendCliCommand "address $thisA.$thisB.$thisC.$thisD/$clnItfMask_v4"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 address [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]/$clnItfMask_v6"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.9" "."] {break} ; set thisB [expr $thisB + $vCnt]
      set rCli [$dut4 sendCliCommand "static-route 0.0.0.0/0 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "static-route 0::0/0 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
      # Add here static-routes for the redirectToVrf vprn
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      if {$addFlowroutesInBase} {
        # - Don't reset b, c and d because they point to the next values to be used
        # - Use isis in the Base instance
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
      }
      #
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "static-arp $thisA.$thisB.$thisC.$thisD 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 neighbor [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD] 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
    }
    
    if {$enableFilterTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"FILTER\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
      }
    }
    if {$enableBgpFlowspecTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"BGP\" " -verbose $option(verbose)
        docli $dut "debug trace trace-point module \"BGP_VPRN\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
        # enableBgpFlowspecTrace $dut
        # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        #  enableBgpFlowspecTrace $dut2 -vprnId $thisVprnId
        # }
      }
    }

  } ; # config
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # Ixia part
    handlePacket -port $portA(Ixia.$dut1) -action stop
    set thisDA 00:00:00:00:00:[int2Hex1 $dataip(id.$dut1)]
    set totalNbrOfFlowroutes 0
    set startStreamId 1
    set streamId $startStreamId 
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }
    if {$addFlowroutesInBase} {
      # - Don't reset b, c and d because they point to the next values to be used
      # - Use isis in the Base instance
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $thisNbrFlowroutesPerVprn -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $thisNbrFlowroutesPerVprn -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
    }
    
    # scrubber
    handlePacket -port $portA(Ixia.$dut3) -action capture
    
    log_msg INFO "Wait till all vprn's are operational before inject flowspec"
    set nbrRedirectVprnOperStateUp 0
    foreach {dut} $checkIpFlowspecFilterDutList {break}
    for {set rCnt 1} {$rCnt <= $option(maxRetryCnt)} {incr rCnt} {
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        set thisRedirectVprnId [expr $redirectVprnId + $vCnt]
        set rCli [$dut sendCliCommand "show service id $thisRedirectVprnId all | match \"Oper State\" "]
        # Admin State       : Up                  Oper State        : Up
        if {[regexp {.*Oper State[ ]+:[ ]+([A-Za-z]+).*} $rCli match vprnOperState]} {
          if {$vprnOperState == "Up"} {
            incr nbrRedirectVprnOperStateUp
          }
        }
      }
      if {$nbrRedirectVprnOperStateUp == $nbrRedirectVprn} {
        log_msg INFO "All redirectVprn are Up ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn)"
        break
      } else {
        log_msg INFO "Waiting $option(interRetryTimeSec) sec ($rCnt/$option(maxRetryCnt)) till all redirectVprn ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn) are Up ..." ; after [expr $option(interRetryTimeSec) * 1000]
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "Precondition: Waiting 20secs and check that traffic flows from $dut1 to $dut6" ; after 20000
      log_msg INFO "$mySubtest"
      if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
        log_msg INFO "Traffic from $dut1 to $dut6 ok"
      } else {
        log_msg ERROR "id20623 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
      }

      subtest "$mySubtest"
    }
    
    if {! [testFailed] && $Result == "OK"} {
      # sbgp part
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$thisVprnId -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$baseDot1qTag -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
          }
        }
      }
      #
      set b 1 ; set c [lindex $vprnIdOnlyList 0] 
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 1
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
            }
            incr d
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 1
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
            }
            incr d
          }
        }
      }
      #
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        sbgp.run -id peer$thisVprnId
      }
      if {$addFlowroutesInBase} {
        sbgp.run -id peer$baseDot1qTag
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "Check that traffic still flows from $dut1 to $dut6, because ingress flowspec/flowspec-ipv6 is not yet applied"
      log_msg INFO "$mySubtest"
      if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
        log_msg INFO "Traffic from $dut1 to $dut6 ok"
      } else {
        log_msg ERROR "id27141 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
      }
      subtest "$mySubtest"
    }
        
    if {! [testFailed] && $Result == "OK"} {
      switch $scenarioNbr {
        "1" {
          set mySubtest "$dut2: Create rollback checkpoint, remove complete configuration and restore via rollback revert.  During the revert do in $dut3 a \"clear router <router-instance> bgp neighbor\" "
          log_msg INFO "$mySubtest"
          set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
          #
          after 1000
          saveOrRestore delete -dut $dut2
          after 1000
          # configure rollback-location again because it was removed during saveOrRestore delete
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
          }
          #
          set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
          }
          #
          set rCli [$dut2 sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
          log_msg INFO "Waiting 20secs ...." ; after 20000
          subtest "$mySubtest"
        }
        
        "2" {
          set randomVprnId [lindex $vprnIdOnlyList [random [llength $vprnIdOnlyList]]]
          set mySubtest "$dut2: Create rollback checkpoint, remove one vprn (#$randomVprnId) and restore via rollback revert.  During the revert do in $dut3 a \"clear router $randomVprnId bgp neighbor\" "
          log_msg INFO "$mySubtest"
          set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
          #
          set rCli [$dut2 sendCliCommand "configure service"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "info"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
          after 1000
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              # remove protocols
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no bgp"] ; log_msg INFO $rCli       
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId ospf shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no ospf"] ; log_msg INFO $rCli       
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId ospf3 shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no ospf3"] ; log_msg INFO $rCli 
              #
              if {$itfType_dut1dut2 == "spoke"} {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] no spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1))"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut1][set thisVprnId]"] ; log_msg INFO $rCli
                #
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut3)) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] no spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut3))"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut3][set thisVprnId]"] ; log_msg INFO $rCli
              } else {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] no sap $dataip(sap.$thisVprnId.$dut2.$dut1)"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut1][set thisVprnId]"] ; log_msg INFO $rCli
                #
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut3) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] no sap $dataip(sap.$thisVprnId.$dut2.$dut3)"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut3][set thisVprnId]"] ; log_msg INFO $rCli
              }
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId shut"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service no vprn $thisVprnId"] ; log_msg INFO $rCli
              break
            }
          }
          after 1000
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
              break
            }
          }
          #
          set rCli [$dut2 sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
              break
            }
          }
          #
          set rCli [$dut2 sendCliCommand "configure service"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "info"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
          #
          set rCli [$dut2 sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
          log_msg INFO "Waiting 20secs ...." ; after 20000
          subtest "$mySubtest"
        }

        "3" {
          set randomVprnId [lindex $vprnIdOnlyList [random [llength $vprnIdOnlyList]]]
          set mySubtest "$dut2: Create rollback checkpoint (.rb.1), remove one vprn (#$randomVprnId), create rollback checkpoint (latest), go back to checkpoint (1) and now to checkpoint (latest).  During the revert do in $dut3 a \"clear router $randomVprnId bgp neighbor\" "
          log_msg INFO "$mySubtest"
          set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
          #
          log_msg INFO "" ; log_msg INFO "Create rollback checkpoint (.rb.1) before remove vprn" ; log_msg INFO ""
          set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
          #
          set rCli [$dut2 sendCliCommand "configure service"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "info"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
          after 1000
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              # remove protocols
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no bgp"] ; log_msg INFO $rCli       
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId ospf shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no ospf"] ; log_msg INFO $rCli       
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId ospf3 shutdown"] ; log_msg INFO $rCli 
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no ospf3"] ; log_msg INFO $rCli 
              #
              if {$itfType_dut1dut2 == "spoke"} {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] no spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1))"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut1][set thisVprnId]"] ; log_msg INFO $rCli
                #
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut3)) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] no spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut3))"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut3][set thisVprnId]"] ; log_msg INFO $rCli
              } else {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] no sap $dataip(sap.$thisVprnId.$dut2.$dut1)"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut1][set thisVprnId]"] ; log_msg INFO $rCli
                #
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut3) shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] no sap $dataip(sap.$thisVprnId.$dut2.$dut3)"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut3][set thisVprnId] shut"] ; log_msg INFO $rCli
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId no interface to_[set dut3][set thisVprnId]"] ; log_msg INFO $rCli
              }
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId shut"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service no vprn $thisVprnId"] ; log_msg INFO $rCli
              break
            }
          }
          log_msg INFO "" ; log_msg INFO "Create rollback checkpoint (latest) after remove vprn" ; log_msg INFO ""
          set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
          after 1000
          log_msg INFO "" ; log_msg INFO "Now go back to checkpoint (.rb.1), which has all vprn's" ; log_msg INFO ""
          set rCli [$dut2 sendCliCommand "admin rollback revert 1 now"] ; log_msg INFO "$rCli"
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
              break
            }
          }
          #
          log_msg INFO "" ; log_msg INFO "Now go back to checkpoint (latest), with removed vprn's" ; log_msg INFO ""
          set rCli [$dut2 sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
          #
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$thisVprnId == $randomVprnId} {
              set rCli [$dut3 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut2)"] ; log_msg INFO "$rCli"
              break
            }
          }
          #
          set rCli [$dut2 sendCliCommand "configure service"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "info"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
          #
          set rCli [$dut2 sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
          set rCli [$dut2 sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
          log_msg INFO "Waiting 20secs ...." ; after 20000
          subtest "$mySubtest"
        }
        
      }
    }

    
  }
  
  if {$option(deconfig)} {
    saveOrRestore delete
    sbgp.closeall
  } 
  
  testcaseTrailer
  $dut2 configure -cli_timeout $cliTimeoutOrig
  if {$dutLoggingDisabled} {
    log_msg WARNING "Logging in dut-logs was disabled, enable it again"
    foreach dut $dutList {
      $dut configure -logging logging
    }
  }
}

proc flowspec.RFE162746 { args } { 
  global masterlog testdir ixia_port logdir
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  set option(verbose) false
  set option(bugxxxxx) false
  set option(returnResult) false
  set option(sbgpDebug) false
  set option(dumpDebugLog) false
  set option(cliTimeout) 600
  set option(maxRetryCnt) 6
  set option(interRetryTimeSec) 30
  set option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected) true
  set option(addDefFilterInLastVprnAfterFlowroutesAreInjected) true
  set option(nbrVprns) 3
  set option(nbrFlowroutesPerVprn) 1
  set option(numTrafficDst_v4) 2
  set option(numTrafficDst_v6) 2
  set option(actionListPerVprn) [list redirectVrf]
  set option(enableFilterTrace) false
  set option(enableBgpFlowspecTrace) false
  set option(sendBgpPrefixUpd_v4) false
  set option(sendBgpPrefixUpd_v6) false
  set option(sendBgpFlowrouteUpd_v4) true
  set option(sendBgpFlowrouteUpd_v6) true
  set option(sendTraffic_v4) true
  set option(sendTraffic_v6) true
  set option(enableIngressFlowspec_v4) true
  set option(enableIngressFlowspec_v6) true
  set option(vrfTargetDirectUnderVprn_noImportPolicy) true
  set option(enableFlowspecBeforeFlowroutesAreInjected) false
  set option(actionExpectedBehaviorList) [list "none" "defaultBehavior" \
                                                                    "adminTech" "none" \
                                                                    "swo" "defaultBehavior" \
                                                                    "removeAllIpv4v6RoutesFromRedirectVprn" "noRedirectToVrfTraffic_allTrafficViaGrtLeaking" \
                                                                    "addAllIpv4v6RoutesFromRedirectVprn" "defaultBehavior" \
                                                                    "addGrtLookupEnableGrtStaticRoute" "noRedirectToVrfTraffic_allTrafficViaGrtLeaking" \
                                                                    "removeGrtLookupEnableGrtStaticRoute" "defaultBehavior" \
                                                                    "negTest_addGrtLookupInFlowrouteVprn" "defaultBehavior" \
                                                                    "negTest_removeGrtLookupInFlowrouteVprn" "defaultBehavior" \
                                                                    "shutFirstFlowrouteVprn" "noFilterEntriesExpInVprn" \
                                                                    "noShutFirstFlowrouteVprn" "defaultBehavior" \
                                                                    "shutNextFlowrouteVprn" "noFilterEntriesExpInVprn" \
                                                                    "noShutNextFlowrouteVprn" "defaultBehavior" \
                                                                    "withdrawAllIpv4v6Flowroutes" "noIpv4v6FilterEntriesExpInDut" \
                                                                    "announceAllIpv4v6FlowroutesAgain" "defaultBehavior" \
                                                                    "clearBgpNeighbor" "defaultBehavior" \
                                                                    "clearBgpProtocol" "defaultBehavior" \
                                                                    "shutNoShutBgpNeighbor_waitOnZeroAndOnAllFlowroutes" "defaultBehavior" \
                                                                    "shutNoShutBgpProtocol_waitOnZeroAndOnAllFlowroutes" "defaultBehavior" \
                                                                    "none" "negTest_fSpecAndUsrDefFilterOnItfInDiffVprns" \
                                                                    "stopTrafficAndClearFilters" "zeroIngMatchesExpInDut" \
                                                                    "startTraffic" "defaultBehavior" \
                                                                    "rollback" "defaultBehavior" \
                                                                    "shutAllRedirectVprn" "noIpv4v6FilterEntriesExpInDut" \
                                                                    "noShutAllRedirectVprn" "defaultBehavior" \
                                                                    "updateRouteTargetAllRedirectVprn" "noIpv4v6FilterEntriesExpInDut" \
                                                                    "restoreRouteTargetAllRedirectVprn" "defaultBehavior" \
                                                                    "shutActualRedirectVprn" "defaultBehavior" \
                                                                    "noShutPreviousRedirectVprn" "defaultBehavior" \
                                                                    "removeImportPolicyFromActualRedirectVprn" "defaultBehavior" \
                                                                    "restoreImportPolicyFromActualRedirectVprn" "defaultBehavior" \
                                                                    "removeImportPolicyFromRouterPolicyOptionsRedirectVprn" "defaultBehavior" \
                                                                    "restoreImportPolicyFromRouterPolicyOptionsRedirectVprn" "defaultBehavior" \
                                                                    "removeCommunityFromImportPolicyRedirectVprn" "defaultBehavior" \
                                                                    "restoreCommunityFromImportPolicyRedirectVprn" "defaultBehavior" \
                                                                    "replaceImportPolicyWithRouteTargetInActualRedirectVprn" "defaultBehavior" \
                                                                    "removeRouteTargetFromActualRedirectVprn" "defaultBehavior" \
                                                                    "restoreRouteTargetFrompreviousRedirectVprn" "defaultBehavior" \
                                                                    "replaceRouteTargetWithImportPolicyInActualRedirectVprn" "defaultBehavior" \
                                                            ]
  #
  #  11.0 action (RFE162746 is R12.0 => Use this to verify 166731-110) 
  #  -actionExpectedBehaviorList) [list "none" "allTrafficViaRedirectToVrf_noTrafficViaGrtLeaking"] -numTrafficDst_v4 1 -numTrafficDst_v6 1 -grtLookupEnableGrt false
  #  
  # spoke (flowroute vprn)
  set option(itfType_dut1dut2) ""
  set option(addFlowroutesInBase) true
  set option(skipCheckFilterLog) true
  
  # maxNbrIterations | maxDuration [hours] | ifFileExists
  set option(iterationMethod) maxNbrIterations
  set option(maxNbrIterations) 1
  set option(maxDurationHrs) 5
  set option(fileExistsName) "/tmp/fspecVprn_running.txt"
  set option(neverDisableDutLogging) false
  
  # there are 4 combinations
  #   autobind - ldp (default)
  #   autobind - gre
  #   sdp - rsvp
  #   sdp - gre
  set option(redirectVprnTunnelMethod) autobind
  set option(redirectVprnTunnelEncap) ldp
  
  # grtLookupEnableGrt should be set only to false to test some hash-label interactions
  set option(grtLookupEnableGrt) true
  # none | static | signal (sdp only)
  set option(hashLabel) "none"
  # mirrorRedirectVrf: should be true ico hashLabel to
  set option(mirrorRedirectVrf) false
  set option(minNbrMplsHashLabelsExp) 20
  
  # Inter-AS option A (Back-To-Back)  PE vprn#x itf ---------- itf vprn#x PE
  # Inter-AS option B                         PE vprn#x -----MP-BGP----- vprn#x PE
  set option(interAsOption) B
  # Since 12.0
  set option(igpInRedirectVprn) isis
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecNbrVprns] != "ERROR"} {
    set nbrVprns [GGV fspecNbrVprns]
  } else {
    set nbrVprns $option(nbrVprns)
  }
  if {[GGV fspecNbrFlowroutesPerVprn] != "ERROR"} {
    set nbrFlowroutesPerVprn [GGV fspecNbrFlowroutesPerVprn]
  } else {
    set nbrFlowroutesPerVprn $option(nbrFlowroutesPerVprn)
  }
  if {[GGV fspecEnableFilterTrace] != "ERROR"} {
    set enableFilterTrace [GGV fspecEnableFilterTrace]
  } else {
    set enableFilterTrace $option(enableFilterTrace)
  }
  if {[GGV fspecEnableBgpFlowspecTrace] != "ERROR"} {
    set enableBgpFlowspecTrace [GGV fspecEnableBgpFlowspecTrace]
  } else {
    set enableBgpFlowspecTrace $option(enableBgpFlowspecTrace)
  }
  if {[GGV fspecSendBgpPrefixUpd_v4] != "ERROR"} {
    set sendBgpPrefixUpd_v4 [GGV fspecSendBgpPrefixUpd_v4]
  } else {
    set sendBgpPrefixUpd_v4 $option(sendBgpPrefixUpd_v4)
  }
  if {[GGV fspecSendBgpPrefixUpd_v6] != "ERROR"} {
    set sendBgpPrefixUpd_v6 [GGV fspecSendBgpPrefixUpd_v6]
  } else {
    set sendBgpPrefixUpd_v6 $option(sendBgpPrefixUpd_v6)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v4] != "ERROR"} {
    set sendBgpFlowrouteUpd_v4 [GGV fspecSendBgpFlowrouteUpd_v4]
  } else {
    set sendBgpFlowrouteUpd_v4 $option(sendBgpFlowrouteUpd_v4)
  }
  if {[GGV fspecSendBgpFlowrouteUpd_v6] != "ERROR"} {
    set sendBgpFlowrouteUpd_v6 [GGV fspecSendBgpFlowrouteUpd_v6]
  } else {
    set sendBgpFlowrouteUpd_v6 $option(sendBgpFlowrouteUpd_v6)
  }
  if {[GGV fspecActionListPerVprn] != "ERROR"} {
    set actionListPerVprn [GGV fspecActionListPerVprn]
  } else {
    set actionListPerVprn $option(actionListPerVprn)
  }
  if {[GGV fspecDumpDebugLog] != "ERROR"} {
    set dumpDebugLog [GGV fspecDumpDebugLog]
  } else {
    set dumpDebugLog $option(dumpDebugLog)
  }
  if {[GGV fspecSendTraffic_v4] != "ERROR"} {
    set sendTraffic_v4 [GGV fspecSendTraffic_v4]
  } else {
    set sendTraffic_v4 $option(sendTraffic_v4)
  }
  if {[GGV fspecSendTraffic_v6] != "ERROR"} {
    set sendTraffic_v6 [GGV fspecSendTraffic_v6]
  } else {
    set sendTraffic_v6 $option(sendTraffic_v6)
  }
  if {[GGV fspecEnableIngressFlowspec_v4] != "ERROR"} {
    set enableIngressFlowspec_v4 [GGV fspecEnableIngressFlowspec_v4]
  } else {
    set enableIngressFlowspec_v4 $option(enableIngressFlowspec_v4)
  }
  if {[GGV fspecEnableIngressFlowspec_v6] != "ERROR"} {
    set enableIngressFlowspec_v6 [GGV fspecEnableIngressFlowspec_v6]
  } else {
    set enableIngressFlowspec_v6 $option(enableIngressFlowspec_v6)
  }
  if {[GGV fspecVrfTargetDirectUnderVprn_noImportPolicy] != "ERROR"} {
    set vrfTargetDirectUnderVprn_noImportPolicy [GGV fspecVrfTargetDirectUnderVprn_noImportPolicy]
  } else {
    set vrfTargetDirectUnderVprn_noImportPolicy $option(vrfTargetDirectUnderVprn_noImportPolicy)
  }
  if {[GGV fspecItfType_dut1dut2] != "ERROR"} {
    set itfType_dut1dut2 [GGV fspecItfType_dut1dut2]
  } else {
    set itfType_dut1dut2 $option(itfType_dut1dut2)
  } 
  if {[GGV fspecActionExpectedBehaviorList] != "ERROR"} {
    set actionExpectedBehaviorList [GGV fspecActionExpectedBehaviorList]
  } else {
    set actionExpectedBehaviorList $option(actionExpectedBehaviorList)
  }
  if {[GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected [GGV fspecAddDefFilterInFirstVprnBeforeFlowroutesAreInjected]
  } else {
    set addDefFilterInFirstVprnBeforeFlowroutesAreInjected $option(addDefFilterInFirstVprnBeforeFlowroutesAreInjected)
  }
  if {[GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected] != "ERROR"} {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected [GGV fspecAddDefFilterInLastVprnAfterFlowroutesAreInjected]
  } else {
    set addDefFilterInLastVprnAfterFlowroutesAreInjected $option(addDefFilterInLastVprnAfterFlowroutesAreInjected)
  }
  if {[GGV fspecAddFlowroutesInBase] != "ERROR"} {
    set addFlowroutesInBase [GGV fspecAddFlowroutesInBase]
  } else {
    set addFlowroutesInBase $option(addFlowroutesInBase)
  }
  if {[GGV fspecSkipCheckFilterLog] != "ERROR"} {
    set skipCheckFilterLog [GGV fspecSkipCheckFilterLog]
  } else {
    set skipCheckFilterLog $option(skipCheckFilterLog)
  }
  if {[GGV fspecIterationMethod] != "ERROR"} {
    set iterationMethod [GGV fspecIterationMethod]
  } else {
    set iterationMethod $option(iterationMethod)
  }
  if {[GGV fspecMaxNbrIterations] != "ERROR"} {
    set maxNbrIterations [GGV fspecMaxNbrIterations]
  } else {
    set maxNbrIterations $option(maxNbrIterations)
  }
  if {[GGV fspecMaxDurationHrs] != "ERROR"} {
    set maxDurationHrs [GGV fspecMaxDurationHrs]
  } else {
    set maxDurationHrs $option(maxDurationHrs)
  }
  if {[GGV fspecNeverDisableDutLogging] != "ERROR"} {
    set neverDisableDutLogging [GGV fspecNeverDisableDutLogging]
  } else {
    set neverDisableDutLogging $option(neverDisableDutLogging)
  }
  if {[GGV fspecEnableFlowspecBeforeFlowroutesAreInjected] != "ERROR"} {
    set enableFlowspecBeforeFlowroutesAreInjected [GGV fspecEnableFlowspecBeforeFlowroutesAreInjected]
  } else {
    set enableFlowspecBeforeFlowroutesAreInjected $option(enableFlowspecBeforeFlowroutesAreInjected)
  }
  if {[GGV fspecRedirectVprnTunnelMethod] != "ERROR"} {
    set redirectVprnTunnelMethod [GGV fspecRedirectVprnTunnelMethod]
  } else {
    set redirectVprnTunnelMethod $option(redirectVprnTunnelMethod)
  }
  if {[GGV fspecRedirectVprnTunnelEncap] != "ERROR"} {
    set redirectVprnTunnelEncap [GGV fspecRedirectVprnTunnelEncap]
  } else {
    set redirectVprnTunnelEncap $option(redirectVprnTunnelEncap)
  }
  if {[GGV fspecGrtLookupEnableGrt] != "ERROR"} {
    set grtLookupEnableGrt [GGV fspecGrtLookupEnableGrt]
  } else {
    set grtLookupEnableGrt $option(grtLookupEnableGrt)
  }
  if {[GGV fspecHashLabel] != "ERROR"} {
    set hashLabel [GGV fspecHashLabel]
  } else {
    set hashLabel $option(hashLabel)
  }
  if {[GGV fspecMirrorRedirectVrf] != "ERROR"} {
    set mirrorRedirectVrf [GGV fspecMirrorRedirectVrf]
  } else {
    set mirrorRedirectVrf $option(mirrorRedirectVrf)
  }
  if {[GGV fspecInterAsOption] != "ERROR"} {
    set interAsOption [GGV fspecInterAsOption]
  } else {
    set interAsOption $option(interAsOption)
  }
  if {[GGV fspecMinNbrMplsHashLabelsExp] != "ERROR"} {
    set minNbrMplsHashLabelsExp [GGV fspecMinNbrMplsHashLabelsExp]
  } else {
    set minNbrMplsHashLabelsExp $option(minNbrMplsHashLabelsExp)
  }
  if {[GGV fspecIgpInRedirectVprn] != "ERROR"} {
    set igpInRedirectVprn [GGV fspecIgpInRedirectVprn]
  } else {
    set igpInRedirectVprn $option(igpInRedirectVprn)
  }
  if {[GGV fspecNumTrafficDst_v4] != "ERROR"} {
    set numTrafficDst_v4 [GGV fspecNumTrafficDst_v4]
  } else {
    set numTrafficDst_v4 $option(numTrafficDst_v4)
  }
  if {[GGV fspecNumTrafficDst_v6] != "ERROR"} {
    set numTrafficDst_v6 [GGV fspecNumTrafficDst_v6]
  } else {
    set numTrafficDst_v6 $option(numTrafficDst_v6)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]

  # vprnIdList => thisVprnId | thisNbrFlowroutesPerVprn | thisActionListPerVprn
  # vprnIdOnlyList => has only the vprnId's
  set vprnIdList "" ; set vprnIdOnlyList ""
  for {set vprnId 1} {$vprnId <= $nbrVprns} {incr vprnId} {
    lappend vprnIdList [expr $minVprnId - 1 + $vprnId] ; lappend vprnIdOnlyList [expr $minVprnId - 1 + $vprnId]
    lappend vprnIdList $nbrFlowroutesPerVprn
    lappend vprnIdList $actionListPerVprn
  }
  # Use the next dot1q tag for the Base
  set baseDot1qTag [expr [lindex $vprnIdOnlyList end] + 1]
  
  set nbrStreamsFamilies 0 ; if {$sendTraffic_v4} {incr nbrStreamsFamilies} ; if {$sendTraffic_v6} {incr nbrStreamsFamilies}
  if {$addFlowroutesInBase} {
    set nbrStreamsUsed [expr [expr $nbrVprns + 1] * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  } else {
    set nbrStreamsUsed [expr $nbrVprns * [llength $actionListPerVprn] * $nbrStreamsFamilies]
  }
  
  # Check the testcase limitations (begin)
  if {$nbrVprns > 250} {
    log_msg ERROR "id20527 Testcase couldn't handle >250 vprn's because of ip address limitation" ; set Result FAIL
  }
  
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
    if {$thisNbrFlowroutesPerVprn > 221} {
      log_msg ERROR "id20733 Testcase couldn't handle >221 (223-2 ; \"-2\" because dot1q=1 is reserved on Linux & one dot1q reserved for Base) flowroutes per vprn because of ip address limitation" ; set Result FAIL ; break
    }
  }
  # Check the testcase limitations (end)
  
  set pktRatePerStream 2 ; set pktSize 128 ; set streamData_ISATMS "49 53 41 54 4D 53" ; set rawProtocol 253
  set trafficDurationSecsDuringPrecondition 30
  
  # used in redirectToVrf
  set redirectVprnId 100 ; set customerId 1 ; set nbrRedirectVprn 4 
  set firstRedirectVprnId $redirectVprnId
  set maxRedirectVprnId [expr $firstRedirectVprnId + $nbrRedirectVprn - 1]
  set minRedirectVprnId $redirectVprnId
  set actualRedirectVprnId $firstRedirectVprnId
  # the vprn (to redirect) is between dut2/dut4
  set thisRT "target:42:1"
   
  set enableTraceDutList [list $dut2 $dut3]
  
  # spokeSdp case
  set spokeIesId 5000 ; set spokeSdpId 1 ; set spokeSdpVcId 1
  
  if {$sendBgpFlowrouteUpd_v4 && $sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv4 ipv6]
  } elseif {$sendBgpFlowrouteUpd_v6} {
    set thisFilterFamilyList [list ipv6]
  } else {
    set thisFilterFamilyList [list ipv4]
  }
  set groupName "onegroup"
  
  # 101..199 => always 101 for flowspec
  set filterLogId 101
  # mirror
  set mirrorId 123 ; set mirrorVlanId 123
  # MPLS hash label is between the range of 524288 and 1048575
  set mplsHashLabel_min 524288 ; set mplsHashLabel_max 1048575
  
  set rollbackLocation "ftp://$::TestDB::thisTestBed:tigris@$::TestDB::thisHostIpAddr/$logdir/device_logs/saved_configs"
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : Validate RFE162746 (PBR: Support grt-leak and hash-label with the redirect to VRF action)"
  log_msg INFO "#   Today, when a flowroute is received with action redirectToVrf a lookup is done by bgp"
  log_msg INFO "#   to find a vprn which has a matching RouteTarget."
  log_msg INFO "#   Once a matching vprn is found a trigger is send by bgp to the filter code and"
  log_msg INFO "#   a filter entry is installed with \"Fwd Rtr\" the just found vprn-id."
  log_msg INFO "#   Then in this \"Fwd Rtr\" context, a lookup is done." 
  log_msg INFO "#   This RFE is applicable:"
  log_msg INFO "#   1) When this lookup in the \"Fwd Rtr\" context fails and"
  log_msg INFO "#      an additional lookup should be done in the Base context because enable-grt"
  log_msg INFO "#      is configured inf the \"Fwd Rtr\" context."
  log_msg INFO "#   2) When in the \"Fwd Rtr\" context \"hash-label (signal-capability)\" is configured (aka \"entropy label\")."
  log_msg INFO "#      In that case an extra (3th) MPLS hash label is pushed (label-range: $mplsHashLabel_min - $mplsHashLabel_max)."
  log_msg INFO "#      The extra MPLS hash label is verified via mirroring itf dut2-dut4."
  log_msg INFO "#   "
  log_msg INFO "# Setup:"
  log_msg INFO "# "
  log_msg INFO "#                              PE($dut4)----------> scrubber (Ixia)"
  log_msg INFO "#                               dut4 (dest for redirect actions)"
  log_msg INFO "#                                |"
  log_msg INFO "#                                | --> PE-PE(dut2-dut4): Inter-AS option[set interAsOption]"
  log_msg INFO "#                                |     default: optionB ; for \"hash-label signal-capability\": optionA (Back-To-Back)"
  log_msg INFO "#                                |"
  log_msg INFO "#                                |       +-- Base-Base(dut2-dut3): BGP to exchange IPv4, IPv6 & flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): BGP in the VPRN to exchange flowroutes"
  log_msg INFO "#                                |       +-- PE-PE(dut2-dut3): L3-VPN to exchange IPv4 & IPv6 routes (Inter-AS optionB)"
  log_msg INFO "#                                |       |"
  log_msg INFO "#                                |       v"
  log_msg INFO "#   Ixia----------dut1----------dut2----------dut3----------dut6"
  log_msg INFO "#                CE1($dut1)    PE($dut2)     PE($dut3)     CE2($dut6)"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                              |"
  log_msg INFO "#                                             Linux (In VPRN & Base: Injects flowroutes via sbgp)"
  log_msg INFO "# "
  log_msg INFO "# Important testcase parameters:"
  log_msg INFO "#   vprnIdOnlyList: $vprnIdOnlyList"
  log_msg INFO "#   redirectVprn => vrpnId: $firstRedirectVprnId till $maxRedirectVprnId (#$nbrRedirectVprn) ; redirectVprnTunnelMethod: $redirectVprnTunnelMethod ; redirectVprnTunnelEncap: $redirectVprnTunnelEncap"
  log_msg INFO "#   igpInRedirectVprn: $igpInRedirectVprn"
  log_msg INFO "#   grtLookupEnableGrt: $grtLookupEnableGrt ; hashLabel: $hashLabel (none | static | signal)"
  log_msg INFO "#   mirrorRedirectVrf: $mirrorRedirectVrf (mirrorId: $mirrorId ; mirrorVlanId: $mirrorVlanId) ; minNbrMplsHashLabelsExp: $minNbrMplsHashLabelsExp"
  log_msg INFO "#   vprnIdList: vprnId | nbrFlowroutesPerVprn | thisActionListPerVprn"
  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
  set actionPrefixAString ""
  foreach thisAction $thisActionListPerVprn {
    append actionPrefixAString "$thisAction\([set a_[set thisAction]].x.x.x\) "
  }
  log_msg INFO [format "%1s %13s %6s | %20s | \"%30s\" " "#" " "  $thisVprnId $thisNbrFlowroutesPerVprn $actionPrefixAString]
  }
  if {$addFlowroutesInBase} {set fTxt "(baseDot1qTag: $baseDot1qTag)"} else {set fTxt ""}
  log_msg INFO "#   addFlowroutesInBase: $addFlowroutesInBase $fTxt"
  log_msg INFO "#   numTrafficDst_v4: $numTrafficDst_v4 ; numTrafficDst_v6: $numTrafficDst_v6"
  log_msg INFO "#   sendBgpPrefixUpd_v4: $sendBgpPrefixUpd_v4 ; sendBgpPrefixUpd_v6: $sendBgpPrefixUpd_v6"
  log_msg INFO "#   sendBgpFlowrouteUpd_v4: $sendBgpFlowrouteUpd_v4 ; sendBgpFlowrouteUpd_v6: $sendBgpFlowrouteUpd_v6"
  log_msg INFO "#   sendTraffic_v4: $sendTraffic_v4 ; sendTraffic_v6: $sendTraffic_v6 (nbrStreamsFamilies: $nbrStreamsFamilies nbrStreamsUsed: $nbrStreamsUsed)"
  log_msg INFO "#   enableIngressFlowspec_v4: $enableIngressFlowspec_v4 ; enableIngressFlowspec_v6: $enableIngressFlowspec_v6"
  log_msg INFO "#   enableFlowspecBeforeFlowroutesAreInjected: $enableFlowspecBeforeFlowroutesAreInjected"
  log_msg INFO "#   vrfTargetDirectUnderVprn_noImportPolicy: $vrfTargetDirectUnderVprn_noImportPolicy"
  log_msg INFO "#   itfType_dut1dut2: $itfType_dut1dut2"
  log_msg INFO "#   addDefFilterInFirstVprnBeforeFlowroutesAreInjected: $addDefFilterInFirstVprnBeforeFlowroutesAreInjected (filter-id: $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId)"
  log_msg INFO "#   addDefFilterInLastVprnAfterFlowroutesAreInjected: $addDefFilterInLastVprnAfterFlowroutesAreInjected (filter-id: $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId)"
  switch $iterationMethod {
    "maxNbrIterations" {set iMethTxt "maxNbrIterations: $maxNbrIterations"}
    "maxDuration" {set iMethTxt "maxDurationHrs: $maxDurationHrs"}
    "ifFileExists" {set iMethTxt "fileExistsName: $option(fileExistsName)"}
  }
  log_msg INFO "#   iterationMethod: $iterationMethod => $iMethTxt"
  log_msg INFO "#   actionExpectedBehaviorList:"
  log_msg INFO [format "%1s %5s %54s | %45s " "#" " " action expectedBehavior] ; log_msg INFO [format "%1s %5s %54s + %45s " "#" " " "--------------------------------------------------" "--------------------------------------------"]
  foreach {action expectedBehavior} $actionExpectedBehaviorList {
  log_msg INFO [format "%1s %5s %54s | %45s " "#" " " $action $expectedBehavior]
  }
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  set dutLoggingDisabled false
  if {([expr $nbrVprns * $nbrFlowroutesPerVprn] > 16)} {
    if {$neverDisableDutLogging} {
      log_msg WARNING "Disable logging in dut-logs NOT done because neverDisableDutLogging: $neverDisableDutLogging"
    } else {
      log_msg WARNING "Disable logging in dut-logs because scale is too high"
      set dutLoggingDisabled true
      foreach dut $dutList {
        $dut configure -logging false
      }
    }
  }

  # handlePacket -action reset -portList all
  CLN.reset
  set cliTimeoutOrig [$dut2 cget -cli_timeout]
  $dut2 configure -cli_timeout $option(cliTimeout)

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as [set [set dut1]_AS]"
    CLN "dut $dut2 systemip [set [set dut2]_ifsystem_ip] isisarea $isisAreaId as [set [set dut2]_AS]"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as [set [set dut3]_AS]"
    CLN "dut $dut4 systemip [set [set dut4]_ifsystem_ip] isisarea $isisAreaId as [set [set dut4]_AS]"
    CLN "dut $dut5 systemip [set [set dut5]_ifsystem_ip] isisarea $isisAreaId as [set [set dut5]_AS]"
    CLN "dut $dut6 systemip [set [set dut6]_ifsystem_ip] isisarea $isisAreaId as [set [set dut6]_AS]"
    
    set a 30 ; set b [expr 20 + [lindex $vprnIdOnlyList 0]] ; set c 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn } $vprnIdList {
      CLN "dut $dut2 vprnid $thisVprnId systemip $a.$b.$c.2 as [set [set dut2]_AS]"
      CLN "dut $dut3 vprnid $thisVprnId systemip $a.$b.$c.3 as [set [set dut3]_AS]"
      incr b ; if {$b > 255} {set b 0 ; incr a}
    }
    
    # used for spokes dut1/dut2
    CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q 1 ip 1.1.1.1 ldp true mpls true"
    CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q 1 ip 1.1.1.2 ldp true mpls true" 
    
    # In the CE's, bgp routes are learned from different peers (the neighbor end point is in different vprn).
    # The learned bgp routes are installed in the Base routing-table and exported again to all neighbors (default ebgp behavior).
    # To avoid that the neigbor end points (in different vprn's) receive the exported bgp routes (CE's Base instance) a reject policy should be installed.
    CLN "dut $dut1 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    CLN "dut $dut6 policy rejectBgpExport entry 1 action reject descr avoidExportFromBaseToNeighborVprns"
    
    # Exchange flowroutes via BGP peer in the VPRN, because SAFI=134 (exchange flowroutes via L3-VPN) is not supported 
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut3 tonode $dut2 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut3 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'flow-ipv4 flow-ipv6' " 
    }

    # redistribute bgp-vpn in ospf
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v4 entry 1 to 'protocol ospf' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 from 'protocol bgp-vpn' action accept"
    CLN "dut $dut2 policy fromBgpVpnToOspf_v6 entry 1 to 'protocol ospf3' action accept"

    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      #
      if {$itfType_dut1dut2 == "spoke"} {
        CLN "dut $dut1 tonode $dut2 porttype hybrid iesid $spokeIesId iftype spoke sdpid '$spokeSdpId gre [set [set dut2]_ifsystem_ip]' dot1q $thisVprnId ip $thisVprnId.$dataip(id.$dut1).$dataip(id.$dut2).$dataip(id.$dut1) ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid iftype spoke sdpid '$spokeSdpId gre [set [set dut1]_ifsystem_ip]' vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      } else {      
        CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut1]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut1]_AS] bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
        CLN "dut $dut2 tonode $dut1 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId ospfexport fromBgpVpnToOspf_v4 ospf3export fromBgpVpnToOspf_v6 as [set [set dut2]_AS] bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      }
   
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut6]_ifsystem_ip] ospfasbr true ospf3asbr true as [set [set dut6]_AS] bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpexport rejectBgpExport"
      CLN "dut $dut3 tonode $dut6 porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId routerid [set [set dut3]_ifsystem_ip] as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      
      CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      CLN "dut $dut2 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
      CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
    }
    
    if {$addFlowroutesInBase} {
      CLN "dut $dut3 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut2]_ifsystem_ip]  bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true"
      CLN "dut $dut2 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor [set [set dut3]_ifsystem_ip] bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 vpn-ipv4 vpn-ipv6 flow-ipv4 flow-ipv6' ldp true" 
      #
      CLN "dut $dut3 tonode $dut6 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut6]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut6 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut3]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
      #
      CLN "dut $dut1 tonode $dut2 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      CLN "dut $dut2 tonode $dut1 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras [set [set dut1]_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' "
      #
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true as [set [set dut3]_AS] bgpneighbor interface4 bgppeeras [set Linux_AS] bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' " 
    }
    
    # Ixia connections
    set filterEntryId 1
    foreach thisAction $actionListPerVprn {
      CLN "dut $dut1 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut6 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut4 filter $cntPktsViaFilter_filterId entry $filterEntryId dstip [set a_[set thisAction]].0.0.0/$cntPktsViaFilter_mask_v4"
      CLN "dut $dut1 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      CLN "dut $dut6 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      CLN "dut $dut4 filterv6 $cntPktsViaFilter_filterId entry $filterEntryId dstip [ipv4ToIpv6  [set a_[set thisAction]].0.0.0]/$cntPktsViaFilter_mask_v6"
      incr filterEntryId
    }
    CLN "dut $dut1 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut $dut6 tonode Ixia inegfilter $cntPktsViaFilter_filterId inegfilterv6 $cntPktsViaFilter_filterId"
    CLN "dut Ixia tonode $dut1"
    CLN "dut Ixia tonode $dut6"
    
    # CE2: static routes and policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v4 entry 1 to 'protocol ospf' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 from 'protocol static' action accept"
        CLN "dut $dut6 policy fromStaticToVprns_v6 entry 1 to 'protocol ospf3' action accept"
        CLN "dut $dut6 ospf 'export fromStaticToVprns_v4' "
        CLN "dut $dut6 ospf3 'export fromStaticToVprns_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    # policies to destine traffic from different vprn's to Ixia
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v4 prefix $thisDstPrefixMask_v4 longer' "
        CLN "dut $dut3 prefixlist 'pfxListVprn[set thisVprnId]_v6 prefix $thisDstPrefixMask_v6 longer' "
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v4 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v4' action accept"
        CLN "dut $dut3 policy fromStaticToVprn[set thisVprnId]_v6 defaultaction reject entry 1 from 'prefix-list pfxListVprn[set thisVprnId]_v6' action accept"
        CLN "dut $dut3 vprnid $thisVprnId ospf 'import fromStaticToVprn[set thisVprnId]_v4' "
        CLN "dut $dut3 vprnid $thisVprnId ospf3 'import fromStaticToVprn[set thisVprnId]_v6' "
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }

    if {$addFlowroutesInBase} {
      # - Use isis in the Base instance
      # - Use mask16 to have a route in the Base for all grt-leak's (2nd lookup in Base) of all vprn's
      set c 0 ; set d 0
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask16_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask16_v6
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v4 next-hop $dataip(ip.1.Ixia.$dut6)'"
        CLN "dut $dut6 staticroute '$thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $dataip(ip.1.Ixia.$dut6)]'"
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v4 prefix $thisDstPrefixMask_v4 exact' "
        CLN "dut $dut6 prefixlist 'pfxListBase[set baseDot1qTag]_v6 prefix $thisDstPrefixMask_v6 exact' "
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v4' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v4 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 from 'prefix-list pfxListBase[set baseDot1qTag]_v6' action accept"
        CLN "dut $dut6 policy fromStaticToBase[set baseDot1qTag]_v6 entry 1 to 'protocol isis' action accept"
        CLN "dut $dut6 isis 'export fromStaticToBase[set baseDot1qTag]_v4 fromStaticToBase[set baseDot1qTag]_v6'"
      }
    }
    
    # used in redirectToVrf
    switch $interAsOption {
      "A" {
        switch $igpInRedirectVprn {
          "isis" {
            CLN "dut $dut2 tonode $dut4 dot1q $baseDot1qTag mpls true ldp true isisarea $isisAreaId"
            CLN "dut $dut4 tonode $dut2 dot1q $baseDot1qTag mpls true ldp true isisarea $isisAreaId"
            for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
              set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
              set thisIp_v4 [set thisRedirectVprnId].[set dataip(id.[set dut2])].[set dataip(id.[set dut4])].[set dataip(id.[set dut2])] ; set thisIp_v6 [ipv4ToIpv6 $thisIp_v4]
              CLN "dut $dut2 tonode $dut4 vprnid $thisRedirectVprnId dot1q $thisRedirectVprnId ip $thisIp_v4 ipv6 $thisIp_v6 isisarea $isisAreaId iftype spoke sdpid '[set dataip(id.[set dut2])][set dataip(id.[set dut4])] rsvp [set [set dut4]_ifsystem_ip]' bgpneighbor interface4 bgppeeras [set [set dut4]_AS] bgpfamily 'ipv4 ipv6'"
              set thisIp_v4 [set thisRedirectVprnId].[set dataip(id.[set dut2])].[set dataip(id.[set dut4])].[set dataip(id.[set dut4])] ; set thisIp_v6 [ipv4ToIpv6 $thisIp_v4]
              CLN "dut $dut4 tonode $dut2 vprnid $thisRedirectVprnId dot1q $thisRedirectVprnId ip $thisIp_v4 ipv6 $thisIp_v6 isisarea $isisAreaId iftype spoke sdpid '[set dataip(id.[set dut4])][set dataip(id.[set dut2])] rsvp [set [set dut2]_ifsystem_ip]' bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6'"
            }
            CLN "dut $dut4 policy fromStaticToIsisVprn entry 1 from 'protocol static' action accept"
            CLN "dut $dut4 policy fromStaticToIsisVprn entry 1 to 'protocol isis' action accept"
          }
          "ospf" {
            CLN "dut $dut2 tonode $dut4 dot1q $baseDot1qTag mpls true ldp true isisarea $isisAreaId"
            CLN "dut $dut4 tonode $dut2 dot1q $baseDot1qTag mpls true ldp true isisarea $isisAreaId"
            for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
              set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
              set thisIp_v4 [set thisRedirectVprnId].[set dataip(id.[set dut2])].[set dataip(id.[set dut4])].[set dataip(id.[set dut2])] ; set thisIp_v6 [ipv4ToIpv6 $thisIp_v4]
              CLN "dut $dut2 tonode $dut4 vprnid $thisRedirectVprnId dot1q $thisRedirectVprnId ip $thisIp_v4 ipv6 $thisIp_v6 ospfarea $ospfAreaId ospf3area $ospfAreaId iftype spoke sdpid '[set dataip(id.[set dut2])][set dataip(id.[set dut4])] rsvp [set [set dut4]_ifsystem_ip]' bgpneighbor interface4 bgppeeras [set [set dut4]_AS] bgpfamily 'ipv4 ipv6'"
              set thisIp_v4 [set thisRedirectVprnId].[set dataip(id.[set dut2])].[set dataip(id.[set dut4])].[set dataip(id.[set dut4])] ; set thisIp_v6 [ipv4ToIpv6 $thisIp_v4]
              CLN "dut $dut4 tonode $dut2 vprnid $thisRedirectVprnId dot1q $thisRedirectVprnId ip $thisIp_v4 ipv6 $thisIp_v6 ospfarea $ospfAreaId ospf3area $ospfAreaId iftype spoke sdpid '[set dataip(id.[set dut4])][set dataip(id.[set dut2])] rsvp [set [set dut2]_ifsystem_ip]' bgpneighbor interface4 bgppeeras [set [set dut2]_AS] bgpfamily 'ipv4 ipv6'"
            }
            CLN "dut $dut4 policy fromStaticToOspfVprn entry 1 from 'protocol static' action accept"
            CLN "dut $dut4 policy fromStaticToOspfVprn entry 1 to 'protocol ospf' action accept"
            CLN "dut $dut4 policy fromStaticToOspf3Vprn entry 1 from 'protocol static' action accept"
            CLN "dut $dut4 policy fromStaticToOspf3Vprn entry 1 to 'protocol ospf3' action accept"
          }
        }
      }
      
      "B" {
        # default
        if {$redirectVprnTunnelMethod == "autobind" && $redirectVprnTunnelEncap == "gre" || \
             $redirectVprnTunnelMethod == "sdp" && $redirectVprnTunnelEncap == "rsvp"} {
          CLN "dut $dut2 tonode $dut4 mpls true isisarea $isisAreaId"
          CLN "dut $dut4 tonode $dut2 mpls true isisarea $isisAreaId"
        } else {
          CLN "dut $dut2 tonode $dut4 ldp true mpls true isisarea $isisAreaId"
          CLN "dut $dut4 tonode $dut2 ldp true mpls true isisarea $isisAreaId"
        }
        CLN "dut $dut2 bgpneighbor [set [set dut4]_ifsystem_ip] bgppeeras [set [set dut4]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"   
        CLN "dut $dut4 bgpneighbor [set [set dut2]_ifsystem_ip] bgppeeras [set [set dut2]_AS] bgpfamily 'vpn-ipv4 vpn-ipv6'"
      }
      
      default {
        log_msg ERROR "id20245 Not supported interAsOption: $interAsOption (should be A or B)"
      }
    }
    CLN.exec
    CLN.reset
    
    set thisPePeList [list $dut2 $dut3 $dut3 $dut2]
    foreach {dut ngbDut} $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        set thisExportRT [expr ($thisVprnId * 100) + ($dataip(id.$dut) * 10) + $dataip(id.$ngbDut)]
        set thisImportRT [expr ($thisVprnId * 100) + ($dataip(id.$ngbDut) * 10) + $dataip(id.$dut)]
        docli $dut "configure router"
        docli $dut "         policy-options"
        docli $dut "            begin"
        docli $dut "            community vprn_[set thisVprnId]_exportRouteTarget members target:1982:$thisExportRT"
        docli $dut "            community vprn_[set thisVprnId]_importRouteTarget members target:1982:$thisImportRT"
        docli $dut "            policy-statement vprn_[set thisVprnId]_exportPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol ospf"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "                entry 2"
        docli $dut "                    from"
        docli $dut "                        protocol ospf3"
        docli $dut "                    exit"
        docli $dut "                    to"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                        community add vprn_[set thisVprnId]_exportRouteTarget"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            policy-statement vprn_[set thisVprnId]_importPol"
        docli $dut "                entry 1"
        docli $dut "                    from"
        docli $dut "                        protocol bgp-vpn"
        docli $dut "                        community vprn_[set thisVprnId]_importRouteTarget"
        docli $dut "                    exit"
        docli $dut "                    action accept"
        docli $dut "                    exit"
        docli $dut "                exit"
        docli $dut "            exit"
        docli $dut "            commit"
        docli $dut "        exit all"
      }
    }
    foreach {dut ngbDut} $thisPePeList {
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        docli $dut "configure service vprn $thisVprnId" 
        docli $dut "no vrf-target"
        docli $dut "vrf-import vprn_[set thisVprnId]_importPol"
        docli $dut "vrf-export vprn_[set thisVprnId]_exportPol"
        docli $dut "exit all"
      }
    }

    # used in redirectToVrf
    switch $interAsOption {
      "A" {
        set thisId $baseDot1qTag
      }
      "B" {
        set thisId 1
      }
    }
    #                                        dut     thisDutId            ngbrDut  ngbrDutId       itfToNgbr
    set redirectVprnDutList [list $dut2 $dataip(id.$dut2) $dut4 $dataip(id.$dut4) $dataip(ip.$thisId.$dut2.$dut4) \
                                              $dut4 $dataip(id.$dut4) $dut2 $dataip(id.$dut2) $dataip(ip.$thisId.$dut4.$dut2)]
    set redirectDutList ""
    foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
      if {[lsearch $redirectDutList $dut] == -1} {
        lappend redirectDutList $dut
      }
    }
    #
    # Also needed is a path from Dut-D to Ixia2 (scrubber).
    #   - In Dut-D: add port to Dut-E in vprn
    #   - In Dut-E: epipe between port to Dut-D and port to Dut-C
    #   - In Dut-C: epipe between port to Dut-E and port to Ixia2
    #                                         dut  epipeId fromPort toPort
    set epipeListToScrubber [list $dut5 666 $portA($dut5.$dut4) $portA($dut5.$dut3) \
                                                $dut3 667 $portA($dut3.$dut5) $portA($dut3.Ixia)]
    # Redirect is done in Dut-B
    set checkIpFlowspecFilterDutList [list $dut2]
  
    foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
      docli $dut "configure router"
      docli $dut "         policy-options"
      docli $dut "            begin"
      docli $dut "            community \"vprn1_exportRouteTarget\" members \"target:[set thisDutId][set ngbrDutId]:1\" "
      docli $dut "            community \"vprn1_importRouteTarget_[set ngbrDutId]\" members \"target:[set ngbrDutId][set thisDutId]:1\" "
      docli $dut "            policy-statement vprn_exportPol_[set thisDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol direct"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "                entry 2"
      docli $dut "                    from"
      docli $dut "                        protocol static"
      docli $dut "                    exit"
      docli $dut "                    to"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                        community add vprn1_exportRouteTarget"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"
      docli $dut "                entry 1"
      docli $dut "                    from"
      docli $dut "                        protocol bgp-vpn"
      docli $dut "                        community vprn1_importRouteTarget_[set ngbrDutId]"
      docli $dut "                    exit"
      docli $dut "                    action accept"
      docli $dut "                    exit"
      docli $dut "                exit"
      docli $dut "            exit"
      docli $dut "            commit"
      docli $dut "        exit all"
    }
    foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
      # redirect rsvp part
      docli $dut "exit all"
      docli $dut "configure router"
      docli $dut "mpls"
      docli $dut "    path pathTo_[set ngbrDut]"
      docli $dut "        hop 1 [set [set ngbrDut]_ifsystem_ip] loose"
      docli $dut "        no shutdown"
      docli $dut "    exit"
      docli $dut "    lsp to_[set ngbrDut]"
      docli $dut "        to [set [set ngbrDut]_ifsystem_ip]"
      docli $dut "        primary pathTo_[set ngbrDut]"
      docli $dut "        exit"
      docli $dut "        no shutdown"
      docli $dut "    exit"
      docli $dut "    no shutdown"
      docli $dut "exit"
      docli $dut "exit all"
      # redirect service part
      docli $dut "configure service" -verbose $option(verbose)
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        # add here the sdp's if needed
        if {$redirectVprnTunnelMethod == "sdp"} {
            switch $redirectVprnTunnelEncap {
              "gre" {
                docli $dut "" -verbose $option(verbose)
                docli $dut "sdp [set thisDutId][set ngbrDutId] gre create"
                docli $dut "    far-end [set [set ngbrDut]_ifsystem_ip]"
                docli $dut "    signaling off"
                docli $dut "    keep-alive"
                docli $dut "        shutdown"
                docli $dut "    exit"
                docli $dut "    no shutdown"
                docli $dut "exit"
              }
              "rsvp" {
                docli $dut "sdp [set thisDutId][set ngbrDutId] mpls create" -verbose $option(verbose)
                docli $dut "    far-end [set [set ngbrDut]_ifsystem_ip]"
                docli $dut "    lsp to_[set ngbrDut]"
                docli $dut "    signaling off"
                docli $dut "    keep-alive"
                docli $dut "        shutdown"
                docli $dut "    exit"
                docli $dut "    no shutdown"
                docli $dut "exit"
              }
              default {
                log_msg ERROR "id31437 Invalid redirectVprnTunnelEncap: $redirectVprnTunnelEncap (should be gre | rsvp)" ; set Result FAIL ; break
              }
            }
        }
        # add here the vprn's
        set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
        docli $dut "        vprn $thisRedirectVprnId customer 1 create" -verbose $option(verbose)
        docli $dut "            no shutdown" -verbose $option(verbose)
        switch $interAsOption {
          "A" {
            switch $igpInRedirectVprn {
              "isis" {
                docli $dut "            isis export fromStaticToIsisVprn" -verbose $option(verbose)
              }
              "ospf" {
                docli $dut "            ospf export fromStaticToOspfVprn" -verbose $option(verbose)
                docli $dut "            ospf3 export fromStaticToOspf3Vprn" -verbose $option(verbose)
              }
            }
          }
          "B" {
            #
          }
        }
        if {$vCnt == [expr $nbrRedirectVprn - 1] && $vrfTargetDirectUnderVprn_noImportPolicy} {
          log_msg INFO "Don't use vrf-import policy for the last vprn $thisRedirectVprnId"
          docli $dut "            vrf-target target:[set ngbrDutId][set thisDutId]:1" -verbose $option(verbose)
        } else {
          docli $dut "            vrf-import vprn_importPol_[set thisDutId]_[set ngbrDutId]" -verbose $option(verbose)
        }
        docli $dut "            vrf-export vprn_exportPol_[set thisDutId]" -verbose $option(verbose)
        docli $dut "            route-distinguisher $thisRedirectVprnId:1" -verbose $option(verbose)
        #
        switch $redirectVprnTunnelMethod {
          "autobind" {
            switch $redirectVprnTunnelEncap {
              "gre" {
                # ldp between dut2/dut4 is disabled
                docli $dut "            auto-bind gre" -verbose $option(verbose)
              }
              "ldp" {
                docli $dut "            auto-bind ldp" -verbose $option(verbose)
              }
              default {
                log_msg ERROR "id21245 Invalid redirectVprnTunnelEncap: $redirectVprnTunnelEncap (should be gre | ldp)" ; set Result FAIL ; break
              }
            }
          }
          "sdp" {
            switch $redirectVprnTunnelEncap {
              "gre" {
                # ldp between dut2/dut4 is disabled
                switch $interAsOption {
                  "A" {
                    if {$hashLabel == "signal"} {
                      docli $dut "interface to_[set ngbrDut][set thisRedirectVprnId] spoke-sdp [set thisDutId][set ngbrDutId]:[set thisRedirectVprnId] hash-label signal-capability" -verbose $option(verbose)
                    }
                  }
                  "B" {
                    docli $dut "spoke-sdp [set thisDutId][set ngbrDutId] create" -verbose $option(verbose)
                    docli $dut "no shutdown" -verbose $option(verbose)
                    docli $dut "exit" -verbose $option(verbose)
                  }
                }
              }
              "rsvp" {
                # ldp between dut2/dut4 is disabled
                switch $interAsOption {
                  "A" {
                    if {$hashLabel == "signal"} {
                      docli $dut "interface to_[set ngbrDut][set thisRedirectVprnId] spoke-sdp [set thisDutId][set ngbrDutId]:[set thisRedirectVprnId] hash-label signal-capability" -verbose $option(verbose)
                    }
                  }
                  "B" {
                    docli $dut "spoke-sdp [set thisDutId][set ngbrDutId] create" -verbose $option(verbose)
                    docli $dut "no shutdown" -verbose $option(verbose)
                    docli $dut "exit" -verbose $option(verbose)
                  }
                }
              }
              default {
                log_msg ERROR "id15880 Invalid redirectVprnTunnelEncap: $redirectVprnTunnelEncap (should be gre | rsvp)" ; set Result FAIL ; break
              }
            }
          }
          default {
            log_msg ERROR "id26224 Invalid redirectVprnTunnelMethod: $redirectVprnTunnelMethod (should be autobind | sdp)" ; set Result FAIL ; break
          }
        }
        #
        if {$grtLookupEnableGrt} {
          docli $dut "            grt-lookup enable-grt" -verbose $option(verbose)
          docli $dut "            exit" -verbose $option(verbose)
        }
        #
        if {$hashLabel == "static"} {
          docli $dut "            hash-label" -verbose $option(verbose)
        }
        #
        docli $dut "        exit"  -verbose $option(verbose)
      }
      docli $dut "exit all" -verbose $option(verbose)
    }
    #
    if {$epipeListToScrubber != ""} {
      foreach {epipeDut epipeId epipeFromPort epipeToPort} $epipeListToScrubber {
        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
          set thisVlanId [expr $vCnt + 1] ; set thisEpipeId [expr $epipeId + $vCnt]
          flowspec_createEpipe $epipeDut $thisEpipeId $epipeFromPort $epipeToPort -fromEncapType dot1q -fromSap "$epipeFromPort:$thisVlanId" -toEncapType dot1q -toSap "$epipeToPort:$thisVlanId"
        }
        #
        if {$mirrorRedirectVrf} {
          incr thisEpipeId
          flowspec_createEpipe $epipeDut $thisEpipeId $epipeFromPort $epipeToPort -fromEncapType dot1q -fromSap "$epipeFromPort:$mirrorVlanId" -toEncapType dot1q -toSap "$epipeToPort:$mirrorVlanId"
        }
      }
    }
    #
    log_msg INFO "$dut4: Create dot1q itfs (#$nbrRedirectVprn) via $portA($dut4.$dut5) and default-route (in vprn) to scrubber (Ixia $portA(Ixia.$dut3))"
    # create itf to scrubber (Ixia2)
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) shut"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet mode access"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) ethernet encap-type dot1q"] ; log_msg INFO "$rCli"
    set rCli [$dut4 sendCliCommand "configure port $portA($dut4.$dut5) no shut"] ; log_msg INFO "$rCli"
    for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
      set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
      set thisVlanId [expr $vCnt + 1]
      set rCli [$dut4 sendCliCommand "exit all"]
      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "sap $portA($dut4.$dut5):$thisVlanId create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "egress filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "egress filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.$dataip(id.$dut3)" "."] {break} ; set thisB [expr $thisB + $vCnt]
      set rCli [$dut4 sendCliCommand "address $thisA.$thisB.$thisC.$thisD/$clnItfMask_v4"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 address [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]/$clnItfMask_v6"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
      foreach {thisA thisB thisC thisD} [split "1.66.9.9" "."] {break} ; set thisB [expr $thisB + $vCnt]
      # Add here static-routes for the redirectToVrf vprn
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      if {$addFlowroutesInBase} {
        # - Don't reset b, c and d because they point to the next values to be used
        # - Use isis in the Base instance
        foreach thisAction $thisActionListPerVprn {
          if {$thisAction == "redirectVrf"} {
            set a [set a_[set thisAction]]
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
            set rCli [$dut4 sendCliCommand "static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
          }
        }
      }
      #
      set rCli [$dut4 sendCliCommand "interface toScrubber_[set thisVlanId] create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "static-arp $thisA.$thisB.$thisC.$thisD 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "ipv6 neighbor [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD] 00:00:00:00:00:99"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit"] ; log_msg INFO "$rCli"
    }
    
    if {$mirrorRedirectVrf} {
      set rCli [$dut4 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "configure mirror"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "mirror-dest $mirrorId create"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "    sap $portA($dut4.$dut5):$mirrorVlanId create "] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "    exit"] ; log_msg INFO "$rCli" 
      set rCli [$dut4 sendCliCommand "    no shutdown"] ; log_msg INFO "$rCli"
      set rCli [$dut4 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
      #
      set rCli [$dut4 sendCliCommand "debug mirror-source $mirrorId port $portA($dut4.$dut2) ingress"] ; log_msg INFO "$rCli"
    }
    
    if {$enableFilterTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"FILTER\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
      }
    }
    if {$enableBgpFlowspecTrace} {
      foreach dut $enableTraceDutList {
        docli $dut "debug trace trace-point module \"BGP\" " -verbose $option(verbose)
        docli $dut "debug trace trace-point module \"BGP_VPRN\" " -verbose $option(verbose)
        docli $dut "debug trace enable" -verbose $option(verbose)
        docli $dut "shell traceLimitDisable" -verbose $option(verbose)
        # enableBgpFlowspecTrace $dut
        # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        #  enableBgpFlowspecTrace $dut2 -vprnId $thisVprnId
        # }
      }
    }
    
    if {$enableFlowspecBeforeFlowroutesAreInjected} {
      if {$enableIngressFlowspec_v4 || $enableIngressFlowspec_v6} {
        if {$enableIngressFlowspec_v4 && $enableIngressFlowspec_v6} {set thisTxt "flowspec/flowspec-ipv6"} elseif {$enableIngressFlowspec_v4} {set thisTxt "flowspec"} else {set thisTxt "flowspec-ipv6"}
        log_msg INFO "$dut2: Apply now ingress $thisTxt (on itf $dut1 => $dut2)"
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$itfType_dut1dut2 == "spoke"} {
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec-ipv6"] ; log_msg INFO $rCli
          } else {
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec-ipv6"] ; log_msg INFO $rCli
          }
        }
        #
        if {$addFlowroutesInBase} {
          set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec"] ; log_msg INFO $rCli
          set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec-ipv6"] ; log_msg INFO $rCli
        }
      }
    }
    
    foreach dut $dutList {
      $dut sendCliCommand "exit all"
    }

  } ; # config
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # Ixia part: capture
    if {$mirrorRedirectVrf} {
      log_msg INFO "configure packet capture on Ixia port: $portA(Ixia.$dut2)"
      handlePacket -port $portA(Ixia.$dut3) -action capture
    }
    # Ixia part: traffic
    handlePacket -port $portA(Ixia.$dut1) -action stop
    set thisDA 00:00:00:00:00:[int2Hex1 $dataip(id.$dut1)]
    set totalNbrOfFlowroutes 0
    set startStreamId 1
    set streamId $startStreamId 
    set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
    foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $numTrafficDst_v4 -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $numTrafficDst_v4 -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $numTrafficDst_v6 -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $numTrafficDst_v6 -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
      incr c ; if {$c > 255} {set c 0 ; incr b}
    }
    if {$addFlowroutesInBase} {
      # - Don't reset b, c and d because they point to the next values to be used
      # - Use isis in the Base instance
      foreach thisAction $thisActionListPerVprn {
        set a [set a_[set thisAction]]
        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
        set thisHandlePacketAction create
        if {$sendTraffic_v4} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $numTrafficDst_v4 -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v4 -numDest $numTrafficDst_v4 -src $dataip(ip.1.Ixia.$dut1) -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
        if {$streamId == $nbrStreamsUsed} {
          # this is the last stream (IPv6)
          set thisHandlePacketAction ""
        } else {
          set thisHandlePacketAction create 
        }
        if {$sendTraffic_v6} {
          log_msg INFO "=> handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $numTrafficDst_v6 -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction"
          handlePacket -port $portA(Ixia.$dut1) -dst $thisDstPrefix_v6 -numDest $numTrafficDst_v6 -src [ipv4ToIpv6  $dataip(ip.1.Ixia.$dut1)] -numSource 1 -damac $thisDA -stream $streamId -rate $pktRatePerStream -data $streamData_ISATMS -framesize $pktSize -rawProtocol $rawProtocol -action $thisHandlePacketAction
          incr streamId
          set totalNbrOfFlowroutes [expr $totalNbrOfFlowroutes + $thisNbrFlowroutesPerVprn]
        }
      }
    }
    
    # scrubber
    handlePacket -port $portA(Ixia.$dut3) -action capture
    
    log_msg INFO "Wait till all vprn's are operational before inject flowspec"
    set nbrRedirectVprnOperStateUp 0
    foreach {dut} $checkIpFlowspecFilterDutList {break}
    for {set rCnt 1} {$rCnt <= $option(maxRetryCnt)} {incr rCnt} {
      for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
        set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
        set rCli [$dut sendCliCommand "show service id $thisRedirectVprnId base | match \"Oper State\" "]
        # Admin State       : Up                  Oper State        : Up
        if {[regexp {.*Oper State[ ]+:[ ]+([A-Za-z]+).*} $rCli match vprnOperState]} {
          if {$vprnOperState == "Up"} {
            incr nbrRedirectVprnOperStateUp
          }
        }
      }
      if {$nbrRedirectVprnOperStateUp == $nbrRedirectVprn} {
        log_msg INFO "All redirectVprn are Up ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn)"
        log_msg INFO "" ; log_msg INFO "Display some interesting info for the redirect vprn's" ; log_msg INFO ""
        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
          set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
          set rCli [$dut sendCliCommand "show service id $thisRedirectVprnId all"] ; log_msg INFO "$rCli"
          set rCli [$dut sendCliCommand "show router ldp bindings service-id $thisRedirectVprnId detail"] ; log_msg INFO "$rCli"
        }
        set rCli [$dut sendCliCommand "show router tunnel-table"] ; log_msg INFO "$rCli"
        if {$redirectVprnTunnelEncap == "rsvp"} {
          set rCli [$dut sendCliCommand "show router mpls lsp"] ; log_msg INFO "$rCli"
        }
        if {$redirectVprnTunnelMethod == "sdp"} {
          set rCli [$dut sendCliCommand "show service sdp detail"] ; log_msg INFO "$rCli"
        }
        break
      } else {
        if {$rCnt == $option(maxRetryCnt)} {
          log_msg ERROR "id4125 Not all redirectVprn ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn) are Up after $option(maxRetryCnt) retries" ; set Result FAIL
        } else {
          log_msg INFO "Waiting $option(interRetryTimeSec) sec ($rCnt/$option(maxRetryCnt)) till all redirectVprn ($nbrRedirectVprnOperStateUp / $nbrRedirectVprn) are Up ..." ; after [expr $option(interRetryTimeSec) * 1000]
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "Precondition: Waiting 20secs and check that traffic flows from $dut1 to $dut6" ; after 20000
      log_msg INFO "$mySubtest"
      if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
        log_msg INFO "Traffic from $dut1 to $dut6 ok"
      } else {
        log_msg ERROR "id11131 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
      }
      subtest "$mySubtest"
    }
  
    if {! [testFailed] && $Result == "OK"} {
      if {$addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
        $dut2 createIpFilterPolicy $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId -Def_Act forward
        $dut2 createIpv6FilterPolicy $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId -Def_Act forward
        log_msg INFO "$dut2: Apply ingress filter (ip/ipv6) $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (on itf $dut1 => $dut2)"
        set vprnCnt 1
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$vprnCnt == 1} {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ip $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ipv6 $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ip $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ipv6 $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            }
          }
          incr vprnCnt
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      # sbgp part
      set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$thisVprnId -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          if {! $sendBgpPrefixUpd_v4} {
            set thisDstPrefix_v4 $dummyNetw
          }
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
          sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs [set [set dut3]_AS] \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag \
            -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
          if {$sendBgpPrefixUpd_v6} {
            sbgp.add -id peer$baseDot1qTag -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
          }
        }
      }
      #
      set b 1 ; set c [lindex $vprnIdOnlyList 0] 
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 0
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
              sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
            }
            incr d
          }
        }
        incr c ; if {$c > 255} {set c 0 ; incr b}
      }
      #
      if {$addFlowroutesInBase} {
        # - Don't reset b and c because they point to the next values to be used
        foreach thisAction $thisActionListPerVprn {
          set a [set a_[set thisAction]]
          set d 0
          for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
            set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
            set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
            set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            if {$thisAction == "redirectVrf"} {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
            } else {
              set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
              set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
            }
            if {$sendBgpFlowrouteUpd_v4} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
              set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
            }
            if {$sendBgpFlowrouteUpd_v6} {
              log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
              set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
              log_msg INFO " =>sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
              sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
            }
            incr d
          }
        }
      }
      #
      foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
        sbgp.run -id peer$thisVprnId
      }
      if {$addFlowroutesInBase} {
        sbgp.run -id peer$baseDot1qTag
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set mySubtest "$dut3: Check that debug log has no unexpected \"Optional Attribute Error\""
      log_msg INFO "$mySubtest"
      set rCli [$dut3 sendCliCommand "show log log-id $debugLog count 200 descending" -bufferedMode true] ; if {$dumpDebugLog} {log_msg INFO "$rCli"}
      if {[regexp {.*Optional Attribute Error.*} $rCli match]} {
        log_msg ERROR "id24463 Found unexpected \"Optional Attribute Error\""
      } else {
        log_msg INFO "No unexpected \"Optional Attribute Error\" found"
      }
      subtest "$mySubtest"
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {[expr $nbrVprns * $nbrFlowroutesPerVprn] > 16} {
        log_msg WARNING "Skip debug log check because scale is too high"
      } else {
        set mySubtest "$dut3: Check that debug log has all expected vprn's ($vprnIdOnlyList)"
        log_msg INFO "$mySubtest"
        if {[flowspec_checkBgpDebugLogForVprnId $dut3 $debugLog $vprnIdOnlyList]} {
          log_msg INFO "$dut3: Found all expected vprn's ($vprnIdOnlyList) in debug log (log-id: $debugLog)"
        } else {
          log_msg ERROR "id1387 $dut3: Couldn't find all expected vprn's ($vprnIdOnlyList) in debug log (log-id: $debugLog)"
        }
        subtest "$mySubtest"
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$enableFlowspecBeforeFlowroutesAreInjected} {
        # skip traffic check
      } else {
        set mySubtest "Check that traffic still flows from $dut1 to $dut6, because ingress flowspec/flowspec-ipv6 is not yet applied"
        log_msg INFO "$mySubtest"
        if {[flowspec_allTrafficFlows $dut1 $dut6 $cntPktsViaFilter_filterId -trafficDurationSecs $trafficDurationSecsDuringPrecondition]} {
          log_msg INFO "Traffic from $dut1 to $dut6 ok"
        } else {
          log_msg ERROR "id22419 Traffic from $dut1 to $dut6 nok" ; set Result FAIL
        }
        subtest "$mySubtest"
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$enableFlowspecBeforeFlowroutesAreInjected} {
        # already done earlier
      } else {
        if {$enableIngressFlowspec_v4 || $enableIngressFlowspec_v6} {
          if {$enableIngressFlowspec_v4 && $enableIngressFlowspec_v6} {set thisTxt "flowspec/flowspec-ipv6"} elseif {$enableIngressFlowspec_v4} {set thisTxt "flowspec"} else {set thisTxt "flowspec-ipv6"}
          set mySubtest "$dut2: Apply now ingress $thisTxt (on itf $dut1 => $dut2)"
          log_msg INFO "$mySubtest"
          foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress flowspec-ipv6"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress flowspec-ipv6"] ; log_msg INFO $rCli
            }
          }
          #
          if {$addFlowroutesInBase} {
            set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec"] ; log_msg INFO $rCli
            set rCli [$dut2 sendCliCommand "configure router interface to_[set dut1][set baseDot1qTag] ingress flowspec-ipv6"] ; log_msg INFO $rCli
          }
          subtest "$mySubtest"
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      if {$addDefFilterInLastVprnAfterFlowroutesAreInjected} {
        $dut2 createIpFilterPolicy $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId -Def_Act forward
        $dut2 createIpv6FilterPolicy $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId -Def_Act forward
        log_msg INFO "$dut2: Apply ingress filter (ip/ipv6) $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (on itf $dut1 => $dut2)"
        set vprnCnt 1 
        foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
          if {$vprnCnt == $nbrVprns} {
            if {$itfType_dut1dut2 == "spoke"} {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ip $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter ipv6 $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            } else {
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ip $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
              set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter ipv6 $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
            }
          }
          incr vprnCnt
        }
      }
    }
    
    if {! [testFailed] && $Result == "OK"} {
      set startTimeStampSec [clock seconds]
      set whileContinue 1 ; set iterationCnt 0
      while {$whileContinue} {
        incr iterationCnt
        foreach {action expectedBehavior} $actionExpectedBehaviorList {
          log_msg INFO "" ; log_msg INFO "======================================================================"
          log_msg INFO "iteration: $iterationCnt | action: \"$action\" => expectedBehavior: \"$expectedBehavior\" "
          log_msg INFO "======================================================================" ; log_msg INFO ""
          # These are the different actions
          switch $action {
            "none" {
              # no action needed
            }
            
            "swo" - "doubleSwo" {
              #
              log_msg INFO "" ; log_msg INFO "vvvvv $dut2: Show fSpec-x BEFORE switchover vvvvv" ; log_msg INFO ""
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  log_msg INFO "" 
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                  log_msg INFO ""
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  log_msg INFO ""
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                  log_msg INFO ""
                }
                #
                log_msg INFO "$dut2: Show filter $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId) BEFORE switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                log_msg INFO "$dut2: Show filter $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId) BEFORE switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                #
              } ; #thisFilterFamilyList 
              log_msg INFO "" ; log_msg INFO "^^^^^ $dut2: Show fSpec-x BEFORE switchover ^^^^^" ; log_msg INFO ""
              
              #
              set actionTodo doubleSwo
              if {$actionTodo == "swo"} {set  nbrSwoToDo 1} else {set nbrSwoToDo 2}
              for {set swoNbr 1} {$swoNbr <= $nbrSwoToDo} {incr swoNbr} {
                set activitySwitchMethod [lindex $fspecSwoMethodList [random $fspecSwoMethodListLen]]
                log_msg INFO "$dut2: Switchover $swoNbr/$nbrSwoToDo activitySwitchMethod: $activitySwitchMethod"
                if {[$dut2 activitySwitch -inSyncTime1 11 -skipCheck true -inSyncTime3 2000 -Method $activitySwitchMethod] == "OK"} {
                  # nop
                } else {
                  log_msg ERROR "id1947 $dut2: Switchover failed" ; set Result FAIL ; break
                }
                after 1000 ; $dut2 closeExpectSession ; after 1000 ; $dut2 openExpectSession ; after 1000
                log_msg INFO "$dut2: Wait until standby is synchronized"
                if {[$dut2 CnWSecInSync] == "OK"} {
                  log_msg INFO "$dut2: Standby is in sync now - a new switchover is allowed"
                  after 5000
                  $dut2 closeExpectSession ; after 1000 ; $dut2 openExpectSession ; after 1000
                } else {
                  log_msg ERROR "id2784 $dut2: Standby not yet in sync" ; set Result FAIL ; break
                }
              }
              #
               log_msg INFO "" ; log_msg INFO "vvvvv $dut2: Show fSpec-x AFTER switchover vvvvv" ; log_msg INFO ""
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli" 
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  set rCli [$dut2 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                }
                #
                log_msg INFO "$dut2: Show filter $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId (addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId) AFTER switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                log_msg INFO "$dut2: Show filter $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId (addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId) AFTER switchover"
                log_msg INFO ""
                set rCli [$dut2 sendCliCommand "show filter $fTxt $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId"] ; log_msg INFO "$rCli"
                log_msg INFO ""
                #
              } ; #thisFilterFamilyList 
              log_msg INFO "" ; log_msg INFO "^^^^^ $dut2: Show fSpec-x AFTER switchover ^^^^^" ; log_msg INFO ""
              #
            }
            
            "shutFirstFlowrouteVprn" - "noShutFirstFlowrouteVprn" {
              if {[regexp {noShut} $action match]} {set shutNoShutTxt "no shut"} else {set shutNoShutTxt "shut"}
              # The first vprn is one with merged fSpec entries into addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
              set vprnCnt 1
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                if {$vprnCnt == 1} {
                  set shutVprnId $thisVprnId
                  if {! [regexp {noShut} $action match]} {
                    # get the active filter-id before the shut
                    if {$itfType_dut1dut2 == "spoke"} {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dataip(id.$dut1))
                    } else {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dut1)
                    }
                    flowspec_getActiveFilterIdFromService $dut2 $shutVprnId $sdpOrSap igIpv4FltrIdActiveBeforeShut igIpv6FltrIdActiveBeforeShut
                  }
                  set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId $shutNoShutTxt"] ; log_msg INFO "$rCli"
                  break
                }
                incr vprnCnt
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "shutNextFlowrouteVprn" - "noShutNextFlowrouteVprn" {
              if {[regexp {noShut} $action match]} {set shutNoShutTxt "no shut"} else {set shutNoShutTxt "shut"}
              # The next vprn is one with non merged fSpec entries
              set vprnCnt 1
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                if {$vprnCnt > 1} {
                  set shutVprnId $thisVprnId
                  if {! [regexp {noShut} $action match]} {
                    # get the active filter-id before the shut
                    if {$itfType_dut1dut2 == "spoke"} {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dataip(id.$dut1))
                    } else {
                      set sdpOrSap $dataip(sap.$shutVprnId.$dut2.$dut1)
                    }
                    flowspec_getActiveFilterIdFromService $dut2 $shutVprnId $sdpOrSap igIpv4FltrIdActiveBeforeShut igIpv6FltrIdActiveBeforeShut
                  }
                  set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId $shutNoShutTxt"] ; log_msg INFO "$rCli"
                  break
                }
                incr vprnCnt
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
                      
            "withdrawAllIpv4v6Flowroutes" {
              set b 1 ; set c [lindex $vprnIdOnlyList 0] 
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 0
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                    }
                    incr d
                  }
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                sbgp.run -id peer$thisVprnId
              }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 0
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv4} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {[regexp {Ipv4v6} $action match] || [regexp {Ipv6} $action match]} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                    }
                    incr d
                  }
                }
                sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "announceAllIpv4v6FlowroutesAgain" {
              set b 1 ; set c [lindex $vprnIdOnlyList 0] 
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 0
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {$thisAction == "redirectVrf"} {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    } else {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                    }
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      sbgp.add -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
                    }
                    incr d
                  }
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                sbgp.run -id peer$thisVprnId
              }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                foreach thisAction $thisActionListPerVprn {
                  set a [set a_[set thisAction]]
                  set d 0
                  for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                    set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                    if {$thisAction == "redirectVrf"} {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    } else {
                      set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                      set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                    }
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      sbgp.add -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
                    }
                    incr d
                  }
                }
                sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "stopTrafficAndClearFilters" {
              handlePacket -port $portA(Ixia.$dut1) -action stop ; after 5000
              #
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                set vprnCnt 1 
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                  } else {
                    set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  }
                  incr vprnCnt

                  set rCli [$dut2 sendCliCommand "clear filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli" 
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  set rCli [$dut2 sendCliCommand "clear filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
                }
                #
              } ; #thisFilterFamilyList 
              # 
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "startTraffic" {
              handlePacket -port $portA(Ixia.$dut1) -action start ; after 5000
            }
            
            "rollback" {
              log_msg INFO "Create rollback checkpoint, remove configuration and restore via rollback revert"
              set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
              #
              after 1000
              saveOrRestore delete -dut $dut2
              after 1000
              # configure rollback-location again because it was removed during saveOrRestore delete
              set rCli [$dut2 sendCliCommand "configure system rollback rollback-location $rollbackLocation/flowspecVprnTesting"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
              set rCli [$dut2 sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
              log_msg INFO "Waiting 20secs ...." ; after 20000
              #
            }
            
            "clearBgpNeighbor" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "clear router $thisVprnId bgp neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3)"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "clear router bgp neighbor [set [set dut3]_ifsystem_ip]"] ; log_msg INFO "$rCli"
              }
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "clearBgpProtocol" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "clear router $thisVprnId bgp protocol"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "clear router bgp protocol"] ; log_msg INFO "$rCli"
              }
              log_msg INFO "Waiting 10secs..." ; after 10000
            }
            
            "shutNoShutBgpNeighbor_waitOnZeroAndOnAllFlowroutes" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3) shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp group $groupName neighbor [set [set dut3]_ifsystem_ip] shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id11570 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp group $groupName neighbor $thisVprnId.$dataip(id.$dut2).$dataip(id.$dut3).$dataip(id.$dut3) no shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp group $groupName neighbor [set [set dut3]_ifsystem_ip] no shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id22039 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
            }
            
            "shutNoShutBgpProtocol_waitOnZeroAndOnAllFlowroutes" {
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id654 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId bgp no shutdown"] ; log_msg INFO "$rCli"
              }
              if {$addFlowroutesInBase} {
                set rCli [$dut2 sendCliCommand "configure router bgp no shutdown"] ; log_msg INFO "$rCli"
              }
              #
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id24932 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
            }
            
            "adminTech" {
              set rCli [$dut2 sendCliCommand "admin tech-support ftp://$::TestDB::thisTestBed:tigris@$::TestDB::thisHostIpAddr/$logdir/device_logs/saved_configs/thisAT_[tms_uptimeSecs $dut2]"] ; log_msg INFO "$rCli"
            }
            
            "announceWithdrawTooMuchIpv4v6Flowroutes" {
              log_msg INFO "First announce tooMuch IPv4/IPv6 flowroutes in Base & vprn context"
              set tooMuch_v4 0 ; set tooMuch_v6 0
              set tooMuchContextList_v4 "" ; set tooMuchContextList_v6 ""
              set rCli [$dut2 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
              set b 1 ; set c [lindex $vprnIdOnlyList 0]
              # The events are throttled, so generate only a flowroute in first vprn and for one action
              set thisVprnCnt 0
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                incr thisVprnCnt
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisVprnCnt == 1 && $thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action/one vprn (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "vprn$thisVprnId"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "vprn$thisVprnId"
              waitDampeningTime
                    }
                  }
                # 
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
              #   sbgp.run -id peer$thisVprnId
              # }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                # the events are trottled, so generate only a flowroute for one action
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "Base"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Inject flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "Base"
              waitDampeningTime
                    }
                  }
                  #
                }
                #sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
              #
              log_msg INFO "" ; log_msg INFO "Expecting tooMuch_v4: $tooMuch_v4 and  tooMuch_v6: $tooMuch_v6" ; log_msg INFO ""
              set rShell [$dut2 sendCliCommand "shell fltrAutoGen_ShowNlriStoreCounts"] ; log_msg INFO "$rShell"
              set rCli [$dut2 sendCliCommand "show log log-id 99 application \"filter\""] ; log_msg INFO "$rCli"
              if {$tooMuch_v4 > 0} {
                foreach tooMuchContext $tooMuchContextList_v4 {
                  set pat ".*fltrtypeselIp Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg INFO "Found \"$pat\""
                  } else {
                    log_msg ERROR "id11810 Couldn't find \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  }
                }
              }
              if {$tooMuch_v6} {
                foreach tooMuchContext $tooMuchContextList_v6 {
                  set pat ".*fltrtypeselIpv6 Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg INFO "Found \"$pat\""
                  } else {
                    log_msg ERROR "id26533 Couldn't find \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  }
                }
              }
              #
              log_msg INFO "Now withdraw tooMuch IPv4/IPv6 flowroutes in Base & vprn context"
              set tooMuch_v4 0 ; set tooMuch_v6 0
              set tooMuchContextList_v4 "" ; set tooMuchContextList_v6 ""
              set rCli [$dut2 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
              set b 1 ; set c [lindex $vprnIdOnlyList 0]
              # The events are throttled, so generate only a flowroute in first vprn and for one action
              set thisVprnCnt 0
              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                incr thisVprnCnt
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisVprnCnt == 1 && $thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action/one vprn (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "vprn$thisVprnId"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "vprn$thisVprnId"
              waitDampeningTime
                    }
                  }
                # 
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
              }
              # foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
              #   sbgp.run -id peer$thisVprnId
              # }
              #
              if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                # the events are trottled, so generate only a flowroute for one action
                set thisActionCnt 0
                foreach thisAction $thisActionListPerVprn {
                  incr thisActionCnt
                  set a [set a_[set thisAction]]
                  set d [expr $thisNbrFlowroutesPerVprn + 1]
                  # 
                  set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                  set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                  set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
                  set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
                  if {$thisAction == "redirectVrf"} {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction -target $thisRT]
                  } else {
                    set comm1_v4 [createFlowSpecExtCommunityAttr $thisAction]
                    set comm1_v6 [createFlowSpecExtCommunityAttr $thisAction]
                  }
                  if {$thisActionCnt == 1} {
                    log_msg INFO "Only send flowroute for one action (because event generation is throttled)"
                    if {$sendBgpFlowrouteUpd_v4} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v4 $thisAction"
                      set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi $mpSafi
                      incr tooMuch_v4 ; lappend tooMuchContextList_v4 "Base"
              waitDampeningTime
                    }
                    if {$sendBgpFlowrouteUpd_v6} {
                      log_msg INFO "Withdraw flowroute $thisDstPrefixMask_v6 $thisAction"
                      set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
                      log_msg INFO " =>sbgp.run -id peer$baseDot1qTag -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]"
                      # Use \"run\" here iso \"add"\ + \"run\" to introduce some delay and avoid throttling of the events
                      sbgp.run -id peer$baseDot1qTag -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi $mpSafi 
                      incr tooMuch_v6 ; lappend tooMuchContextList_v6 "Base"
              waitDampeningTime
                    }
                  }
                  #
                }
                #sbgp.run -id peer$baseDot1qTag
              }
              #
              log_msg INFO "Waiting 30secs..." ; after 30000
              #
              log_msg INFO "" ; log_msg INFO "Expecting tooMuch_v4: $tooMuch_v4 and  tooMuch_v6: $tooMuch_v6" ; log_msg INFO ""
              set rShell [$dut2 sendCliCommand "shell fltrAutoGen_ShowNlriStoreCounts"] ; log_msg INFO "$rShell"
              set rCli [$dut2 sendCliCommand "show log log-id 99 application \"filter\""] ; log_msg INFO "$rCli"
              if {$tooMuch_v4 > 0} {
                foreach tooMuchContext $tooMuchContextList_v4 {
                  set pat ".*fltrtypeselIp Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg ERROR "id31630 Found unexpected \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  } else {
                    log_msg INFO "Couldn't find (exp behavior) \"$pat\""
                  }
                }
              }
              if {$tooMuch_v6} {
                foreach tooMuchContext $tooMuchContextList_v6 {
                  set pat ".*fltrtypeselIpv6 Insufficient resources problem encountered while handling BGP NLRI in Filter module in vRtr $tooMuchContext.*"
                  if {[regexp -- $pat $rCli match]} {
                    log_msg ERROR "id22090 Found unexpected \"$pat\""
                    set rCli [$dut2 sendCliCommand "show log log-id 99"] ; log_msg DEBUG "$rCli"
                    break
                  } else {
                    log_msg INFO "Couldn't find (exp behavior) \"$pat\""
                  }
                }
              }
              #
            }
            
            "removeAllIpv4v6RoutesFromRedirectVprn" {
              for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                set thisVlanId [expr $vCnt + 1]
                set rCli [$dut4 sendCliCommand "exit all"]
                foreach {thisA thisB thisC thisD} [split "1.66.9.9" "."] {break} ; set thisB [expr $thisB + $vCnt]
                # Add here static-routes for the redirectToVrf vprn
                set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  foreach thisAction $thisActionListPerVprn {
                    if {$thisAction == "redirectVrf"} {
                      set a [set a_[set thisAction]]
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId no static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId no static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
                    }
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                if {$addFlowroutesInBase} {
                  # - Don't reset b, c and d because they point to the next values to be used
                  # - Use isis in the Base instance
                  foreach thisAction $thisActionListPerVprn {
                    if {$thisAction == "redirectVrf"} {
                      set a [set a_[set thisAction]]
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId no static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId no static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
                    }
                  }
                }
                #
              }
              set rCli [$dut4 sendCliCommand "exit all"]
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "addAllIpv4v6RoutesFromRedirectVprn" {
              for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                set thisVlanId [expr $vCnt + 1]
                set rCli [$dut4 sendCliCommand "exit all"]
                foreach {thisA thisB thisC thisD} [split "1.66.9.9" "."] {break} ; set thisB [expr $thisB + $vCnt]
                # Add here static-routes for the redirectToVrf vprn
                set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  foreach thisAction $thisActionListPerVprn {
                    if {$thisAction == "redirectVrf"} {
                      set a [set a_[set thisAction]]
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
                    }
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                if {$addFlowroutesInBase} {
                  # - Don't reset b, c and d because they point to the next values to be used
                  # - Use isis in the Base instance
                  foreach thisAction $thisActionListPerVprn {
                    if {$thisAction == "redirectVrf"} {
                      set a [set a_[set thisAction]]
                      set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId static-route $thisDstPrefixMask_v4 next-hop $thisA.$thisB.$thisC.$thisD"] ; log_msg INFO "$rCli"
                      set rCli [$dut4 sendCliCommand "configure service vprn $thisRedirectVprnId static-route $thisDstPrefixMask_v6 next-hop [ipv4ToIpv6 $thisA.$thisB.$thisC.$thisD]"] ; log_msg INFO "$rCli"
                    }
                  }
                }
                #
              }
              set rCli [$dut4 sendCliCommand "exit all"]
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "addGrtLookupEnableGrtStaticRoute" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    foreach thisAction $thisActionListPerVprn {
                      if {$thisAction == "redirectVrf"} {
                        set a [set a_[set thisAction]]
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        set rCli [$dut sendCliCommand "exit all"]
                        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                            set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                            set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt static-route $thisDstPrefixMask_v4 grt"] ; log_msg INFO "$rCli"
                            set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt static-route $thisDstPrefixMask_v6 grt"] ; log_msg INFO "$rCli"
                        }
                        set rCli [$dut sendCliCommand "exit all"]
                      }
                      incr c ; if {$c > 255} {set c 0 ; incr b}
                    }
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b, c and d because they point to the next values to be used
                    # - Use isis in the Base instance
                    foreach thisAction $thisActionListPerVprn {
                      if {$thisAction == "redirectVrf"} {
                        set a [set a_[set thisAction]]
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        set rCli [$dut sendCliCommand "exit all"]
                        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                          set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                          set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt static-route $thisDstPrefixMask_v4 grt"] ; log_msg INFO "$rCli"
                          set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt static-route $thisDstPrefixMask_v6 grt"] ; log_msg INFO "$rCli"
                        }
                        set rCli [$dut sendCliCommand "exit all"]
                      }
                    }
                  }
                  #
                }
              }
              log_msg INFO "Waiting 5secs..." ; after 5000
            }
            
            "removeGrtLookupEnableGrtStaticRoute" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    foreach thisAction $thisActionListPerVprn {
                      if {$thisAction == "redirectVrf"} {
                        set a [set a_[set thisAction]]
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        set rCli [$dut sendCliCommand "exit all"]
                        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                            set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                            set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt no static-route $thisDstPrefixMask_v4 grt"] ; log_msg INFO "$rCli"
                            set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt no static-route $thisDstPrefixMask_v6 grt"] ; log_msg INFO "$rCli"
                        }
                        set rCli [$dut sendCliCommand "exit all"]
                      }
                      incr c ; if {$c > 255} {set c 0 ; incr b}
                    }
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b, c and d because they point to the next values to be used
                    # - Use isis in the Base instance
                    foreach thisAction $thisActionListPerVprn {
                      if {$thisAction == "redirectVrf"} {
                        set a [set a_[set thisAction]]
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
                        set rCli [$dut sendCliCommand "exit all"]
                        for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                          set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                          set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt no static-route $thisDstPrefixMask_v4 grt"] ; log_msg INFO "$rCli"
                          set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId grt-lookup enable-grt no static-route $thisDstPrefixMask_v6 grt"] ; log_msg INFO "$rCli"
                        }
                        set rCli [$dut sendCliCommand "exit all"]
                      }
                    }
                  }
                  #
                }
              }
              log_msg INFO "Waiting 5secs..." ; after 5000
            }
            
            "shutAllRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                    set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                    set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId shutdown"] ; log_msg INFO "$rCli"
                  }
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "noShutAllRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                    set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                    set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no shutdown"] ; log_msg INFO "$rCli"
                  }
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "shutActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId $actualRedirectVprnId
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId shutdown"] ; log_msg INFO "$rCli"
                  incr actualRedirectVprnId
                  log_msg INFO "actualRedirectVprnId goes from $thisRedirectVprnId to $actualRedirectVprnId because of $action"
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "noShutPreviousRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId [expr $actualRedirectVprnId - 1]
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no shutdown"] ; log_msg INFO "$rCli"
                  log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $thisRedirectVprnId because of $action"
                  decr actualRedirectVprnId
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "removeImportPolicyFromActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId $actualRedirectVprnId
                  ###
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId"] 
                  set rCli [$dut sendCliCommand "info | match vrf-import"]
                  #             vrf-import "vprn_importPol_2_4"
                  regexp {.*vrf-import "(.+)".*} $rCli match removedImportPolicy
                  set rCli [$dut sendCliCommand "exit all"]
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-import"] ; log_msg INFO "$rCli"
                  ###
                  incr actualRedirectVprnId
                  log_msg INFO "actualRedirectVprnId goes from $thisRedirectVprnId to $actualRedirectVprnId because of $action (removedImportPolicy: $removedImportPolicy)"
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "restoreImportPolicyFromActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId [expr $actualRedirectVprnId - 1]
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId vrf-import $removedImportPolicy"] ; log_msg INFO "$rCli"
                  log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $thisRedirectVprnId because of $action"
                  decr actualRedirectVprnId
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "removeImportPolicyFromRouterPolicyOptionsRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options begin"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"] 
                  set rCli [$dut sendCliCommand "info"]
                  set cliBuf [split $rCli "\n"] ; set cliBufLen [llength $cliBuf]
                  # Everything between 2 lines with dashes is valid
                  set start 0 ; set stop 0 ; set removedImportPolicyCliCmdList_[set dut] ""
                  foreach line $cliBuf {
                    if {[regexp {.*----------.*} $line match]} {
                      if {$start && ! $stop} {
                        set stop 1
                        lappend removedImportPolicyCliCmdList_[set dut] "exit all"
                      }
                      if {! $start} {
                        set start 1
                        lappend removedImportPolicyCliCmdList_[set dut] "configure router policy-options policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"
                      }
                    } else {
                      if {$start && ! $stop} {
                        lappend removedImportPolicyCliCmdList_[set dut] $line
                      }
                    }
                  }
                  set rCli [$dut sendCliCommand "exit all"]
                  set rCli [$dut sendCliCommand "configure router policy-options no policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId]"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options commit"] ; log_msg INFO "$rCli"
                }
              }
              # The last vprn doesn't use vrf-import policy (vrfTargetDirectUnderVprn_noImportPolicy), so this one will be selected
              log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $maxRedirectVprnId because of $action"
              set actualRedirectVprnId $maxRedirectVprnId
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "restoreImportPolicyFromRouterPolicyOptionsRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options begin"] ; log_msg INFO "$rCli"
                  # add here removed import policy again
                  foreach line [set removedImportPolicyCliCmdList_[set dut]] {
                    set rCli [$dut sendCliCommand "$line"] ; log_msg INFO "$rCli"
                  }
                  set rCli [$dut sendCliCommand "configure router policy-options commit"] ; log_msg INFO "$rCli"
                }
              }
              log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $firstRedirectVprnId because of $action"
              set actualRedirectVprnId $firstRedirectVprnId
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "removeCommunityFromImportPolicyRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options begin"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options no community \"vprn1_importRouteTarget_[set ngbrDutId]\""] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options commit"] ; log_msg INFO "$rCli"
                }
              }
              # The last vprn doesn't use vrf-import policy (vrfTargetDirectUnderVprn_noImportPolicy), so this one will be selected
              log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $maxRedirectVprnId because of $action"
              set actualRedirectVprnId $maxRedirectVprnId
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "restoreCommunityFromImportPolicyRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options begin"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options community \"vprn1_importRouteTarget_[set ngbrDutId]\" members \"target:[set ngbrDutId][set thisDutId]:1\" "] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure router policy-options commit"] ; log_msg INFO "$rCli"
                }
              }
              log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $firstRedirectVprnId because of $action"
              set actualRedirectVprnId $firstRedirectVprnId
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "updateRouteTargetAllRedirectVprn" {
              foreach dut $redirectDutList {
                log_msg INFO "Create rollback checkpoint tobe used in \"restoreRouteTargetAllRedirectVprn\""
                set rCli [$dut sendCliCommand "configure system rollback rollback-location $rollbackLocation/restoreRouteTargetAllRedirectVprn_[set dut]"] ; log_msg INFO "$rCli"
                set rCli [$dut sendCliCommand "admin rollback save"] ; log_msg INFO "$rCli"
              }
              #
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                  # add here the vprn's
                  set thisRedirectVprnId [expr $firstRedirectVprnId + $vCnt]
                  if {$vCnt == [expr $nbrRedirectVprn - 1] && $vrfTargetDirectUnderVprn_noImportPolicy} {
                    set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-target"] ; log_msg INFO "$rCli"
                  } else {
                    # Here 3 actions could be done: 
                    #   0. Under the vprn context: Remove the vrf-import
                    #       Under the policy context: 
                    #   1.   - Remove the community from the policy-statement
                    #   2.   - Change the target under community
                    if {$vCnt == 0} {
                      set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-import"] ; log_msg INFO "$rCli"
                    }
                  }
                }
              }
              #
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                 for {set vCnt 0} {$vCnt < $nbrRedirectVprn} {incr vCnt} {
                  if {$vCnt >= 2 && ! ($vCnt == [expr $nbrRedirectVprn - 1] && $vrfTargetDirectUnderVprn_noImportPolicy)} {
                    set rCli [$dut sendCliCommand "configure router policy-options"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "begin"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "no community \"vprn1_importRouteTarget_[set ngbrDutId]\" "] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "community \"vprn1_importRouteTarget_[set ngbrDutId]\" members \"target:99:99\" "] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "commit"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  }
                  if {$vCnt == 1} {
                    set rCli [$dut sendCliCommand "configure router policy-options"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "begin"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "policy-statement vprn_importPol_[set thisDutId]_[set ngbrDutId] entry 1 from no community"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "commit"] ; log_msg INFO "$rCli"
                    set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  }
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "restoreRouteTargetAllRedirectVprn" {
              foreach dut $redirectDutList {
                set rCli [$dut sendCliCommand "admin rollback revert latest-rb now"] ; log_msg INFO "$rCli"
                set rCli [$dut sendCliCommand "admin rollback delete latest-rb"] ; log_msg INFO "$rCli"
                set rCli [$dut sendCliCommand "configure system rollback no rollback-location"] ; log_msg INFO "$rCli"
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "negTest_addGrtLookupInFlowrouteVprn" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" "
              log_msg INFO "$mySubtest"
              log_msg INFO ""
              log_msg INFO "This is a negative test to cover following scenario:"
              log_msg INFO "  It's the intention to enable grt lookup in the redirectVprn (vrpnId: $firstRedirectVprnId ; nbrRedirectVprn: $nbrRedirectVprn)."
              log_msg INFO "  But, it's not forbidden to enable grt lookup in the flowroute vprn's (vrpnId's: $vprnIdOnlyList)."
              log_msg INFO "  This should have no impact."
              log_msg INFO ""

              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId grt-lookup enable-grt"] ; log_msg INFO "$rCli"
                set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
              }
            }
              
            "negTest_removeGrtLookupInFlowrouteVprn" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" "
              log_msg INFO "$mySubtest"
              log_msg INFO ""

              foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId grt-lookup no enable-grt"] ; log_msg INFO "$rCli"
                set rCli [$dut2 sendCliCommand "exit all"] ; log_msg INFO "$rCli"
              }
            }
            
            "replaceImportPolicyWithRouteTargetInActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId $actualRedirectVprnId
                  ###
                  set rCli [$dut sendCliCommand "exit all"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId"] 
                  set rCli [$dut sendCliCommand "info | match vrf-import"]
                  #             vrf-import "vprn_importPol_2_4"
                  regexp {.*vrf-import "(.+)".*} $rCli match removedImportPolicy
                  set rCli [$dut sendCliCommand "exit all"]
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-import"] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId vrf-target target:[set ngbrDutId][set thisDutId]:1"] ; log_msg INFO "$rCli"
                  ###
                  log_msg INFO "actualRedirectVprnId $actualRedirectVprnId unchanged during $action (removedImportPolicy: $removedImportPolicy)"
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "replaceRouteTargetWithImportPolicyInActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId $actualRedirectVprnId
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-target "] ; log_msg INFO "$rCli"
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId vrf-import $removedImportPolicy"] ; log_msg INFO "$rCli"
                  log_msg INFO "actualRedirectVprnId $actualRedirectVprnId unchanged during $action"
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "removeRouteTargetFromActualRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId $actualRedirectVprnId
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId no vrf-target "] ; log_msg INFO "$rCli"
                  incr actualRedirectVprnId
                  log_msg INFO "actualRedirectVprnId goes from $thisRedirectVprnId to $actualRedirectVprnId because of $action"
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }
            
            "restoreRouteTargetFrompreviousRedirectVprn" {
              foreach {dut thisDutId ngbrDut ngbrDutId itfToNgbr} $redirectVprnDutList {
                if {$dut == $dut2} {
                  # do this only in dut2
                  set thisRedirectVprnId [expr $actualRedirectVprnId - 1]
                  set rCli [$dut sendCliCommand "configure service vprn $thisRedirectVprnId vrf-target target:[set ngbrDutId][set thisDutId]:1"] ; log_msg INFO "$rCli"
                  log_msg INFO "actualRedirectVprnId goes from $actualRedirectVprnId to $thisRedirectVprnId because of $action"
                  decr actualRedirectVprnId
                }
              }
              log_msg INFO "Waiting 30secs..." ; after 30000
            }

          } ; # action
          
          # And here the expected behavior
          switch $expectedBehavior {
            "none" {
              # nothing expected
            }
            
            "defaultBehavior" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => Check traffic goes through $dut4 (redirected) and $dut6 (redirected with 2nd lookup to Base ... if \"grt-lookup enable-grt\" is configured)"
              log_msg INFO "$mySubtest"
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id21468 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              ###
              if {! [testFailed] && $Result == "OK"} {
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                if {$option(sendTraffic_v4)} {
                  set rCli [$dut1 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                if {$option(sendTraffic_v6)} {
                  set rCli [$dut1 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                log_msg INFO "Wait 5secs and display egress counters in $dut4 and $dut6 before traffic starts" ; after 5000
                if {$option(sendTraffic_v4)} {
                  log_msg INFO "$dut4: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                  log_msg INFO "$dut6: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                }
                if {$option(sendTraffic_v6)} {
                  log_msg INFO "$dut4: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                  log_msg INFO "$dut6: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                }
                #
                handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                log_msg INFO "Traffic started, waiting 20secs and check that all traffic is redirected" ; after 20000
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                #
                if {$option(sendTraffic_v4)} {
                  set ingressTrafficList_[set dut1]_v4 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv4 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v4 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v4 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count] 
                  if {$grtLookupEnableGrt} {
                    if {[set ingressTrafficList_[set dut1]_v4] == [expr [set egressTrafficList_[set dut4]_v4] + [set egressTrafficList_[set dut6]_v4]]  && [set egressTrafficList_[set dut4]_v4] != 0 && [set egressTrafficList_[set dut6]_v4] != 0} {
                      log_msg INFO "Traffic (IPv4) goes like expected: partial redirected to $dut4, partial to $dut6 (redirect 1st lookup fails, but 2nd lookup in GRT is ok)"
                      log_msg INFO "  => ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] == egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] + egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4]"
                    } else {
                      log_msg DEBUG "Traffic (IPv4) doesn't goes like expected => restart traffic for debugging ..."
                      handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                      log_msg ERROR "id21021 Traffic (IPv4) doesn't goes like expected: partial redirected to $dut4, partial to $dut6 (ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] <> egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] + egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4])" 
                      set Result FAIL ; break
                    }
                  } else {
                    #  Traffic loss expected in dut6, because the 2nd lookup in the GRT fails (\"grt-lookup enable-grt\" not configured)
                    if {[set ingressTrafficList_[set dut1]_v4] != 0 && [set egressTrafficList_[set dut4]_v4] != 0 && [set egressTrafficList_[set dut6]_v4] == 0} {
                      log_msg INFO "Traffic (IPv4) goes like expected: partial redirected to $dut4, NO partial to $dut6 (redirect 1st lookup fails, and 2nd lookup in GRT is nok because \"grt-lookup enable-grt\" not configured)"
                      log_msg INFO "  => ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] ; egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] ; egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4]"
                    } else {
                      log_msg DEBUG "Traffic (IPv4) doesn't goes like expected => restart traffic for debugging ..."
                      handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                      log_msg ERROR "id11692 Traffic (IPv4) doesn't goes like expected: partial redirected to $dut4, NO partial to $dut6 (redirect 1st lookup fails, and 2nd lookup in GRT is nok because \"grt-lookup enable-grt\" not configured) (ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] ; egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] ; egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4])" 
                      set Result FAIL ; break
                    }
                  }
                }
                if {$option(sendTraffic_v6)} {
                  set ingressTrafficList_[set dut1]_v6 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv6 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v6 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v6 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  if {$grtLookupEnableGrt} {
                    if {[set ingressTrafficList_[set dut1]_v6] == [expr [set egressTrafficList_[set dut4]_v6] + [set egressTrafficList_[set dut6]_v6]] && [set egressTrafficList_[set dut4]_v6] != 0 && [set egressTrafficList_[set dut6]_v6] != 0} {
                      log_msg INFO "Traffic (IPv6) goes like expected: partial redirected to $dut4, partial to $dut6 (redirect 1st lookup fails, but 2nd lookup in GRT is ok)"
                      log_msg INFO "  => ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] == egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] + egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6]"
                    } else {
                      log_msg DEBUG "Traffic (IPv6) doesn't goes like expected => restart traffic for debugging ..."
                      handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                      log_msg ERROR "id4393 Traffic (IPv6) doesn't goes like expected: partial redirected to $dut4, partial to $dut6 (ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] <> egressTrafficList_[set dut4]_v6: [set set egressTrafficList_[set dut4]_v6] + egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6])" 
                      set Result FAIL ; break
                    }
                  } else {
                    #  Traffic loss expected in dut6, because the 2nd lookup in the GRT fails (\"grt-lookup enable-grt\" not configured)
                    if {[set ingressTrafficList_[set dut1]_v6] != 0 && [set egressTrafficList_[set dut4]_v6] != 0 && [set egressTrafficList_[set dut6]_v6] == 0} {
                      log_msg INFO "Traffic (IPv6) goes like expected: partial redirected to $dut4, NO partial to $dut6 (redirect 1st lookup fails, and 2nd lookup in GRT is nok because \"grt-lookup enable-grt\" not configured)"
                      log_msg INFO "  => ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] ; egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] ; egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6]"
                    } else {
                      log_msg DEBUG "Traffic (IPv6) doesn't goes like expected => restart traffic for debugging ..."
                      handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                      log_msg ERROR "id28019 Traffic (IPv6) doesn't goes like expected: partial redirected to $dut4, NO partial to $dut6 (redirect 1st lookup fails, and 2nd lookup in GRT is nok because \"grt-lookup enable-grt\" not configured) (ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] ; egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] ; egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6])" 
                      set Result FAIL ; break
                    }
                  }
                }
                #
                subtest "$mySubtest"
              }
              ###
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter for \"Ing. Matches\" - \"Dest. IP\" - \"Fwd Rtr\""
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1 
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                    } else {
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                    }
                    incr vprnCnt
                    
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        log_msg INFO "getIpFlowspecFilter for thisVprnId: $thisVprnId ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false]} {
                          log_msg ERROR "id591 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                    if {[testFailed] || $Result == "FAIL"} {break}
                    incr c ; if {$c > 255} {set c 0 ; incr b}
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b and c because they point to the next values to be used
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        set thisFilterId "fSpec-0"
                        log_msg INFO "getIpFlowspecFilter for Base ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -showFilter false]} {
                          log_msg ERROR "id28480 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                  }
                  #
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                subtest "$mySubtest"
              }
              ###
              if {! [testFailed] && $Result == "OK"} {
                if {$mirrorRedirectVrf} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut4: mirror port $portA($dut4.$dut2) to analyse redirectVrf traffic (mirrorId: $mirrorId ; mirrorSap: $portA($dut4.$dut5):$mirrorVlanId)"
                log_msg INFO "$mySubtest"
                log_msg INFO "Ixia port: $portA(Ixia.$dut3): Stop capture/Start traffic/Start capture/Stop traffic (after 5secs)/Stop capture/Analyse capture"
                handlePacket -port $portA(Ixia.$dut1) -action start ; after 500
                handlePacket -port $portA(Ixia.$dut3) -action capturestop ; after 500
                handlePacket -port $portA(Ixia.$dut2) -action capture ; after 500
                #
                log_msg INFO "Traffic started, waiting 5secs and check mirrored traffic" ; after 5000
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 500
                #
                handlePacket -port $portA(Ixia.$dut3) -action capturestop ; after 500
                set thisCaptureBuf [handlePacket -port $portA(Ixia.$dut3) -action view -maxCaptureFrames 1000]
                set fCnt 1 ; set nbrMplsHashLabelsFound 0
                foreach capturedFrame $thisCaptureBuf {
                  # First look for mirrored pkts only.  They should have the mirrorVlanId as 802.1Q tag (81 00 00 7B).
                  set dot1qTag_hex "81 00 00 [format %02X $mirrorVlanId]"
                  set dot1qTag_offset [string first $dot1qTag_hex $capturedFrame]
                  if {$dot1qTag_offset != -1} {
                    log_msg INFO "Found frame ($fCnt) with mirrorVlanId ($mirrorVlanId => \"$dot1qTag_hex\")"
                    set streamData_offset [string first $streamData_ISATMS $capturedFrame]
                    if {$streamData_offset != -1} {
                      log_msg INFO "  => and this frame has pattern \"$streamData_ISATMS\" at offset $streamData_offset"
                      set mplsLabelSwitchedPacket_offset [string first "88 47" $capturedFrame]
                      # Search for "88 47" => MPLS Label switched packet.
                      if {$mplsLabelSwitchedPacket_offset != -1} {
                        log_msg INFO "    => and this is a \"MPLS Label switched packet\" (label \"88 47\" at offset $mplsLabelSwitchedPacket_offset)"
                        log_msg INFO "$capturedFrame"
                        # Go through all labels till label with "Bottom Of Label Stack" flag 1 is found.
                        # MPLS Label looks like this (4 bytes).  See RFC3032.
                        #  0                                  1                                2                                  3
                        #  0  1  2  3 4  5  6  7 8  9  0 1  2  3  4  5 6  7 8  9  0  1 2  3  4  5  6 7  8  9  0 1
                        #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ Label
                        #|                Label                                              | Exp   |S|           TTL           | Stack
                        #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ Entry
                        #
                        #                    Label:  Label Value, 20 bits
                        #                    Exp:    Experimental Use, 3 bits
                        #                    S:      Bottom of Stack, 1 bit
                        #                    TTL:    Time to Live, 8 bits
                        # see proc getMplsLabelValuesPkt in gash/library/packetModify.tcl
                        #
                        set labelValueList "" ; set bottomOfStackFound false ; set nextLabelOffset 0 ; set labelCnt 0
                        while {! $bottomOfStackFound} {
                          # 88 47 3F FF F0 FF 3F FF B0 FD AE 4C 11 00
                          set labelBegin [expr $mplsLabelSwitchedPacket_offset + 6 + $nextLabelOffset]
                          set labelEnd [expr $labelBegin + (4 * 3) - 2] ; # 4 bytes taking 3 positions
                          set thisLabelHexTmp [string range $capturedFrame $labelBegin $labelEnd]
                          foreach {thisLabelHexTmp_1 thisLabelHexTmp_2 thisLabelHexTmp_3 thisLabelHexTmp_4} [split $thisLabelHexTmp " "] {break}
                          set thisLabelHex [set thisLabelHexTmp_1][set thisLabelHexTmp_2][set thisLabelHexTmp_3][set thisLabelHexTmp_4]
                          set thisLabelDec [hex_to_dec $thisLabelHex]
                          set labelValue [expr 0x$thisLabelHex & 0xFFFFF000] ; set labelValue [expr $labelValue >> 12] ; # shift to right 12bits
                          lappend labelValueList $labelValue
                          set labelExp [expr 0x$thisLabelHex & 0x00000E00] ; set labelExp [expr $labelExp >> 9] ; # shift to right 9bits
                          set labelBottomOfStack [expr 0x$thisLabelHex & 0x00000100] ; set labelBottomOfStack [expr $labelBottomOfStack >> 8] ; # shift to right 8bits
                          if {$labelBottomOfStack == 1} {set bottomOfStackFound true}
                          set labelTTL [expr $thisLabelDec & 0x000000FF]
                          log_msg INFO "      => found label 0x[set thisLabelHex] => labelValue: $labelValue ; labelExp: $labelExp ; labelBottomOfStack: $labelBottomOfStack ; labelTTL: $labelTTL"
                          incr labelCnt
                          if {$labelCnt > 10} {
                            log_msg ERROR "id24944 Too many (do you know \"Too Many DJ's\"?) labels found ... there is something wrong" ; set Result FAIL ; break
                          } else {
                            set nextLabelOffset [expr (4 * 3) * $labelCnt] ; # 4 bytes taking 3 positions
                          }
                        }
                        #
                        if {! [testFailed] && $Result == "OK"} {
                          log_msg INFO "    => so this \"MPLS Label switched packet\" contains following label values \"$labelValueList\" ... check if it contain a hash-label"
                          set foundMplsHashLabel false
                          # Normally the last label has the hash-label, so start searching from the last label
                          for {set labelValueIdx [expr [llength $labelValueList] - 1]} {$labelValueIdx >= 0} {decr labelValueIdx} {
                            set mplsHashLabel [lindex $labelValueList $labelValueIdx]
                            if {$mplsHashLabel >= $mplsHashLabel_min && $mplsHashLabel <= $mplsHashLabel_max} {
                              log_msg INFO "Successful validated this \"MPLS hash-label\" $mplsHashLabel ($mplsHashLabel_min <= $mplsHashLabel <= $mplsHashLabel_max)"
                              set foundMplsHashLabel true ; incr nbrMplsHashLabelsFound ; break
                            }
                          }
                          if {! $foundMplsHashLabel} {
                            log_msg ERROR "id10597 Not successful validated this \"MPLS hash-label\".  Couldn't find a hash-label in \"$labelValueList\" which is in the range $mplsHashLabel_min till $mplsHashLabel_max"
                            set Result FAIL ; break
                          }
                        }
                      }
                    }
                  }
                  incr fCnt
                  if {$nbrMplsHashLabelsFound > $minNbrMplsHashLabelsExp} {
                    log_msg INFO "Found enough (> $minNbrMplsHashLabelsExp) MPLS hash labels \"Trop is te veel en te veel is trop\""
                    break
                  }
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                #
                subtest "$mySubtest"
                }
              }
              ###
              # defaultBehavior
            } 
            
            "noFilterEntriesExpInVprn" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: No filter entries expected in the vprn"
              log_msg INFO "$mySubtest"
              if {$sendBgpFlowrouteUpd_v4} {
                if {[flowspec_filterHasNoMatchCriteria $dut2 $igIpv4FltrIdActiveBeforeShut -family ipv4]} {
                  log_msg INFO "$dut2: Filter $igIpv4FltrIdActiveBeforeShut has no match criteria (expected behavior)"
                } else {
                  log_msg ERROR "id22429 $dut2: Filter $igIpv4FltrIdActiveBeforeShut has unexpected match criteria" ; set Result FAIL ; break
                }
              }
              if {$sendBgpFlowrouteUpd_v6} {
                if {[flowspec_filterHasNoMatchCriteria $dut2 $igIpv6FltrIdActiveBeforeShut -family ipv6]} {
                  log_msg INFO "Filter $igIpv4FltrIdActiveBeforeShut has no match criteria (expected behavior)"
                } else {
                  log_msg ERROR "id6307 Filter $igIpv4FltrIdActiveBeforeShut has unexpected match criteria" ; set Result FAIL ; break
                }
              }
              subtest "$mySubtest"
            }
            
            "noIpv4v6FilterEntriesExpInDut" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: No filter entries expected in the dut"
              log_msg INFO "$mySubtest"
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: No flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id28736 $dut2: Still flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              if {! [testFailed] && $Result == "OK"} {
                if {[flowspec_getNoIpFlowspecFilterEntries $dut2 -family ipv4] && \
                      [flowspec_getNoIpFlowspecFilterEntries $dut2 -family ipv6]} {
                  log_msg INFO "$dut2: No unexpected filter entries found"
                } else {
                  log_msg ERROR "id19023 $dut2: Unexpected filter entries found" ; set Result FAIL ; break
                }
              }
              subtest "$mySubtest"
            }
            
            "negTest_fSpecAndUsrDefFilterOnItfInDiffVprns" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" "
              log_msg INFO "$mySubtest"
              log_msg INFO ""
              log_msg INFO "This is a negative test to cover following restriction (copied from PRD):"
              log_msg INFO "  IPv4 flow-spec cannot be enabled on a \"vprn sap\" or \"spoke sdp\"  itf if"
              log_msg INFO "  a user-defined IPv4 filter policy has been applied to the ingress context of the"
              log_msg INFO "  interface and that same user-defined IPv4 filter policy has also been applied to itfs"
              log_msg INFO "  to other vprn's.  The same applies for IPv6 flow-spec."
              log_msg INFO ""
              foreach thisFamily $thisFilterFamilyList {
                set vprnCnt 1
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  switch $thisFamily {
                    "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                    "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                  }
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    # this is a vprn with a user-defined filter on it
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    # this is a vprn with a user-defined filter on it"
                  } else {
                    if {$itfType_dut1dut2 == "spoke"} {
                      set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                    } else {
                      set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                    }
                    set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                    if {[regexp -- $pat $rCli match]} {
                      log_msg INFO "Found \"$pat\""
                    } else {
                      log_msg ERROR "id10284 Couldn't find \"$pat\"" ; set Result FAIL ; break
                    }
                  }
                  incr vprnCnt
                } ; # vprnIdList

              } ; # thisFilterFamilyList
              
              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Remove now the flowspec/flowspec-ipv6 from the interface and check that the user-defined filter could be applied now"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress no $fSpecTxt"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress no $fSpecTxt"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                      }
                      set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg ERROR "id17737 Found \"$pat\"" ; set Result FAIL ; break
                      } else {
                        log_msg INFO "Couldn't find (expected behavior) \"$pat\""
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }

              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Enable now the flowspec/flowspec-ipv6 again on the interface and check that this is rejected"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      }
                      set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg INFO "Found \"$pat\""
                      } else {
                        log_msg ERROR "id13190 Couldn't find \"$pat\"" ; set Result FAIL ; break
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }
              
              if {! [testFailed] && $Result == "OK"} {
                log_msg INFO "Remove now ip/ipv6 filter from the interface and enable flowspec/flowspec-ipv6 again"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    switch $thisFamily {
                      "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                      "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                    }
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      # this is a vprn with a user-defined filter on it"
                    } else {
                      if {$itfType_dut1dut2 == "spoke"} {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress no filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] spoke-sdp $dataip(sap.$thisVprnId.$dut2.$dataip(id.$dut1)) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      } else {
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress no filter $fTxt $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId"] ; log_msg INFO $rCli
                        set rCli [$dut2 sendCliCommand "configure service vprn $thisVprnId interface to_[set dut1][set thisVprnId] sap $dataip(sap.$thisVprnId.$dut2.$dut1) ingress $fSpecTxt"] ; log_msg INFO $rCli
                      }
                      # set pat ".*Feature not supported on this SAP - a [set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                       set pat ".*[set patFlowspecCannotBeEnabled_[set itfType_dut1dut2]].*"
                      if {[regexp -- $pat $rCli match]} {
                        log_msg ERROR "id29769 Found \"$pat\"" ; set Result FAIL ; break
                      } else {
                        log_msg INFO "Couldn't find (expected behavior) \"$pat\""
                      }
                    }
                    incr vprnCnt
                  } ; # vprnIdList
                } ; # thisFilterFamilyList
              }
              
              subtest "$mySubtest"
            }
            
            "zeroIngMatchesExpInDut" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: All filter entries should have \"Ing. Matches\" with 0 pkts & bytes"
              log_msg INFO "$mySubtest"
              foreach thisFamily $thisFilterFamilyList {
                switch $thisFamily {
                  "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
                  "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
                }
                set vprnCnt 1 
                set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                  if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                  } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                    set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                  } else {
                    set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                  }
                  incr vprnCnt

                  if {[flowspec_zeroCountersInFilterId $dut2 $thisFilterId]} {
                    log_msg INFO "$dut2: Found zeroCounters in filterId: $thisFilterId"
                  } else {
                    log_msg ERROR "id25174 $dut2: Found unexpected non zeroCounters in filterId: $thisFilterId" ; set Result FAIL ; break
                  }
                  incr c ; if {$c > 255} {set c 0 ; incr b}
                }
                #
                if {$addFlowroutesInBase} {
                  set thisFilterId "fSpec-0"
                  if {[flowspec_zeroCountersInFilterId $dut2 $thisFilterId]} {
                    log_msg INFO "$dut2: Found zeroCounters in filterId: $thisFilterId"
                  } else {
                    log_msg ERROR "id30337 $dut2: Found unexpected non zeroCounters in filterId: $thisFilterId" ; set Result FAIL ; break
                  }
                }
                #
              } ; #thisFilterFamilyList 
              subtest "$mySubtest"
            }
            
            "noRedirectToVrfTraffic_allTrafficViaGrtLeaking" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => Check traffic doesn't go through $dut4 (redirected).  Instead all traffic should go through $dut6 (redirected with 2nd lookup to Base)"
              log_msg INFO "$mySubtest"
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id842 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
             
              if {! [testFailed] && $Result == "OK"} {
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                if {$option(sendTraffic_v4)} {
                  set rCli [$dut1 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                if {$option(sendTraffic_v6)} {
                  set rCli [$dut1 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                log_msg INFO "Wait 5secs and display egress counters in $dut4 and $dut6 before traffic starts" ; after 5000
                if {$option(sendTraffic_v4)} {
                  log_msg INFO "$dut4: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                  log_msg INFO "$dut6: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                }
                if {$option(sendTraffic_v6)} {
                  log_msg INFO "$dut4: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                  log_msg INFO "$dut6: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                }
                #
                handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                log_msg INFO "Traffic started, waiting 20secs and check that all traffic is redirected" ; after 20000
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                #
                if {$option(sendTraffic_v4)} {
                  set ingressTrafficList_[set dut1]_v4 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv4 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v4 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v4 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v4] == [set egressTrafficList_[set dut6]_v4] && [set egressTrafficList_[set dut4]_v4] == 0} {
                    log_msg INFO "Traffic (IPv4) goes like expected: nothing redirected to $dut4, all to $dut6 (redirect 1st lookup fails, but 2nd lookup in GRT is ok)"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] == egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] and egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] == 0"
                  } else {
                    log_msg DEBUG "Traffic (IPv4) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id7387 Traffic (IPv4) doesn't goes like expected: nothing redirected to $dut4, all to $dut6 (ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] <> egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] and egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                if {$option(sendTraffic_v6)} {
                  set ingressTrafficList_[set dut1]_v6 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv6 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v6 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v6 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v6] == [set egressTrafficList_[set dut6]_v6] && [set egressTrafficList_[set dut4]_v6] == 0} {
                    log_msg INFO "Traffic (IPv6) goes like expected: nothing redirected to $dut4, all to $dut6 (redirect 1st lookup fails, but 2nd lookup in GRT is ok)"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] == egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] and egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] == 0"
                  } else {
                    log_msg DEBUG "Traffic (IPv6) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id455 Traffic (IPv6) doesn't goes like expected: nothing redirected to $dut4, all to $dut6 (ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] <> egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] and egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                #
                subtest "$mySubtest"
              }
              
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter for \"Ing. Matches\" - \"Dest. IP\" - \"Fwd Rtr\""
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1 
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                    } else {
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                    }
                    incr vprnCnt
                    
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        log_msg INFO "getIpFlowspecFilter for thisVprnId: $thisVprnId ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false]} {
                          log_msg ERROR "id22519 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                    if {[testFailed] || $Result == "FAIL"} {break}
                    incr c ; if {$c > 255} {set c 0 ; incr b}
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b and c because they point to the next values to be used
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        set thisFilterId "fSpec-0"
                        log_msg INFO "getIpFlowspecFilter for Base ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -showFilter false]} {
                          log_msg ERROR "id1417 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                  }
                  #
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                subtest "$mySubtest"
              }
            }

            "noRedirectToVrfTraffic_noTrafficViaGrtLeaking" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => Check traffic doesn't go through $dut4 (redirected) and not through $dut6 (redirected with 2nd lookup to Base) ... typical because the redirect vprn is shut"
              log_msg INFO "$mySubtest"
              set nbrInstalledExp 0
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id14911 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
             
              if {! [testFailed] && $Result == "OK"} {
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                if {$option(sendTraffic_v4)} {
                  set rCli [$dut1 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                if {$option(sendTraffic_v6)} {
                  set rCli [$dut1 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                log_msg INFO "Wait 5secs and display egress counters in $dut4 and $dut6 before traffic starts" ; after 5000
                if {$option(sendTraffic_v4)} {
                  log_msg INFO "$dut4: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                  log_msg INFO "$dut6: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                }
                if {$option(sendTraffic_v6)} {
                  log_msg INFO "$dut4: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                  log_msg INFO "$dut6: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                }
                #
                handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                log_msg INFO "Traffic started, waiting 20secs and check that all traffic is redirected" ; after 20000
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                #
                if {$option(sendTraffic_v4)} {
                  set ingressTrafficList_[set dut1]_v4 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv4 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v4 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v4 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v4] != 0 && [set egressTrafficList_[set dut6]_v4] == 0 && [set egressTrafficList_[set dut4]_v4] == 0} {
                    log_msg INFO "Traffic (IPv4) goes like expected: nothing redirected to $dut4, noting to $dut6"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] ; egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] ; egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4]"
                  } else {
                    log_msg DEBUG "Traffic (IPv4) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id16309 Traffic (IPv4) doesn't goes like expected: nothing redirected to $dut4, nothing to $dut6 (ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] ; egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] (exp=0) ; egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                if {$option(sendTraffic_v6)} {
                  set ingressTrafficList_[set dut1]_v6 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv6 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v6 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v6 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v6] != 0 && [set egressTrafficList_[set dut6]_v6] == 0 && [set egressTrafficList_[set dut4]_v6] == 0} {
                    log_msg INFO "Traffic (IPv6) goes like expected: nothing redirected to $dut4, nothing to $dut6"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] ; egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] ; egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6]"
                  } else {
                    log_msg DEBUG "Traffic (IPv6) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id31046 Traffic (IPv6) doesn't goes like expected: nothing redirected to $dut4, nothing to $dut6 (ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] ; egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] (exp=0) ; egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                #
                subtest "$mySubtest"
              }
              
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter for \"Ing. Matches\" - \"Dest. IP\" - \"Fwd Rtr\""
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1 
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                    } else {
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                    }
                    incr vprnCnt
                    
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        log_msg INFO "getIpFlowspecFilter for thisVprnId: $thisVprnId ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false]} {
                          log_msg ERROR "id27148 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                    if {[testFailed] || $Result == "FAIL"} {break}
                    incr c ; if {$c > 255} {set c 0 ; incr b}
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b and c because they point to the next values to be used
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        set thisFilterId "fSpec-0"
                        log_msg INFO "getIpFlowspecFilter for Base ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -showFilter false]} {
                          log_msg ERROR "id32611 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                  }
                  #
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                subtest "$mySubtest"
              }
            }
            
            "allTrafficViaRedirectToVrf_noTrafficViaGrtLeaking" {
              set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => Check traffic doesn't go through $dut6 (redirected with 2nd lookup to Base).  Instead all traffic should go through $dut4 (redirected)."
              log_msg INFO "$mySubtest"
              set nbrInstalledExp $totalNbrOfFlowroutes
              if {[flowspec_waitTillFlowroutesInstalledInBgpNlriBuf $dut2 $nbrInstalledExp]} {
                log_msg INFO "$dut2: All flowroutes installed in bgpNlriBuf"
              } else {
                log_msg ERROR "id1675 $dut2: Not all flowroutes installed in bgpNlriBuf" ; set Result FAIL 
              }
              #
             
              if {! [testFailed] && $Result == "OK"} {
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                if {$option(sendTraffic_v4)} {
                  set rCli [$dut1 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ip $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                if {$option(sendTraffic_v6)} {
                  set rCli [$dut1 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut6 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                  set rCli [$dut4 sendCliCommand "clear filter ipv6 $cntPktsViaFilter_filterId"] ; log_msg INFO "$rCli"
                }
                log_msg INFO "Wait 5secs and display egress counters in $dut4 and $dut6 before traffic starts" ; after 5000
                if {$option(sendTraffic_v4)} {
                  log_msg INFO "$dut4: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                  log_msg INFO "$dut6: IPv4 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count
                }
                if {$option(sendTraffic_v6)} {
                  log_msg INFO "$dut4: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                  log_msg INFO "$dut6: IPv6 egress vvvvv"
                  getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv6 dir egress] -return count
                }
                #
                handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                log_msg INFO "Traffic started, waiting 20secs and check that all traffic is redirected" ; after 20000
                handlePacket -port $portA(Ixia.$dut1) -action stop ; after 2000
                #
                if {$option(sendTraffic_v4)} {
                  set ingressTrafficList_[set dut1]_v4 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv4 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v4 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v4 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v4] == [set egressTrafficList_[set dut4]_v4] && [set egressTrafficList_[set dut6]_v4] == 0} {
                    log_msg INFO "Traffic (IPv4) goes like expected: all traffic to $dut4, no traffic to $dut6"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] == egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut6]_v4] and egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] == 0"
                  } else {
                    log_msg DEBUG "Traffic (IPv4) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id1921 Traffic (IPv4) doesn't goes like expected: all traffic to $dut4, no traffic to $dut6 (ingressTrafficList_[set dut1]_v4: [set ingressTrafficList_[set dut1]_v4] <> egressTrafficList_[set dut4]_v4: [set egressTrafficList_[set dut4]_v4] and egressTrafficList_[set dut6]_v4: [set egressTrafficList_[set dut6]_v4] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                if {$option(sendTraffic_v6)} {
                  set ingressTrafficList_[set dut1]_v6 [getFilter -print true -dut $dut1 -match [list id $cntPktsViaFilter_filterId version ipv4 dir ingress] -return count]
                  set egressTrafficList_[set dut4]_v6 [getFilter -print true -dut $dut4 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  set egressTrafficList_[set dut6]_v6 [getFilter -print true -dut $dut6 -match [list id $cntPktsViaFilter_filterId version ipv4 dir egress] -return count]
                  if {[set ingressTrafficList_[set dut1]_v6] == [set egressTrafficList_[set dut4]_v6] && [set egressTrafficList_[set dut6]_v6] == 0} {
                    log_msg INFO "Traffic (IPv6) goes like expected: all traffic to $dut4, no traffic to $dut6"
                    log_msg INFO "  => ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] == egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut6]_v6] and egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] == 0"
                  } else {
                    log_msg DEBUG "Traffic (IPv6) doesn't goes like expected => restart traffic for debugging ..."
                    handlePacket -port $portA(Ixia.$dut1) -action start ; after 2000
                    log_msg ERROR "id11881 Traffic (IPv6) doesn't goes like expected: all traffic to $dut4, no traffic to $dut6 (ingressTrafficList_[set dut1]_v6: [set ingressTrafficList_[set dut1]_v6] <> egressTrafficList_[set dut4]_v6: [set egressTrafficList_[set dut4]_v6] and egressTrafficList_[set dut6]_v6: [set egressTrafficList_[set dut6]_v6] (exp=0))" 
                    set Result FAIL ; break
                  }
                }
                #
                subtest "$mySubtest"
              }
              
              if {! [testFailed] && $Result == "OK"} {
                set mySubtest "action: \"$action\" expectedBehavior: \"$expectedBehavior\" => $dut2: Check filter for \"Ing. Matches\" - \"Dest. IP\" - \"Fwd Rtr\""
                log_msg INFO "$mySubtest"
                foreach thisFamily $thisFilterFamilyList {
                  set vprnCnt 1 
                  set b 1 ; set c [lindex $vprnIdOnlyList 0] 
                  foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                    if {$vprnCnt == 1 && $addDefFilterInFirstVprnBeforeFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInFirstVprnBeforeFlowroutesAreInjected_filterId
                    } elseif {$vprnCnt == $nbrVprns && $addDefFilterInLastVprnAfterFlowroutesAreInjected} {
                      set thisFilterId $addDefFilterInLastVprnAfterFlowroutesAreInjected_filterId
                    } else {
                      set thisFilterId [flowspec_getfSpecFilterId $dut2 $thisVprnId -family $thisFamily]
                    }
                    incr vprnCnt
                    
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        log_msg INFO "getIpFlowspecFilter for thisVprnId: $thisVprnId ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -svcId $thisVprnId -showFilter false]} {
                          log_msg ERROR "id3729 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                    if {[testFailed] || $Result == "FAIL"} {break}
                    incr c ; if {$c > 255} {set c 0 ; incr b}
                  }
                  #
                  if {$addFlowroutesInBase} {
                    # - Don't reset b and c because they point to the next values to be used
                    foreach thisAction $thisActionListPerVprn {
                      set a [set a_[set thisAction]]
                      set d 0
                      for {set flowroutePerVprnCnt 1} {$flowroutePerVprnCnt <= $thisNbrFlowroutesPerVprn} {incr flowroutePerVprnCnt} {
                        set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                        switch $thisFamily {
                          "ipv4" {set findDestPrefixMsk $thisDstPrefixMask_v4}
                          "ipv6" {set findDestPrefixMsk $thisDstPrefixMask_v6}
                        }
                        if {$thisAction == "redirectVrf"} {set findFwdRtr $actualRedirectVprnId} else {set findFwdRtr ""}
                        set thisFilterId "fSpec-0"
                        log_msg INFO "getIpFlowspecFilter for Base ; thisFilterId: $thisFilterId"
                        if {! [flowspec_getIpFlowspecFilter $dut2 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -findFwdRtr $findFwdRtr -showFilter false]} {
                          log_msg ERROR "id12237 $dut2: Filter not found" ; set Result FAIL ; break
                        }
                        incr d
                      }
                    }
                  }
                  #
                  if {[testFailed] || $Result == "FAIL"} {break}
                }
                subtest "$mySubtest"
              }
            }
            
          }; # expectedBehavior

          if {[testFailed] || $Result == "FAIL"} {break}
        }
        if {[testFailed] || $Result == "FAIL"} {break}
        #
        # Check if a new iteration should start
        switch $iterationMethod {
          "maxNbrIterations" {
            if {$iterationCnt == $maxNbrIterations} {set whileContinue 0}
          }
          "maxDuration" {
            set stopTimeStampSec [clock seconds]
            set deltaTimeHrs [exec echo "($stopTimeStampSec  - $startTimeStampSec) / 3600"  | bc]
            if {$deltaTimeHrs >= $maxDurationHrs } {set whileContinue 0}
          }
          "ifFileExists" {
            if {! [file exists $option(fileExistsName)]} {set whileContinue 0}
          }
        }
        #
      }

    }

    
  }
  
  if {$option(deconfig)} {
    saveOrRestore delete
    sbgp.closeall
  } 
  
  testcaseTrailer
  $dut2 configure -cli_timeout $cliTimeoutOrig
  if {$dutLoggingDisabled} {
    log_msg WARNING "Logging in dut-logs was disabled, enable it again"
    foreach dut $dutList {
      $dut configure -logging logging
    }
  }
}
#
proc flowspec.reproduceCenturyLink { args } { 
  global masterlog testdir ixia_port
  global portA dataip
    
  source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
  source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
  set option(config) true
  set option(test) true
  set option(deconfig) true
  set option(debug) false
  
  set option(dumpDebugLog) true
  set option(nbrVprns) 1
  set option(sendNotSupportedWithdraw) false
  set option(RR) true
  set option(wrongAsWithoutDstPfx) false
  set option(stopSbgp) false
  set option(killSbgp) false
  set option(invalidAsPath) true
  
  getopt option      $args
  
  set testID $::TestDB::currentTestCase
  set Result OK
  
  testcaseHeader
  
  ##### Testcase GGV paramerters (begin)
  if {[GGV fspecNbrVprns] != "ERROR"} {
    set nbrVprns [GGV fspecNbrVprns]
  } else {
    set nbrVprns $option(nbrVprns)
  }
  if {[GGV fspecSendNotSupportedWithdraw] != "ERROR"} {
    set sendNotSupportedWithdraw [GGV fspecSendNotSupportedWithdraw]
  } else {
    set sendNotSupportedWithdraw $option(sendNotSupportedWithdraw)
  }
  if {[GGV fspecStopSbgp] != "ERROR"} {
    set stopSbgp [GGV fspecStopSbgp]
  } else {
    set stopSbgp $option(stopSbgp)
  }
  if {[GGV fspecKillSbgp] != "ERROR"} {
    set killSbgp [GGV fspecKillSbgp]
  } else {
    set killSbgp $option(killSbgp)
  }
  if {[GGV fspecRR] != "ERROR"} {
    set RR [GGV fspecRR]
  } else {
    set RR $option(RR)
  }
  ##### Testcase GGV paramerters (end)
  
  set dut1 Dut-A ; set dut2 Dut-B ; set dut3 Dut-C ; set dut4 Dut-D ; set dut5 Dut-E ; set dut6 Dut-F
  set dutList [list $dut1 $dut2 $dut3 $dut4 $dut5 $dut6]
  set bgpDutList_addIpv6Nhop [list $dut1 $dut2 $dut3]
  set ibgp_AS 100 ; set ebgp_AS 200
  set Linux_AS 107 ; set Linux_wrongAS 108
  set dot1qTag 2
  set clusterId 3.3.3.3

  set filterFamilyList [list ipv4 ipv6]
  set filterFamilyTxtList [list ip ipv6]
  set groupName "onegroup"
  
  set vprnIdList "" ; set vprnIdOnlyList ""
  for {set vprnId 1} {$vprnId <= $nbrVprns} {incr vprnId} {
    lappend vprnIdList [expr $minVprnId - 1 + $vprnId] ; lappend vprnIdOnlyList [expr $minVprnId - 1 + $vprnId]
  }
  
  set aV 44 ; set bV 44 ; set cV 44 ; set dV 1

  # Use the next dot1q tag for the Base
  set baseDot1qTag [expr [lindex $vprnIdOnlyList end] + 1]
  
  log_msg INFO "########################################################################"
  log_msg INFO "# Test : $testID"
  log_msg INFO "# Descr : Reproduce CenturyLink filter cleanup issue"
  log_msg INFO "#"
  log_msg INFO "# Setup: "
  log_msg INFO "# "
  log_msg INFO "#                            dut1($dut1)"
  log_msg INFO "#                             |"
  log_msg INFO "#                            dut3($dut3) AS$ibgp_AS RR($RR)"
  log_msg INFO "#                             |Base & #[set nbrVprns]vprns"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                             |"
  log_msg INFO "#                           Linux AS$Linux_AS (sbgp)"
  log_msg INFO "# "
  log_msg INFO "# "
  log_msg INFO "########################################################################"

  if {$option(config) && ! [testFailed] && $Result == "OK"} {
    CLN.reset
    CLN "dut $dut1 systemip [set [set dut1]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    CLN "dut $dut3 systemip [set [set dut3]_ifsystem_ip] isisarea $isisAreaId as $ibgp_AS"
    #
    CLN "dut $dut1 tonode $dut3 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    CLN "dut $dut3 tonode $dut1 porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId bgpneighbor interface4 bgppeeras $ebgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'"
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut1 tonode $dut3 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ebgp_AS bgppeeras $ibgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 tonode $dut1 porttype hybrid dot1q $thisVprnId vprnid $thisVprnId bgpneighbor interface4 as $ibgp_AS bgppeeras $ebgp_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' ospfarea $ospfAreaId ospf3area $ospfAreaId"
    }
    #

    CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router bgp update}"
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut3 logid $debugLog from debug to 'memory 3000' debug {router $thisVprnId bgp update}"
    }
    # Linux
    if {$RR} {
      foreach thisVprnId $vprnIdList {
        CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true bgpneighbor interface4 as $ibgp_AS bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
      }
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true bgpneighbor interface4 bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6' bgpcluster $clusterId" 
    } else {
      foreach thisVprnId $vprnIdList {
        CLN "dut $dut3 link Linux porttype hybrid vprnid $thisVprnId dot1q $thisVprnId ospfarea $ospfAreaId ospf3area $ospfAreaId passive true bgpneighbor interface4 as $ibgp_AS bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
      }
      CLN "dut $dut3 link Linux porttype hybrid dot1q $baseDot1qTag isisarea $isisAreaId passive true bgpneighbor interface4 bgppeeras $Linux_AS bgpfamily 'ipv4 ipv6 flow-ipv4 flow-ipv6'" 
    }
    # Also loopback/system itf in vprn
    foreach thisVprnId $vprnIdList {
      CLN "dut $dut1 vprnid $thisVprnId loopbackip [set [set dut1]_ifsystem_ip] ospfarea $ospfAreaId ospf3area $ospfAreaId"
      CLN "dut $dut3 vprnid $thisVprnId loopbackip [set [set dut3]_ifsystem_ip] ospfarea $ospfAreaId ospf3area $ospfAreaId"
    }
    CLN.exec
    CLN.reset
  }
  
  if {$option(test) && ! [testFailed] && $Result == "OK"} {
    # sbgp Base
    set thisDstPrefix_v4 $dummyNetw ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
    sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs $ibgp_AS \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag
    sbgp.add -id peer$baseDot1qTag -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$baseDot1qTag.Linux.$dut3)]
    sbgp.run -id peer$baseDot1qTag
    # sbgp vprn
    foreach thisVprnId $vprnIdList {
      set thisDstPrefix_v4 $dummyNetw ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
      set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
      sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs $ibgp_AS \
            -capability $sbgpDefCapabilityList \
            -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId
      sbgp.add -id peer$thisVprnId -mpReach "prefix $thisDstPrefixMask_v6" -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
      sbgp.run -id peer$thisVprnId
    }
    #
    if {! [testFailed] && $Result == "OK"} {
      log_msg INFO "Advertise IPv4/IPv6 flowroute in vprn's only"
      set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
      #
      foreach thisVprnId $vprnIdList {
        set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
        set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
        set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
        set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
        set comm1_v4 [createFlowSpecExtCommunityAttr drop]
        set comm1_v6 [createFlowSpecExtCommunityAttr drop]
        set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v4 -community $comm1_v4 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi
        set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
        log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs \"$nlriAs\" -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]"
        sbgp.run -id peer$thisVprnId -mpReachRaw $flow1_v6 -community $comm1_v6 -nlriAs $nlriAs -mpAfi $mpAfi -mpSafi $mpSafi -mpNHop [ipv4ToIpv6 $dataip(ip.$thisVprnId.Linux.$dut3)]
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        log_msg INFO ""; log_msg INFO "Waiting $tBgpPeerGroupMinRouteAdvertisementSecs secs to avoid bgp transient errors" ; log_msg INFO ""
        after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
        #
        foreach thisVprnId $vprnIdList {
          set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
          set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
          foreach thisFamily $filterFamilyList {
            switch $thisFamily {
              "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec" ; set findDestPrefixMsk $thisDstPrefixMask_v4}
              "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6" ; set findDestPrefixMsk $thisDstPrefixMask_v6}
            }
            set thisFilterId [flowspec_getfSpecFilterId $dut3 $thisVprnId -family $thisFamily]
            set rCli [$dut3 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
            if {! [flowspec_getIpFlowspecFilter $dut3 -filterId $thisFilterId -family $thisFamily -findDestPrefixMsk $findDestPrefixMsk -svcId $thisVprnId -showFilter false -expectIngressMatches false]} {
              log_msg ERROR "id14601 $dut3: Expected filter not found" ; set Result FAIL ; break
            } else {
               log_msg INFO "$dut3: Expected filter found"
            }
          }
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        log_msg INFO "Withdraw IPv4/IPv6 flowroute in vprn's only"
        set rCli [$dut3 sendCliCommand "clear log 99"] ; log_msg INFO "$rCli"
        set rCli [$dut3 sendCliCommand "clear log $debugLog"] ; log_msg INFO "$rCli"
        set rCli [$dut3 sendCliCommand "show log event-control bgp"] ; log_msg INFO "$rCli"
        set rCli [$dut3 sendCliCommand "show log event-control filter"] ; log_msg INFO "$rCli"
        if {$stopSbgp} {
          sbgp.closeall
        } elseif {$killSbgp} {
           log_msg WARNING "YOU HAVE NOW 1MIN TO KILL SBGP" ; after 60000
        } else {
          foreach thisVprnId $vprnIdList {
            set thisDstPrefix_v4 $aV.$bV.$cV.$thisVprnId ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
            set thisDstPrefixMask_v4 $thisDstPrefix_v4/$srMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$srMask_v6
            if {$sendNotSupportedWithdraw} {
              log_msg WARNING "Send not supported withdraw (with dstPort=25 only, without protocol)"
              set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4 -dstPort 25]
              set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6 -dstPort 25]
            } else {
              set flow1_v4 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v4]
              set flow1_v6 [createFlowSpecNLRIType -dstPrefix $thisDstPrefixMask_v6]
            }
            set mpAfi "ipv4" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
            log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base"
            sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v4 -mpAfi $mpAfi -mpSafi flow-base
            #
            set mpAfi "ipv6" ; set mpSafi "flow-base" ; set nlriAs "$Linux_AS 65001 65002"
            log_msg INFO " =>sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base"
            sbgp.run -id peer$thisVprnId -mpUnReachRaw $flow1_v6 -mpAfi $mpAfi -mpSafi flow-base
          }
        }
      }
      #
      if {! [testFailed] && $Result == "OK"} {
        log_msg INFO ""; log_msg INFO "Waiting $tBgpPeerGroupMinRouteAdvertisementSecs secs to avoid bgp transient errors" ; log_msg INFO "";
        after [expr $tBgpPeerGroupMinRouteAdvertisementSecs * 1000]
        if {[flowspec_getNoIpFlowspecFilterEntries $dut3 -family ipv4] && \
          [flowspec_getNoIpFlowspecFilterEntries $dut3 -family ipv6]} {
          log_msg INFO "$dut3: No unexpected filter entries found"
        } else {
          log_msg ERROR "id19373 $dut3: Unexpected filter entries found" ; set Result FAIL
          set rCli [$dut3 sendCliCommand "show log event-control bgp"] ; log_msg DEBUG "$rCli"
          set rCli [$dut3 sendCliCommand "show log event-control filter"] ; log_msg DEBUG "$rCli"
        }
        #
        foreach thisVprnId $vprnIdList {
          foreach thisFamily $filterFamilyList {
            switch $thisFamily {
              "ipv4" {set fTxt "ip" ; set fSpecTxt "flowspec"}
              "ipv6" {set fTxt "ipv6" ; set fSpecTxt "flowspec-ipv6"}
            }
            set thisFilterId [flowspec_getfSpecFilterId $dut3 $thisVprnId -family $thisFamily]
            puts "fvyn thisVprnId: $thisVprnId ; thisFamily: $thisFamily ; thisFilterId: $thisFilterId"
            set rCli [$dut3 sendCliCommand "show router $thisVprnId bgp summary"] ; log_msg INFO "$rCli"
            set rCli [$dut3 sendCliCommand "show filter $fTxt $thisFilterId"] ; log_msg INFO "$rCli"
          }
        }
        set rCli [$dut3 sendCliCommand "show log log-id 99"] ; log_msg INFO "$rCli"
        set rCli [$dut3 sendCliCommand "show log log-id $debugLog"] ; log_msg INFO "$rCli"
      }
    }

  }
  
  if {$option(deconfig) == "true" } {
     saveOrRestore delete
     sbgp.closeall
  }
  testcaseTrailer

}




