proc configureNetworkTopo1_sh {args} {

#    topo1:
#
#       CE            PE            PE            CE
#     -------       -------       -------       -------
#    | Dut-A |-----| Dut-B |-----| Dut-D |-----| Dut-F |
#     -------       -------       -------       -------
#        |             |             |             |
#        |             |             |             |
#     -------       -------       -------       -------
#    | Ixia  |     | Dut-C |-----| Dut-E |     | Ixia  |
#     -------       -------       -------       -------
#                      P             P
#
#    topo2 (tcam):
#
#       CE                          PE
#     -------       -------       -------
#    | Ixia  |-->--| Dut-A |-->--| Dut-B |
#     -------       -------       -------
#        |                           |
#        |                           |
#        |                        -------
#        --------------<---------| Dut-C |
#                                 -------
#                                   PE

    global topoMap

    set opt(ldp)        true
    set opt(rsvp)       true
    set opt(mpls)       true

    # auto-bind
    set opt(auto-bind)  true
    set opt(ab-type)    "mpls" ; # ldp | gre | rsvp-te | mpls | mpls-gre"

    #explictly defined spoke-sdp
    set opt(exp-def)    true
    set opt(sdp-encap)  "gre" ; # gre | mpls
    set opt(sdp-ldp)    true
    set opt(sdp-lsp)    true  ; # only one can be true ?!
    set opt(sdp-sig)    "tldp" ; # tldp | off | bgp
#    set opt(sdp-mixed1) true ; # primary:rsvp secondary:ldp
#    set opt(sdp-mixed2) true ; # primary:ldp  secondary:bgp3107

    #bgp3107
    set opt(bgp3107)    true

#    set opt(ldpOrsvp)   true ; # budu 3 lable ??? treba ldp enablovat na P routroch? (Dut-C a Dut-E)
#    set opt(label-mode) "vrf" ; # vrf | next-hop | prefix

    set result "PASSED"

    # R1
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/1) shutdown"]
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/1) ethernet mode access"]
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/1) ethernet encap-type dot1q"]
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/1) no shutdown"]
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/2) no shutdown"]
    myset result [mysendCli Dut-B "/configure port $topoMap(Dut-B,1/1/3) no shutdown"]
    myset result [mysendCli Dut-B "/configure router interface \"system\" address 10.10.10.1/32"]
    myset result [mysendCli Dut-B "/configure router interface \"toR2\" address 10.1.2.1/24"]
    myset result [mysendCli Dut-B "/configure router interface \"toR2\" port $topoMap(Dut-B,1/1/2)"]
    myset result [mysendCli Dut-B "/configure router interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router interface \"toR3\" address 10.1.3.1/24"]
    myset result [mysendCli Dut-B "/configure router interface \"toR3\" port $topoMap(Dut-B,1/1/3)"]
    myset result [mysendCli Dut-B "/configure router interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router autonomous-system 65000"]
    # ospf
    myset result [mysendCli Dut-B "/configure router ospf area 0.0.0.0 interface \"system\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router ospf area 0.0.0.0 interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router ospf area 0.0.0.0 interface \"toR3\" no shutdown"]
    # mpls
    myset result [mysendCli Dut-B "/configure router mpls interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router mpls interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router mpls no shutdown"]
    # rsvp
    myset result [mysendCli Dut-B "/configure router rsvp interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router rsvp interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router rsvp no shutdown"]
    # mpls
    myset result [mysendCli Dut-B "/configure router mpls path \"loose\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR2\" to 10.10.10.2"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR2\" primary \"loose\""]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR3\" to 10.10.10.3"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR3\" primary \"loose\""]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR3\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR4\" to 10.10.10.4"]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR4\" primary \"loose\""]
    myset result [mysendCli Dut-B "/configure router mpls lsp \"toR4\" no shutdown"]
    # ldp
    myset result [mysendCli Dut-B "/configure router ldp interface-parameters interface \"toR2\" ipv4 fec-type-capability"]
    myset result [mysendCli Dut-B "/configure router ldp interface-parameters interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router ldp interface-parameters interface \"toR3\" ipv4 fec-type-capability"]
    myset result [mysendCli Dut-B "/configure router ldp interface-parameters interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-B "/configure router ldp targeted-session"]
    # bgp
    myset result [mysendCli Dut-B "/configure router bgp group \"vprn\" family vpn-ipv4"]
    myset result [mysendCli Dut-B "/configure router bgp group \"vprn\" peer-as 65000"]
    myset result [mysendCli Dut-B "/configure router bgp group \"vprn\" neighbor 10.10.10.2"]
    myset result [mysendCli Dut-B "/configure router bgp group \"vprn\" neighbor 10.10.10.3"]
    myset result [mysendCli Dut-B "/configure router bgp group \"vprn\" neighbor 10.10.10.4"]
    myset result [mysendCli Dut-B "/configure router bgp no shutdown"]
    # service
    myset result [mysendCli Dut-B "/configure service sdp 12 mpls create"]
    myset result [mysendCli Dut-B "/configure service sdp 12 far-end 10.10.10.2"]
    myset result [mysendCli Dut-B "/configure service sdp 12 lsp \"toR2\""]
    myset result [mysendCli Dut-B "/configure service sdp 12 no shutdown"]
    myset result [mysendCli Dut-B "/configure service customer 100 create"]
    myset result [mysendCli Dut-B "/configure service customer 100 description \"customer-100\""]
    myset result [mysendCli Dut-B "/configure service vprn 10 customer 100 create"]
    myset result [mysendCli Dut-B "/configure service vprn 10 autonomous-system 65000"]
    myset result [mysendCli Dut-B "/configure service vprn 10 route-distinguisher 65000:1"]
    myset result [mysendCli Dut-B "/configure service vprn 10 vrf-target target:65000:10"]
    myset result [mysendCli Dut-B "/configure service vprn 10 interface \"toR5\" create"]
    myset result [mysendCli Dut-B "/configure service vprn 10 interface \"toR5\" address 192.168.5.1/24"]
    myset result [mysendCli Dut-B "/configure service vprn 10 interface \"toR5\" sap 1/1/1:5 create"]
    myset result [mysendCli Dut-B "/configure service vprn 10 spoke-sdp 12 create"]
    myset result [mysendCli Dut-B "/configure service vprn 10 no shutdown"]
    myset result [mysendCli Dut-B "exit all"]

    # R2
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/2) shutdown"]
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/2) ethernet mode access"]
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/2) ethernet encap-type dot1q"]
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/1) no shutdown"]
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/2) no shutdown"]
    myset result [mysendCli Dut-D "/configure port $topoMap(Dut-D,1/1/3) no shutdown"]
    myset result [mysendCli Dut-D "/configure router interface \"system\" address 10.10.10.2/32"]
    myset result [mysendCli Dut-D "/configure router interface \"toR1\" address 10.1.2.2/24"]
    myset result [mysendCli Dut-D "/configure router interface \"toR1\" port $topoMap(Dut-D,1/1/1)"]
    myset result [mysendCli Dut-D "/configure router interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router interface \"toR4\" address 10.2.4.2/24"]
    myset result [mysendCli Dut-D "/configure router interface \"toR4\" port $topoMap(Dut-D,1/1/3)"]
    myset result [mysendCli Dut-D "/configure router interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router autonomous-system 65000"]
    # ospf
    myset result [mysendCli Dut-D "/configure router ospf area 0.0.0.0 interface \"system\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router ospf area 0.0.0.0 interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router ospf area 0.0.0.0 interface \"toR4\" no shutdown"]
    # mpls
    myset result [mysendCli Dut-D "/configure router mpls interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router mpls interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router mpls no shutdown"]
    # rsvp
    myset result [mysendCli Dut-D "/configure router rsvp interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router rsvp interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router rsvp no shutdown"]
    # mpls
    myset result [mysendCli Dut-D "/configure router mpls path \"loose\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR1\" to 10.10.10.1"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR1\" primary \"loose\""]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR3\" to 10.10.10.3"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR3\" primary \"loose\""]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR3\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR4\" to 10.10.10.4"]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR4\" primary \"loose\""]
    myset result [mysendCli Dut-D "/configure router mpls lsp \"toR4\" no shutdown"]
    # ldp
    myset result [mysendCli Dut-D "/configure router ldp interface-parameters interface \"toR1\" ipv4 fec-type-capability"]
    myset result [mysendCli Dut-D "/configure router ldp interface-parameters interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router ldp interface-parameters interface \"toR4\" ipv4 fec-type-capability"]
    myset result [mysendCli Dut-D "/configure router ldp interface-parameters interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-D "/configure router ldp targeted-session"]
    # bgp
    myset result [mysendCli Dut-D "/configure router bgp group \"vprn\" family vpn-ipv4"]
    myset result [mysendCli Dut-D "/configure router bgp group \"vprn\" peer-as 65000"]
    myset result [mysendCli Dut-D "/configure router bgp group \"vprn\" neighbor 10.10.10.1"]
    myset result [mysendCli Dut-D "/configure router bgp group \"vprn\" neighbor 10.10.10.3"]
    myset result [mysendCli Dut-D "/configure router bgp group \"vprn\" neighbor 10.10.10.4"]
    myset result [mysendCli Dut-D "/configure router bgp no shutdown"]
    # service
    myset result [mysendCli Dut-D "/configure service sdp 21 mpls create"]
    myset result [mysendCli Dut-D "/configure service sdp 21 far-end 10.10.10.1"]
    myset result [mysendCli Dut-D "/configure service sdp 21 lsp \"toR1\""]
    myset result [mysendCli Dut-D "/configure service sdp 21 no shutdown"]
    myset result [mysendCli Dut-D "/configure service customer 100 create"]
    myset result [mysendCli Dut-D "/configure service customer 100 description \"customer-100\""]
    myset result [mysendCli Dut-D "/configure service vprn 10 customer 100 create"]
    myset result [mysendCli Dut-D "/configure service vprn 10 autonomous-system 65000"]
    myset result [mysendCli Dut-D "/configure service vprn 10 route-distinguisher 65000:1"]
    myset result [mysendCli Dut-D "/configure service vprn 10 vrf-target target:65000:10"]
    myset result [mysendCli Dut-D "/configure service vprn 10 interface \"toR6\" create"]
    myset result [mysendCli Dut-D "/configure service vprn 10 interface \"toR6\" address 192.168.6.1/24"]
    myset result [mysendCli Dut-D "/configure service vprn 10 interface \"toR6\" sap 1/1/2:6 create"]
    myset result [mysendCli Dut-D "/configure service vprn 10 spoke-sdp 21 create"]
    myset result [mysendCli Dut-D "/configure service vprn 10 no shutdown"]
    myset result [mysendCli Dut-D "exit all"]

    # R3
    myset result [mysendCli Dut-C "/configure port $topoMap(Dut-C,1/1/2) no shutdown"]
    myset result [mysendCli Dut-C "/configure port $topoMap(Dut-C,2/1/1) no shutdown"]
    myset result [mysendCli Dut-C "/configure router interface \"system\" address 10.10.10.3/32"]
    myset result [mysendCli Dut-C "/configure router interface \"toR1\" address 10.1.3.3/24"]
    myset result [mysendCli Dut-C "/configure router interface \"toR1\" port $topoMap(Dut-C,1/1/2)"]
    myset result [mysendCli Dut-C "/configure router interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router interface \"toR4\" address 10.3.4.3/24"]
    myset result [mysendCli Dut-C "/configure router interface \"toR4\" port $topoMap(Dut-C,2/1/1)"]
    myset result [mysendCli Dut-C "/configure router interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router autonomous-system 65000"]
    # ospf
    myset result [mysendCli Dut-C "/configure router ospf area 0.0.0.0 interface \"system\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router ospf area 0.0.0.0 interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router ospf area 0.0.0.0 interface \"toR4\" no shutdown"]
    # mpls
    myset result [mysendCli Dut-C "/configure router mpls interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router mpls interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router mpls no shutdown"]
    # rsvp
    myset result [mysendCli Dut-C "/configure router rsvp interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router rsvp interface \"toR4\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router rsvp no shutdown"]
    # mpls
    myset result [mysendCli Dut-C "/configure router mpls path \"loose\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR1\" to 10.10.10.1"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR1\" primary \"loose\""]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR1\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR2\" to 10.10.10.2"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR2\" primary \"loose\""]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR2\" no shutdown"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR4\" to 10.10.10.4"]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR4\" primary \"loose\""]
    myset result [mysendCli Dut-C "/configure router mpls lsp \"toR4\" no shutdown"]
    # ldp
#    myset result [mysendCli Dut-C "/configure router ldp interface-parameters interface \"toR1\" ipv4 fec-type-capability"]
#    myset result [mysendCli Dut-C "/configure router ldp interface-parameters interface \"toR1\" no shutdown"]
#    myset result [mysendCli Dut-C "/configure router ldp interface-parameters interface \"toR4\" ipv4 fec-type-capability"]
#    myset result [mysendCli Dut-C "/configure router ldp interface-parameters interface \"toR4\" no shutdown"]
#    myset result [mysendCli Dut-C "/configure router ldp targeted-session"]
    # bgp
    myset result [mysendCli Dut-C "/configure router bgp group \"vprn\" family vpn-ipv4"]
    myset result [mysendCli Dut-C "/configure router bgp group \"vprn\" peer-as 65000"]
    myset result [mysendCli Dut-C "/configure router bgp group \"vprn\" neighbor 10.10.10.1"]
    myset result [mysendCli Dut-C "/configure router bgp group \"vprn\" neighbor 10.10.10.2"]
    myset result [mysendCli Dut-C "/configure router bgp group \"vprn\" neighbor 10.10.10.4"]
    myset result [mysendCli Dut-C "/configure router bgp no shutdown"]
    myset result [mysendCli Dut-C "exit all"]

    # R4
    myset result [mysendCli Dut-E "/configure port $topoMap(Dut-E,1/1/1) no shutdown"]
    myset result [mysendCli Dut-E "/configure port $topoMap(Dut-E,1/1/3) no shutdown"]
    myset result [mysendCli Dut-E "/configure router interface \"system\" address 10.10.10.4/32"]
    myset result [mysendCli Dut-E "/configure router interface \"toR2\" address 10.2.4.4/24"]
    myset result [mysendCli Dut-E "/configure router interface \"toR2\" port $topoMap(Dut-E,1/1/3)"]
    myset result [mysendCli Dut-E "/configure router interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router interface \"toR3\" address 10.3.4.4/24"]
    myset result [mysendCli Dut-E "/configure router interface \"toR3\" port $topoMap(Dut-E,1/1/1)"]
    myset result [mysendCli Dut-E "/configure router interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router autonomous-system 65000"]
    # ospf
    myset result [mysendCli Dut-E "/configure router ospf area 0.0.0.0 interface \"system\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router ospf area 0.0.0.0 interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router ospf area 0.0.0.0 interface \"toR3\" no shutdown"]
    # mpls
    myset result [mysendCli Dut-E "/configure router mpls interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router mpls interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router mpls no shutdown"]
    # rsvp
    myset result [mysendCli Dut-E "/configure router rsvp interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router rsvp interface \"toR3\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router rsvp no shutdown"]
    # mpls
    myset result [mysendCli Dut-E "/configure router mpls path \"loose\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR1\" to 10.10.10.1"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR1\" primary \"loose\""]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR1\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR2\" to 10.10.10.2"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR2\" primary \"loose\""]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR2\" no shutdown"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR3\" to 10.10.10.3"]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR3\" primary \"loose\""]
    myset result [mysendCli Dut-E "/configure router mpls lsp \"toR3\" no shutdown"]
    # ldp
#    myset result [mysendCli Dut-E "/configure router ldp interface-parameters interface \"toR2\" ipv4 fec-type-capability"]
#    myset result [mysendCli Dut-E "/configure router ldp interface-parameters interface \"toR2\" no shutdown"]
#    myset result [mysendCli Dut-E "/configure router ldp interface-parameters interface \"toR3\" ipv4 fec-type-capability"]
#    myset result [mysendCli Dut-E "/configure router ldp interface-parameters interface \"toR3\" no shutdown"]
#    myset result [mysendCli Dut-E "/configure router ldp targeted-session"]
    # bgp
    myset result [mysendCli Dut-E "/configure router bgp group \"vprn\" family vpn-ipv4"]
    myset result [mysendCli Dut-E "/configure router bgp group \"vprn\" peer-as 65000"]
    myset result [mysendCli Dut-E "/configure router bgp group \"vprn\" neighbor 10.10.10.1"]
    myset result [mysendCli Dut-E "/configure router bgp group \"vprn\" neighbor 10.10.10.2"]
    myset result [mysendCli Dut-E "/configure router bgp group \"vprn\" neighbor 10.10.10.3"]
    myset result [mysendCli Dut-E "/configure router bgp no shutdown"]
    myset result [mysendCli Dut-E "exit all"]

    # R5
    myset result [mysendCli Dut-A "/configure port $topoMap(Dut-A,1/1/1) shutdown"]
    myset result [mysendCli Dut-A "/configure port $topoMap(Dut-A,1/1/1) ethernet encap-type dot1q"]
    myset result [mysendCli Dut-A "/configure port $topoMap(Dut-A,1/1/1) no shutdown"]
    myset result [mysendCli Dut-A "/configure router interface \"toR1\" address 192.168.5.5/24"]
    myset result [mysendCli Dut-A "/configure router interface \"toR1\" port $topoMap(Dut-A,1/1/1):5"]
    myset result [mysendCli Dut-A "/configure router interface \"toR1\" no shutdown"]
    myset result [mysendCli Dut-A "/configure router static-route 0.0.0.0/0 next-hop 192.168.5.1"]
    myset result [mysendCli Dut-A "exit all"]


    # R6
    myset result [mysendCli Dut-F "/configure port $topoMap(Dut-F,1/1/1) shutdown"]
    myset result [mysendCli Dut-F "/configure port $topoMap(Dut-F,1/1/1) ethernet encap-type dot1q"]
    myset result [mysendCli Dut-F "/configure port $topoMap(Dut-F,1/1/1) no shutdown"]
    myset result [mysendCli Dut-F "/configure router interface \"toR2\" address 192.168.6.6/24"]
    myset result [mysendCli Dut-F "/configure router interface \"toR2\" port $topoMap(Dut-F,1/1/1):6"]
    myset result [mysendCli Dut-F "/configure router interface \"toR2\" no shutdown"]
    myset result [mysendCli Dut-F "/configure router static-route 0.0.0.0/0 next-hop 192.168.6.1"]
    myset result [mysendCli Dut-F "exit all"]

    # myset result [mysendCli Dut-B ""]
    # myset result [mysendCli Dut-B ""]
    # myset result [mysendCli Dut-B ""]
    # myset result [mysendCli Dut-B ""]

    return $result

}

proc serviceAwareFilter_setGlobalParams {args} {

    global topoMap

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4
    global ospfArea

    set dut1         "B"
    set dut1Id       1
    set dut2         "C"
    set dut2Id       2
    set dut3         "D"
    set dut3Id       3
    set dut4         "E"
    set dut4Id       4
    set dut5         "A"
    set dut5Id       5
    set dut6         "F"
    set dut6Id       6

    set port_1_5     $topoMap(Dut-$dut1,1/1/1)
    set port_1_2     $topoMap(Dut-$dut1,1/1/3) ; # change if u want to use lag!
    set port_1_3     $topoMap(Dut-$dut1,1/1/2)
    set port_1_x4a   $topoMap(Dut-$dut1,1/1/7) ; # ixia4
    set port_1_x4b   $topoMap(Dut-$dut1,1/1/8) ; # ixia4
    set port_2_1     $topoMap(Dut-$dut2,1/1/2) ; # change if u want to use lag!
    set port_2_6     $topoMap(Dut-$dut2,2/1/2)
    set port_2_4     $topoMap(Dut-$dut2,2/1/1)
    set port_2_x2    $topoMap(Dut-$dut2,1/1/4) ; # ixia2
    set port_2_x3    $topoMap(Dut-$dut2,2/1/5) ; # ixia3
    set port_3_1     $topoMap(Dut-$dut3,1/1/1)
    set port_3_4     $topoMap(Dut-$dut3,1/1/3)
    set port_4_2     $topoMap(Dut-$dut4,1/1/1)
    set port_4_3     $topoMap(Dut-$dut4,1/1/3)
    set port_5_1     $topoMap(Dut-$dut5,1/1/1)
    set port_5_x1    $topoMap(Dut-$dut5,1/1/3) ; # ixia1
    set port_6_2     $topoMap(Dut-$dut6,1/1/4)
    set port_6_x4    $topoMap(Dut-$dut6,1/1/3) ; # ixia4

    set ospfArea     "0.0.0.0"

    return {}

}

proc serviceAwareFilter_setupPorts {args} {

    set opt(useIxia)        "false"
    set opt(skipDuts)       ""
    getopt opt $args

    set result PASSED
    set res {}

    global dut1 dut2 dut3 dut4 dut5 dut6
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4

    if { [lsearch [split $opt(skipDuts) " "] $dut1] == -1 } {
        lappend res [Dut-$dut1 configurePort $port_1_5 -Mode access  -Encap qEncap    -MTU 1518]
        lappend res [Dut-$dut1 configurePort $port_1_2 -Mode network -Encap nullEncap -MTU 1514]
        lappend res [Dut-$dut1 configurePort $port_1_3 -Mode network -Encap nullEncap -MTU 1514]
    }

    if { [lsearch [split $opt(skipDuts) " "] $dut2] == -1 } {
        lappend res [Dut-$dut2 configurePort $port_2_1 -Mode network -Encap nullEncap -MTU 1514]
        lappend res [Dut-$dut2 configurePort $port_2_4 -Mode network -Encap nullEncap -MTU 1514]
        lappend res [Dut-$dut2 configurePort $port_2_6 -Mode access  -Encap qEncap    -MTU 1518]
    }

    if { [lsearch [split $opt(skipDuts) " "] $dut3] == -1 } {
        lappend res [Dut-$dut3 configurePort $port_3_1 -Mode network -Encap nullEncap -MTU 1514]
        lappend res [Dut-$dut3 configurePort $port_3_4 -Mode network -Encap nullEncap -MTU 1514]
    }

    if { [lsearch [split $opt(skipDuts) " "] $dut4] == -1 } {
        lappend res [Dut-$dut4 configurePort $port_4_2 -Mode network -Encap nullEncap -MTU 1514]
        lappend res [Dut-$dut4 configurePort $port_4_3 -Mode network -Encap nullEncap -MTU 1514]
    }

    if {$opt(useIxia)} {
        if { [lsearch [split $opt(skipDuts) " "] $dut5] == -1 } {
            lappend res [Dut-$dut5 configurePort $port_5_1  -Mode access -Encap qEncap -MTU 1518]
            lappend res [Dut-$dut5 configurePort $port_5_x1 -Mode access -Encap nullEncap -MTU 1514]
        }
        if { [lsearch [split $opt(skipDuts) " "] $dut6] == -1 } {
            lappend res [Dut-$dut6 configurePort $port_6_2  -Mode access -Encap qEncap -MTU 1518]
            lappend res [Dut-$dut6 configurePort $port_6_x4 -Mode access -Encap nullEncap -MTU 1514]
        }
    } else {
        if { [lsearch [split $opt(skipDuts) " "] $dut5] == -1 } {
            lappend res [Dut-$dut5 configurePort $port_5_1 -Mode network -Encap qEncap    -MTU 1518]
        }
        if { [lsearch [split $opt(skipDuts) " "] $dut6] == -1 } {
            lappend res [Dut-$dut6 configurePort $port_6_2 -Mode network -Encap qEncap    -MTU 1518]
        }
    }

    foreach r $res {
        if { $r != "OK" } { set result ERROR }
    }
    return $result

}

proc serviceAwareFilter_cleanupPorts {args} {

    set opt(useIxia)        "false"
    getopt opt $args

    set result PASSED
    set res {}

    global dut1 dut2 dut3 dut4 dut5 dut6
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4

    lappend res [Dut-$dut1 deconfigurePort $port_1_5]
    lappend res [Dut-$dut1 deconfigurePort $port_1_2]
    lappend res [Dut-$dut1 deconfigurePort $port_1_3]

    lappend res [Dut-$dut2 deconfigurePort $port_2_1]
    lappend res [Dut-$dut2 deconfigurePort $port_2_4]
    lappend res [Dut-$dut2 deconfigurePort $port_2_6]

    lappend res [Dut-$dut3 deconfigurePort $port_3_1]
    lappend res [Dut-$dut3 deconfigurePort $port_3_4]

    lappend res [Dut-$dut4 deconfigurePort $port_4_2]
    lappend res [Dut-$dut4 deconfigurePort $port_4_3]

    if {$opt(useIxia)} {
        lappend res [Dut-$dut5 deconfigurePort $port_5_1]
        lappend res [Dut-$dut5 deconfigurePort $port_5_x1]
        lappend res [Dut-$dut6 deconfigurePort $port_6_2]
        lappend res [Dut-$dut6 deconfigurePort $port_6_x4]
    } else {
        lappend res [Dut-$dut5 deconfigurePort $port_5_1]
        lappend res [Dut-$dut6 deconfigurePort $port_6_2]
    }

    foreach r $res {
        if { $r != "OK" } { set result ERROR }
    }
    return $result

}

proc serviceAwareFilter_setupNetwork {args} {

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4
    global ospfArea

    set opt(useIxia)        "false"
    set opt(skipDuts)       ""

    getopt opt $args

    set result PASSED
    set res {}

    # customer edge

    if {$opt(useIxia)} {
        # nothing
    } else {
        if { [lsearch [split $opt(skipDuts) " "] $dut5] == -1 } {
            lappend res [lindex [Dut-$dut5 createRouterInterface [ipConvert Ipv6 192.168.$dut5Id.$dut5Id] [maskConvert Ipv6 24] -name "link$dut1Id$dut5Id" -port $port_5_1 -vlan $dut5Id] 0]
            lappend res [Dut-$dut5 createIpAddress [Dut-$dut5 interfaceNameToIfIndex "link$dut1Id$dut5Id"] 192.168.$dut5Id.$dut5Id 255.255.255.0]
            lappend res [Dut-$dut5 createStaticRoute 0.0.0.0 0.0.0.0 192.168.${dut5Id}.1]
            lappend res [cliConfigNoError Dut-$dut5 "/configure router static-route ::/0 next-hop [ipConvert Ipv6 192.168.${dut5Id}.1]"]
        }
        if { [lsearch [split $opt(skipDuts) " "] $dut6] == -1 } {
            lappend res [lindex [Dut-$dut6 createRouterInterface [ipConvert Ipv6 192.168.$dut6Id.$dut6Id] [maskConvert Ipv6 24] -name "link$dut2Id$dut6Id" -port $port_6_2 -vlan $dut6Id] 0]
            lappend res [Dut-$dut6 createIpAddress [Dut-$dut6 interfaceNameToIfIndex "link$dut2Id$dut6Id"] 192.168.$dut6Id.$dut6Id 255.255.255.0]
            lappend res [Dut-$dut6 createStaticRoute 0.0.0.0 0.0.0.0 192.168.${dut6Id}.1]
            lappend res [cliConfigNoError Dut-$dut6 "/configure router static-route ::/0 next-hop [ipConvert Ipv6 192.168.${dut6Id}.1]"]        
        }
    }

    # provider (edge)

    for { set i 1 } { $i <= 4 } { incr i } {

        if { [lsearch [split $opt(skipDuts) " "] [set dut${i}]] != -1 } { continue }

        lappend res [lindex [Dut-[set dut$i] createSystemInterface 10.20.1.$i] 0]
        lappend res [Dut-[set dut$i] configureMplsInterface 10.20.1.$i]
        lappend res [Dut-[set dut$i] configureOspfInterface 10.20.1.$i $ospfArea]
        lappend res [Dut-[set dut$i] createMplsProtocol]
        lappend res [Dut-[set dut$i] createLdpProtocol]
        # ipv6
        lappend res [lindex [Dut-[set dut$i] createSystemInterface [ipConvert Ipv6 10.20.1.$i]] 0]
        lappend res [Dut-[set dut$i] configureOspfInterface [ipConvert Ipv6 10.20.1.$i] $ospfArea]
        # bgp
        lappend res [Dut-[set dut$i] setRouterAS -AS 65000]
        lappend res [Dut-[set dut$i] configBgpRouterID 10.20.1.$i]
        lappend res [Dut-[set dut$i] createBgpGroup "vprn" -Family "vpn" -PeerAS 65000]
        lappend res [Dut-[set dut$i] createBgpGroup "vprn6" -Family "vpn6" -PeerAS 65000]
        lappend res [cliConfigNoError Dut-[set dut$i] "/configure router bgp connect-retry 1"]
        lappend res [cliConfigNoError Dut-[set dut$i] "/configure router bgp min-route-advertisement 1"]
        lappend res [cliConfigNoError Dut-[set dut$i] "/configure router bgp enable-peer-tracking"]

        for { set j 1 } { $j <= 4 } { incr j } {
            if { $i != $j } {
                if { $i < $j } {
                    set link1 $i
                    set link2 $j
                } else {
                    set link1 $j
                    set link2 $i
                }
                if {[info exists port_${i}_${j}]} {
                    lappend res [lindex [Dut-[set dut$i] createRouterInterface 10.${link1}.${link2}.${i} 255.255.255.0 -name "link$link1$link2" -port [set port_${i}_${j}]] 0]
                    lappend res [Dut-[set dut$i] createIpAddress [Dut-[set dut$i] interfaceNameToIfIndex "link$link1$link2"] [ipConvert Ipv6 10.${link1}.${link2}.${i}] [maskConvert Ipv6 255.255.255.0]]
                    lappend res [Dut-[set dut$i] configureMplsInterface 10.${link1}.${link2}.$i]
                    lappend res [Dut-[set dut$i] configureOspfInterface 10.${link1}.${link2}.$i $ospfArea]
                    lappend res [Dut-[set dut$i] configureRsvpInterface 10.${link1}.${link2}.$i]
                    lappend res [Dut-[set dut$i] configureLdpInterface  10.${link1}.${link2}.$i]
                    # ipv6
                    lappend res [Dut-[set dut$i] configureOspfInterface [ipConvert Ipv6 10.${link1}.${link2}.$i] $ospfArea]
                }
                lappend res [Dut-[set dut$i] createBgpPeer 10.20.1.$j "vprn" 65000 -MEDSource noMedOut]
                lappend res [Dut-[set dut$i] createBgpPeer [ipConvert Ipv6 10.20.1.$j] "vprn6" 65000 -MEDSource noMedOut]
                lappend res [cliConfigNoError Dut-[set dut$i] "/configure router bgp group vprn6 neighbor [ipConvert Ipv6 10.20.1.$j] no family"]
                lappend res [Dut-[set dut$i] createPrimaryLsp $i$j 1 "loose" "to[set dut$j]" 10.20.1.$j]
            }
        }
    }

    foreach r $res {
        if { ($r != "OK") && ($r != "noError") && ($r != "") } { set result ERROR }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result
}

proc serviceAwareFilter_cleanupNetwork {args} {

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4
    global ospfArea

    set opt(useIxia)        "false"

    getopt opt $args

    set result PASSED
    set res {}

    # customer edge

    if {$opt(useIxia)} {
        # nothing
    } else {
        lappend res [Dut-$dut5 deleteRouterInterface 192.168.$dut5Id.$dut5Id]
        lappend res [Dut-$dut6 deleteRouterInterface 192.168.$dut6Id.$dut6Id]
        lappend res [Dut-$dut5 deleteStaticRoute 0.0.0.0 0.0.0.0 192.168.${dut5Id}.1]
        lappend res [Dut-$dut5 deleteStaticRoute :: 0 [ipConvert Ipv6 192.168.${dut5Id}.1]]
        lappend res [Dut-$dut6 deleteStaticRoute 0.0.0.0 0.0.0.0 192.168.${dut6Id}.1]
        lappend res [Dut-$dut6 deleteStaticRoute :: 0 [ipConvert Ipv6 192.168.${dut6Id}.1]]
    }

    # provider (edge)

    for { set i 1 } { $i <= 4} { incr i } {

        # bgp
        lappend res [Dut-[set dut$i] deleteAllBgp]
        # mpls, ospf, ldp ...
        lappend res [Dut-[set dut$i] deconfigureMplsInterface 10.20.1.$i]
        lappend res [Dut-[set dut$i] deconfigureOspfInterface 10.20.1.$i $ospfArea]
        lappend res [Dut-[set dut$i] deconfigureOspfInterface [ipConvert Ipv6 10.20.1.$i] $ospfArea]
        # rsvp ?
        lappend res [Dut-[set dut$i] deleteMplsProtocol]
        lappend res [Dut-[set dut$i] deleteLdpProtocol]
        lappend res [Dut-[set dut$i] deleteOspfProtocol]
        lappend res [Dut-[set dut$i] deleteOspfProtocol --version v3]
        lappend res [Dut-[set dut$i] deleteSystemInterface 10.20.1.$i]

        for { set j 1 } { $j <= 4 } { incr j } {
            if { $i != $j } {
                if { $i < $j } {
                    set link1 $i
                    set link2 $j
                } else {
                    set link1 $j
                    set link2 $i
                }
                if {[info exists port_${i}_${j}]} {
                    lappend res [Dut-[set dut$i] deleteRouterInterface 10.${link1}.${link2}.${i}]
                }
            }
        }
    }

    foreach r $res {
        if { $r != "OK" } { set result ERROR }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result
}

proc serviceAwareFilter_setupService {args} {

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4

    set opt(filterId)       0

    set opt(svcId)          1
    set opt(dflt_cust)      1
    set opt(svcType)        "vprn"
    set opt(tunnelType)     "explicit"  ; # explicit | autobind

    set opt(sdpDelivery)    "mpls"      ; # mpls | gre
    set opt(sdpLdp)         "disabled"  ; # disabled = lsp | enabled = ldp
    set opt(sdpLspList)     none
    set opt(lspName)        none

    set opt(setupDut1)      "true"
    set opt(setupDut2)      "true"

    set opt(useIxia)        "false"
    set opt(skipDuts)       ""

    getopt opt $args

    set result PASSED
    set res {}

    if { $opt(svcType) == "vprn" } {

        set sdpList {}

        if { $opt(setupDut1) && ([lsearch [split $opt(skipDuts) " "] $dut1] == -1) } {

            lappend res [Dut-$dut1 createVprn $opt(svcId) $opt(dflt_cust) 65000:$opt(svcId) -AS 65000]
            lappend res [cliConfigNoError Dut-$dut1 "/configure service $opt(svcType) $opt(svcId) vrf-target target:65000:1"]
            set vRtr [Dut-$dut1 getSvcVRouterId $opt(svcId) ]
            lappend res [lindex [Dut-$dut1 createIesInterface $opt(svcId) 192.168.${dut5Id}.1 255.255.255.0 [Dut-$dut1 convert_port_ifIndex port $port_1_5] $dut5Id -name "itfTo$dut5" -vRtrID $vRtr] 0]
            lappend res [cliConfigNoError Dut-$dut1 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut5 ipv6 address [ipConvert Ipv6 192.168.${dut5Id}.1]/[maskConvert Ipv6 255.255.255.0]"]

            if { $opt(tunnelType) == "explicit" } {
                if { $opt(sdpLdp) == "disabled" } {
                    set s [cookCliData [Dut-$dut1 sendCliCommand "show router mpls lsp to 10.20.1.$dut2Id | match 10.20.1.$dut2Id"]]
                    set lspId [lindex [regsub -all {\s+} $s " "] 2]
                    set sdpId 12
                    set lspIdhex [format "%02s" [decToHex $lspId]]
                    set opt(lspName) [lindex [regsub -all {\s+} $s " "] 0]
                    set opt(sdpLspList) "00:00:00:$lspIdhex:00:00:00:00"
                }
                lappend res [lindex [Dut-$dut1 createSdp 10.20.1.$dut2Id $opt(sdpDelivery) $opt(sdpLspList) -ldp $opt(sdpLdp) -Id $sdpId -signaling 2] 0]
                lappend sdpList $dut1 10.20.1.$dut2Id $sdpId
                lappend res [Dut-$dut1 bindSdp $opt(svcId) $sdpId -type spoke]
            }
        }

        if { $opt(setupDut2) && ([lsearch [split $opt(skipDuts) " "] $dut2] == -1)} {

            lappend res [Dut-$dut2 createVprn $opt(svcId) $opt(dflt_cust) 65000:$opt(svcId) -AS 65000]
            lappend res [cliConfigNoError Dut-$dut2 "/configure service $opt(svcType) $opt(svcId) vrf-target target:65000:1"]
            set vRtr [Dut-$dut2 getSvcVRouterId $opt(svcId) ]
            lappend res [lindex [Dut-$dut2 createIesInterface $opt(svcId) 192.168.${dut6Id}.1 255.255.255.0 [Dut-$dut2 convert_port_ifIndex port $port_2_6] $dut6Id -name "itfTo$dut6" -vRtrID $vRtr] 0]
            lappend res [cliConfigNoError Dut-$dut2 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut6 ipv6 address [ipConvert Ipv6 192.168.${dut6Id}.1]/[maskConvert Ipv6 255.255.255.0]"]

            if { $opt(tunnelType) == "explicit" } {
                if { $opt(sdpLdp) == "disabled" } {
                    set s [cookCliData [Dut-$dut2 sendCliCommand "show router mpls lsp to 10.20.1.$dut1Id | match 10.20.1.$dut1Id"]]
                    set lspId [lindex [regsub -all {\s+} $s " "] 2]
                    set sdpId 21
                    set lspIdhex [format "%02s" [decToHex $lspId]]
                    set opt(lspName) [lindex [regsub -all {\s+} $s " "] 0]
                    set opt(sdpLspList) "00:00:00:$lspIdhex:00:00:00:00"
                }
                lappend res [lindex [Dut-$dut2 createSdp 10.20.1.$dut1Id $opt(sdpDelivery) $opt(sdpLspList) -ldp $opt(sdpLdp) -Id $sdpId -signaling 2] 0]
                lappend sdpList $dut2 10.20.1.$dut1Id $sdpId
                lappend res [Dut-$dut2 bindSdp $opt(svcId) $sdpId -type spoke]
            }
        }

        # check sdp

        foreach { dut remoteIp sdpId } $sdpList {
            set r [check_converge $dut $sdpId ]
            set r [Dut-$dut getSdpOperStatus $sdpId]
            if { ($r != "up") } {
                log_msg DEBUG "converge for Dut-$dut sdp $sdpId not ok - $r"
            }
        }

        if {$opt(useIxia)} {
            # configure vpls on dut-a and dut-f
            if { [lsearch [split $opt(skipDuts) " "] $dut5] == -1 } {
                Dut-$dut5 createTls 1 1
                Dut-$dut5 createSap 1 [Dut-$dut5 convert_port_ifIndex port $port_5_1] $dut5Id
                Dut-$dut5 createSap 1 [Dut-$dut5 convert_port_ifIndex port $port_5_x1] 0
            }
            if { [lsearch [split $opt(skipDuts) " "] $dut6] == -1 } {
                Dut-$dut6 createTls 1 1
                Dut-$dut6 createSap 1 [Dut-$dut6 convert_port_ifIndex port $port_6_2] $dut6Id
                Dut-$dut6 createSap 1 [Dut-$dut6 convert_port_ifIndex port $port_6_x4] 0
            }

            # static-arp
            if { [lsearch [split $opt(skipDuts) " "] $dut1] == -1 } {
                lappend res [cliConfigNoError Dut-$dut1 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut5 static-arp 192.168.${dut5Id}.${dut5Id} 01:02:03:04:05:06"]
                lappend res [cliConfigNoError Dut-$dut1 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut5 ipv6 neighbor [ipConvert Ipv6 192.168.${dut5Id}.${dut5Id}] 01:02:03:04:05:06"]
            }
            if { [lsearch [split $opt(skipDuts) " "] $dut2] == -1 } {
                lappend res [cliConfigNoError Dut-$dut2 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut6 static-arp 192.168.${dut6Id}.${dut6Id} 06:05:04:03:02:01"]
                lappend res [cliConfigNoError Dut-$dut2 "/configure service $opt(svcType) $opt(svcId) interface itfTo$dut6 ipv6 neighbor [ipConvert Ipv6 192.168.${dut6Id}.${dut6Id}] 06:05:04:03:02:01"]
            }
        }
    }
    
    foreach r $res {
        if { ($r != "OK") && ($r != "") && ($r != "noError") } { set result ERROR }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result
}

proc serviceAwareFilter_cleanupService {args} {

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4

    set opt(filterId)       0

    set opt(svcId)          1
    set opt(dflt_cust)      1
    set opt(svcType)        "vprn"
    set opt(tunnelType)     "explicit"  ; # explicit | autobind

    set opt(sdpDelivery)    "mpls"      ; # mpls | gre
    set opt(sdpLdp)         "disabled"  ; # disabled = lsp | enabled = ldp
    set opt(sdpLspList)     none
    set opt(lspName)        none

    set opt(cleanupDut1)    "true"
    set opt(cleanupDut2)    "true"

    set opt(useIxia)        "false"

    getopt opt $args

    set result PASSED
    set res {}

    if { $opt(svcType) == "vprn" } {

        if { $opt(cleanupDut1) } {

            if { $opt(tunnelType) == "explicit" } {
                if { $opt(sdpLdp) == "disabled" } {
                    set s [cookCliData [Dut-$dut1 sendCliCommand "show router mpls lsp to 10.20.1.$dut2Id | match 10.20.1.$dut2Id"]]
                    set lspId [lindex [regsub -all {\s+} $s " "] 2]
                    set sdpId 12
                    set lspIdhex [format "%02s" [decToHex $lspId]]
                    set opt(lspName) [lindex [regsub -all {\s+} $s " "] 0]
                    set opt(sdpLspList) "00:00:00:$lspIdhex:00:00:00:00"
                }
                lappend res [Dut-$dut1 unbindSdp $opt(svcId) $sdpId -type spoke]
                lappend res [Dut-$dut1 deleteSdp $sdpId $opt(sdpDelivery)]
            }
            lappend res [Dut-$dut1 deleteIesInterface $opt(svcId) 192.168.${dut5Id}.1 [Dut-$dut1 convert_port_ifIndex port $port_1_5] $dut5Id -vRtrID [Dut-$dut1 getSvcVRouterId $opt(svcId)]]
            lappend res [Dut-$dut1 deleteVprn $opt(svcId)]
        }

        if { $opt(cleanupDut2) } {

            if { $opt(tunnelType) == "explicit" } {
                if { $opt(sdpLdp) == "disabled" } {
                    set s [cookCliData [Dut-$dut2 sendCliCommand "show router mpls lsp to 10.20.1.$dut1Id | match 10.20.1.$dut1Id"]]
                    set lspId [lindex [regsub -all {\s+} $s " "] 2]
                    set sdpId 21
                    set lspIdhex [format "%02s" [decToHex $lspId]]
                    set opt(lspName) [lindex [regsub -all {\s+} $s " "] 0]
                    set opt(sdpLspList) "00:00:00:$lspIdhex:00:00:00:00"
                }
                lappend res [Dut-$dut2 unbindSdp $opt(svcId) $sdpId -type spoke]
                lappend res [Dut-$dut2 deleteSdp $sdpId $opt(sdpDelivery)]
            }
            lappend res [Dut-$dut2 deleteIesInterface $opt(svcId) 192.168.${dut6Id}.1 [Dut-$dut2 convert_port_ifIndex port $port_2_6] $dut6Id -vRtrID [Dut-$dut2 getSvcVRouterId $opt(svcId)]]
            lappend res [Dut-$dut2 deleteVprn $opt(svcId)]
        }

        if {$opt(useIxia)} {
            # deconfigure vpls on dut-a and dut-f
            Dut-$dut5 deleteSap 1 [Dut-$dut5 convert_port_ifIndex port $port_5_1] $dut5Id
            Dut-$dut5 deleteSap 1 [Dut-$dut5 convert_port_ifIndex port $port_5_x1] 0
            Dut-$dut5 deleteTls 1
            Dut-$dut6 deleteSap 1 [Dut-$dut6 convert_port_ifIndex port $port_6_2] $dut6Id
            Dut-$dut6 deleteSap 1 [Dut-$dut6 convert_port_ifIndex port $port_6_x4] 0
            Dut-$dut6 deleteTls 1
        }

    }

    foreach r $res {
        if { ($r != "OK") && ($r != "noError") } { set result ERROR }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result
}

proc serviceAwareFilter_config {args} {

    set opt(cleanupFirst)   "false"
    set opt(useIxia)        "false"
    set opt(skipDuts)       ""

    getopt opt $args

    set result PASSED
    set res {}

    serviceAwareFilter_setGlobalParams

    if { $opt(cleanupFirst) } {
        log_msg INFO "Cleanup started."
        log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
        setGlobalVar consoleLogLevel ERROR
        if { [saveOrRestore delete] != "noError" } { log_msg ERROR "Cleanup failed!" set result FAILED }
        setGlobalVar consoleLogLevel DEBUG
        log_msg INFO "Cleanup finished."
    }

    lappend res [serviceAwareFilter_setupPorts -useIxia $opt(useIxia) -skipDuts $opt(skipDuts)]
    lappend res [serviceAwareFilter_setupNetwork -useIxia $opt(useIxia) -skipDuts $opt(skipDuts)]
    lappend res [serviceAwareFilter_setupService -useIxia $opt(useIxia) -skipDuts $opt(skipDuts)]

    log_msg INFO "Wait for the network to converge..."
    printDotsWhileWaiting 60

    foreach r $res {
        if { $r != "PASSED" } {
            set result ERROR
        }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result

}

proc serviceAwareFilter_deconfig {args} {

    set opt(useIxia)        "false"

    getopt opt $args

    set result PASSED

    lappend res [serviceAwareFilter_cleanupService -useIxia $opt(useIxia)]
    lappend res [serviceAwareFilter_cleanupNetwork -useIxia $opt(useIxia)]
    lappend res [serviceAwareFilter_cleanupPorts -useIxia $opt(useIxia)]

    foreach r $res {
        if { $r != "PASSED" } {
            set result ERROR
        }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    return $result

}

proc randomFilterName {args} {

    set opt(length)         64
    set opt(signs)          31
    set opt(exclude)        "\#\""
    set opt(randomSigns)    true

    #set all_signs "\ \!\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\}\|\~\""; # exclude \" because it is a non displayable char for cli

    getopt opt $args

    # filter-name rules:
    # cannot start with number
    # cannot start with '_'
    # cannot start with fSpec-[0-9]+
    # cannot contain only spaces, but can contain <space> in the name
    # cannot contain white chars
    # cannot contain '"'
    # string after '#' is stripped (treated as comment)

    if { $opt(length) == 0 } {
        log_msg NOTICE "Filter name cannot be of length 0. Defaulting to 64."
        set opt(length) 64
    }
    set signs $opt(signs)
    if { $opt(signs) == 0 } {
        set signs 0
    } elseif { $opt(randomSigns) } {
        set signs [random $opt(signs)]
    } else {
        set signs $opt(signs)
    }
    if { $opt(length) < $signs } {
        set signs $opt(length)
    }

    set invalidName true

    while { $invalidName } {

        set filterName [randomAsciiString $opt(length) -signs $signs -exclude $opt(exclude)]

        # first char
        if { ([isNumber [string index $filterName 0]]) || ([string index $filterName 0] == "_") } {
            continue
        }
        # fSpec-
        if { [regexp {fSpec-[0-9]+} $filterName] } {
            continue
        }
        # only space
        if { [regexp -all " " $filterName] == [string length $filterName] } {
            continue
        }
        # '"'
        if { [regexp "\"" $filterName] } {
            continue
        }

        # if we get here, the name should be valid :)
        set invalidName false
    }

    return $filterName
}

proc serviceAwareFilter_applyFilter {dut svcId svcType family direction value args} {

    set opt(mode)           ""
    set opt(returnCliError) false
    set opt(removeId)       ""
    set opt(useFilterName)  false ; # applicable only for cli
    set opt(filterName)     "dummy"

    getopt opt $args

    if { $value == 0 } { set action "remove" } else { set action "apply" }

    if { $opt(mode) == "" } {
        if { [random 2] } {
            set opt(mode) "cli"
            log_msg DEBUG "Randomly chosen to use CLI to $action filter."
        } else {
            set opt(mode) "snmp"
            log_msg DEBUG "Randomly chosen to use SNMP to $action filter."
        }
    } else {
        log_msg DEBUG "[string toupper $opt(mode)] chosen to $action filter."
    }

    if { [string tolower $family] == "ipv4" } {
        set family "IP"
    } elseif { [string tolower $family] == "ipv6" } {
        set family "IPv6"
    } else {
        #log_msg WARNING "Unsupported filter type: $family!"
        if {$opt(mode) == "snmp"} {
            return FAILED
        }
    }

    if {$opt(mode) == "snmp"} {

        if {[string totitle $direction] == "Ingress"} {
            # vprn network ingress filter
            set r [ Dut-$dut setSvcNetIng${family}FilterId $svcId $value ]
        } else {
            if { $value != 0 } {
                log_msg WARNING "Cannot change vprn network filter on $direction!"
                set r FAILED
            } else {
                set r "noError"
            }
        }

    } else  { ; # cli

        set cmd "/configure service $svcType $svcId network"
        if {[string totitle $direction] == "Ingress"} {
            set cmd "$cmd [string tolower $direction]"
        } else {
            log_msg WARNING "Cannot $action vprn network filter on $direction!"
            set r FAILED
        }

        if {$value == "0"} {
            if {$opt(removeId) != ""} {
                if { $opt(useFilterName) } {
                    set cmd "$cmd no filter [string tolower $family] $opt(filterName)"
                } else {
                    set cmd "$cmd no filter [string tolower $family] $opt(removeId)"
                }
            } else {
                set cmd "$cmd no filter" ; # attention: will remove both ip and ipv6 filter if applied together (use -removeId)
            }
        } else {
            if { $opt(useFilterName) } {
                set cmd "$cmd filter [string tolower $family] $opt(filterName)"
            } else {
                set cmd "$cmd filter [string tolower $family] $value"
            }
        }

        #Dut-$dut sendCliCommand "exit all"
        set errMsg [ cookCliData [ Dut-$dut sendCliCommand $cmd] ]
        #Dut-$dut sendCliCommand "exit all"
        if { $errMsg == "" } {
            set r "noError"
        } else {
            if { $opt(returnCliError) } {
                set r [list "FAILED" "$errMsg"]
            } else {
                set r FAILED
            }
        }
    }

    return $r
}

proc serviceAwareFilter_rollbackSave {dut rollIdx args} {

    global logdir

    set result PASSED

    log_msg INFO "--------------------------------------"
    log_msg INFO " Save rollback restore point $rollIdx "
    log_msg INFO "--------------------------------------"

    log_msg INFO "Creating rollback restore point $rollIdx"

    set username    $::TestDB::thisTestBed
    set hostIp      $::TestDB::thisHostIpAddr
    set logDir      "ftp://${username}:tigris@${hostIp}/$logdir/device_logs"
    set extCliTim   [Dut-$dut cget -cli_timeout]
    set extTim      [Dut-$dut cget -timeout]

    Dut-$dut configure -cli_timeout 3600
    Dut-$dut configure -timeout 125

    Dut-$dut sendCliCommand "exit all"
    Dut-$dut sendCliCommand "shell rollbackBlackListDisable"
    Dut-$dut sendCliCommand "configure system rollback rollback-location $logDir/serviceAwareFilter"
    Dut-$dut sendCliCommand "admin rollback save"

    after 1000
    log_msg DEBUG [Dut-$dut sendCliCommand "show system rollback"]

    set rollbackSaveResult [filter_getRollbackResult $dut save]
    if {$rollbackSaveResult != "Successful"} {
        log_msg ERROR "error with creating rollback restore point $rollIdx - $rollbackSaveResult"
        set result "FAILED"
    }
    Dut-$dut configure -cli_timeout $extCliTim
    Dut-$dut configure -timeout $extTim

    return $result
}

proc stripInvisible str {
    # removes all except..
    return [regsub -all {[^\u0020-\u007e]} $str ""]
}

proc serviceAwareFilter_rollbackRestore {dut rollIdx args} {

    set result PASSED

    log_msg INFO "----------------------------------------------------"
    log_msg INFO " Perform rollback to restore point $rollIdx"
    log_msg INFO "----------------------------------------------------"

    # rollback to the first restore point
    log_msg INFO "Rollback to restore point $rollIdx"
    set errMsg [cookCliData [Dut-$dut sendCliCommand "/admin rollback revert $rollIdx now" -match_max 200000 -timeout 20]]

    after 5000

    if { [regexp -nocase {^Restoring rollback configuration .*\n.*Processing current config\.\.\. [0-9]+\.[0-9]+ s\n.*Processing .*\.\.\. [0-9]+\.[0-9]+ s\n.*Resolving dependencies\.\.\. [0-9]+\.[0-9]+ s\n.*Tearing setup down\.\.\. [0-9]+\.[0-9]+ s\n.*Rebuilding setup\.\.\. [0-9]+\.[0-9]+ s\n.*Finished in [0-9]+\.[0-9]+ s$} $errMsg] } {
        if { [regexp -nocase "CRITICAL|MAJOR|MINOR|ERROR|WARNING|INFO|FAILED" $errMsg] } {
            set result FAILED
            log_msg ERROR "Error with reverting to rollback restore point $rollIdx (found error in output):\n$errMsg"
        } elseif { [filter_getRollbackResult $dut revert] != "Successful" } {
            set result FAILED
            log_msg ERROR "Error with reverting to rollback restore point $rollIdx (Last Revert Result Check Failed):\n$errMsg"
        } else {
            # rollback successful
        }
    } else {
        set result FAILED
        log_msg ERROR "Error with reverting to rollback restore point $rollIdx (regexp failed):\n$errMsg"
        #log_msg DEBUG "Output without special characters:\n[stripInvisible $errMsg]"
    }

    log_msg DEBUG [Dut-$dut sendCliCommand "show system rollback"]

    #set rollbackRevertResult [filter_getRollbackResult $dut revert]
    #if {$rollbackRevertResult != "Successful" || [regexp "CLI Rollback revert failed" $errMsg]} {
    #    log_msg ERROR "error with reverting to rollback restore point $rollIdx - $rollbackRevertResult - $errMsg"
    #    set result "FAILED"
    #}

    return $result
}

proc serviceAwareFilter_rollbackCleanup {dut args} {

    set result PASSED

    set res [ cookCliData [Dut-$dut sendCliCommand "show system rollback | match \"No Matching Entries\""]]
    if { [regexp {No Matching Entries} $res] } {
        log_msg DEBUG "No rollback files found!"
        return $result
    }

    set res [ cookCliData [Dut-$dut sendCliCommand "show system rollback | match \"No. of Rollback Files:\""]]
    regexp {No. of Rollback Files:.*([0-9]+)} $res rollCount rollCount

    for { set num 0 } { $num < $rollCount } { incr num } {
        set rCli [Dut-$dut sendCliCommand "/admin rollback delete latest-rb"]
        log_msg INFO "$rCli"
        set res [ cookCliData [Dut-$dut sendCliCommand "show system rollback | match \"Last Rollback Delete Result:\""]]
        if { ! [regexp {Last Rollback Delete Result: Successful} $res] } {
            set result FAILED
        }
    }
    set rCli [Dut-$dut sendCliCommand "/configure system rollback no rollback-location"]
    log_msg INFO "$rCli"

    return $result
}

proc serviceAwareFilter_adminSave {dut args} {

    global logdir
    set result PASSED

    set opt(method)     "" ; # 0 | 1 | 2

    getopt opt $args

    if { $opt(method) == "" } {
        set method [random 3]
    } else {
        set method $opt(method)
    }

    if { $method == 0 } {
        set method "detail"
        set fileName "serviceAwareFilter_Dut-${dut}_detail.cfg"
    } elseif { $method == 1 }  {
        set method "index"
        set fileName "serviceAwareFilter_Dut-${dut}_index.cfg"
    } else {
        set method ""
        set fileName "serviceAwareFilter_Dut-${dut}.cfg"
    }
    set username $::TestDB::thisTestBed
    set hostIp $::TestDB::thisHostIpAddr
    set dir "ftp://${username}:tigris@${hostIp}/$logdir/device_logs"

    Dut-$dut getSysName

    log_msg INFO "Saving config file $fileName"
    set CLI [ cookCliData [ Dut-$dut sendCliCommand "/admin save $method $dir/$fileName" -timeout 20]]
    if { [ string first "Completed" $CLI ] < 1 } {
        log_msg DEBUG "$CLI"
        log_msg ERROR "Save of $fileName FAILED!"
        set result FAILED
    }

    return $result
}

proc serviceAwareFilter_adminExec {dut args} {

    global logdir
    set result PASSED

    set opt(method)     "" ; # 0 | 1 | 2

    getopt opt $args

    if { $opt(method) == 0 } {
        set fileName "serviceAwareFilter_Dut-${dut}_detail.cfg"
    } elseif { $opt(method) == 1 }  {
        set fileName "serviceAwareFilter_Dut-${dut}_index.cfg"
    } else {
        set fileName "serviceAwareFilter_Dut-${dut}.cfg"
    }

    set username $::TestDB::thisTestBed
    set hostIp $::TestDB::thisHostIpAddr
    set dir "ftp://${username}:tigris@${hostIp}/$logdir/device_logs"

    Dut-$dut getSysName

    log_msg INFO "Executing saved config file $fileName"
    Dut-$dut sendCliCommand "exit all"
    set CLI [ cookCliData [ Dut-$dut sendCliCommand "exec $dir/$fileName" -timeout 20]]

    if { [ string first "Executed" $CLI ] < 1 } {
        log_msg DEBUG "$CLI"
        log_msg ERROR "Exec of $fileName FAILED"
        set result FAILED
    }

    return $result
}

proc serviceAwareFilter_checkFilter {dut family filterId entryId args} {

    set opt(scope)                      "template"
    set opt(applied)                    "No"
    set opt(svcType)                    "vprn"
    set opt(svcId)                      1
    set opt(direction)                  "Ingress"
    set opt(nofilter)                   "false"
    set opt(association)                "vprnNetIng"
    set opt(filter_row_status)          "active"
    #set opt(filter_para_row_status)     "active"
    set opt(svcFilterId)                0
    set opt(maxFilterId)                65535
    set opt(checkServiceFId)            "false"

    getopt opt $args

    set result PASSED

    if { [string tolower $family] == "ipv4" } {
        set filterType "IP"
    } elseif { [string tolower $family] == "ipv6" } {
        set filterType "IPv6"
    } elseif { [string tolower $family] == "mac" } {
        set filterType "Mac"
    } else {
        log_msg WARNING "Unsupported filter type: $family!"
        return FAILED
    }

#ref_count

    set res [cookCliData [Dut-$dut sendCliCommand "show filter [string tolower $filterType] $filterId associations" ]]

    if { ($filterId > $opt(maxFilterId)) || ($filterId == 0) } {

        set res [string map {"\n" ""} $res]
        set res [string trim $res]

        if { $res == "^Error: Invalid parameter." } {
            log_msg INFO "Out of range filter id: $filterId"
            log_msg INFO "Expected error returned: $res"
            return $result
        } else {
            log_msg INFO "Out of range filter id: $filterId"
            log_msg ERROR "Unexpected error returned: $res"
            return FAILED
        }
    }

    if { $filterType == "IP" || $filterType == "IPv6" } {
        set resSnmpSvcFiId  [Dut-$dut getSvcNetIng${filterType}FilterId $opt(svcId) ]
    } else {
        set resSnmpSvcFiId "0"
    }
#    set resSnmpSvcLaCh  [Dut-$dut getSvcVprnInfoEntryLastChanged $opt(svcId) ]

    set resSnmpFiRoSt   [Dut-$dut getT${filterType}FilterRowStatus $filterId ]
    set resSnmpFiSc     [Dut-$dut getT${filterType}FilterScope $filterId ]
#    set resSnmpFiPaRoSt [Dut-$dut getT${filterType}FilterParamsRowStatus $filterId $entryId ]

    # puts "service filter id        : $resSnmpSvcFiId"
    # puts "service last change      : $resSnmpSvcLaCh"
    # puts "filter row status        : $resSnmpFiRoSt"
    # puts "filter scope             : $resSnmpFiSc"
    # puts "filter params row status : $resSnmpFiPaRoSt"

    if { $opt(nofilter) } {
        if { [regexp -nocase -line "=*\n$filterType Filter\n=*\nNo Matching Filter\n=*" $res out] } {
            #puts $out
            log_msg INFO "No Filter (cli) ....................... OK"
            set out ""
        } else {
            set result ERROR
            log_msg ERROR "No Filter (cli) ...................... ERROR"
            set out ""
        }
        if { $resSnmpFiRoSt == "ERROR" } {
            log_msg INFO "No Filter (snmp) ...................... OK (=$resSnmpFiRoSt)"
        } else {
            set result ERROR
            log_msg ERROR "No Filter (snmp) ..................... ERROR (=$resSnmpFiRoSt)"
        }
        if { $resSnmpSvcFiId == $opt(svcFilterId) } {
            log_msg INFO "Filter associated with vprn (snmp) .... OK (=$resSnmpSvcFiId)"
        } else {
            set result ERROR
            log_msg ERROR "Filter associated with vprn (snmp) ... ERROR (=$resSnmpSvcFiId)"
        }

    } else {

        # row status
        if { $resSnmpFiRoSt == $opt(filter_row_status) } {
            log_msg INFO "Filter Row Status (snmp) .............. OK (=$resSnmpFiRoSt)"
        } else {
            set result ERROR
            log_msg ERROR "Filter Row Status (snmp) ............. ERROR (=$resSnmpFiRoSt)"
        }

        # params row status
        #if { $resSnmpFiPaRoSt == $opt(filter_para_row_status) } {
        #    log_msg INFO "Filter Params Row Status (snmp) ....... OK"
        #} else {
        #    set result ERROR
        #    log_msg ERROR "Filter Params Row Status (snmp) ...... ERROR"
        #}

        # scope
        if { [regexp -nocase -line "Scope * : $opt(scope)" $res out] } {
            #puts $out
            log_msg INFO "Filter Scope (cli) .................... OK (=$opt(scope))"
            set out ""
        } else {
            set result ERROR
            log_msg ERROR "Filter Scope (cli) ................... ERROR"
            set out ""
        }
        if { $resSnmpFiSc == $opt(scope) } {
            log_msg INFO "Filter Scope (snmp) ................... OK (=$resSnmpFiSc)"
        } else {
            set result ERROR
            log_msg ERROR "Filter Scope (snmp) .................. ERROR (=$resSnmpFiSc)"
        }

        # applied
        if { $opt(scope) != "embedded"} {
            if { [regexp -nocase -line "Applied * : $opt(applied)" $res out] } {
                #puts $out
                log_msg INFO "Filter Applied (cli) .................. OK (=$opt(applied))"
                set out ""
            } else {
                set result ERROR
                log_msg ERROR "Filter Applied (cli) ................. ERROR"
                set out ""
            }
        }

        # associations


        if { $opt(association) == "vprnNetIng" } {

            if { [GGV 7710Support] } {
                # sparrow / sicily
                set exp "Filter Association : $filterType.*Service Id * : $opt(svcId) * Type * : $opt(svcType).* - Network * \\($opt(direction)\\)"
            } else {
                set chassisIdx 1; set i 1
                while { [Dut-C getTmnxCardHwIndex $chassisIdx $i] != "ERROR" } { incr i }
                set iomString [range 1 $i]
                set exp "Filter Association : $filterType.*Service Id * : $opt(svcId) * Type * : $opt(svcType).* - Network * \\($opt(direction)\\).*Filter associated with IOM: $iomString"
            }
            if { [regexp -nocase $exp $res out] } {
                #puts $out
                log_msg INFO "Filter Associations (cli) ............. OK"
                set out ""
            } else {
                #puts $out
                set result ERROR
                log_msg ERROR "Filter Associations (cli) ............ ERROR"
                set out ""
            }
            if { $resSnmpSvcFiId == $opt(svcFilterId) } {
                log_msg INFO "Filter associated with vprn (snmp) .... OK (=$resSnmpSvcFiId)"
            } else {
                set result ERROR
                log_msg ERROR "Filter associated with vprn (snmp) ... ERROR (=$resSnmpSvcFiId)"
            }
        }

        if { $opt(checkServiceFId) } {
            if { $resSnmpSvcFiId == $opt(svcFilterId) } {
                log_msg INFO "Filter associated with vprn (snmp) .... OK (=$resSnmpSvcFiId)"
            } else {
                set result ERROR
                log_msg ERROR "Filter associated with vprn (snmp) ... ERROR (=$resSnmpSvcFiId)"
            }
        }
    }

    if { $result == "ERROR" } { puts $res }

    return $result
}

proc serviceAwareFilter_checkErrMsg {dut mode fScope fType fExists action args} {

    set opt(errMsg)         ""
    set opt(fId)            0
    set opt(maxFilterId)    65535
    set opt(filterName)     ""
    set opt(maxFilterName)  64
    set opt(referenced)     false

    getopt opt $args

    set result "noError"

    if { $fExists } { ; # filter exists

        if { $action == "apply" } {

            if { $mode == "cli" } {

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {

                    if { ($opt(filterName) != "") && ([expr [string length $opt(filterName)] -2] > $opt(maxFilterName)) } {
                        if { $opt(errMsg) == "^Error: Invalid parameter." } {
                            log_msg INFO "Expected error returned: $opt(errMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                            set result ERROR
                        }

                    } else {

                        if { $fScope == "exclusive" } {
                            if { $opt(errMsg) == "MINOR: SVCMGR #8203 Cannot assign filter to a VPRN network - must be template." } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } elseif { $fScope == "system" } {
                            if { $opt(errMsg) == "MINOR: SVCMGR #2654 Cannot apply system filter" } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } elseif { $fScope == "embedded" } {
                            if { $opt(errMsg) == "MINOR: SVCMGR #1619 Cannot apply an embedded filter" } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }
                    }

                } else {

                    if { $opt(errMsg) == "^Error: Invalid parameter." } {
                        log_msg INFO "Expected error returned: $opt(errMsg)"
                    } else {
                        log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                        set result ERROR
                    }
                }

            } elseif { $mode == "snmp" } {

                array set err [getTmnxSnmpSetErrsEntry $dut -printAll 0 -verbose 0 -returnLastArray 1]

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {
                    if { $fScope == "exclusive" } {
                        if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "SVCMGR") && ($err(tmnxSseErrorCode) == "8203") \
                                                                   && ($err(tmnxSseErrorMsg) == "Cannot assign filter to a VPRN network - must be template.") } {
                            log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            set result ERROR
                        }
                    } elseif { $fScope == "system" } {
                        if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "SVCMGR") && ($err(tmnxSseErrorCode) == "2654") \
                                                                   && ($err(tmnxSseErrorMsg) == "Cannot apply system filter") } {
                            log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            set result ERROR
                        }
                    } elseif { $fScope == "embedded" } {
                        if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "SVCMGR") && ($err(tmnxSseErrorCode) == "1619") \
                                                                   && ($err(tmnxSseErrorMsg) == "Cannot apply an embedded filter") } {
                            log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            set result ERROR
                        }
                    }
                }
                # no snmp functions for other filter types, hence to error to check :)
            }

        } elseif { $action == "remove" } {

            if { $mode == "cli" } {

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {

                    if { $opt(filterName) != "" } {

                        if { [expr [string length $opt(filterName)] -2] > $opt(maxFilterName) } {
                            # invalid parameter
                            if { $opt(errMsg) == "^Error: Invalid parameter." } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            if { $opt(referenced) } {
                                #
                                if { [string first "MINOR: FILTER #1213 Cannot delete a referenced filter" $opt(errMsg)] == 0} {
                                    log_msg INFO "Expected error returned: $opt(errMsg)"
                                } else {
                                    log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                    set result ERROR
                                }
                            } else {
                                # filter exists, but it is not assigned
                                #if { $fType == "ipv4" } { set fType "ip" }
                                if { [string first "MINOR: CLI Invalid [string tolower $fType] filter-id: $opt(fId)." $opt(errMsg)] == 0} {
                                    log_msg INFO "Expected error returned: $opt(errMsg)"
                                } else {
                                    log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                    set result ERROR
                                }
                            }
                        }

                    } else {
                        if { $opt(referenced) } {
                            #
                            if { [string first "MINOR: FILTER #1213 Cannot delete a referenced filter" $opt(errMsg)] == 0} {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            if { [regexp "MINOR: CLI Invalid [string tolower $fType] filter-id: $opt(fId)." $opt(errMsg)] } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }
                    }
                } else {
                    if { $opt(errMsg) == "^Error: Invalid parameter." } {
                        log_msg INFO "Expected error returned: $opt(errMsg)"
                    } else {
                        log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                        set result ERROR
                    }
                }

            } else { ; # snmp

                if { $opt(referenced) } {
                    #
                    array set err [getTmnxSnmpSetErrsEntry $dut -printAll 0 -verbose 0 -returnLastArray 1]

                    if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {
                        if { $opt(fId) > $opt(maxFilterId) } {
                            if { ($opt(errMsg) == "wrongValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "AGENT") && ($err(tmnxSseErrorCode) == "10") \
                                                                         && ($err(tmnxSseErrorMsg) == "Wrong Value error") } {
                                log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                                set result ERROR
                            }
                        } else {
                            if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "FILTER") && ($err(tmnxSseErrorCode) == "1213") \
                                                                         && ($err(tmnxSseErrorMsg) == "Cannot delete a referenced filter") } {
                                log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                                set result ERROR
                            }
                        }
                    }

                } else {
                    log_msg ERROR "No error checking for snmp!"
                    set result ERROR
                }
            }

        } elseif { $action == "changeScope" } {

            if { $mode == "cli" } {

                if { [string first "MINOR: FILTER #1224 Cannot change scope of the filter - filter is used as network ingress filter in a VPRN" $opt(errMsg)] == 0 } {
                    log_msg INFO "Expected error returned: $opt(errMsg)"
                } else {
                    log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                    set result ERROR
                }

            } elseif { $mode == "snmp" } {

                array set err [getTmnxSnmpSetErrsEntry $dut -printAll 0 -verbose 0 -returnLastArray 1]

                if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "FILTER") && ($err(tmnxSseErrorCode) == "1224") \
                                                             && ($err(tmnxSseErrorMsg) == "Cannot change scope of the filter") && ($err(tmnxSseExtraText) == "filter is used as network ingress filter in a VPRN") } {
                    log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                } else {
                    log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                    set result ERROR
                }
            }
        }

    } else { ; # filter does not exist

        if { $action == "apply" } {

            if { $mode == "cli" } {

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {

                    if { $opt(filterName) != "" } {

                        if { [expr [string length $opt(filterName)] -2] > $opt(maxFilterName) } {
                            # invalid parameter
                            set opt(errMsg) [string trim $opt(errMsg)]
                            if { $opt(errMsg) == "^Error: Invalid parameter." } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            set opt(errMsg) [string trim $opt(errMsg)]
                            if { $fType == "ipv4" } { set fType "ip" }
                            if { [string first "^MINOR: CLI Invalid [string tolower $fType] filter-id $opt(filterName)." $opt(errMsg)] == 0} {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }

                    } else {

                        if { $opt(fId) > $opt(maxFilterId) } {
                            if { $opt(errMsg) == "MINOR: AGENT #10 Wrong Value error" } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            if { $opt(errMsg) == "MINOR: SVCMGR #1618 Invalid filter-id" } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }
                    }
                } else {
                    if { $opt(errMsg) == "^Error: Invalid parameter." } {
                        log_msg INFO "Expected error returned: $opt(errMsg)"
                    } else {
                        log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                        set result ERROR
                    }
                }

            } elseif { $mode == "snmp" } {

                array set err [getTmnxSnmpSetErrsEntry $dut -printAll 0 -verbose 0 -returnLastArray 1]

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {
                    if { $opt(fId) > $opt(maxFilterId) } {
                        if { ($opt(errMsg) == "wrongValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "AGENT") && ($err(tmnxSseErrorCode) == "10") \
                                                                     && ($err(tmnxSseErrorMsg) == "Wrong Value error") } {
                            log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            set result ERROR
                        }
                    } else {
                        if { ($opt(errMsg) == "inconsistentValue") && ([string toupper $err(tmnxSseSeverityLevel)] == "MINOR") && ($err(tmnxSseModuleName) == "SVCMGR") && ($err(tmnxSseErrorCode) == "1618") \
                                                                     && ($err(tmnxSseErrorMsg) == "Invalid filter-id") } {
                            log_msg INFO "Expected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                        } else {
                            log_msg ERROR "Unexpected error returned: $opt(errMsg), $err(tmnxSseSeverityLevel), $err(tmnxSseModuleName), $err(tmnxSseErrorCode), $err(tmnxSseErrorMsg)"
                            set result ERROR
                        }
                    }
                }
                # no snmp functions for other filter types, hence to error to check :)
            }

        } elseif { $action == "remove" } {

            if { $mode == "cli" } {

                if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") } {

                    if { $opt(filterName) != "" } {

                        if { [expr [string length $opt(filterName)] -2] > $opt(maxFilterName) } {
                            # invalid parameter
                            set opt(errMsg) [string trim $opt(errMsg)]
                            if { $opt(errMsg) == "^Error: Invalid parameter." } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            # invalid filter-id
                            set opt(errMsg) [string trim $opt(errMsg)]
                            if { $fType == "ipv4" } { set fType "ip" }
                            if { [string first "^MINOR: CLI Invalid [string tolower $fType] filter-id $opt(filterName)." $opt(errMsg)] == 0 } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }

                    } else {

                        if { $opt(fId) > 4294967295 } {
                            if { $opt(errMsg) == "^Error: Invalid parameter." } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        } else {
                            # filter does not exist
                            if { [string first "MINOR: CLI Invalid [string tolower $fType] filter-id: $opt(fId)." $opt(errMsg)] == 0 } {
                                log_msg INFO "Expected error returned: $opt(errMsg)"
                            } else {
                                log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                                set result ERROR
                            }
                        }
                    }
                } else {
                    if { $opt(errMsg) == "^Error: Invalid parameter." } {
                        log_msg INFO "Expected error returned: $opt(errMsg)"
                    } else {
                        log_msg ERROR "Unexpected error returned: $opt(errMsg)"
                        set result ERROR
                    }
                }

            } elseif { $mode == "snmp" } {
                log_msg ERROR "No error checking for snmp!"
                set result ERROR
            }
        }
    }

    return $result
}

proc serviceAwareFilter_CliSnmp {args} {

    serviceAwareFilter_setGlobalParams

    global dut1 dut2 dut3 dut4 dut5 dut6

    set opt(svcType)        "vprn"
    set opt(svcId)          "1"
    set opt(family)         "Ipv4"
    set opt(direction)      "Ingress"
    set opt(filterId)       "1"
    set opt(entryId)        "1"

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    if { [string tolower $opt(family)] == "ipv4" } {
        set filterType "IP"
    } elseif { [string tolower $opt(family)] == "ipv6" } {
        set filterType "IPv6"
    }

    # check filter associations (dts 187309)
    myset result [mysendCli Dut-$dut2 "/configure filter ip-filter 1 create"]
    myset result [mysendCli Dut-$dut2 "/configure service vprn 1 create customer 1"]
    set temp [cookCliData [Dut-$dut2 sendCliCommand "show filter ip 1 associations"]]
    if { [regexp "Service Id" $temp] || [regexp "Filter not associated with any IOM" $temp] || [regexp "Type .* VPRN" $temp] || [regexp "Network .*Ingress" $temp] } {
        lappend res "ERROR"
        log_msg INFO "Filter associations check FAILED! (dts 187309)"
    } elseif { [regexp "No Match Found" $temp] } {
        lappend res "PASSED"
        log_msg INFO "Filter associations check PASSED (dts 187309)"
    }
    myset result [mysendCli Dut-$dut2 "/configure filter no ip-filter 1"]
    myset result [mysendCli Dut-$dut2 "/configure service no vprn 1"]

    ###############################################
    puts "" ; log_msg INFO "HELP/AUTOCOMPLETE" ; puts ""
    ###############################################

    lappend res [serviceAwareFilter_checkHelpAndAutocomplete -dutList "Dut-C"]
    log_msg DEBUG "Check Help/Autocomplete Result: [lindex $res end]"


    ###############################################
    puts "" ; log_msg INFO "CONFIG" ; puts ""
    ###############################################

    lappend res [serviceAwareFilter_config]
    log_msg DEBUG "Config Result: [lindex $res end]"


    ###############################################
    puts "" ; log_msg INFO "CHASSIS MODE" ; puts ""
    ###############################################

    if { [Dut-$dut2 getTmnxChassisAdminMode 1] < "modeD" } {
        log_msg NOTICE "Chassis mode is lower than required for this feature. Test will be SKIPPED!"
        #test negative case
        log_msg INFO "Create and check filter"
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
        log_msg DEBUG "Create Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"
        
        log_msg INFO "Apply filter"
        set mode [expr [random 2]=="0"?"cli":"snmp"]
        if { $mode == "snmp" } {
            set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId) -mode $mode]
            # check err msg
            if { $temp != "inconsistentValue" } {
                log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong return value   : $temp"
                log_msg ERROR "serviceAwareFilter_applyFilter -> Expected return value: inconsistentValue"
                lappend res $temp
            } else {
                log_msg INFO "serviceAwareFilter_applyFilter -> Correct return value: $temp"
                lappend res "noError"
            }
        } else {
            set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId) -mode $mode -returnCliError true]
            # check err msg
            if { [lindex $temp 1] != "MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN." } {
                log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong error message   : [lindex $temp 1]"
                log_msg ERROR "serviceAwareFilter_applyFilter -> Expected error message: MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN."
                lappend res [lindex $temp 0]
            } else {
                log_msg INFO "serviceAwareFilter_applyFilter -> Correct error message: [lindex $temp 1]"
                lappend res "noError"
            }
        }
        log_msg INFO "Check filter again"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"

        log_msg INFO "Destroy filter"
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
        log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"

        # deconfig
        lappend res [serviceAwareFilter_deconfig]

        foreach r $res {
            if { ($r != "PASSED") && ($r != "noError") } {
                set result ERROR
            }
        }
        if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

        if { $result == "PASSED" } {
            log_result PASSED $testid
        } else  {
            log_result FAILED $testid
        }

        return $result
    } else {
        log_msg INFO "Chassis mode check PASSED."
    }


    ###########################################
    puts "" ; log_msg INFO "ASTERISK" ; puts ""
    ###########################################

    lappend res [serviceAwareFilter_checkAsterisk -dutList "Dut-C"]
    log_msg DEBUG "Check Asterisk Result: [lindex $res end]"


    ###############################################
    puts "" ; log_msg INFO "APPLY/REMOVE" ; puts ""
    ###############################################

    lappend res [serviceAwareFilter_applyRemove -dutList "Dut-C"]
    log_msg DEBUG "Check Apply/Remove Result: [lindex $res end]"


    ###############################################
    puts "" ; log_msg INFO "TRAPS" ; puts ""
    ###############################################

    lappend res [serviceAwareFilter_checkTraps -dutList "Dut-C"]
    log_msg DEBUG "Check Traps Result: [lindex $res end]"


    ###########################################
    puts "" ; log_msg INFO "ROLLBACK" ; puts ""
    ###########################################

    # create and apply filter
    log_msg INFO "######################################"
    log_msg INFO "   create and apply filter"
    log_msg INFO "######################################"
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
    log_msg DEBUG "Create Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId)]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    # rollback save
    log_msg INFO "######################################"
    log_msg INFO "   rollback save"
    log_msg INFO "######################################"
    set rollIdx "latest-rb"
    lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
    log_msg DEBUG "Rollback save result: [lindex $res end]"

    # remove and destroy filter
    log_msg INFO "######################################"
    log_msg INFO "   remove and destroy filter"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true"]
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    # rollback restore (1st)
    log_msg INFO "######################################"
    log_msg INFO " rollback restore (1st)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
    log_msg DEBUG "Rollback restore result: [lindex $res end]"

    # check filter after 1st rollback restore
    log_msg INFO "######################################"
    log_msg INFO "   check filter (1st)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    #if { [GGV checkDTS] == "193767" } {

        # remove whole service
        log_msg INFO "######################################"
        log_msg INFO "   remove whole service"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_cleanupService -cleanupDut1 "false"]
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        log_msg DEBUG "Remove service result: [lindex $res end]"

        # rollback restore (2nd)
        log_msg INFO "######################################"
        log_msg INFO "   rollback restore (2nd)"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
        log_msg DEBUG "Rollback restore result: [lindex $res end]"

        # check filter after 2nd rollback restore
        log_msg INFO "######################################"
        log_msg INFO "   check filter (2nd)"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
    #}

    # remove and destroy filter
    log_msg INFO "######################################"
    log_msg INFO "   remove and destroy filter"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true"]
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    # delete rollback(s)
    log_msg INFO "######################################"
    log_msg INFO "   delete rollback files"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackCleanup $dut2]
    log_msg DEBUG "Rollback files cleanup result: [lindex $res end]"

    # vice versa (rollback save without filter, use rollback restore to "deconfig")

    # rollback save
    log_msg INFO "######################################"
    log_msg INFO "   rollback save"
    log_msg INFO "######################################"
    set rollIdx "latest-rb"
    lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
    log_msg DEBUG "Rollback save result: [lindex $res end]"

    # create and apply filter
    log_msg INFO "######################################"
    log_msg INFO "   create and apply filter"
    log_msg INFO "######################################"
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
    log_msg DEBUG "Create Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0  -checkServiceFId "true"]
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId)]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    # rollback restore (3rd)
    log_msg INFO "######################################"
    log_msg INFO " rollback restore (3rd)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
    log_msg DEBUG "Rollback restore result: [lindex $res end]"

    # check filter after 3rd rollback restore
    log_msg INFO "######################################"
    log_msg INFO "   check filter (3rd)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    # delete rollback(s)
    log_msg INFO "######################################"
    log_msg INFO "   delete rollback files"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackCleanup $dut2]
    log_msg DEBUG "Rollback files cleanup result: [lindex $res end]"

    # remove service, rollback save, re-add service + filter, rollback restore

    # remove whole service
    log_msg INFO "######################################"
    log_msg INFO "   remove whole service"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_cleanupService -cleanupDut1 "false"]
    log_msg DEBUG "Remove service result: [lindex $res end]"

    # rollback save
    log_msg INFO "######################################"
    log_msg INFO "   rollback save"
    log_msg INFO "######################################"
    set rollIdx "latest-rb"
    lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
    log_msg DEBUG "Rollback save result: [lindex $res end]"

    # re-add whole service
    log_msg INFO "######################################"
    log_msg INFO "   re-add whole service"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_setupService -setupDut1 "false"]
    log_msg DEBUG "Re-add service result: [lindex $res end]"

    # create and apply filter
    log_msg INFO "######################################"
    log_msg INFO "   create and apply filter"
    log_msg INFO "######################################"
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
    log_msg DEBUG "Create Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0  -checkServiceFId "true"]
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId)]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    # rollback restore (4th)
    log_msg INFO "######################################"
    log_msg INFO " rollback restore (4th)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
    log_msg DEBUG "Rollback restore result: [lindex $res end]"

    # check filter after 4th rollback restore
    log_msg INFO "######################################"
    log_msg INFO "   check filter (4th)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId "ERROR"]

    # re-add whole service
    log_msg INFO "######################################"
    log_msg INFO "   re-add whole service"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_setupService -setupDut1 "false"]
    log_msg DEBUG "Re-add service result: [lindex $res end]"

    # delete rollback(s)
    log_msg INFO "######################################"
    log_msg INFO "   delete rollback files"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackCleanup $dut2]
    log_msg DEBUG "Rollback files cleanup result: [lindex $res end]"


    ##################################################
    puts "" ; log_msg INFO "ADMIN SAVE/EXEC" ; puts ""
    ##################################################

    set method [random 3]

    # rollback save
    log_msg INFO "######################################"
    log_msg INFO "   rollback save"
    log_msg INFO "######################################"
    set rollIdx "latest-rb"
    lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
    log_msg DEBUG "Rollback save result: [lindex $res end]"

    # create and apply filter
    log_msg INFO "######################################"
    log_msg INFO "   create and apply filter"
    log_msg INFO "######################################"
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
    log_msg DEBUG "Create Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0  -checkServiceFId "true"]
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId)]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    # admin save
    log_msg INFO "######################################"
    log_msg INFO "   admin save"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_adminSave $dut2 -method $method]
    log_msg DEBUG "Admin Save Result: [lindex $res end]"

    # remove and destroy filter
    log_msg INFO "######################################"
    log_msg INFO "   remove and destroy filter"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0  -checkServiceFId "true"]
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    # 1st exec
    log_msg INFO "######################################"
    log_msg INFO "   admin exec (1st)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
    log_msg DEBUG "Admin Exec Result: [lindex $res end]"

    # 2nd exec
    log_msg INFO "######################################"
    log_msg INFO "   admin exec (2nd)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
    log_msg DEBUG "Admin Exec Result: [lindex $res end]"

    # check filter
    log_msg INFO "######################################"
    log_msg INFO "   check filter after exec(s)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    #if { [GGV checkDTS] == "193767" } {
        # deconfig service and filter
        log_msg INFO "######################################"
        log_msg INFO "   remove whole service and filter"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_cleanupService -cleanupDut1 "false"]
        log_msg DEBUG "Remove service result: [lindex $res end]"
        #lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
        log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId "ERROR"]

        # 3rd exec
        log_msg INFO "######################################"
        log_msg INFO "   admin exec (3rd)"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
        log_msg DEBUG "Admin Exec Result: [lindex $res end]"

        # 4th exec
        log_msg INFO "######################################"
        log_msg INFO "   admin exec (4th)"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
        log_msg DEBUG "Admin Exec Result: [lindex $res end]"

        # check filter
        log_msg INFO "######################################"
        log_msg INFO "   check filter after exec(s)"
        log_msg INFO "######################################"
        lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
    #}

    # rollback restore
    log_msg INFO "######################################"
    log_msg INFO " rollback restore"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
    log_msg DEBUG "Rollback restore result: [lindex $res end]"

    # 5th exec
    log_msg INFO "######################################"
    log_msg INFO "   admin exec (5th)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
    log_msg DEBUG "Admin Exec Result: [lindex $res end]"

    # 6th exec
    log_msg INFO "######################################"
    log_msg INFO "   admin exec (6th)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_adminExec $dut2 -method $method]
    log_msg DEBUG "Admin Exec Result: [lindex $res end]"

    # check filter
    log_msg INFO "######################################"
    log_msg INFO "   check filter after exec(s)"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    # remove and destroy filter
    log_msg INFO "######################################"
    log_msg INFO "   remove and destroy filter"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true"]
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    # delete rollback(s)
    log_msg INFO "######################################"
    log_msg INFO "   delete rollback files"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_rollbackCleanup $dut2]
    log_msg DEBUG "Rollback files cleanup result: [lindex $res end]"

    # admin save with reboot

    # adminSaveConfig Dut-$dut2

    ##################################################
    puts "" ; log_msg INFO "LAST CHANGED" ; puts ""
    ##################################################

    set resSnmpSvcLaCh_before  [Dut-$dut2 getSvcVprnInfoEntryLastChanged $opt(svcId) ]

    # create and apply filter
    log_msg INFO "######################################"
    log_msg INFO "   create and apply filter"
    log_msg INFO "######################################"
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
    log_msg DEBUG "Create Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) $opt(filterId)]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]

    set resSnmpSvcLaCh_after   [Dut-$dut2 getSvcVprnInfoEntryLastChanged $opt(svcId) ]

    if { $resSnmpSvcLaCh_after <= $resSnmpSvcLaCh_before } {
        lappend res "ERROR"
        log_msg ERROR "SvcVprnInfoEntryLastChanged did not change after applying filter (before: $resSnmpSvcLaCh_before after: $resSnmpSvcLaCh_after)"
    } else {
        log_msg DEBUG "SvcVprnInfoEntryLastChanged changed after applying filter (before: $resSnmpSvcLaCh_before after: $resSnmpSvcLaCh_after)"
    }

    set resSnmpSvcLaCh_before  [Dut-$dut2 getSvcVprnInfoEntryLastChanged $opt(svcId) ]

    # remove and destroy filter
    log_msg INFO "######################################"
    log_msg INFO "   remove and destroy filter"
    log_msg INFO "######################################"
    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $opt(family) $opt(direction) 0]
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
    lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
    lappend res [serviceAwareFilter_checkFilter $dut2 $opt(family) $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]

    set resSnmpSvcLaCh_after   [Dut-$dut2 getSvcVprnInfoEntryLastChanged $opt(svcId) ]

    if { $resSnmpSvcLaCh_after <= $resSnmpSvcLaCh_before } {
        lappend res "ERROR"
        log_msg ERROR "SvcVprnInfoEntryLastChanged did not change after filter was removed (before: $resSnmpSvcLaCh_before after: $resSnmpSvcLaCh_after)"
    } else {
        log_msg DEBUG "SvcVprnInfoEntryLastChanged changed after filter was removed (before: $resSnmpSvcLaCh_before after: $resSnmpSvcLaCh_after)"
    }

    ##################################################

    # deconfig
    lappend res [serviceAwareFilter_deconfig]

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") } {
            set result ERROR
        }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_checkHelpAndAutocomplete {args} {

    set opt(svcType)    vprn
    set opt(svcId)      1
    set opt(dutList)    ""

    getopt opt $args

    set result PASSED

    if { $opt(dutList) == "" } {
        set opt(dutList) [getDutList]
    }

    foreach dut $opt(dutList) {

        puts "##################\n     $dut     \n##################"

        set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]

        unixCommand $session "/configure service $opt(svcType) $opt(svcId) create customer 1" -matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)\\$ $"
        unixCommand $session "/configure filter ip-filter 4 create" -matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>filter>ip-filter\\$ $"
        unixCommand $session "/configure filter ip-filter 4 filter-name filter4"
        unixCommand $session "/configure filter ip-filter 41 create scope exclusive"
        unixCommand $session "/configure filter ip-filter 41 filter-name filter41"
        unixCommand $session "/configure filter ip-filter 42 create scope embedded"
        unixCommand $session "/configure filter ip-filter 42 filter-name filter42"
        unixCommand $session "/configure filter ip-filter 43 create scope system"
        unixCommand $session "/configure filter ip-filter 43 filter-name filter43"
        unixCommand $session "/configure filter ipv6-filter 6 create" -matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>filter>ipv6-filter\\$ $"
        unixCommand $session "/configure filter ipv6-filter 6 filter-name filter6"
        unixCommand $session "/configure filter ipv6-filter 61 create scope exclusive"
        unixCommand $session "/configure filter ipv6-filter 61 filter-name filter61"
        unixCommand $session "/configure filter ipv6-filter 62 create scope embedded"
        unixCommand $session "/configure filter ipv6-filter 62 filter-name filter62"
        unixCommand $session "/configure filter ipv6-filter 63 create scope system"
        unixCommand $session "/configure filter ipv6-filter 63 filter-name filter63"
        unixCommand $session "/configure filter mac-filter 9 create" -matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>filter>mac-filter\\$ $"
        unixCommand $session "/configure filter mac-filter 9 filter-name filter9"
        unixCommand $session "/configure filter mac-filter 91 create scope exclusive"
        unixCommand $session "/configure filter mac-filter 91 filter-name filter91"
        unixCommand $session "/environment no more"
        unixCommand $session "exit all"

        # /configure service $opt(svcType) $opt(svcId) ?

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)# $"
            }
            exp_send -i $session "?"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n      network         \\+ Configure network policy\r\n.*${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # /configure service $opt(svcType) $opt(svcId) \t

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)# $"
            }
            exp_send -i $session "\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "network .*${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ?

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network# $"
            }
            exp_send -i $session "?"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n      ingress         \\+ Configure ingress policies\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmd}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network \t

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network# $"
            }
            exp_send -i $session "\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\ningress${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) n*\t

        set cmd_part [string range "network" 0 [expr [random [expr [string length "network"] - 1]] + 1]]
        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}network"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)# network"
            }
            exp_send -i $session "${cmd_part}\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n.*network * network-interface.*${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}${cmd_part}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}${cmd_part}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress ?

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# $"
            }
            exp_send -i $session "?"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n \\\[no\\\] filter          - Apply network ingress filter\r\n.*${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmd}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress \t

        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
            } else {
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# $"
            }
            exp_send -i $session "\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\nfilter( .*|)${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network i*\t

        set cmd_part [string range "ingress" 0 [expr [random [expr [string length "ingress"] - 2]] + 2]]
        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "${cmd}ingress "
            } else {
                unixCommand $session $cmd
                set matchPrompt "ingress "
            }
            exp_send -i $session "${cmd_part}\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}${cmd_part}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}${cmd_part}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter $"
                exp_send -i $session "filter ?"
                set cmdX "${cmd}filter "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter $"
                exp_send -i $session "filter \t"
                set cmdX "${cmd}filter "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "filter .*\r\nip <ip-filter-id>\r\nipv6 <ipv6-filter-id>\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress f*\t

        set cmd_part [string range "filter" 0 [random [string length "filter"]]]
        for { set i 0 } { $i < 2 } { incr i } {
            set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
            if { $i } {
                exp_send -i $session $cmd
                set matchPrompt "${cmd}filter "
            } else {
                unixCommand $session $cmd
                set matchPrompt "filter "
            }
            exp_send -i $session "${cmd_part}\t"
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmd}${cmd_part}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmd}${cmd_part}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ip ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ip $"
                exp_send -i $session "filter ip ?"
                set cmdX "${cmd}filter ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ip \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ip $"
                exp_send -i $session "filter ip \t"
                set cmdX "${cmd}filter ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip <ip-filter-id>\r\n \"filter4\"  4\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter i*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}ip"
                exp_send -i $session "i\t"
                set cmdX "${cmd}i"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ip"
                exp_send -i $session "filter i\t"
                set cmdX "${cmd}filter i"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip    ipv6${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ip 1 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ip 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ip 1 $"
                exp_send -i $session "filter ip 1 ?"
                set cmdX "${cmd}filter ip 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ip 1 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ip 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ip 1 $"
                exp_send -i $session "filter ip 1 \t"
                set cmdX "${cmd}filter ip 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ipv6 $"
                exp_send -i $session "filter ipv6 ?"
                set cmdX "${cmd}filter ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ipv6 $"
                exp_send -i $session "filter ipv6 \t"
                set cmdX "${cmd}filter ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ipv6 <ipv6-filter-id>\r\n \"filter6\"  6\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ipv*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter "
                exp_send -i $session $cmd
                set matchPrompt "${cmd}ipv6 "
                exp_send -i $session "ipv\t"
                set cmdX "${cmd}ipv"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "filter ipv6 "
                exp_send -i $session "filter ipv\t"
                set cmdX "${cmd}filter ipv"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}$" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 1 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ipv6 1 $"
                exp_send -i $session "filter ipv6 1 ?"
                set cmdX "${cmd}filter ipv6 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 1 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress filter ipv6 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# filter ipv6 1 $"
                exp_send -i $session "filter ipv6 1 \t"
                set cmdX "${cmd}filter ipv6 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter $"
                exp_send -i $session "no filter ?"
                set cmdX "${cmd}no filter "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter $"
                exp_send -i $session "no filter \t"
                set cmdX "${cmd}no filter "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip <ip-filter-id>\r\nipv6 <ipv6-filter-id>\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no f*\t

        set cmd_part [string range "filter" 0 [random [string length "filter"]]]
        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no "
                exp_send -i $session $cmd
                set matchPrompt "${cmd}filter "
                exp_send -i $session "${cmd_part}\t"
                set cmdX "${cmd}${cmd_part}"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "no filter "
                exp_send -i $session "no ${cmd_part}\t"
                set cmdX "${cmd}no ${cmd_part}"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip $"
                exp_send -i $session "no filter ip ?"
                set cmdX "${cmd}no filter ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip $"
                exp_send -i $session "no filter ip \t"
                set cmdX "${cmd}no filter ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip <ip-filter-id>\r\n \"filter4\"  4\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter i*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}ip"
                exp_send -i $session "i\t"
                set cmdX "${cmd}i"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip"
                exp_send -i $session "no filter i\t"
                set cmdX "${cmd}no filter i"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip    ipv6${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 $"
                exp_send -i $session "no filter ip 1 ?"
                set cmdX "${cmd}no filter ip 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 $"
                exp_send -i $session "no filter ip 1 \t"
                set cmdX "${cmd}no filter ip 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ipv6 <ipv6-filter-id>\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 ipv6 $"
                exp_send -i $session "no filter ip 1 ipv6 ?"
                set cmdX "${cmd}no filter ip 1 ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 ipv6 $"
                exp_send -i $session "no filter ip 1 ipv6 \t"
                set cmdX "${cmd}no filter ip 1 ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ipv6 <ipv6-filter-id>\r\n \"filter6\"  6\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } { 
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 "
                exp_send -i $session $cmd
                set matchPrompt "${cmd}ipv6 "
                exp_send -i $session "ipv\t"
                set cmdX "${cmd}ipv"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "no filter ip 1 ipv6 "
                exp_send -i $session "no filter ip 1 ipv\t"
                set cmdX "${cmd}no filter ipv"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 2 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 2 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 ipv6 2 $"
                exp_send -i $session "no filter ip 1 ipv6 2 ?"
                set cmdX "${cmd}no filter ip 1 ipv6 2 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 2 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ip 1 ipv6 2 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ip 1 ipv6 2 $"
                exp_send -i $session "no filter ip 1 ipv6 2 \t"
                set cmdX "${cmd}no filter ip 1 ipv6 2 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 $"
                exp_send -i $session "no filter ipv6 ?"
                set cmdX "${cmd}no filter ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 $"
                exp_send -i $session "no filter ipv6 \t"
                set cmdX "${cmd}no filter ipv6 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ipv6 <ipv6-filter-id>\r\n \"filter6\"  6\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter "
                exp_send -i $session $cmd
                set matchPrompt "${cmd}ipv6 "
                exp_send -i $session "ipv\t"
                set cmdX "${cmd}ipv"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "no filter ipv6 "
                exp_send -i $session "no filter ipv\t"
                set cmdX "${cmd}no filter ipv"
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 $"
                exp_send -i $session "no filter ipv6 1 ?"
                set cmdX "${cmd}no filter ipv6 1 "
            }   
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 $"
                exp_send -i $session "no filter ipv6 1 \t"
                set cmdX "${cmd}no filter ipv6 1 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip <ip-filter-id>\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 ip $"
                exp_send -i $session "no filter ipv6 1 ip ?"
                set cmdX "${cmd}no filter ipv6 1 ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 ip $"
                exp_send -i $session "no filter ipv6 1 ip \t"
                set cmdX "${cmd}no filter ipv6 1 ip "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "ip <ip-filter-id>\r\n \"filter4\"  4\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 i*\t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 "
                exp_send -i $session $cmd
                set matchPrompt "${cmd}ip "
                exp_send -i $session "i\t"
                set cmdX "${cmd}i"
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "no filter ipv6 1 ip "
                exp_send -i $session "no filter ipv6 1 i\t"
                set cmdX "${cmd}no filter ipv6 1 ip "
            }   
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip 2 ?

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip 2 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "?"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 ip 2 $"
                exp_send -i $session "no filter ipv6 1 ip 2 ?"
                set cmdX "${cmd}no filter ipv6 1 ip 2 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "\r\n  - filter ip <ip-filter-id>\r\n  - filter ipv6 <ipv6-filter-id>\r\n  - no filter \\\[ip <ip-filter-id>\\\] \\\[ipv6 <ipv6-filter-id>\\\]\r\n\r\n <ip-filter-id>       : \\\[1..65535\\\]|<name:64 char max>\r\n <ipv6-filter-id>     : \\\[1..65535\\\]|<name:64 char max>\r\n\r\n${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}? .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}? .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        # /configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip 2 \t

        for { set i 0 } { $i < 2 } { incr i } {
            if { $i } {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress no filter ipv6 1 ip 2 "
                exp_send -i $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# ${cmd}$"
                exp_send -i $session "\t"
                set cmdX $cmd
            } else {
                set cmd "/configure service $opt(svcType) $opt(svcId) network ingress "
                unixCommand $session $cmd
                set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# no filter ipv6 1 ip 2 $"
                exp_send -i $session "no filter ipv6 1 ip 2 \t"
                set cmdX "${cmd}no filter ipv6 1 ip 2 "
            }
            set cli [waitForUnixPrompt $session -matchPrompt $matchPrompt]
#puts $cli
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "$dut: ${cmdX}<tab> .. PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Unexpected result:\n$cli"
                log_msg ERROR "$dut: ${cmdX}<tab> .. FAILED"
            }
            exp_send -i $session "[char 4]" ; # ctrl+c
            exp_send -i $session "\r\n"
            waitForUnixPrompt $session
            unixCommand $session "exit all"
        }

        unixCommand $session "/environment more"
        unixCommand $session "/configure service no $opt(svcType) $opt(svcId)"
        unixCommand $session "/configure filter no ip-filter 4"
        unixCommand $session "/configure filter no ip-filter 41"
        unixCommand $session "/configure filter no ip-filter 42"
        unixCommand $session "/configure filter no ip-filter 43"
        unixCommand $session "/configure filter no ipv6-filter 6"
        unixCommand $session "/configure filter no ipv6-filter 61"
        unixCommand $session "/configure filter no ipv6-filter 62"
        unixCommand $session "/configure filter no ipv6-filter 63"
        unixCommand $session "/configure filter no mac-filter 9"
        unixCommand $session "/configure filter no mac-filter 91"

        closeRootUser $session

    }

    return $result
}

proc serviceAwareFilter_checkAsterisk {args} {

    serviceAwareFilter_setGlobalParams

    global dut1 dut2 dut3 dut4 dut5 dut6

    set opt(dutList)        ""
    set opt(svcType)        "vprn"
    set opt(svcId)          1
    set opt(skipConfig)     "true"

    getopt opt $args

    set result PASSED

    if { $opt(dutList) == "" } {
        set opt(dutList) [getDutList]
    }

    foreach dut $opt(dutList) {

        set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
        unixCommand $session "/environment no more"
        unixCommand $session "/configure log no event-damping" ; # related to problem in dts 192541
        unixCommand $session "exit all"

        #rollback save ?

        #configure service

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service $opt(svcType) $opt(svcId) create customer 1"
            unixCommand $session "exit all"
        }
        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        #create filter(s)

        lappend res [$dut setTIPFilterRowStatus 4 "createAndGo"]
        log_msg DEBUG "Create IP Filter Result: [lindex $res end]"
        lappend res [$dut setTIPv6FilterRowStatus 6 "createAndGo"]
        log_msg DEBUG "Create IPv6 Filter Result: [lindex $res end]"

        unixCommand $session "/configure filter"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        #check *

        set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (*) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (*) FAILED!"
        }

        #admin save

        lappend res [serviceAwareFilter_adminSave [getDutLetterFromDutString $dut]]
        log_msg DEBUG "Admin Save Result: [lindex $res end]"

        #check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        # goto service>vprn>network and check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network# $"
        set cli [unixCommand $session "/configure service $opt(svcType) $opt(svcId) network" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        # goto service>vprn>network>ingress and check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}>config>service>$opt(svcType)>network>ingress# $"
        set cli [unixCommand $session "/configure service $opt(svcType) $opt(svcId) network ingress" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        unixCommand $session "exit all"

        # assign ip filter (cli/snmp)

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        lappend res [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) ipv4 Ingress 4]
        log_msg DEBUG "Apply IP Filter Result: [lindex $res end]"

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        # check *

        set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (*) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (*) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check *

            set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (*) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (*) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        #admin save

        lappend res [serviceAwareFilter_adminSave [getDutLetterFromDutString $dut]]
        log_msg DEBUG "Admin Save Result: [lindex $res end]"

        #check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        # assign ipv6 filter (cli/snmp)

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        lappend res [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) ipv6 Ingress 6]
        log_msg DEBUG "Apply IPv6 Filter Result: [lindex $res end]"

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        # check *

        set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (*) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (*) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check *

            set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (*) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (*) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # admin save

        lappend res [serviceAwareFilter_adminSave [getDutLetterFromDutString $dut]]
        log_msg DEBUG "Admin Save Result: [lindex $res end]"

        #check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check no *

            set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (no *) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (no *) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # remove ip filter (cli/snmp)

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        lappend res [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) ipv4 Ingress 0 -removeId 4]
        log_msg DEBUG "Remove IP Filter Result: [lindex $res end]"

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        # check *

        set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (*) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (*) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check *

            set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (*) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (*) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # admin save

        lappend res [serviceAwareFilter_adminSave [getDutLetterFromDutString $dut]]
        log_msg DEBUG "Admin Save Result: [lindex $res end]"

        #check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check no *

            set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (no *) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (no *) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # remove ipv6 filter

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        lappend res [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) ipv6 Ingress 0 -removeId 6]
        log_msg DEBUG "Remove IPv6 Filter Result: [lindex $res end]"

        unixCommand $session "/configure service"
        puts [unixCommand $session "info"]
        unixCommand $session "exit all"

        # check *

        set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (*) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (*) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check *

            set matchPrompt "\r\n\\*[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt $matchPrompt]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (*) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (*) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # admin save

        lappend res [serviceAwareFilter_adminSave [getDutLetterFromDutString $dut]]
        log_msg DEBUG "Admin Save Result: [lindex $res end]"

        #check no *

        set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
        set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
        if { [regexp "${matchPrompt}" $cli] } {
            log_msg INFO "Asterisk check (no *) PASSED"
        } else {
            set result ERROR
            log_msg ERROR "Asterisk check (no *) FAILED!"
        }

        if { [$dut cget -redundantSystem] } {
            log_msg NOTICE "Rebooting active CPM via ctrl+x"
            exp_send -i $session "[char 24]" ; # ctrl+x ? reboot
            closeRootUser $session
            log_msg NOTICE "Wait a while till new CPM becomes active and cli is opened"
            printDotsWhileWaiting 21
            reconnect -dutList $dut
            set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]
            unixCommand $session "/environment no more"

            # check no *

            set matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"
            set cli [unixCommand $session "show version" -matchPrompt "\r\n[getActiveCpm $dut]:${dut}# $"]
            if { [regexp "${matchPrompt}" $cli] } {
                log_msg INFO "Asterisk check (no *) PASSED"
            } else {
                set result ERROR
                log_msg ERROR "Asterisk check (no *) FAILED!"
            }

            # wait for switchover to finish!!!

            log_msg NOTICE "Wait for previous switchover to finish"
            lappend res [ $dut CnWRedCardStatus ]
        }

        # delete filter(s)
        lappend res [$dut setTIPFilterRowStatus 4 "destroy"]
        log_msg DEBUG "Destroy IP Filter Result: [lindex $res end]"
        lappend res [$dut setTIPv6FilterRowStatus 6 "destroy"]
        log_msg DEBUG "Destroy IPv6 Filter Result: [lindex $res end]"

        # deconfigure service

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service no $opt(svcType) $opt(svcId)"
        }

        # rollback restore ?

        unixCommand $session "/environment more"
        unixCommand $session "/configure log event-damping" ; # related to problem in dts 192541
        closeRootUser $session
    }

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    return $result

}

proc serviceAwareFilter_checkTraps {args} {

    set opt(dutList)        ""
    set opt(skipConfig)     true
    set opt(svcType)        "vprn"
    set opt(svcId)          1

    getopt opt $args

    set result PASSED

    if { $opt(dutList) == "" } {
        set opt(dutList) [getDutList]
    }

    foreach dut $opt(dutList) {

        set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]

        # config service ?

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service $opt(svcType) $opt(svcId) create customer 1"
        }
        unixCommand $session "/environment no more"

        # filter list

        lappend fList [list "ip" "4" "0" "template"]
        lappend fList [list "ip" "41" "0" "exclusive"]
        lappend fList [list "ip" "42" "0" "embedded"]
        lappend fList [list "ip" "43" "0" "system"]
        lappend fList [list "ip" "44" "0" "template"]
        lappend fList [list "ipv6" "6" "0" "template"]
        lappend fList [list "ipv6" "61" "0" "exclusive"]
        lappend fList [list "ipv6" "62" "0" "embedded"]
        lappend fList [list "ipv6" "63" "0" "system"]
        lappend fList [list "ipv6" "66" "0" "template"]
        lappend fList [list "mac" "9" "0" "template"]
        lappend fList [list "mac" "91" "0" "exclusive"]
        lappend fList [list "mac" "99" "0" "template"]

        # create filters

        foreach filter $fList {
            foreach {fType fId eId fScope} $filter {
                unixCommand $session "/configure filter ${fType}-filter $fId create scope $fScope"
            }
        }
        unixCommand $session "/configure log log-id 90 no shutdown"
        unixCommand $session "exit all"

after 3000 ; # it takes time for the msg to appear in log

        set out [cookCliData [$dut sendCliCommand "show log log-id 90 count 1"]]
        regexp ".*\n(.*).*\n" $out out out
        puts ""
        regexp "^\[0-9\]+" $out msgIdBefore
        log_msg INFO "The latest msg id in log 90 = $msgIdBefore"
        puts ""

        # apply filter

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                set mode [expr [random 2]=="0"?"cli":"snmp"]
                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

after 3000 ; # it takes time for the msg to appear in log

                set ret [cookCliData [$dut sendCliCommand "show log log-id 90 count 10"]]
                regexp -line ".*$opt(svcType)$opt(svcId) SVCMGR\n.*" $ret out
                regexp "^\[0-9\]+" $out msgIdNow
                regexp "\n(.*)" $out msgText msgText

                if { (($fType == "ipv4") || ($fType == "ipv6")) && ($fScope == "template") } {
                    if { $msgIdNow <= $msgIdBefore } {
                        puts $ret
                        log_msg ERROR "Snmp trap missing in log 90!"
                        lappend res "ERROR"
                    } else {
                        log_msg INFO "msgIdBefore : $msgIdBefore"
                        log_msg INFO "msgIdNow    : $msgIdNow"
                        log_msg INFO "msgText     : $msgText"

                        log_msg INFO "New snmp trap in log 90 after modifying config"
                        lappend res "noError"
                    }
                } else {
                    if { $msgIdNow != $msgIdBefore } {
                        puts $ret
                        log_msg ERROR "Unexpected snmp trap in log 90!"
                        lappend res "ERROR"
                    } else {
                        log_msg INFO "No new snmp trap in log 90"
                        lappend res "noError"
                    }
                }

                set msgIdBefore $msgIdNow
            }
        }

        # remove filter (one by one)

        foreach {fType fId} {"ip" "44" "ipv6" "66"} {
            puts "-------------------------------------------------------------------------------"
            if { $fType == "ip" } {
                set fType "ipv4"
            }
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            log_msg INFO "Remove Filter ($fType $fId):"
            set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -returnCliError true -removeId $fId]
            set temp [string map {"\n" ""} $temp]
            log_msg INFO "Remove Filter Result: $temp"

after 3000 ; # it takes time for the msg to appear in log

            set out [cookCliData [$dut sendCliCommand "show log log-id 90 count 10"]]
            regexp -line ".*$opt(svcType)$opt(svcId) SVCMGR\n.*" $out out
            regexp "^\[0-9\]+" $out msgIdNow
            regexp "\n(.*)" $out msgText msgText

            if { $msgIdNow <= $msgIdBefore } {
                puts $ret
                log_msg ERROR "Snmp trap missing in log 90!"
                lappend res "ERROR"
            } else {
                log_msg INFO "msgIdBefore : $msgIdBefore"
                log_msg INFO "msgIdNow    : $msgIdNow"
                log_msg INFO "msgText     : $msgText"

                log_msg INFO "New snmp trap in log 90 after modifying config"
                lappend res "noError"
            }

            set msgIdBefore $msgIdNow
        }

        # apply filter

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                set mode [expr [random 2]=="0"?"cli":"snmp"]
                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

after 3000 ; # it takes time for the msg to appear in log

                set ret [cookCliData [$dut sendCliCommand "show log log-id 90 count 10"]]
                regexp -line ".*$opt(svcType)$opt(svcId) SVCMGR\n.*" $ret out
                regexp "^\[0-9\]+" $out msgIdNow
                regexp "\n(.*)" $out msgText msgText

                if { (($fType == "ipv4") || ($fType == "ipv6")) && ($fScope == "template") } {
                    if { $msgIdNow <= $msgIdBefore } {
                        puts $ret
                        log_msg ERROR "Snmp trap missing in log 90!"
                        lappend res "ERROR"
                    } else {
                        log_msg INFO "msgIdBefore : $msgIdBefore"
                        log_msg INFO "msgIdNow    : $msgIdNow"
                        log_msg INFO "msgText     : $msgText"

                        log_msg INFO "New snmp trap in log 90 after modifying config"
                        lappend res "noError"
                    }
                } else {
                    if { $msgIdNow != $msgIdBefore } {
                        puts $ret
                        log_msg ERROR "Unexpected snmp trap in log 90!"
                        lappend res "ERROR"
                    } else {
                        log_msg INFO "No new snmp trap in log 90"
                        lappend res "noError"
                    }
                }

                set msgIdBefore $msgIdNow
            }
        }

        # remove filter (all at once)

        set mode "cli"
        puts "-------------------------------------------------------------------------------"
        log_msg INFO "Remove Filter (all at once):"
        set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) "ipv4" Ingress 0 -mode $mode -returnCliError true] ; # family does not matter when removing all at once
        set temp [string map {"\n" ""} $temp]
        log_msg INFO "Remove Filter Result: $temp"

after 3000 ; # it takes time for the msg to appear in log

        set out [cookCliData [$dut sendCliCommand "show log log-id 90 count 10"]]
        regexp -line ".*$opt(svcType)$opt(svcId) SVCMGR\n.*" $out out
        regexp "^\[0-9\]+" $out msgIdNow
        regexp "\n(.*)" $out msgText msgText

        if { $msgIdNow <= $msgIdBefore } {
            puts $ret
            log_msg ERROR "Snmp trap missing in log 90!"
            lappend res "ERROR"
        } else {
            log_msg INFO "msgIdBefore : $msgIdBefore"
            log_msg INFO "msgIdNow    : $msgIdNow"
            log_msg INFO "msgText     : $msgText"

            log_msg INFO "New snmp trap in log 90 after modifying config"
            lappend res "noError"
        }
        puts "-------------------------------------------------------------------------------"

        # destroy filters

        foreach filter $fList {
            foreach {fType fId eId fScope} $filter {
                unixCommand $session "/configure filter no ${fType}-filter $fId"
            }
        }
        unixCommand $session "exit all"

        # deconfig service ?

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service no $opt(svcType) $opt(svcId)"
        }
        unixCommand $session "/environment more"

        closeRootUser $session
    }

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    return $result
}

proc serviceAwareFilter_applyRemove {args} {

    set opt(svcType)        "vprn"
    set opt(svcId)          1
    set opt(dutList)        ""
    set opt(skipConfig)     "true"
    set opt(maxFilterName)  64

    getopt opt $args

    set result PASSED

    if { $opt(dutList) == "" } {
        set opt(dutList) [getDutList]
    }

    foreach dut $opt(dutList) {

        set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]

        # cli/snmp
        # in/out ranges ; weird characters ; whitespace characters

        # config service ?

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service $opt(svcType) $opt(svcId) create customer 1"
        }
        unixCommand $session "/environment no more"

        # filter list with filter-names

        lappend fList [list "ip"   "41"  "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ip"   "42"  "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ip"   "43"  "0" "template"  "\"[randomFilterName -length $opt(maxFilterName)]\""]
        lappend fList [list "ip"   "411" "0" "exclusive" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ip"   "412" "0" "exclusive" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ip"   "421" "0" "embedded"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ip"   "422" "0" "embedded"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ip"   "431" "0" "system"    "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ip"   "432" "0" "system"    "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ip"   "441" "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ip"   "444" "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ipv6" "61"  "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ipv6" "62"  "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ipv6" "63"  "0" "template"  "\"[randomFilterName -length $opt(maxFilterName)]\""]
        lappend fList [list "ipv6" "611" "0" "exclusive" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ipv6" "612" "0" "exclusive" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ipv6" "621" "0" "embedded"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ipv6" "622" "0" "embedded"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ipv6" "631" "0" "system"    "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ipv6" "632" "0" "system"    "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fList [list "ipv6" "661" "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+64]]\""]
        lappend fList [list "ipv6" "666" "0" "template"  "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]

        # create filters

        foreach filter $fList {
            foreach {fType fId eId fScope fName} $filter {
                unixCommand $session "/configure filter ${fType}-filter $fId create scope $fScope"
                unixCommand $session "/configure filter ${fType}-filter $fId filter-name $fName"
            }
        }
        unixCommand $session "exit all"

        # apply filters using filter-name

        puts ""
        log_msg INFO "################################"
        log_msg INFO "  apply existing filter (name)  "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode "cli"
            foreach {fType fId eId fScope fName} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true -useFilterName true -filterName $fName]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [expr [string length $fName] - 2] > $opt(maxFilterName) } {
                    # expected error
                    if { [lindex $temp 0] == "FAILED"} {
                        log_msg INFO "Applying filter with longer filter-name than supported correctly failed"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [string trim [lindex $temp 1]] -filterName $fName -maxFilterName $opt(maxFilterName)]
                    } else {
                        log_msg ERROR "Applying filter with longer filter-name than supported incorrectly passed!"
                        lappend res "ERROR"
                    }

                } else {

                    if { $fScope != "template" } {
                        # expected error
                        if { $temp == "noError" } {
                            log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                            lappend res ERROR
                        } else {
                            log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                            lappend res "noError"

                            # check err msg
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [string trim [lindex $temp 1]] -filterName $fName -maxFilterName $opt(maxFilterName)]

                            log_msg INFO "Check Filter ($filter) AFTER apply:"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                        }
                    } else {

                        if { [lindex $temp 0] == "FAILED" } {
                            log_msg ERROR "Applying filter by filter-name FAILED!"
                            lappend res "ERROR"
                        } else {
                            log_msg INFO "Applying filter by filter-name PASSED"
                            lappend res "noError"
                        }
                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                    }
                }
            }
        }

        # remove filter(s) using filter-name

        puts ""
        log_msg INFO "################################"
        log_msg INFO "   remove all filters (name)    "
        log_msg INFO "################################"
        puts ""

        set mode "cli"
        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope fName} $filter {
                if { $fType == "ip" } { set fType "ipv4" }

                # one by one
                log_msg INFO "Remove Filter ($filter):"
                # remove specific filter by filter-name
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -removeId $fId -returnCliError true -useFilterName true -filterName $fName]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Remove Filter Result: $temp"

                if { ($fId == "444") || ($fId == "666") } {
                    if { [lindex $temp 0] == "FAILED" } {
                        lappend res "FAILED"
                        log_msg ERROR "Removing filter by filter-name FAILED!"
                    } else {
                        lappend res "noError"
                        log_msg INFO "Removing filter by filter-name passed"
                    }

                    log_msg INFO "Check Filter ($filter) AFTER remove:"
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                } else {

                    # expected error

                    if { [lindex $temp 0] == "FAILED" } {
                        lappend res "noError"
                        log_msg INFO "Removing filter by filter-name correctly failed (because it was not assigned!)"
                    } else {
                        lappend res ERROR
                        log_msg INFO "Removing filter by filter-name should have failed (because it was not assigned), but it did NOT!"
                    }

                    log_msg INFO "Check Filter ($filter) AFTER remove:"
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                    # check err msg
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "remove" -errMsg [string trim [lindex $temp 1]] -filterName $fName -maxFilterName $opt(maxFilterName) -fId $fId]

                }
            }
        }

        # destroy filter(s)

        foreach filter $fList {
            foreach {fType fId eId fScope fName} $filter {
                unixCommand $session "/configure filter no ${fType}-filter $fId"
            }
        }

        # filter list

        set fList {}
        lappend fList [list "ip" "4" "0" "template"]
        lappend fList [list "ip" "66661" "0" "template"]
        lappend fList [list "ip" "41" "0" "exclusive"]
        lappend fList [list "ip" "66662" "0" "exclusive"]
        lappend fList [list "ip" "42" "0" "embedded"]
        lappend fList [list "ip" "66663" "0" "embedded"]
        lappend fList [list "ip" "43" "0" "system"]
        lappend fList [list "ip" "66664" "0" "system"]
        lappend fList [list "ip" "44" "0" "template"]
        lappend fList [list "ipv6" "6" "0" "template"]
        lappend fList [list "ipv6" "66665" "0" "template"]
        lappend fList [list "ipv6" "61" "0" "exclusive"]
        lappend fList [list "ipv6" "66666" "0" "exclusive"]
        lappend fList [list "ipv6" "62" "0" "embedded"]
        lappend fList [list "ipv6" "66667" "0" "embedded"]
        lappend fList [list "ipv6" "63" "0" "system"]
        lappend fList [list "ipv6" "66668" "0" "system"]
        lappend fList [list "ipv6" "66" "0" "template"]
        lappend fList [list "ipv6" "66669" "0" "template"]
        lappend fList [list "mac" "9" "0" "template"]
        lappend fList [list "mac" "99991" "0" "template"]
        lappend fList [list "mac" "91" "0" "exclusive"]
        lappend fList [list "mac" "99992" "0" "exclusive"]
        lappend fList [list "mac" "99" "0" "template"]

        # apply non-existing filter(s) both in/out range filter-id

        puts ""
        log_msg INFO "################################"
        log_msg INFO "   apply non-existing filter    "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    # expecting error
                    if { $temp == "noError" } {
                        log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply! (because it does not exists or id is out of range)"
                        lappend res ERROR
                    } else {
                        log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied (because it does not exists or id is out of range)"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "apply" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}] -fId $fId]

                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]
                    }
                } else {
                    # still expecting error
                    if { $temp == "noError"} {
                        log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply! (only ipv4/ipv6; but it does not exist anyway)"
                        lappend res ERROR
                    } else {
                        log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied (only ipv4/ipv6; but it does not exist anyway)"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "apply" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]

                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]
                    }
                }
            }
        }

        # apply non-existing filter(s) filter-name

        puts ""
        log_msg INFO "#######################################"
        log_msg INFO "   apply non-existing filter (name)    "
        log_msg INFO "#######################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode "cli"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                set fName "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+[random $opt(maxFilterName)]]]\""
                log_msg INFO "Check Filter ($filter $fName) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true -useFilterName true -filterName $fName]
                set temp [string map {"\n" ""} $temp]
                set temp [string map {"^\\nMINOR" "^MINOR"} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    # expecting error
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "apply" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}] -fId $fId -filterName $fName]
                } else {
                    # mac / still expecting error
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "apply" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]
                }

                log_msg INFO "Check Filter ($filter) AFTER apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]
            }
        }

        # remove non-existing filter(s) both in/out range filter-id

        puts ""
        log_msg INFO "######################################"
        log_msg INFO "   remove non-existing filters (id)   "
        log_msg INFO "######################################"
        puts ""

        set mode "cli"
        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } { set fType "ipv4" }
                log_msg INFO "Remove Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -removeId $fId -returnCliError true] ; # remove specific filter
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Remove Filter Result: $temp"

                # expecting error, check err msg
                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "remove" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}] -fId $fId]
                } else {
                    # mac
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "remove" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]
                }
                log_msg INFO "Check Filter ($filter) AFTER remove:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]
            }
        }

        # remove non-existing filter(s) both in/out range filter-name

        puts ""
        log_msg INFO "########################################"
        log_msg INFO "   remove non-existing filters (name)   "
        log_msg INFO "########################################"
        puts ""

        set mode "cli"
        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } { set fType "ipv4" }
                set fName "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+[random $opt(maxFilterName)]]]\""
                log_msg INFO "Remove Filter ($filter $fName):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -removeId $fId -returnCliError true -useFilterName true -filterName $fName]
                set temp [string map {"\n" ""} $temp]
                set temp [string map {"^\\nMINOR" "^MINOR"} $temp]
                log_msg INFO "Remove Filter Result: $temp"

                # expecting error, check err msg
                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "remove" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}] -fId $fId -filterName $fName]
                } else {
                    # mac
                    lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "remove" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]
                }
                log_msg INFO "Check Filter ($filter) AFTER remove:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true -svcFilterId 0]
            }
        }

        # filter list

        set fList {}
        lappend fList [list "ip" "4" "0" "template"]
        lappend fList [list "ip" "41" "0" "exclusive"]
        lappend fList [list "ip" "42" "0" "embedded"]
        lappend fList [list "ip" "43" "0" "system"]
        lappend fList [list "ip" "44" "0" "template"]
        lappend fList [list "ipv6" "6" "0" "template"]
        lappend fList [list "ipv6" "61" "0" "exclusive"]
        lappend fList [list "ipv6" "62" "0" "embedded"]
        lappend fList [list "ipv6" "63" "0" "system"]
        lappend fList [list "ipv6" "66" "0" "template"]
        lappend fList [list "mac" "9" "0" "template"]
        lappend fList [list "mac" "91" "0" "exclusive"]
        lappend fList [list "mac" "99" "0" "template"]

        # create filters

        foreach filter $fList {
            foreach {fType fId eId fScope} $filter {
                unixCommand $session "/configure filter ${fType}-filter $fId create scope $fScope"
            }
        }
        unixCommand $session "exit all"

        # apply filter(s)

        puts ""
        log_msg INFO "################################"
        log_msg INFO "  apply existing filter (1st)   "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } { 
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    if { $fScope != "template" } {
                        # expected error
                        if { $temp == "noError" } {
                            log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                            lappend res ERROR
                        } else {
                            log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                            lappend res "noError"

                            # check err msg
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}]]

                            log_msg INFO "Check Filter ($filter) AFTER apply:"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                        }
                    } else {
                        lappend res $temp
                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId] 
                    }
                } else {
                    if { $temp == "noError"} {
                        log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                        lappend res ERROR
                    } else {
                        log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]

                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
                    }
                }
            }
        }

        # remove all filters (all at once)

        puts ""
        log_msg INFO "################################"
        log_msg INFO "      remove all filters        "
        log_msg INFO "################################"
        puts ""

        set mode [expr [random 2]=="0"?"cli":"snmp"] 
        if { $mode == "cli" } {
            log_msg INFO "Remove Filter ($filter):"
            lappend res [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) "ipv4" Ingress 0 -mode $mode] ; # remove all at once (no filter) ; ipv4/ipv6 is not relevant
            log_msg INFO "Remove Filter Result: [lindex $res end]"
        }
        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } { set fType "ipv4" }
                if { $mode == "snmp" } {
                    log_msg INFO "Remove Filter ($filter):"
                    set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode]
                    log_msg INFO "Remove Filter Result: $temp"
                    if { ($fType == "mac") && ($temp == "FAILED") } {
                        lappend res "noError"
                    } else {
                        lappend res $temp
                    }
                }
                log_msg INFO "Check Filter ($filter) AFTER remove:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
            }
        }

        # apply existing filter(s)

        puts ""
        log_msg INFO "################################"
        log_msg INFO "  apply existing filter (2nd)   "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    if { $fScope != "template" } {
                        # expected error
                        if { $temp == "noError" } {
                            log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                            lappend res ERROR
                        } else {
                            log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                            lappend res "noError"

                            # check err msg
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}]]

                            log_msg INFO "Check Filter ($filter) AFTER apply:"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                        }
                    } else {
                        lappend res $temp
                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                    }
                } else {
                    if { $temp == "noError"} {
                        log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                        lappend res ERROR
                    } else {
                        log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]

                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
                    }
                }
            }
        }

        # remove filters one-by-one

        puts ""
        log_msg INFO "################################"
        log_msg INFO "   remove filters one-by-one    "
        log_msg INFO "################################"
        puts ""

        set mode [expr [random 2]=="0"?"cli":"snmp"] ; # cannot combine modes, because removing thru snmp always removes the assigned filter, no matter the "removeId"
        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } { set fType "ipv4" }
                if { $mode == "snmp" } {
                    log_msg INFO "Remove Filter ($filter):"
                    set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode]
                    log_msg INFO "Remove Filter Result: $temp"
                    if { ($fType == "mac") && ($temp == "FAILED") } {
                        lappend res "noError"
                    } else {
                        lappend res $temp
                    }

                } else {
                    log_msg INFO "Remove Filter ($filter):"
                    set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -removeId $fId -returnCliError true] ; # remove specific filter
                    set temp [string map {"\n" ""} $temp]
                    log_msg INFO "Remove Filter Result: $temp"

                    if { ($fId == 44) || ($fId == 66) } {
                        if { $temp != "noError" } {
                            log_msg ERROR "Failed to remove $fType filter $fId thru CLI!"
                            lappend res ERROR
                        }
                    } else {
                        # expecting error, check err msg
                        if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "remove" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}] -fId $fId]
                        } else {
                            # mac
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "remove" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]
                        }
                    }
                }
                log_msg INFO "Check Filter ($filter) AFTER remove:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
            }
        }

        # apply filter, then change to non-existing filter/out-of-range id

        puts ""
        log_msg INFO "################################"
        log_msg INFO "  apply existing filter (3rd)   "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) BEFORE apply:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    if { $fScope != "template" } {
                        # expected error
                        if { $temp == "noError" } {
                            log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                            lappend res ERROR
                        } else {
                            log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                            lappend res "noError"

                            # check err msg
                            lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}]]

                            log_msg INFO "Check Filter ($filter) AFTER apply:"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]

                        }
                    } else {
                        lappend res $temp
                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                    }
                } else {
                    if { $temp == "noError"} {
                        log_msg ERROR "[string toupper $fType] Filter of scope $fScope should not be allowed to apply!"
                        lappend res ERROR
                    } else {
                        log_msg INFO "[string toupper $fType] Filter of scope $fScope correctly denied to be applied"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "apply" -errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}]]

                        log_msg INFO "Check Filter ($filter) AFTER apply:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
                    }
                }
            }
        }

        # ..change to non-existing filter(s)

        puts ""
        log_msg INFO "################################"
        log_msg INFO " change to non-existing filter  "
        log_msg INFO "################################"
        puts ""

        lappend fListX [list "ip" "444" "0" "template"]
        lappend fListX [list "ip" "11111" "0" "exclusive"]
        lappend fListX [list "ip" "33333" "0" "embedded"]
        lappend fListX [list "ip" "55555" "0" "system"]
        lappend fListX [list "ip" "65534" "0" "template"]
        lappend fListX [list "ip" "65535" "0" "template"]
        lappend fListX [list "ip" "65536" "0" "template"]
        lappend fListX [list "ip" "99999" "0" "template"]
        lappend fListX [list "ipv6" "666" "0" "template"]
        lappend fListX [list "ipv6" "22222" "0" "exclusive"]
        lappend fListX [list "ipv6" "44444" "0" "embedded"]
        lappend fListX [list "ipv6" "55555" "0" "system"]
        lappend fListX [list "ipv6" "65534" "0" "template"]
        lappend fListX [list "ipv6" "65535" "0" "template"]
        lappend fListX [list "ipv6" "65536" "0" "template"]
        lappend fListX [list "ipv6" "77777" "0" "template"]
        lappend fListX [list "mac" "999" "0" "template"]
        lappend fListX [list "mac" "12345" "0" "exclusive"]
        lappend fListX [list "mac" "65534" "0" "template"]
        lappend fListX [list "mac" "65535" "0" "template"]
        lappend fListX [list "mac" "65536" "0" "template"]
        lappend fListX [list "mac" "66666" "0" "template"]
        lappend fListX [list "mac" "66666" "0" "template"]
        lappend fListX [list "ip" "0" "0" "template"] ; # remove filter
        lappend fListX [list "ipv6" "0" "0" "template"] ; # remove filter
        lappend fListX [list "mac" "0" "0" "template"] ; # remove filter

        set firstTime "true"

        foreach filter $fListX {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }

                if { ($fId == 0) && ($firstTime == "true") } {

                    # before removing a filter, check that there is still the same filter applied from previous step

                    if { ($fType == "ipv4") || ($fType == "ipv6") } {
                        set firstTime "false"
                        log_msg INFO "Check Filter ($fType 44 $eId $fScope) BEFORE remove:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] "ipv4" 44 $eId -applied "Yes" -filter_row_status "active" -svcFilterId 44]
                        log_msg INFO "Check Filter ($fType 66 $eId $fScope) BEFORE remove:"
                        lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] "ipv6" 66 $eId -applied "Yes" -filter_row_status "active" -svcFilterId 66]

                        # then try to change it to different existing filter

                        set fListY {}
                        lappend fListY [list "ip" "4" "0" "template"]
                        lappend fListY [list "ipv6" "6" "0" "template"]

                        foreach filter $fListY {
                            puts "-------------------------------------------------------------------------------"
                            set mode [expr [random 2]=="0"?"cli":"snmp"]
                            foreach {fTypeY fIdY eIdY fScopeY} $filter {
                                if { $fTypeY == "ip" } {
                                    set fTypeY "ipv4"
                                }

                                log_msg INFO "Change Filter ($filter):"
                                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fTypeY Ingress $fIdY -mode $mode -returnCliError true]
                                set temp [string map {"\n" ""} $temp]
                                log_msg INFO "Change Filter Result: $temp"

                                if { $temp != "noError" } {
                                    log_msg ERROR "Failed to change filter!"
                                    lappend res ERROR
                                } else {
                                    log_msg INFO "Change filter to existing filter passed"
                                    lappend res $temp
                                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fTypeY $fIdY $eIdY -applied "Yes" -filter_row_status "active" -svcFilterId $fIdY]
                                }
                            }
                        }
                    }
                }

                log_msg INFO "Change Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Change Filter Result: $temp"

                if { [string tolower $fType] == "ipv4" || [string tolower $fType] == "ipv6" } {
                    set errMsg [expr {$mode=="cli"?[lindex $temp 1]:$temp}]
                } else {
                    set errMsg [expr {$mode=="cli"?[string trim [lindex $temp 1]]:$temp}] ; # invalid parameter
                }

                if { $fId == 0 } {

                    if { ([string tolower $fType] == "ipv4") || ([string tolower $fType] == "ipv6") || (($mode == "cli") && ($fType == "mac")) } {
                        if { $temp != "noError" } {
                            log_msg ERROR "Failed to remove filter!"
                            lappend res ERROR
                        } else {
                            lappend res $temp
                        }
                    } else {
                        # mac && snmp
                        if { $temp != "FAILED" } {
                            log_msg ERROR "Action with [string toupper $fType] Filter should not be allowed!"
                            lappend res ERROR
                        } else {
                            lappend res "noError"
                        }
                    }
                } else {
                    # expected error
                    if { $temp == "noError" } {
                        log_msg ERROR "Non-existing [string toupper $fType] Filter should not be allowed to apply!"
                        lappend res ERROR
                    } else {
                        log_msg INFO "Non-existing [string toupper $fType] Filter correctly denied to be applied"
                        lappend res "noError"

                        # check err msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType false "apply" -errMsg $errMsg -fId $fId]
                    }
                }
            }
        }

        # check no filter is applied

        puts ""
        log_msg INFO "################################"
        log_msg INFO "   check no filter is applied   "
        log_msg INFO "################################"
        puts ""

        foreach filter $fList {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) AFTER change:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
            }
        }

        foreach filter $fListX {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Check Filter ($filter) AFTER change:"
                lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -nofilter true]
            }
        }

        # apply filter

        puts ""
        log_msg INFO "################################"
        log_msg INFO "         apply filter           "
        log_msg INFO "################################"
        puts ""

        set fListY {}
        lappend fListY [list "ip" "4" "0" "template" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]
        lappend fListY [list "ipv6" "6" "0" "template" "\"[randomFilterName -length [expr [random $opt(maxFilterName)]+1]]\""]

        foreach filter $fListY {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope fName} $filter {

                # assign filter-name
                unixCommand $session "/configure filter ${fType}-filter $fId filter-name $fName"

                if { $fType == "ip" } {
                    set fType "ipv4"
                }

                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { $temp != "noError" } {
                    log_msg ERROR "Failed to apply filter!"
                    lappend res ERROR
                } else {
                    log_msg INFO "Apply filter passed"
                    lappend res $temp
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                }
            }
        }

        # check filter CANNOT be destroyed when associated

        puts ""
        log_msg INFO "######################################################"
        log_msg INFO "   check filter cannot be destroyed when associated   "
        log_msg INFO "######################################################"
        puts ""

        foreach filter $fListY {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope fName} $filter {
                if { $fType == "ip" } {
                    set fTypeLong "ipv4"
                } else {
                    set fTypeLong $fType
                }

                log_msg INFO "Use [string toupper $mode] to destroy [string toupper $fType] filter (should fail)"
                if { $mode == "cli" } {
                    if { [random 2] } {
                        set fIdOrName $fName ; # randomly use filter-id or filter-name to destroy filter
                    } else {
                        set fIdOrName $fId
                    }
                    set errMsg [cookCliData [unixCommand $session "/configure filter no ${fType}-filter $fIdOrName"]]
                } else {
                    set errMsg [$dut setT[getVar3 $fType]FilterRowStatus $fId "destroy"]
                }

                # expected error
                lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fTypeLong true "remove" -errMsg $errMsg -fId $fId -referenced true]

                # remove filter ...

                log_msg INFO "Remove Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fTypeLong Ingress 0 -mode $mode -removeId $fId -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Remove Filter Result: $temp"

                if { $temp != "noError" } {
                    log_msg ERROR "Failed to remove filter!"
                    lappend res ERROR
                } else {
                    log_msg INFO "Remove filter passed"
                    lappend res $temp
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fTypeLong $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
                }

                # ... and try to destroy again

                puts ""
                log_msg INFO "#######################################################"
                log_msg INFO "   check filter can be destroyed when not associated   "
                log_msg INFO "#######################################################"
                puts ""

                set mode [expr [random 2]=="0"?"cli":"snmp"]
                log_msg INFO "Use [string toupper $mode] to destroy [string toupper $fType] filter (should pass)"
                if { $mode == "cli" } {
                    if { [random 2] } {
                        set fId $fName ; # randomly use filter-id or filter-name
                    }
                    set errMsg [cookCliData [unixCommand $session "/configure filter no ${fType}-filter $fId"]]
                } else {
                    set errMsg [$dut setT[getVar3 $fType]FilterRowStatus $fId "destroy"]
                }

                if { ($errMsg != "noError") && ($errMsg != "") } {
                    log_msg ERROR "Failed to destroy [string toupper $fType] filter after dereferencing it!"
                    log_msg ERROR "$errMsg"
                    lappend res ERROR
                } else {
                    log_msg INFO "[string toupper $fType] filter successfully destroyed after dereferencing"
                }
            }
        }

        # re-create filter we destroyed in previous step

        set fListY {}
        lappend fListY [list "ip" "4" "0" "template"]
        lappend fListY [list "ipv6" "6" "0" "template"]

        puts "-------------------------------------------------------------------------------"
        log_msg INFO "Re-create filters we destroyed in previous step"
        foreach filter $fListY {
            foreach {fType fId eId fScope} $filter {
                unixCommand $session "/configure filter ${fType}-filter $fId create"
            }
        }

        # apply filter

        puts ""
        log_msg INFO "################################"
        log_msg INFO "        apply filter            "
        log_msg INFO "################################"
        puts ""

        foreach filter $fListY {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope fName} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Apply Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress $fId -mode $mode -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Apply Filter Result: $temp"

                if { $temp != "noError" } {
                    log_msg ERROR "Failed to apply filter!"
                    lappend res ERROR
                } else {
                    log_msg INFO "Apply filter passed"
                    lappend res $temp
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                }
            }
        }

        # change scope after filter is applied

        puts ""
        log_msg INFO "##################################"
        log_msg INFO "   check we cannot change scope   "
        log_msg INFO "##################################"
        puts ""

        foreach filter $fListY {
            foreach scope "exclusive embedded system template" {
                puts "-------------------------------------------------------------------------------"
                set mode [expr [random 2]=="0"?"cli":"snmp"]
                foreach {fType fId eId fScope fName} $filter {

                    log_msg INFO "Change Scope ($filter) to $scope:"
                    if { $mode == "snmp" } {
                        set temp [$dut setT[getVar3 $fType]FilterScope $fId $scope]
                    } else {
                        set temp [cookCliData [unixCommand $session "/configure filter ${fType}-filter $fId scope $scope"]]
                    }
                    set errMsg $temp
                    log_msg INFO "Change Scope Result: $temp"

                    if { $fType == "ip" } {
                        set fType "ipv4"
                    }

                    if { $scope != "template" } {

                        # expected error

                        if { $temp == "noError" || $temp == "" } {
                            log_msg ERROR "Changing scope of filter to $scope incorrectly allowed! (only template allowed)"
                            lappend res ERROR
                        } else {
                            log_msg INFO "Changing scope of filter correctly denied"
                            lappend res "noError"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                        }

                        # check error msg
                        lappend res [serviceAwareFilter_checkErrMsg $dut $mode $fScope $fType true "changeScope" -errMsg $errMsg]

                    } else {
                        if { $temp == "noError" || $temp == "" } {
                            log_msg INFO "Changing scope of filter to $scope (actually just applying the same scope as was) correctly allowed"
                            lappend res "noError"
                            lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "Yes" -filter_row_status "active" -svcFilterId $fId]
                        } else {
                            log_msg ERROR "Changing scope of filter to $scope (actually just applying the same scope as was) incorrectly denied!"
                            lappend res ERROR
                        }
                    }
                }
            }
        }

        # remove filters

        set fListY {}
        lappend fListY [list "ip" "4" "0" "template"]
        lappend fListY [list "ipv6" "6" "0" "template"]

        foreach filter $fListY {
            puts "-------------------------------------------------------------------------------"
            set mode [expr [random 2]=="0"?"cli":"snmp"]
            foreach {fType fId eId fScope fName} $filter {
                if { $fType == "ip" } {
                    set fType "ipv4"
                }
                log_msg INFO "Remove Filter ($filter):"
                set temp [serviceAwareFilter_applyFilter [getDutLetterFromDutString $dut] $opt(svcId) $opt(svcType) $fType Ingress 0 -mode $mode -removeId $fId -returnCliError true]
                set temp [string map {"\n" ""} $temp]
                log_msg INFO "Remove Filter Result: $temp"

                if { $temp != "noError" } {
                    log_msg ERROR "Failed to remove filter!"
                    lappend res ERROR
                } else {
                    log_msg INFO "Remove filter passed"
                    lappend res $temp
                    lappend res [serviceAwareFilter_checkFilter [getDutLetterFromDutString $dut] $fType $fId $eId -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -scope $fScope]
                }
            }
        }



        # try applying flowspec filter

        # tru applying internal flowspec filter-id

        # dynamic behavior ?





        # cleanup

        foreach filter $fList {
            foreach {fType fId eId fScope} $filter {
                unixCommand $session "/configure filter no ${fType}-filter $fId"
            }
        }

        unixCommand $session "/environment more"

        if { ! $opt(skipConfig) } {
            unixCommand $session "/configure service no $opt(svcType) $opt(svcId)"
        }

        closeRootUser $session
    }

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    return $result

}

proc serviceAwareFilter_chassisMode {args} {

    serviceAwareFilter_setGlobalParams

    global dut1 dut2 dut3 dut4 dut5 dut6

    set opt(svcType)        "vprn"
    set opt(svcId)          "1"
    set opt(direction)      "Ingress"
    set opt(filterId)       "1"
    set opt(entryId)        "1"
    set opt(forceDut)       ""
    set opt(repeat)         "10"

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    if { $opt(forceDut) != "" } { set dut2 $opt(forceDut) }

    ###############################################
    puts "" ; log_msg INFO "CHASSIS MODE" ; puts ""
    ###############################################

    # config
    lappend res [Dut-$dut2 createVprn $opt(svcId) 1 65000:$opt(svcId)]
    log_msg DEBUG "Config Result: [lindex $res end]"

    foreach filterType {"IP" "IPv6"} {
        if { $filterType == "IP" } { set family "ipv4" } else { set family "ipv6" }
        log_msg INFO "Create and check filter"
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
        log_msg DEBUG "Create Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"
    }

    set chassisOrig [Dut-$dut2 getTmnxChassisAdminMode 1]

    set rollbackOnce1 true
    set rollbackOnce2 true

    # cycle: (admin vs. oper mode .. should not matter if this statement is true: admin state is always lower or equal to oper state)
    for { set i 0 } { $i < $opt(repeat) } { incr i } {

        set chm [cookCliData [Dut-$dut2 sendCliCommand "show chassis"]]

        if { [regexp -nocase "chassis mode" $chm] == 0 } {

            log_msg NOTICE "Chassis mode cannot be changed on this setup!"
            # example: Hsa1G is modeD but it cannot be changed

            foreach family {"IPv4" "IPv6"} {
                foreach mode {"snmp" "cli"} {
                    log_msg INFO "Apply filter ($family, $mode)"
                    if { $mode == "snmp" } {
                        set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode]
                        # check err msg
                        if { $temp != "noError" } {
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong return value   : $temp"
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Expected return value: noError"
                            lappend res $temp
                        } else {
                            log_msg INFO "serviceAwareFilter_applyFilter -> Correct return value: $temp"
                            lappend res "noError"
                        }
                    } else {
                        set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode -returnCliError true]
                        # check err msg
                        if { [lindex $temp 1] != "" } {
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong error message   : [lindex $temp 1]"
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Expected no error message."
                            lappend res [lindex $temp 0]
                        } else {
                            log_msg INFO "serviceAwareFilter_applyFilter -> Filter successfully applied."
                            lappend res "noError"
                        }
                    }
                    # check filter
                    log_msg INFO "Check filter"
                    lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
                    log_msg DEBUG "Check Filter Result: [lindex $res end]"
                    # remove filter
                    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) 0]
                    log_msg DEBUG "Remove Filter Result: [lindex $res end]"
                }
            }
            break

        } elseif { [Dut-$dut2 getTmnxChassisAdminMode 1] >= "modeD" } {

            # create restore point (1) .. only once
            if { $rollbackOnce1 } {
                set rollIdx "latest-rb"
                lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
                log_msg DEBUG "Rollback save result: [lindex $res end]"
                set rollbackOnce1 false
            }

            # downgrade chassis mode (a,b,c) + apply filter (and check filter) .. should not be allowed

            foreach modeChassis {"c" "b" "a"} {
                if { ([getGlobalVar mixedMode] == "true") && ($modeChassis == "c") } {
                    # skip this one .. mixedMode does not suppoort chassis-mode c
                    continue
                }
                if { $modeChassis == "c" } { 
                    set ipList [list "IPv4" "IPv6"]
                } else {
                    set ipList "IPv4"
                    # destroy ipv6 filter
                    log_msg INFO "Destroy IPv6 filter before downgrade"
                    lappend res [Dut-$dut2 setTIPv6FilterRowStatus $opt(filterId) "destroy"]
                    log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
                    lappend res [serviceAwareFilter_checkFilter $dut2 ipv6 $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
                    log_msg DEBUG "Check Filter Result: [lindex $res end]"
                }
                # downgrade ...
                foreach modeDowngrade {"snmp" "cli"} {
                    log_msg INFO "Downgrade chassis mode to [string toupper $modeChassis] ($modeDowngrade)"
                    if { $modeDowngrade == "snmp" } {
                        lappend res [Dut-$dut2 setChassisMode $modeChassis -force true]
                    } else {
                        set ret [cookCliData [Dut-$dut2 sendCliCommand "/configure system chassis-mode $modeChassis"]]
                        if { $ret != "" } {
                            lappend res "ERROR"
                        } else {
                            lappend res "noError"
                        }
                    }
                
                    # apply ...
                    foreach family $ipList {
                        foreach mode {"snmp" "cli"} {
                            log_msg INFO "Apply filter ($family, $mode)"
                            if { $mode == "snmp" } {
                                set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode]
                                # check err msg
                                if { $temp != "inconsistentValue" } {
                                    log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong return value   : $temp"
                                    log_msg ERROR "serviceAwareFilter_applyFilter -> Expected return value: inconsistentValue"
                                    lappend res $temp
                                } else {
                                    log_msg INFO "serviceAwareFilter_applyFilter -> Correct return value: $temp"
                                    lappend res "noError"
                                }
                            } else {
                                set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode -returnCliError true]
                                # check err msg
                                if { [lindex $temp 1] != "MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN." } {
                                    log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong error message   : [lindex $temp 1]"
                                    log_msg ERROR "serviceAwareFilter_applyFilter -> Expected error message: MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN."
                                    lappend res [lindex $temp 0]
                                } else {
                                    log_msg INFO "serviceAwareFilter_applyFilter -> Correct error message: [lindex $temp 1]"
                                    lappend res "noError"
                                }
                            }
                            log_msg INFO "Check filter"
                            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
                            log_msg DEBUG "Check Filter Result: [lindex $res end]"
                        }
                    }
                    # back to original chassis mode
                    log_msg INFO "Restore chassis mode to original value: $chassisOrig"
                    lappend res [Dut-$dut2 setChassisMode [regsub "mode" $chassisOrig ""] -force true]
                    log_msg DEBUG "Restore Chassis Mode Result: [lindex $res end]"
                }
                if { $modeChassis != "c" } {
                    # recreate ipv6 filter
                    log_msg INFO "Recreate and check IPv6 filter"
                    lappend res [Dut-$dut2 setTIPv6FilterRowStatus $opt(filterId) "createAndGo"]
                    log_msg DEBUG "Create Filter Result: [lindex $res end]"
                    lappend res [serviceAwareFilter_checkFilter $dut2 ipv6 $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
                    log_msg DEBUG "Check Filter Result: [lindex $res end]"
                }
            }

            # chassis mode should be back to its original value at this point (D or higher), try to apply filter now

            foreach family {"IPv4" "IPv6"} {
                set mode [expr [random 2]=="0"?"cli":"snmp"]
                log_msg INFO "Apply filter ($family, $mode)"
                if { $mode == "snmp" } {
                    set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode]
                    # check err msg
                    if { $temp != "noError" } {
                        log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong return value   : $temp"
                        log_msg ERROR "serviceAwareFilter_applyFilter -> Expected return value: noError"
                        lappend res $temp
                    } else {
                        log_msg INFO "serviceAwareFilter_applyFilter -> Correct return value: $temp"
                        lappend res "noError"
                    }
                } else {
                    set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode -returnCliError true]
                    # check err msg
                    if { [lindex $temp 1] != "" } {
                        log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong error message   : [lindex $temp 1]"
                        log_msg ERROR "serviceAwareFilter_applyFilter -> Expected no error message."
                        lappend res [lindex $temp 0]
                    } else {
                        log_msg INFO "serviceAwareFilter_applyFilter -> Filter successfully applied."
                        lappend res "noError"
                    }
                }
                # check filter
                log_msg INFO "Check filter"
                lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
                log_msg DEBUG "Check Filter Result: [lindex $res end]"
            }

            # ..and create restore point (2) .. only once

            if { $rollbackOnce2 } {
                set rollIdx "latest-rb"
                lappend res [serviceAwareFilter_rollbackSave $dut2 $rollIdx]
                log_msg DEBUG "Rollback save result: [lindex $res end]"
                set rollbackOnce2 false
            }

            # try to lower the chassis mode .. should not be allowed

            set removeOnce true
            foreach modeChassis {"c" "b" "a"} {
                if { ([getGlobalVar mixedMode] == "true") && ($modeChassis == "c") } {
                    # skip this one .. mixedMode does not suppoort chassis-mode c
                    log_msg NOTICE "Chassis mode C not supported on mixedMode .. skipping!"
                    continue
                }
                if { $modeChassis == "c" } {
                    set filterNo 2
                } elseif { $removeOnce } {
                    set filterNo 1
                    # remove filter
                    lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) ipv6 $opt(direction) 0 -removeId $opt(filterId)]
                    log_msg DEBUG "Remove Filter Result: [lindex $res end]"
                    # destroy ipv6 filter
                    log_msg INFO "Destroy IPv6 filter before downgrade"
                    lappend res [Dut-$dut2 setTIPv6FilterRowStatus $opt(filterId) "destroy"]
                    log_msg DEBUG "Destroy IPv6 Filter Result: [lindex $res end]"
                    lappend res [serviceAwareFilter_checkFilter $dut2 ipv6 $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
                    log_msg DEBUG "Check IPv6 Filter Result: [lindex $res end]"
                    log_msg INFO "Check IPv4 filter:"
                    lappend res [serviceAwareFilter_checkFilter $dut2 ipv4 $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
                    log_msg DEBUG "Check IPv4 Filter Result: [lindex $res end]"
                    set removeOnce false
                }
                # downgrade ...
                foreach modeDowngrade {"snmp" "cli"} {
                    log_msg INFO "Try to downgrade chassis mode to [string toupper $modeChassis] ($modeDowngrade)"
                    if { $modeDowngrade == "snmp" } {
                        set temp [Dut-$dut2 setChassisMode $modeChassis -force true]
                        set expErr "inconsistentValue"
                    } else {
                        set temp [cookCliData [Dut-$dut2 sendCliCommand "/configure system chassis-mode $modeChassis"]]
                        set expErr "MINOR: CHMGR #1010 Can not change mode - $filterNo vprn network ingress filter bindings configured"
                    }
                    if { $temp == $expErr } {
                        lappend res "noError"
                        log_msg INFO "Downgrade Result: $temp"
                    } else {
                        lappend res "ERROR"
                        log_msg ERROR "Downgrade Result: $temp"
                    }
                }
            }

            # check we are still mode D (or higher)

            if { [Dut-$dut2 getTmnxChassisAdminMode 1] >= "modeD" } {
                lappend res "noError"
                log_msg INFO "Verify we didnt lower the chassis mode ... PASSED"
            } else {
                lappend res ERROR
                log_msg ERROR "Verify we didnt lower the chassis mode ... FAILED"
            }

            # remove filter + lower chassis mode + rollback (2/latest)

            lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) ipv4 $opt(direction) 0 -removeId $opt(filterId)]
            log_msg DEBUG "Remove Filter Result: [lindex $res end]"
            # destroy ipv4 filter
            log_msg INFO "Destroy IPv4 filter"
            lappend res [Dut-$dut2 setTIPFilterRowStatus $opt(filterId) "destroy"]
            log_msg DEBUG "Destroy IPv4 Filter Result: [lindex $res end]"
            lappend res [serviceAwareFilter_checkFilter $dut2 ipv4 $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
            log_msg DEBUG "Check IPv4 Filter Result: [lindex $res end]"
            # lower chassis mode
            if { ([getGlobalVar mixedMode] == "true") } {
                # mixedMode does not suppoort chassis-mode c
                set modeChassis [randomString 1 "ab"]
            } else {
                set modeChassis [randomString 1 "abc"]
            }
            # downgrade ...
            foreach modeDowngrade {"snmp" "cli"} {
                log_msg INFO "Try to downgrade chassis mode to [string toupper $modeChassis] ($modeDowngrade)"
                if { $modeDowngrade == "snmp" } {
                    set temp [Dut-$dut2 setChassisMode $modeChassis -force true]
                    set expErr "noError"
                } else {
                    set temp [cookCliData [Dut-$dut2 sendCliCommand "/configure system chassis-mode $modeChassis"]]
                    set expErr ""
                }
                if { $temp == $expErr } {
                    lappend res "noError"
                    log_msg INFO "Downgrade Result ($modeDowngrade): $temp"
                } else {
                    lappend res "ERROR"
                    log_msg ERROR "Downgrade Result ($modeDowngrade): $temp"
                }
            }
            # rollback to 2/latest
            set rollIdx "latest-rb"
            lappend res [serviceAwareFilter_rollbackRestore $dut2 $rollIdx]
            log_msg DEBUG "Rollback restore result: [lindex $res end]"

            # we should have our filters back and chassis mode D (or higher)

            if { [Dut-$dut2 getTmnxChassisAdminMode 1] >= "modeD" } {
                lappend res "noError"
                log_msg INFO "Verify chassis mode is D or higher ... PASSED"
            } else {
                lappend res ERROR
                log_msg ERROR "Verify chassis mode is D or higher ... FAILED"
            }
            # check filters
            log_msg INFO "Check IPv4 filter"
            lappend res [serviceAwareFilter_checkFilter $dut2 ipv4 $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
            log_msg DEBUG "Check IPv4 Filter Result: [lindex $res end]"
            log_msg INFO "Check IPv6 filter"
            lappend res [serviceAwareFilter_checkFilter $dut2 ipv6 $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
            log_msg DEBUG "Check IPv6 Filter Result: [lindex $res end]"

            # try to lower the chassis mode again .. should not be allowed

            if { ([getGlobalVar mixedMode] == "true") } {
                # mixedMode does not suppoort chassis-mode c
                set modeChassis [randomString 1 "ab"]
            } else {
                set modeChassis [randomString 1 "abc"]
            }
            foreach modeDowngrade {"snmp" "cli"} {
                log_msg INFO "Try to downgrade chassis mode to [string toupper $modeChassis] ($modeDowngrade)"
                if { $modeDowngrade == "snmp" } {
                    set temp [Dut-$dut2 setChassisMode $modeChassis -force true]
                    set expErr "inconsistentValue"
                } else {
                    set temp [cookCliData [Dut-$dut2 sendCliCommand "/configure system chassis-mode $modeChassis"]]
                    if { ($modeChassis == "c") || ([getGlobalVar mixedMode] == "true") } {
                        set expErr "MINOR: CHMGR #1010 Can not change mode - 2 vprn network ingress filter bindings configured"
                    } else {
                        set expErr "MINOR: CHMGR #1010 Can not change mode - One or more ipv6 ACL filters exist"
                    }
                }
                if { $temp == $expErr } {
                    lappend res "noError"
                    log_msg INFO "Downgrade Result: $temp"
                } else {
                    lappend res "ERROR"
                    log_msg ERROR "Downgrade Result: $temp"
                }
            }

            # rollback (1)

            lappend res [serviceAwareFilter_rollbackRestore $dut2 1]
            log_msg DEBUG "Rollback restore result: [lindex $res end]"

        } else {

            # try to apply filter .. should not be allowed (chassis mode is lower than D)

            foreach family {"IPv4" "IPv6"} {
                foreach mode {"snmp" "cli"} {
                    log_msg INFO "Apply filter ($family, $mode)"
                    if { $mode == "snmp" } {
                        set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode]
                        # check err msg
                        if { $temp != "inconsistentValue" } {
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong return value   : $temp"
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Expected return value: inconsistentValue"
                            lappend res $temp
                        } else {
                            log_msg INFO "serviceAwareFilter_applyFilter -> Correct return value: $temp"
                            lappend res "noError"
                        }
                    } else {
                        set temp [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId) -mode $mode -returnCliError true]
                        # check err msg
                        if { [lindex $temp 1] != "MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN." } {
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Wrong error message   : [lindex $temp 1]"
                            log_msg ERROR "serviceAwareFilter_applyFilter -> Expected error message: MINOR: SVCMGR #8201 Chassis mode D is required to assign a filter to a VPRN."
                            lappend res [lindex $temp 0]
                        } else {
                            log_msg INFO "serviceAwareFilter_applyFilter -> Correct error message: [lindex $temp 1]"
                            lappend res "noError"
                        }
                    }
                    log_msg INFO "Check filter"
                    lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
                    log_msg DEBUG "Check Filter Result: [lindex $res end]"
                }
            }
        }
    }

    # delete all restore points
    lappend res [serviceAwareFilter_rollbackCleanup $dut2]
    log_msg DEBUG "Rollback files cleanup result: [lindex $res end]"

    # deconfig
    lappend res [Dut-$dut2 deleteVprn $opt(svcId)]
    log_msg DEBUG "Deconfig Result: [lindex $res end]"

    foreach filterType {"IP" "IPv6"} {
        if { $filterType == "IP" } { set family "ipv4" } else { set family "ipv6" }
        log_msg INFO "Destroy filter"
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
        log_msg DEBUG "Destroy Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -nofilter true -svcFilterId "ERROR"]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"
    }

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }
    if { $result != "PASSED" } { log_msg INFO "Something went terribly wrong! Found: $res" }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result

}

proc serviceAwareFilter_CpmFailover {args} {

    serviceAwareFilter_setGlobalParams

    global dut1 dut2 dut3 dut4 dut5 dut6
    global dut1Id dut2Id dut3Id dut4Id dut5Id dut6Id
    global port_1_5 port_1_2 port_1_3 port_1_x4a port_1_x4b port_2_1 port_2_6 port_2_4 port_2_x2 port_2_x3 port_3_1 port_3_4 port_4_2 port_4_3 port_5_1 port_5_x1 port_6_2 port_6_x4
    global ixia_port

    set opt(svcType)        "vprn"
    set opt(svcId)          "1"
    set opt(direction)      "Ingress"
    set opt(filterId)       "1"
    set opt(entryId)        "1"
    set opt(withAdminSave)  ""

    set opt(framesize)      "100"
    set opt(burst)          "20"
    set opt(rate)           "20"
    set opt(loops)          "1"

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    # 1. setup whole config + test traffic + check entry hits

    handlePacket -action reset -portList all -scheduler sequential

    lappend res [serviceAwareFilter_config -useIxia true]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Config Result: [lindex $res end]"

    foreach {family filterType} {"ipv4" "IP" "ipv6" "IPv6"} {

        log_msg INFO "Testing $filterType..."

        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Create Filter Result: [lindex $res end]"
        lappend res [Dut-$dut2 create[getVar1 $filterType]FilterEntries $opt(filterId) $opt(entryId)]
        lappend res [lindex [Dut-$dut2 set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction $opt(filterId) $opt(entryId)] "forward" ]]] 0]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsDestinationIpAddr $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"192.168.${dut6Id}.${dut6Id}":[ipv62MibVal [ipConvert $family 192.168.${dut6Id}.${dut6Id}]]}]]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsDestinationIpMask $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"32":[maskConvert $family 32]}]]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsSourceIpAddr $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"192.168.${dut5Id}.${dut5Id}":[ipv62MibVal [ipConvert $family 192.168.${dut5Id}.${dut5Id}]]}]]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsSourceIpMask $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"32":[maskConvert $family 32]}]]
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
        lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId)]
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
    
        #handlePacket -action reset -portList all -scheduler sequential
        #parray ixia_port

        #ixia check
        scan $ixia_port(1) "%d %d %d" chassis card port
        ixClearPortStats $chassis $card $port
        stat get allStats $chassis $card $port
        set txNeighborSolicits [stat cget -txNeighborSolicits]
        set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
        set txTotal [expr [stat cget -framesSent] - $txNeighborSolicits - $txNeighborAdvertisements]

        scan $ixia_port(4) "%d %d %d" chassis card port
        ixClearPortStats $chassis $card $port
        stat get allStats $chassis $card $port
        set rxNeighborSolicits [stat cget -rxNeighborSolicits]
        set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
        set rxTotal [expr [stat cget -framesReceived] - $rxNeighborSolicits - $rxNeighborAdvertisements]

        log_msg INFO "BEFORE /// Sent: $txTotal Received: $rxTotal"

        log_msg INFO "Sending traffic..."
        lappend res [handlePacket -port 1 -dst [ipConvert $filterType 192.168.${dut6Id}.${dut6Id}] -numDest 1 -src [ipConvert $filterType 192.168.${dut5Id}.${dut5Id}] -numSource 1 \
                    -damac [getMac Dut-$dut1 $port_1_5] -samac 01:02:03:04:05:06 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                    -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownloadstart -dma stopStream]
        #lappend res [handlePacket -port 4 -dst [ipConvert $filterType 192.168.${dut5Id}.${dut5Id}] -numDest 1 -src [ipConvert $filterType 192.168.${dut6Id}.${dut6Id}] -numSource 1 \
                    -damac [getMac Dut-$dut2 $port_2_6] -samac 06:05:04:03:02:01 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                    -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownloadstart -dma stopStream]

        printDotsWhileWaiting 10    

        #ixia check
        scan $ixia_port(1) "%d %d %d" chassis card port
        stat get allStats $chassis $card $port
        set txNeighborSolicits [stat cget -txNeighborSolicits]
        set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
        set txTotal [expr [stat cget -framesSent ] - $txNeighborSolicits - $txNeighborAdvertisements]

        scan $ixia_port(4) "%d %d %d" chassis card port
        stat get allStats $chassis $card $port
        set rxNeighborSolicits [stat cget -rxNeighborSolicits]
        set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
        set rxTotal [expr [stat cget -framesReceived ] - $rxNeighborSolicits - $rxNeighborAdvertisements]

        log_msg INFO "AFTER /// Sent: $txTotal Received: $rxTotal"

        if { $txTotal != $rxTotal } {
            set result ERROR
            log_msg ERROR "Traffic test FAILED!"
        } else {
            log_msg INFO "Traffic test PASSED"
        }

        set ingress_hits 0
        set ingress_byte 0
        set ingress_hits [Dut-$dut2 getT[getVar3 $filterType]FilterParamsIngressHitCount $opt(filterId) $opt(entryId)]
        set ingress_byte [Dut-$dut2 getT[getVar3 $filterType]FilterParamsIngrHitByteCount $opt(filterId) $opt(entryId)]

        puts [cookCliData [Dut-$dut2 sendCliCommand "show filter [string tolower $filterType] $opt(filterId)"]]
        if { $ingress_hits != [expr $opt(rate) * $opt(loops)] } {
            set result ERROR
            log_msg ERROR "Filter hits incorrect!"
        } else {
            log_msg INFO "Filter hits correct"
        }
    }

    # 2. reboot both cpms

    if { $opt(withAdminSave) == "" } { set opt(withAdminSave) [random 2] }

    if { $opt(withAdminSave) } {
        log_msg INFO "Admin saving config before reboot..."
        set ret [cookCliData [Dut-$dut2 sendCliCommand "/admin save"]]
        log_msg [expr {[regexp -nocase "Saving configuration .* OK.*Completed" $ret]?"INFO":"ERROR"}] "CLI: /admin save $ret" -multiline true
    } else {
        log_msg INFO "Not going to admin save config before reboot..."
    }

    log_msg INFO "Reboot all CPMs"
    if { [Dut-$dut2 cget -redundantSystem] } {
        set ret [cookCliData [Dut-$dut2 sendCliCommand "/admin reboot standby now"]]
        log_msg [expr {$ret == ""?"INFO":"ERROR"}] "CLI: /admin reboot standby now $ret" -multiline true
    }
    set ret [cookCliData [Dut-$dut2 sendCliCommand "/admin reboot active now"]]
    log_msg [expr {$ret == ""?"INFO":"ERROR"}] "CLI: /admin reboot active now $ret" -multiline true
    log_msg INFO "Wait 180 seconds before reconnect"
    printDotsWhileWaiting 180
    reconnect
    lappend res [ Dut-$dut2 CnWRedCardStatus ]

    if { $opt(withAdminSave) } {
        log_msg INFO "Wait for the network to converge..."
        printDotsWhileWaiting 60
    }

    # 3. check dipf on all ioms

    if { $opt(withAdminSave) } {
        foreach iom [getIomList $dut2] {
            set ret [cookCliData [Dut-$dut2 sendCliCommand "shell cardcmd $iom dipf"]]
            if { [regexp {\*\*\* No matching ACL_FILTER_LIST_MAP entries found} $ret] } {
                set result ERROR
                log_msg ERROR "Iom $iom failed to sync!"
            } else {
                log_msg INFO "Iom $iom synced successfully."
            }
        }
    } else {
        foreach iom [getIomList $dut2] {
            set ret [cookCliData [Dut-$dut2 sendCliCommand "shell cardcmd $iom dipf"]]
            if { [regexp {\*\*\* No matching ACL_FILTER_LIST_MAP entries found} $ret] } {
                log_msg INFO "Iom $iom was cleaned up properly."
            } else {
                set result ERROR
                log_msg ERROR "Iom $iom failed to cleanup!"
            }
        }
    }

    # 4. setup again + test traffic + check entry hits

    foreach {family filterType} {"ipv4" "IP" "ipv6" "IPv6"} {
        log_msg INFO "Check $filterType Filter:"
        if { $opt(withAdminSave) } {
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
        } else {
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -nofilter true -svcFilterId "ERROR"]
        }
    }

    if { $opt(withAdminSave) } {
        # nothing
    } else {
        log_msg INFO "Recreate config"
        lappend res [serviceAwareFilter_config -useIxia true -cleanupFirst false -skipDuts "A B D E F"]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Config Result: [lindex $res end]"
        foreach {family filterType} {"ipv4" "IP" "ipv6" "IPv6"} {
            log_msg INFO "Check $filterType Filter:"
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
        }
    }

    foreach {family filterType} {"ipv4" "IP" "ipv6" "IPv6"} {

        log_msg INFO "Testing $filterType..."

        if { $opt(withAdminSave) } {
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
        } else {
            lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "createAndGo"]
            log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Create Filter Result: [lindex $res end]"
            lappend res [Dut-$dut2 create[getVar1 $filterType]FilterEntries $opt(filterId) $opt(entryId)]
            lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsDestinationIpAddr $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"192.168.${dut6Id}.${dut6Id}":[ipv62MibVal [ipConvert $family 192.168.${dut6Id}.${dut6Id}]]}]]
            lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsDestinationIpMask $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"32":[maskConvert $family 32]}]]
            lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsSourceIpAddr $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"192.168.${dut5Id}.${dut5Id}":[ipv62MibVal [ipConvert $family 192.168.${dut5Id}.${dut5Id}]]}]]
            lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterParamsSourceIpMask $opt(filterId) $opt(entryId) [expr {$family=="ipv4"?"32":[maskConvert $family 32]}]]
            lappend res [lindex [Dut-$dut2 set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction $opt(filterId) $opt(entryId)] "forward" ]]] 0]
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0]
            lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) $opt(filterId)]
            lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "Yes" -filter_row_status "active" -svcFilterId $opt(filterId)]
        }

        #handlePacket -action reset -portList all -scheduler sequential
        #parray ixia_port

        #ixia check
        scan $ixia_port(1) "%d %d %d" chassis card port
        ixClearPortStats $chassis $card $port
        stat get allStats $chassis $card $port
        set txNeighborSolicits [stat cget -txNeighborSolicits]
        set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
        set txTotal [expr [stat cget -framesSent ] -$txNeighborSolicits -$txNeighborAdvertisements]

        scan $ixia_port(4) "%d %d %d" chassis card port
        ixClearPortStats $chassis $card $port
        stat get allStats $chassis $card $port
        set rxNeighborSolicits [stat cget -rxNeighborSolicits]
        set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
        set rxTotal [expr [stat cget -framesReceived ] -$rxNeighborSolicits -$rxNeighborAdvertisements]

        log_msg INFO "BEFORE /// Sent: $txTotal Received: $rxTotal"

        log_msg INFO "Sending traffic..."
        lappend res [handlePacket -port 1 -dst [ipConvert $filterType 192.168.${dut6Id}.${dut6Id}] -numDest 1 -src [ipConvert $filterType 192.168.${dut5Id}.${dut5Id}] -numSource 1 \
                    -damac [getMac Dut-$dut1 $port_1_5] -samac 01:02:03:04:05:06 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                    -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownloadstart -dma stopStream]
        #lappend res [handlePacket -port 4 -dst [ipConvert $filterType 192.168.${dut5Id}.${dut5Id}] -numDest 1 -src [ipConvert $filterType 192.168.${dut6Id}.${dut6Id}] -numSource 1 \
                    -damac [getMac Dut-$dut2 $port_2_6] -samac 06:05:04:03:02:01 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                    -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownloadstart -dma stopStream]

        printDotsWhileWaiting 10    

        #ixia check
        scan $ixia_port(1) "%d %d %d" chassis card port
        stat get allStats $chassis $card $port
        set txNeighborSolicits [stat cget -txNeighborSolicits]
        set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
        set txTotal [expr [stat cget -framesSent ] -$txNeighborSolicits -$txNeighborAdvertisements]

        scan $ixia_port(4) "%d %d %d" chassis card port
        stat get allStats $chassis $card $port
        set rxNeighborSolicits [stat cget -rxNeighborSolicits]
        set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
        set rxTotal [expr [stat cget -framesReceived ] -$rxNeighborSolicits -$rxNeighborAdvertisements]

        log_msg INFO "AFTER /// Sent: $txTotal Received: $rxTotal"

        if { $txTotal != $rxTotal } {
            set result ERROR
            log_msg ERROR "Traffic test FAILED!"
        } else {
            log_msg INFO "Traffic test PASSED"
        }

        set ingress_hits 0
        set ingress_byte 0
        set ingress_hits [Dut-$dut2 getT[getVar3 $filterType]FilterParamsIngressHitCount $opt(filterId) $opt(entryId)]
        set ingress_byte [Dut-$dut2 getT[getVar3 $filterType]FilterParamsIngrHitByteCount $opt(filterId) $opt(entryId)]

        puts [cookCliData [Dut-$dut2 sendCliCommand "show filter [string tolower $filterType] $opt(filterId)"]]
        if { $ingress_hits != [expr $opt(rate) * $opt(loops)] } {
            set result ERROR
            log_msg ERROR "Filter hits incorrect!"
        } else {
            log_msg INFO "Filter hits correct"
        }
    }

    # 5. cleanup 

    foreach {family filterType} {"ipv4" "IP" "ipv6" "IPv6"} {
        lappend res [serviceAwareFilter_applyFilter $dut2 $opt(svcId) $opt(svcType) $family $opt(direction) 0]
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true"]
        lappend res [Dut-$dut2 setT[getVar3 $filterType]FilterRowStatus $opt(filterId) "destroy"]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Destroy Filter Result: [lindex $res end]"
        lappend res [serviceAwareFilter_checkFilter $dut2 $family $opt(filterId) $opt(entryId) -nofilter true -svcFilterId 0]
    }

    lappend res [serviceAwareFilter_deconfig -useIxia true]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Deconfig Result: [lindex $res end]"

    set ret [cookCliData [Dut-$dut2 sendCliCommand "/admin save"]]
    log_msg [expr {[regexp -nocase "Saving configuration .* OK.*Completed" $ret]?"INFO":"ERROR"}] "CLI: /admin save $ret" -multiline true

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_scaleConfigTestApply {args} {

    set opt(dut)                        "C"
    set opt(maxVprn)                    1023
    set opt(svcNetIngIPFilterId)        true
    set opt(svcNetIngIPv6FilterId)      true

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    # prepare config

    log_msg INFO "Create $opt(maxVprn) IP Filters"
    lappend res [filterScaleAddBatchRules $opt(dut) "" IP 1 1 -startFilter 1 -endFilter $opt(maxVprn)]
    log_msg [expr {[lindex $res end] == "OK"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create $opt(maxVprn) IPv6 Filters"
    lappend res [filterScaleAddBatchRules $opt(dut) "" IPv6 1 1 -startFilter [expr $opt(maxVprn) + 1] -endFilter [expr 2 * $opt(maxVprn)]]
    log_msg [expr {[lindex $res end] == "OK"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    lappend res [serviceAwareFilter_configMaxVprns $opt(maxVprn) -dut $opt(dut) -svcNetIngIPFilterId $opt(svcNetIngIPFilterId) -svcNetIngIPv6FilterId $opt(svcNetIngIPv6FilterId)]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    # test

    set var [random 2]
    if { [GGV 7710Support] } {
        # only one filter can be created (max = 2047)
        if { $var } {
            log_msg INFO "Create one more IP Filter"
            lappend res [Dut-$opt(dut) setTIPFilterRowStatus [expr $opt(maxVprn) + 1] "createAndGo"]
            log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

            log_msg INFO "Create one more IP Filter Entry"
            lappend res [Dut-$opt(dut) createIpFilterEntries [expr $opt(maxVprn) + 1] 1]
            log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"
        } else {
            log_msg INFO "Create one more IPv6 Filter"
            lappend res [Dut-$opt(dut) setTIPv6FilterRowStatus [expr (2 * $opt(maxVprn)) + 1] "createAndGo"]
            log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

            log_msg INFO "Create one more IPv6 Filter Entry"
            lappend res [Dut-$opt(dut) createIpv6FilterEntries [expr (2 * $opt(maxVprn)) + 1] 1]
            log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"
        }
    } else {
        log_msg INFO "Create one more IP Filter"
        lappend res [Dut-$opt(dut) setTIPFilterRowStatus [expr $opt(maxVprn) + 1] "createAndGo"]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Create one more IP Filter Entry"
        lappend res [Dut-$opt(dut) createIpFilterEntries [expr $opt(maxVprn) + 1] 1]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Create one more IPv6 Filter"
        lappend res [Dut-$opt(dut) setTIPv6FilterRowStatus [expr 2 * ($opt(maxVprn) + 1)] "createAndGo"]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Create one more IPv6 Filter Entry"
        lappend res [Dut-$opt(dut) createIpv6FilterEntries [expr 2 * ($opt(maxVprn) + 1)] 1]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"
    }

    log_msg INFO "Create one more VPRN"
    lappend res [Dut-$opt(dut) createVprn [expr $opt(maxVprn) + 1] 1 111:1]
    log_msg [expr {[lindex $res end] == "OK"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    if { [GGV 7710Support] } {
        set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom"]]
        log_msg DEBUG "$dump" -multiline true
        if { $var } {
            log_msg INFO "Applying IP Filter"
            set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv4" Ingress [expr $opt(maxVprn) + 1]]
            if { $temp != "noError" } {
                log_msg ERROR "Failed to apply filter!"
                set result ERROR
            } else {
                log_msg INFO "Filter applied successfully"
            }
            lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv4" [expr $opt(maxVprn) + 1] 1 -applied "Yes" -filter_row_status "active" -svcFilterId [expr $opt(maxVprn) + 1] -svcId [expr $opt(maxVprn) + 1]]
        } else {
            log_msg INFO "Applying IPv6 Filter"
            set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv6" Ingress [expr (2 * $opt(maxVprn)) + 1]]
            if { $temp != "noError" } {
                log_msg ERROR "Failed to apply filter!"
                set result ERROR
            } else {
                log_msg INFO "Filter applied successfully"
            }
            lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv6" [expr (2 * $opt(maxVprn)) + 1] 1 -applied "Yes" -filter_row_status "active" -svcFilterId [expr (2 * $opt(maxVprn)) + 1] -svcId [expr $opt(maxVprn) + 1]]
        }
    } else {
        for { set i 0 } { $i < 2 } { incr i } {
            set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom"]]
            log_msg DEBUG "$dump" -multiline true
            if { $i == $var } {
                # ipv4
                if { $i == 0 } {
                    log_msg INFO "Randomly applying IP Filter as the first one"
                    set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv4" Ingress [expr $opt(maxVprn) + 1]]
                    if { $temp != "noError" } {
                        log_msg ERROR "Failed to apply filter!"
                        set result ERROR
                    } else {
                        log_msg INFO "Filter applied successfully"
                    }
                    lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv4" [expr $opt(maxVprn) + 1] 1 -applied "Yes" -filter_row_status "active" -svcFilterId [expr $opt(maxVprn) + 1] -svcId [expr $opt(maxVprn) + 1]]
                } else {
                    log_msg INFO "Randomly applying IP Filter as the second one (should not be allowed)"
                    set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv4" Ingress [expr $opt(maxVprn) + 1]]
                    if { $temp != "noError" } {
                        log_msg INFO "Filter failed to apply (expected)"
                    } else {
                        log_msg ERROR "Filter applied successfully (should not be allowed)!"
                        set result ERROR
                    }
                    lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv4" [expr $opt(maxVprn) + 1] 1 -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true" -svcId [expr $opt(maxVprn) + 1]]
                }
            } else {
                # ipv6
                if { $i == 0 } {
                    log_msg INFO "Randomly applying IPv6 Filter as the first one"
                    set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv6" Ingress [expr 2 * ($opt(maxVprn) + 1)]]
                    if { $temp != "noError" } {
                        log_msg ERROR "Failed to apply filter!"
                        set result ERROR
                    } else {
                        log_msg INFO "Filter applied successfully"
                    }
                    lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv6" [expr 2 * ($opt(maxVprn) + 1)] 1 -applied "Yes" -filter_row_status "active" -svcFilterId [expr 2 * ($opt(maxVprn) + 1)] -svcId [expr $opt(maxVprn) + 1]]
                } else {
                    log_msg INFO "Randomly applying IPv6 Filter as the second one (should not be allowed)"
                    set temp [serviceAwareFilter_applyFilter $opt(dut) [expr $opt(maxVprn) + 1] vprn "ipv6" Ingress [expr 2 * ($opt(maxVprn) + 1)]]
                    if { $temp != "noError" } {
                        log_msg INFO "Filter failed to apply (expected)"
                    } else {
                        log_msg ERROR "Filter applied successfully (should not be allowed)!"
                        set result ERROR
                    }
                    lappend res [serviceAwareFilter_checkFilter $opt(dut) "ipv6" [expr 2 * ($opt(maxVprn) + 1)] 1 -applied "No" -association "" -filter_row_status "active" -svcFilterId 0 -checkServiceFId "true" -svcId [expr $opt(maxVprn) + 1]]
                }
            }
        }
    }
    set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom"]]
    log_msg DEBUG "$dump" -multiline true

    # cleanup

    log_msg INFO "Cleanup started."
    log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
    setGlobalVar consoleLogLevel ERROR
    cleanupConfig
    setGlobalVar consoleLogLevel DEBUG
    log_msg INFO "Cleanup finished."

    foreach r $res {
        if { ($r != "OK") && ($r != "PASSED") && ($r != "noError") } { 
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_checkDump {family applied args} {

    set opt(dut)            "C"
    set opt(reserved)       "2"
    set opt(maxFreev4)      ""
    set opt(maxFreev6)      ""

    getopt opt $args

    set result PASSED

    if { $opt(maxFreev4) == "" } {
        if { [GGV 7710Support] } {
            set opt(maxFreev4)      "32768"
        } elseif { [filter_isHsa $opt(dut)] } {
            set opt(maxFreev4)      "32768"
        } else {
            set opt(maxFreev4)      "65536"
        }
    }
    if { $opt(maxFreev6) == "" } {
        if { [GGV 7710Support] } {
            set opt(maxFreev6)      "14336"
        } elseif { [filter_isHsa $opt(dut)] } {
            set opt(maxFreev6)      "12288"
        } else {
            set opt(maxFreev6)      "28672"
        }
    }

    if { $family == "ipv4" } {
        set idx 6
        set maxFree $opt(maxFreev4)
    } else {
        set idx 8
        set maxFree $opt(maxFreev6)
    }

    set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom | match Ingr"]]
    log_msg DEBUG "$dump" -multiline true
    foreach line [split $dump "\n"] {
        set free([lindex [split [join $line " "]] 0]) [lindex [split [join $line " "]] $idx]
        set used([lindex [split [join $line " "]] 0]) [lindex [split [join $line " "]] [expr $idx - 1]]
    }
    foreach {key value} [array get free] {
        log_msg INFO "$family entries available iom $key = $value"
        if { $value == [expr $maxFree - $opt(reserved) - $applied] } {
            log_msg INFO "$family entries available check iom($key): PASSED"
        } else {
            set result ERROR
            log_msg ERROR "$family entries available check iom($key): FAILED"
        }
    }
    foreach {key value} [array get used] {
        log_msg INFO "$family entries used iom $key = $value"
        if { $value == [expr $applied + $opt(reserved)] } {
            log_msg INFO "$family entries used check iom($key): PASSED"
        } else {
            set result ERROR
            log_msg ERROR "$family entries used check iom($key): FAILED"
        }
    }

    return $result
}

proc serviceAwareFilter_scaleConfigTestSwitch {args} {

    set opt(dut)            "C"
    set opt(filterIdv4)     "4"
    set opt(filterIdv6)     "6"
    set opt(filterIdv44)    "44"
    set opt(filterIdv66)    "66"

    #set opt(freeEntries)    "18"

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    # prepare config

    if { [GGV 7710Support] } {
        set smallSizev4         121
        set smallSizev6         33
        set bigSizev4           32645
        set bigSizev6           14301
        set nbrEntriesv4        316
        set nbrEntriesv6        155
    } elseif { [filter_isHsa $opt(dut)] } {
        set smallSizev4         121
        set smallSizev6         102
        set bigSizev4           32645
        set bigSizev6           12184
        set nbrEntriesv4        316
        set nbrEntriesv6        133
    } else {
        set smallSizev4         18
        set smallSizev6         12
        set bigSizev4           65516
        set bigSizev6           28658
        set nbrEntriesv4        0
        set nbrEntriesv6        0
    }

    set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom"]]
    log_msg DEBUG "$dump" -multiline true

    log_msg INFO "Create IP Filter (id: $opt(filterIdv4))"
    lappend res [Dut-$opt(dut) setTIPFilterRowStatus $opt(filterIdv4) "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create IPv6 Filter (id: $opt(filterIdv6))"
    lappend res [Dut-$opt(dut) setTIPv6FilterRowStatus $opt(filterIdv6) "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create IP Filter (id: $opt(filterIdv4)) Entries"
    lappend res [lindex [makeIPfilterEntries $opt(dut) $opt(filterIdv4) ingress -iom3 true -nbrEntries $nbrEntriesv4] 0]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create IPv6 Filter (id: $opt(filterIdv6)) Entries"
    lappend res [lindex [makeIPv6filterEntries $opt(dut) $opt(filterIdv6) ingress -iom3 true -nbrEntries $nbrEntriesv6] 0]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create VPRN"
    lappend res [Dut-$opt(dut) createVprn 1 1 222:1]
    log_msg [expr {[lindex $res end] == "OK"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create IP Filter (id: $opt(filterIdv44))"
    lappend res [Dut-$opt(dut) setTIPFilterRowStatus $opt(filterIdv44) "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create $smallSizev4 Entries for IP Filter (id: $opt(filterIdv44))"
    for { set i 1 } { $i <= $smallSizev4 } { incr i } {
        lappend res [Dut-$opt(dut) createIpFilterEntries $opt(filterIdv44) $i]
        #log_msg INFO "$i: [lindex $res end]"
        lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack tIPFilterParamsAction $opt(filterIdv44) $i] "forward" ]]] 0]
        #log_msg INFO "$i: [lindex $res end]"
    }

    log_msg INFO "Create IPv6 Filter (id: $opt(filterIdv66))"
    lappend res [Dut-$opt(dut) setTIPv6FilterRowStatus $opt(filterIdv66) "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

    log_msg INFO "Create $smallSizev6 Entries for IPv6 Filter (id: $opt(filterIdv66))"
    for { set i 1 } { $i <= $smallSizev6} { incr i } {
        lappend res [Dut-$opt(dut) createIpv6FilterEntries $opt(filterIdv66) $i]
        #log_msg INFO "$i: [lindex $res end]"
        lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack tIPv6FilterParamsAction $opt(filterIdv66) $i] "forward" ]]] 0]
        #log_msg INFO "$i: [lindex $res end]"
    }

    foreach {bigFilter smallFilter} [list $opt(filterIdv4) $opt(filterIdv44) $opt(filterIdv6) $opt(filterIdv66)] {

        if { [regexp {4|44} $bigFilter] } {
            set family "ipv4"
            set filterType "IP"
            set smallSize $smallSizev4
            set bigSize $bigSizev4
        } else {
            set family "ipv6"
            set filterType "IPv6"
            set smallSize $smallSizev6
            set bigSize $bigSizev6
        }

        # apply small / apply big / apply small

        log_msg INFO "Apply Small Filter (id: $smallFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $smallFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family $smallSize]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Apply Big Filter (id: $bigFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $bigFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family $bigSize]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Apply Small Filter (id: $smallFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $smallFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family $smallSize]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        # add entry to small

        log_msg INFO "add 1 entry to $family filter (id: $smallFilter)"
        lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries $smallFilter [expr $smallSize + 1]]
        lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction $smallFilter [expr $smallSize + 1]] "forward" ]]] 0]

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family [expr $smallSize + 1]]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        # apply big / apply small

        log_msg INFO "Apply Big Filter (id: $bigFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $bigFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family $bigSize]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Apply Small Filter (id: $smallFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $smallFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family [expr $smallSize + 1]]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        # add 12/18 entries to big (full)

        for { set i 1 } { $i <= $smallSize } { incr i } {
            lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries $bigFilter $i]
            lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction $bigFilter $i] "forward" ]]] 0]
        }

        # apply big / apply small

        log_msg INFO "Apply Big Filter (id: $bigFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $bigFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family [expr $bigSize + $smallSize]]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Apply Small Filter (id: $smallFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $smallFilter]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family [expr $smallSize + 1]]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        # add 1 entry to big (full+1)

        lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries $bigFilter [expr $smallSize + 1]]
        lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction $bigFilter [expr $smallSize + 1]] "forward" ]]] 0]

        # apply big (should fail)

        log_msg INFO "Apply Big Filter (id: $bigFilter family: $family)"
        set temp [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress $bigFilter]
        if { $temp != "noError" } {
            log_msg INFO "Result: $temp (expected)"
        } else {
            log_msg ERROR "Result: $temp (should not have been allowed!)"
            set result ERROR
        }

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family [expr $smallSize + 1]]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        # remove small (we should always end up with small)

        log_msg INFO "Remove Small Filter (id: $smallFilter family: $family)"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress 0]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Result: [lindex $res end]"

        log_msg INFO "Check Tools Dump:"
        lappend res [serviceAwareFilter_checkDump $family 0]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Result: [lindex $res end]"
    }

    set dump [cookCliData [Dut-$opt(dut) sendCliCommand "/tools dump filter resources iom | match Ingr"]]
    log_msg DEBUG "$dump" -multiline true

    # cleanup

    log_msg INFO "Cleanup started."
    log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
    setGlobalVar consoleLogLevel ERROR
    cleanupConfig
    setGlobalVar consoleLogLevel DEBUG
    log_msg INFO "Cleanup finished."

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_printDebug {args} {

    set opt(dut)            "C"
    set opt(filterId)       "1"
    set opt(entryId)        "1"
    set opt(family)         "ipv4"

    getopt opt $args

    set chassisIdx 1; set i 1
    while { [Dut-$opt(dut) getTmnxCardHwIndex $chassisIdx $i] != "ERROR" } { incr i }
    set iomCnt [expr $i - 1]

    log_msg INFO "Found $iomCnt IOM(s)"

    for { set j 1 } { $j <= $iomCnt } { incr j } {
        if { [string tolower $opt(family)] == "ip" } {
            log_msg DEBUG [cookCliData [Dut-$opt(dut) sendCliCommand "shell cardcmd $j dipf $opt(filterId) $opt(entryId)"]] -multiline true
        } else {
            log_msg DEBUG [cookCliData [Dut-$opt(dut) sendCliCommand "shell cardcmd $j dip6f $opt(filterId) $opt(entryId)"]] -multiline true
        }
        log_msg DEBUG [cookCliData [Dut-$opt(dut) sendCliCommand "shell cardcmd $j dcami $opt(filterId) $opt(entryId)"]] -multiline true
        log_msg DEBUG [cookCliData [Dut-$opt(dut) sendCliCommand "shell cardcmd $j dcame $opt(filterId) $opt(entryId)"]] -multiline true
        log_msg DEBUG [cookCliData [Dut-$opt(dut) sendCliCommand "shell cardcmd $j dresource $opt(filterId) $opt(entryId)"]] -multiline true
    }
}

proc serviceAwareFilter_basicTestTcamFramework {args} {

    global ixia_port

    set opt(issuBeforeConfig)   "false"
    set opt(issuAfterConfig)    "false"
    set opt(dut)                "C"
    set opt(pktsPerStream)      "20"
    set opt(withHA)             "false"

    getopt opt $args

    set result PASSED
    set testid $::TestDB::currentTestCase

    if { $opt(issuBeforeConfig) } {
        Dut-$opt(dut) activitySwitch
        reconnect
    }

    # pick config

    set filterType [lindex [list "IP" "IPv6"] [random 2]]

    lappend specialList "nullEncap_vprn_autobindGre"
    lappend specialList "nullEncap_vprn_autobindLdp"
    lappend specialList "nullEncap_vprn_autobindLdpOverRsvp"
    lappend specialList "nullEncap_vprn_autobindRsvp"
    lappend specialList "nullEncap_vprn_exSpokeGre"
    lappend specialList "nullEncap_vprn_exSpokeMplsLdp"
    lappend specialList "nullEncap_vprn_exSpokeMplsLdpOverRsvp"
    lappend specialList "nullEncap_vprn_exSpokeMplsLsp"
    lappend specialList "nullEncap_vprn_exSpoke3107"

    log_msg NOTICE "setupList to select random setupCase for filterType $filterType = $specialList"
    set setupList [lindex $specialList [random [llength $specialList]]]

    set setupType "${filterType}_${setupList}"

    # config

    log_msg INFO " --- Config --- "
    lappend res [filterTCAM_test $setupType -test "" -config true -trafficTest true -cleanup false]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Config Result: [lindex $res end]"

    # create filter

    log_msg INFO "Create $filterType Filter"
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterRowStatus 1 "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Create Filter Result: [lindex $res end]"

    # add entry and set action to forward

    log_msg INFO "Add Entry"
    lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries 1 1]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Add Entry Result: [lindex $res end]"

    log_msg INFO "Change Action Of Entry To Forward"
    lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction 1 1] "forward" ]]] 0]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Change Action Result: [lindex $res end]"

    if { $opt(issuAfterConfig) } {
        Dut-$opt(dut) activitySwitch
        reconnect
    }

    # apply filter

    log_msg INFO "Apply Filter"
    lappend res [filterTCAM_applyFilter $setupType Ingress 1]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Apply Filter Result: [lindex $res end]"

    # traffic test

    set iteration 1

    log_msg INFO "Traffic Test:"
    lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

    # check entry hits

    set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
    set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

    scan $ixia_port(1) "%d %d %d" chassis card port
    port get $chassis $card $port
    set i 1
    while { ! [stream get $chassis $card $port $i] } {
        incr i
        if { $i > 100 } {
            log_msg ERROR "Found more than 100 streams .. stopping now!"
            break
        }
    }
    set numStreams [expr $i - 1]
    log_msg INFO "Found $numStreams stream(s) in Ixia"

    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
    if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
        set result ERROR
        log_msg ERROR "Filter Hits Check: FAILED!"
        serviceAwareFilter_printDebug -family $filterType
    } else {
        log_msg INFO "Filter Hits Check: PASSED"
    }

    if { $opt(withHA) } {

        global port_3_2 sdpList

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

        # 1. boot standby CPM to force reconcile

        log_msg INFO "=== first boot standby CPM to force reconcile of Dut-$opt(dut) and retest traffic ==="
        Dut-$opt(dut) sendCliCommand "/admin reboot standby now"
        sleep 2
        Dut-$opt(dut) CnWRedCardStatus

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

        set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
        if {$rc != "OK"} {
            log_msg ERROR "Resource mismatch after standby reboot"
            set result ERROR
        }

        # traffic test

        printDotsWhileWaiting 30

        incr iteration

        log_msg INFO "Traffic Test:"
        lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

        # check entry hits

        set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
        set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
        if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
            set result ERROR
            log_msg ERROR "Filter Hits Check: FAILED!"
            serviceAwareFilter_printDebug -family $filterType
        } else {
            log_msg INFO "Filter Hits Check: PASSED"
        }

        # 2. activityswitch and retest traffic

        log_msg INFO "=== switchover CPM of Dut-$opt(dut) and retest traffic  ==="
        Dut-$opt(dut) activitySwitch
        reconnect

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

        set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
        if {$rc != "OK"} {
            log_msg ERROR "Resource mismatch after cpm switchover"
            set result ERROR
        }

        # traffic test

        printDotsWhileWaiting 30

        incr iteration

        if { ([GGV 7710Support]) && ([GGV subTopology] == "sparrow") } {
            # entry hit counter is reset during first reconcile, so standby stats are 0 and after the swo, the previous hits are missing
            incr iteration -1
            log_msg NOTICE "Adapting iteration variable because of subTopology [GGV subTopology]."
            puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
        }

        log_msg INFO "Traffic Test:"
        lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

        # check entry hits

        set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
        set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
        if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
            set result ERROR
            log_msg ERROR "Filter Hits Check: FAILED!"
            serviceAwareFilter_printDebug -family $filterType
        } else {
            log_msg INFO "Filter Hits Check: PASSED"
        }

        # 3. second activityswitch and retest traffic

        log_msg INFO "=== second switchover CPM of Dut-$opt(dut) and retest traffic ==="
        Dut-$opt(dut) activitySwitch
        reconnect

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

        set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
        if {$rc != "OK"} {
            log_msg ERROR "Resource mismatch after 2nd switchover"
            set result ERROR
        }

        # traffic test

        printDotsWhileWaiting 30

        incr iteration

        if { ([GGV 7710Support]) && ([GGV subTopology] == "sparrow") } { 
            # entry hit counter is reset during first reconcile, so standby stats are 0 and after the swo, the previous hits are missing
            incr iteration -1 
            log_msg NOTICE "Adapting iteration variable because of subTopology [GGV subTopology]."
            puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
        }

        log_msg INFO "Traffic Test:"
        lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
        log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

        # check entry hits

        set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
        set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

        puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
        if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
            set result ERROR
            log_msg ERROR "Filter Hits Check: FAILED!"
            serviceAwareFilter_printDebug -family $filterType
        } else {
            log_msg INFO "Filter Hits Check: PASSED"
        }

        # 4. remove/insert mda

        set done ""
        foreach port "$port_3_2" {
            set slot [lindex [ split $port "/" ] 0]
            set mda  [lindex [ split $port "/" ] 1]
            if {[lsearch $done "$slot/$mda"] == "-1"} {
                lappend done "$slot/$mda"
                log_msg INFO "=== remove and insert mda $slot/$mda of Dut-$opt(dut) and retest traffic ==="
                Dut-$opt(dut) sendCliCommand "shell cardcmd $slot remove_mda n:$mda"
                after 5000
                Dut-$opt(dut) sendCliCommand "shell cardcmd $slot insert_mda n:$mda"
                after 5000
                Dut-$opt(dut) CnWMdaStatus

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

                set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
                if {$rc != "OK"} {
                    log_msg ERROR "Resource mismatch after remove/insert mda"
                    set result ERROR
                }

                # wait for sdps to converge before continuing
                foreach { dut remoteIp sdpId } $sdpList {
                    set r [check_converge $dut $sdpId ]
                    set r [Dut-$opt(dut) getSdpOperStatus $sdpId]
                    if { ($r != "up") } { log_msg DEBUG "converge for Dut-$opt(dut) sdp $sdpId not ok - $r" }
                }

                log_msg NOTICE "Wait 60 seconds for network convergence ..."
                printDotsWhileWaiting 60

                # traffic test

                incr iteration

                log_msg INFO "Traffic Test:"
                lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
                log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

                # check entry hits

                set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
                set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
                if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
                    set result ERROR
                    log_msg ERROR "Filter Hits Check: FAILED!"
                    serviceAwareFilter_printDebug -family $filterType
                } else {
                    log_msg INFO "Filter Hits Check: PASSED"
                }
            }
        }

        # 5. clear mda

        set done ""
        foreach port "$port_3_2" {
            set card [lindex [ split $port "/" ] 0]
            set mda  [lindex [ split $port "/" ] 1]
            if {[lsearch $done "${card}/${mda}"] == "-1"} {
                lappend done "${card}/${mda}"
                log_msg INFO "=== clear mda ${card}/${mda} of Dut-$opt(dut) and retest traffic ==="
                Dut-$opt(dut) sendCliCommand "/clear mda ${card}/${mda}"
                Dut-$opt(dut) CnWMdaStatus -Time 300

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

                set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
                if {$rc != "OK"} {
                    log_msg ERROR "Resource mismatch after clear mda"
                    set result ERROR
                }

                # wait for sdps to converge before continuing
                foreach { dut remoteIp sdpId } $sdpList {
                    set r [check_converge $dut $sdpId ]
                    set r [Dut-$dut getSdpOperStatus $sdpId]
                    if { ($r != "up") } { log_msg DEBUG "converge for Dut-$dut sdp $sdpId not ok - $r" }
                }

                log_msg NOTICE "Wait 60 seconds for network convergence ..."
                printDotsWhileWaiting 60

                # traffic test

                incr iteration

                log_msg INFO "Traffic Test:"
                lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
                log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

                # check entry hits

                set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
                set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
                if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
                    set result ERROR
                    log_msg ERROR "Filter Hits Check: FAILED!"
                    serviceAwareFilter_printDebug -family $filterType
                } else {
                    log_msg INFO "Filter Hits Check: PASSED"
                }
            }
        }

        # 6. clear card

        set done ""
        foreach port "$port_3_2" {
            set card [lindex [ split $port "/" ] 0]
            if {[lsearch $done "$card"] == "-1"} {
                lappend done "$card"
                log_msg INFO "=== clear iom card $card of Dut-$opt(dut) and retest traffic ==="
                catch {Dut-$opt(dut) getTmnxCardEquippedType 1 $card} card_type
                Dut-$opt(dut) sendCliCommand "/clear card $card"
                after 15000 ; set i 1 ; set card_reboot "Fail"
                while {$i < 20} {
                    catch {Dut-$opt(dut) getTmnxCardEquippedType 1 $card} card_type_new
                    if {$card_type == $card_type_new} {
                        set card_reboot "Ok"
                        break
                    }
                    incr i ; after 5000
                }
                log_msg DEBUG "Card reboot returned $card_reboot"
                Dut-$opt(dut) CnWCardStatus

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

                set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
                if {$rc != "OK"} {
                    log_msg ERROR "Resource mismatch after clear card"
                    set result ERROR
                }

                # wait for sdps to converge before continuing
                foreach { dut remoteIp sdpId } $sdpList {
                    set r [check_converge $dut $sdpId ]
                    set r [Dut-$dut getSdpOperStatus $sdpId]
                    if { ($r != "up") } { log_msg DEBUG "converge for Dut-$dut sdp $sdpId not ok - $r" }
                }

                log_msg NOTICE "Wait 60 seconds for network convergence ..."
                printDotsWhileWaiting 60

                # traffic test

                if { ([GGV 7710Support]) && ([GGV subTopology] == "sparrow") } {
                    # entry hit counter is reset during first reconcile, so standby stats are 0 and after the swo, the previous hits are missing
                    incr iteration
                    log_msg NOTICE "Adapting iteration variable because of subTopology [GGV subTopology]."
                    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
                } else {
                    set iteration 1
                }

                log_msg INFO "Traffic Test:"
                lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
                log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

                # check entry hits

                set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
                set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

                puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
                if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
                    set result ERROR
                    log_msg ERROR "Filter Hits Check: FAILED!"
                    serviceAwareFilter_printDebug -family $filterType
                } else {
                    log_msg INFO "Filter Hits Check: PASSED"
                }
            }
        }

        # 7. hsa switch microcode

        if {[filter_isHsa $opt(dut)]} {

            Dut-$opt(dut) hsa_switchAndVerify_ActiveCpmMicrocodeSlot

            puts [cookCliData [Dut-$opt(dut) sendCliCommand "show card"]]

            set rc [resMgr_verify_resources OK -dut Dut-$opt(dut) -maxTries 60]
            if {$rc != "OK"} {
                log_msg ERROR "Resource mismatch after hsa switch microcode"
                set result ERROR
            }

            log_msg NOTICE "Wait 60 seconds for network convergence ..."
            printDotsWhileWaiting 60

            # traffic test

            incr iteration

            log_msg INFO "Traffic Test:"
            lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
            log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"

            # check entry hits

            set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
            set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

            puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
            if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * $iteration] } {
                set result ERROR
                log_msg ERROR "Filter Hits Check: FAILED!"
                serviceAwareFilter_printDebug -family $filterType
            } else {
                log_msg INFO "Filter Hits Check: PASSED"
            }
        }
    }

    # cleanup

    log_msg INFO "Remove Filter"
    lappend res [filterTCAM_applyFilter $setupType Ingress 0]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Remove Filter Result: [lindex $res end]"

    log_msg INFO "Destroy $filterType Filter"
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterRowStatus 1 "destroy"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Destroy Filter Result: [lindex $res end]"

    log_msg INFO " --- Cleanup --- "
    lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest false -cleanup true]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Cleanup Result: [lindex $res end]"

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_snmpWalk {args} {

    set opt(dut)                        "C"
    set opt(maxVprn)                    1023
    set opt(cleanup)                    true
    set opt(svcNetIngIPFilterId)        true
    set opt(svcNetIngIPv6FilterId)      true

    getopt opt $args

    set result PASSED
    set testID $::TestDB::currentTestCase

    lappend res [filterScaleAddBatchRules $opt(dut) "" IP 1 1 -startFilter 1 -endFilter $opt(maxVprn)]
    lappend res [filterScaleAddBatchRules $opt(dut) "" IPv6 1 1 -startFilter [expr $opt(maxVprn) + 1] -endFilter [expr 2 * $opt(maxVprn)]]

    lappend res [serviceAwareFilter_configMaxVprns $opt(maxVprn) -dut $opt(dut) -svcNetIngIPFilterId $opt(svcNetIngIPFilterId) -svcNetIngIPv6FilterId $opt(svcNetIngIPv6FilterId)]

    # str: noError
    # int: 0
    # {svcVprnInfoEntryLastChanged.1 SNMPv2-TC:TimeStamp 1277323}
    # {svcNetIngQosPolicyId.1 TIMETRA-TC-MIB:TPolicyID 0}
    # {svcNetIngQosFPQGrp.1 TIMETRA-TC-MIB:TNamedItemOrEmpty {}}
    # {svcNetIngQosFPQGrpInstanceId.1 TIMETRA-TC-MIB:TQosQGrpInstanceIDorZero 0}
    # {svcNetIngIPFilterId.1 TIMETRA-FILTER-MIB:TIPFilterID 1}
    # {svcNetIngIPv6FilterId.1 TIMETRA-FILTER-MIB:TIPFilterID 2}

    if { [filter_isHsa $opt(dut)] } {
        set snmpEntries "svcVprnInfoEntryLastChanged svcNetIngIPFilterId svcNetIngIPv6FilterId"
    } else {
        set snmpEntries "svcVprnInfoEntryLastChanged svcNetIngQosPolicyId svcNetIngQosFPQGrp svcNetIngQosFPQGrpInstanceId svcNetIngIPFilterId svcNetIngIPv6FilterId"
    }

    foreach {resStr resInt mibList} [Dut-C walk svcVprnInfoTable] {
        if { $resStr != "noError" || $resInt != 0 } {
            set result ERROR
            log_msg ERROR "Unexpected error during snmp walk: $resStr $resInt"
        }
        #foreach row $mibList {
        #    puts $row
        #}
        set j 0
        foreach lineType $snmpEntries {
            for { set i 1 } { $i <= $opt(maxVprn) } { incr i } {
                #puts "[lindex $mibList [expr ($i * $j) - 1]]"
                if { ! [regexp "${lineType}.${i}" [lindex $mibList [expr ($i + ($j * $opt(maxVprn))) - 1]]] } {
                    set result ERROR
                    log_msg ERROR "expected: ${lineType}.${i}"
                    log_msg ERROR "have    : [lindex $mibList [expr ($i + ($j * $opt(maxVprn))) - 1]]"
                    puts ""
                } else {
                    log_msg INFO "expected: ${lineType}.${i}"
                    log_msg INFO "have    : [lindex $mibList [expr ($i + ($j * $opt(maxVprn))) - 1]]"
                }
            }
            incr j
        }
    }

    # cleanup

    if { $opt(cleanup)} {
        log_msg INFO "Cleanup started."
        log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
        setGlobalVar consoleLogLevel ERROR
        cleanupConfig
        setGlobalVar consoleLogLevel DEBUG
        log_msg INFO "Cleanup finished."
    }

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED "Test Case $testID PASSED"
    } else {
        log_result FAILED "Test Case $testID FAILED"
    }

    return $result

}

proc serviceAwareFilter_configMaxVprns {maxVprn args} {


    set opt(dut)                    "C"
    set opt(svcNetIngIPFilterId)    false
    set opt(svcNetIngIPv6FilterId)  false

    getopt opt $args

    set result PASSED

    log_msg INFO "Configure $maxVprn VPRNs"

    set filename "serviceAwareFilter_maxVPRN_${opt(dut)}"
    set lfileid [openConfigFile $filename ]

    for {set i 1} {$i <= $maxVprn} {incr i} {
        puts $lfileid "exit all"
        puts $lfileid "configure service vprn $i customer 1 create"
        puts $lfileid "        service-name \"VPRN $i\""
        puts $lfileid "    no shutdown"
        puts $lfileid "exit all"
        if { $opt(svcNetIngIPFilterId) } {
            puts $lfileid "configure service vprn $i network ingress filter ip $i"
            puts $lfileid "exit all"
        }
        if { $opt(svcNetIngIPv6FilterId) } {
            puts $lfileid "configure service vprn $i network ingress filter ipv6 [expr $i + $maxVprn]"
            puts $lfileid "exit all"
        }
    }

    set r [execConfigFile $opt(dut) $lfileid $filename -execTimeout 1000]
    if { $r != "OK"} {
        log_msg ERROR "error during exec of config file $filename"
        set result "FAILED"
    }

    return $result
}

proc serviceAwareFilter_configMaxSdp {maxSdp args} {


    set opt(dut)                    "C"
    set opt(assignToService)        0
    set opt(startFarEnd)            10.20.1.1
    set opt(deliveryType)           ""
    set opt(startId)                1

    getopt opt $args

    set result PASSED

    if { $opt(startId) < 1 } {
        log_msg ERROR "Wrong value for sdp id!"
        return ERROR
    }

    log_msg INFO "Configure $maxSdp SDPs"

    set filename "serviceAwareFilter_maxSDP_${opt(dut)}"
    set lfileid [openConfigFile $filename ]

    set a [lindex [split $opt(startFarEnd) "."] 0]
    set b [lindex [split $opt(startFarEnd) "."] 1]
    set c [lindex [split $opt(startFarEnd) "."] 2]
    set d [lindex [split $opt(startFarEnd) "."] 3]

    for { set i $opt(startId) } { $i <= [expr $opt(startId) + $maxSdp - 1] } { incr i } {

        if { $d > 254 } {
            set d 0
            incr c
            if { $c > 255 } {
                set c 0
                incr b
                if { $b > 255 } {
                    set b 0
                    incr a
                    if { $a > 255 } {
                        set a 0
                    }
                }
            }
        } else {
            incr d
        }

        puts $lfileid "exit all"
        puts $lfileid "configure service sdp $i $opt(deliveryType) create far-end ${a}.${b}.${c}.${d}"
        puts $lfileid "exit all"

        if { $opt(assignToService) > 0 } {
            puts $lfileid "configure service vprn $opt(assignToService) spoke-sdp $i create"
            puts $lfileid "exit all"
        }
    }

    set r [execConfigFile $opt(dut) $lfileid $filename -execTimeout 1000]
    if { $r != "OK"} {
        log_msg ERROR "error during exec of config file $filename"
        set result "FAILED"
    }

    return $result
}

proc rebootAllSimsNoWait {} {

    foreach dut "Dut-A Dut-B Dut-C Dut-D Dut-E Dut-F" {

        set session [becomeRootUser -ip [lindex [split [getDutIpAddress $dut] "/"] 0] -login admin -pw admin]

        exp_send -i $session "admin reboot now\r"

        closeRootUser $session
    }

} ;# End of rebootAllSimsNoWait

proc serviceAwareFilter_flowspec {args} {

    global testdir logdir
    global portA dataip
    
    source $testdir/testsuites/flowspec/flowspec_vprnParams.tcl
    source $testdir/testsuites/flowspec/flowspec_Procs.tcl
    
    set option(config)                    true
    set option(test)                      true
    set option(deconfig)                  true
    set option(debug)                     false
    set option(verbose)                   false
    set option(bugxxxxx)                  false
    set option(returnResult)              false
    set option(sbgpDebug)                 false
    set option(dumpDebugLog)              false
    set option(cliTimeout)                600
    set option(nbrVprns)                  3
    set option(nbrFlowroutesPerVprn)      1
    set option(actionListPerVprn)         [list drop] ;#[list drop log accept redirectVrf]
    set option(sendBgpFlowrouteUpd_v4)    true
    set option(sendBgpFlowrouteUpd_v6)    true
    set option(itfType_dut1dut2)          ""
    set option(addFlowroutesInBase)       true
    set option(neverDisableDutLogging)    false
  
    getopt option $args
  
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
    if {[GGV fspecItfType_dut1dut2] != "ERROR"} {
        set itfType_dut1dut2 [GGV fspecItfType_dut1dut2]
    } else {
        set itfType_dut1dut2 $option(itfType_dut1dut2)
    } 
    if {[GGV fspecAddFlowroutesInBase] != "ERROR"} {
        set addFlowroutesInBase [GGV fspecAddFlowroutesInBase]
    } else {
        set addFlowroutesInBase $option(addFlowroutesInBase)
    }
    if {[GGV fspecNeverDisableDutLogging] != "ERROR"} {
        set neverDisableDutLogging [GGV fspecNeverDisableDutLogging]
    } else {
        set neverDisableDutLogging $option(neverDisableDutLogging)
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
  
    set nbrStreamsFamilies 0 ;
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
  
    # the vprn (to redirect) is between dut2/dut4
    set thisRT "target:42:1"
   
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
  
    } ; # config
  
    if {$option(test) && ! [testFailed] && $Result == "OK"} {
    
        if {! [testFailed] && $Result == "OK"} {
            # sbgp part
            set b 1 ; set c [lindex $vprnIdOnlyList 0] ; set d 0
            foreach {thisVprnId thisNbrFlowroutesPerVprn thisActionListPerVprn} $vprnIdList {
                foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefix_v4 $dummyNetw
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$thisVprnId -linuxIp $dataip(ip.$thisVprnId.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$thisVprnId.$dut3.Linux) -dutAs [set [set dut3]_AS] \
                              -capability $sbgpDefCapabilityList \
                              -announce $thisDstPrefixMask_v4 -linuxDot1q $thisVprnId \
                              -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
                }
                incr c ; if {$c > 255} {set c 0 ; incr b}
            }
            #
            if {$addFlowroutesInBase} {
                # - Don't reset b and c because they point to the next values to be used
                foreach thisAction $thisActionListPerVprn {
                    set a [set a_[set thisAction]]
                    set thisDstPrefix_v4 $a.$b.$c.$d ; set thisDstPrefix_v6 [ipv4ToIpv6 $thisDstPrefix_v4]
                    set thisDstPrefix_v4 $dummyNetw
                    set thisDstPrefixMask_v4 $thisDstPrefix_v4/$clnItfMask_v4 ; set thisDstPrefixMask_v6 $thisDstPrefix_v6/$clnItfMask_v6
                    sbgp.init -linuxItf $portA(Linux.$dut3) -id peer$baseDot1qTag -linuxIp $dataip(ip.$baseDot1qTag.Linux.$dut3) -linuxAs $Linux_AS -dutIp $dataip(ip.$baseDot1qTag.$dut3.Linux) -dutAs [set [set dut3]_AS] \
                              -capability $sbgpDefCapabilityList \
                              -announce $thisDstPrefixMask_v4 -linuxDot1q $baseDot1qTag \
                              -debug $option(sbgpDebug) -verbose $option(sbgpDebug)
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
    
    }

    foreach family [list "ip" "ipv6"] {
        if { $family == "ip" } { set cmd "dipf" } else { set cmd "dip6f" }
        if { $family == "ip" } { set suffix "" } else { set suffix "-ipv6" }
        set cliOut [cookCliData [$dut3 sendCliCommand "show filter $family | match FlowSpec"]]
        #log_msg INFO "$cliOut" -multiline true
        foreach line [split $cliOut "\n"] {
            set filter "[lindex [split $line] 0]"
            set vprnId [lindex [split $filter -] 1]

            if { $vprnId == 0 } {
                continue
            }

            # apply fSpec-X filter

            set clicmd "/configure service vprn $vprnId network ingress filter $family $filter"
            log_msg INFO "$clicmd"
            set temp [cookCliData [$dut3 sendCliCommand "$clicmd"]]
            if { $temp == "MINOR: AGENT #10 Wrong Value error" } {
                log_msg INFO "Failed to apply $family filter $filter (expected)"
            } else {
                set Result FAIL
                log_msg ERROR "Unexpected return value while applying $family filter $filter: $temp"
            }

            # apply fSpec-X filter using internal id

            cliCne $dut3 "/configure service vprn $vprnId interface to_Dut-B${vprnId} sap $topoMap($dut3,1/1/2):${vprnId} ingress flowspec${suffix}"
            set cliOut [cookCliData [$dut3 sendCliCommand "shell cardcmd 1 $cmd"]]
            #log_msg INFO "$cliOut" -multiline true
            foreach line [split $cliOut "\n"] {
                if { [regexp -nocase {filter list ([0-9]+)} $cliOut intId intId] } {
                    #puts "$filter $intId"
                    break
                }
            }
            set clicmd "/configure service vprn $vprnId network ingress filter $family $intId"
            log_msg INFO "$clicmd"
            set temp [cookCliData [$dut3 sendCliCommand "$clicmd"]]
            if { $temp == "MINOR: AGENT #10 Wrong Value error" } {
                log_msg INFO "Failed to apply $family filter $intId (expected)"
            } else {
                set Result FAIL
                log_msg ERROR "Unexpected return value while applying $family filter $indId: $temp"
            }

            # merge with normal filter

            cliCne $dut3 "/configure filter ${family}-filter 1 create entry 1 create action forward"
            cliCne $dut3 "/configure service vprn $vprnId interface to_Dut-B${vprnId} sap $topoMap($dut3,1/1/2):${vprnId} ingress filter $family 1"
            cliCne $dut3 "/configure service vprn $vprnId network ingress filter $family 1"
            set clicmd "show filter $family 1"
            set cliOut [cookCliData [$dut3 sendCliCommand "$clicmd"]]
            if { [regexp -nocase "Entry *: $filter" $cliOut] } {
                log_msg INFO "Successfully merged $family filter 1 with flowspec filter $filter."
            } else {
                set Result FAIL
                log_msg ERROR "Failed to merge $family filter 1 with flowspec filter $filter!"
            }

            # cleanup
            cliCne $dut3 "/configure service vprn $vprnId network ingress no filter"
            cliCne $dut3 "/configure service vprn $vprnId interface to_Dut-B${vprnId} sap $topoMap($dut3,1/1/2):${vprnId} ingress no filter"
            cliCne $dut3 "/configure filter no ${family}-filter 1"
            cliCne $dut3 "/configure service vprn $vprnId interface to_Dut-B${vprnId} sap $topoMap($dut3,1/1/2):${vprnId} ingress no flowspec${suffix}"
        }
    }

    if { $option(deconfig) } {
        log_msg INFO "Cleanup started."
        log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
        setGlobalVar consoleLogLevel ERROR
        cleanupConfig
        sbgp.closeall
        setGlobalVar consoleLogLevel DEBUG
        log_msg INFO "Cleanup finished."
    }

    if { $Result == "OK" } {
        log_result PASSED $testID
    } else  {
        log_result FAILED $testID
    }

    return $Result
}

proc serviceAwareFilter_pbf {args} {

    global topoMap

    set opt(dut)        "C"
    set opt(port)       "1/1/1"

    getopt opt $args

    set testid $::TestDB::currentTestCase
    set result PASSED

    set port $topoMap(Dut-$opt(dut),$opt(port))

    log_msg INFO "Create VPRN"
    lappend res [Dut-$opt(dut) createVprn 1 1 999:1]
    log_msg [expr {[lindex $res end] == "OK"?"INFO":"ERROR"}] "Create VPRN Result: [lindex $res end]"

    foreach filterType [list "IP" "IPv6"] {

        if { $filterType == "IP" } { set family "ipv4" } else { set family "ipv6" }

        # filter with pbf sap .. cannot apply in vprn

        log_msg INFO "Create $filterType Filter"
        lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterRowStatus 1 "createAndGo"]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Create Filter Result: [lindex $res end]"

        log_msg INFO "Add Entry"
        lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries 1 1]
        log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Add Entry Result: [lindex $res end]"

        lappend res [cliCne Dut-$opt(dut) "/configure port $port shutdown"]
        lappend res [cliCne Dut-$opt(dut) "/configure port $port ethernet mode access"]
        lappend res [cliCne Dut-$opt(dut) "/configure port $port no shutdown"]

        lappend res [cliCne Dut-$opt(dut) "/configure filter [string tolower $filterType]-filter 1 entry 1 action forward sap $port"]

        log_msg INFO "Apply $filterType Filter"
        set mode [expr [random 2]=="0"?"cli":"snmp"] 
        set temp [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress 1 -mode $mode -returnCliError true]
        if { $mode == "cli" } {
            if { ([lindex $temp 0] == "FAILED") && ([lindex $temp 1] == "MINOR: SVCMGR #2659 A filter containing a PBF rule that points to a SAP can only be allocated to a VPLS service") } {
                log_msg INFO "Result: $temp"
                log_msg INFO "Filter failed to apply (expected)"
            } else {
                set result ERROR
                log_msg ERROR "Filter applied successfully (shouldnt be allowed)"
            }
        } else {
            array set err [getTmnxSnmpSetErrsEntry Dut-$opt(dut) -printAll 0 -verbose 0 -returnLastArray 1]
            if { ([lindex $temp 0] == "inconsistentValue") && ($err(tmnxSseErrorCode) == "2659") \
                                                           && ($err(tmnxSseErrorMsg) == "A filter containing a PBF rule that points to a SAP can only be allocated to a VPLS service") \
                                                           && ($err(tmnxSseModuleName) == "SVCMGR") \
                                                           && ($err(tmnxSseSeverityLevel) == "minor") } {
                log_msg INFO "Result: $temp"
                log_msg INFO "Filter failed to apply (expected)"

            } else {
                set result ERROR
                log_msg ERROR "Filter applied successfully (shouldnt be allowed)"
            }
        }

        lappend res [serviceAwareFilter_checkFilter $opt(dut) $family 1 1 -applied "No" -association "" -filter_row_status "active" -checkServiceFId true -svcFilterId 0]
        log_msg DEBUG "Check Filter Result: [lindex $res end]"

        # vprn with filter, cannot change filter action to pbf

        lappend res [cliCne Dut-$opt(dut) "/configure filter [string tolower $filterType]-filter 1 entry 1 action drop"]

        log_msg INFO "Apply $filterType Filter"
        lappend res [serviceAwareFilter_applyFilter $opt(dut) 1 vprn $family Ingress 1]
        lappend res [serviceAwareFilter_checkFilter $opt(dut) $family 1 1 -applied "Yes" -filter_row_status "active" -svcFilterId 1]

        log_msg INFO "Change Filter Action"
        set temp [cookCliData [Dut-$opt(dut) sendCliCommand "/configure filter [string tolower $filterType]-filter 1 entry 1 action forward sap $port"]]
        
        if { $temp == "MINOR: FILTER #1802 The filter is not applied on a single VPLS, or SAP/SDP is not defined in this VPLS" } {
            log_msg INFO "Result: $temp"
            log_msg INFO "Filter action failed to change (expected)"
        } else {
            set result ERROR
            log_msg ERROR "Filter action successfully changed (shouldnt be allowed)"
        }

        set temp [cookCliData [Dut-$opt(dut) sendCliCommand "/show filter [string tolower $filterType] 1 entry 1"]]
        log_msg INFO "$temp" -multiline true

        if { [regexp -nocase "Match action *: Drop" $temp] } {
            log_msg INFO "Verified that filter match action remained as Drop"
        } else {
            set result ERROR
            log_msg ERROR "Unexpected filter match action (expected Drop)"
        }

        lappend res [serviceAwareFilter_checkFilter $opt(dut) $family 1 1 -applied "Yes" -filter_row_status "active" -svcFilterId 1]
    }

    # cleanup

    log_msg INFO "Cleanup started."
    log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
    setGlobalVar consoleLogLevel ERROR
    cleanupConfig
    setGlobalVar consoleLogLevel DEBUG
    log_msg INFO "Cleanup finished."

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") && ($r != "") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_cflowd {args} {

    global testdir
    global ixia_port
    global dut1 dut2 dut3 dut4 dut5
    global itfType svcType itfBind itfMode filterType
    global port_3_2 port_3_3
    global topoMap

    set opt(issu)           "false"
    set opt(dut)            "C"
    set opt(pktsPerStream)  20
    set opt(withHA)         "false"

    set opt(framesize)      "100"
    set opt(burst)          "20"
    set opt(rate)           "20"
    set opt(loops)          "1"

    set opt(useStream)      "1"

    getopt opt $args

    set testid $::TestDB::currentTestCase
    set result PASSED

    source $testdir/testsuites/filter/params_file_filter_tcam.tcl
    
    # pick config

    set filterType [lindex [list "IP" "IPv6"] [random 2]]

    lappend specialList "nullEncap_vprn_autobindGre"
    lappend specialList "nullEncap_vprn_autobindLdp"
    lappend specialList "nullEncap_vprn_autobindLdpOverRsvp"
    lappend specialList "nullEncap_vprn_autobindRsvp"
    lappend specialList "nullEncap_vprn_exSpokeGre"
    lappend specialList "nullEncap_vprn_exSpokeMplsLdp"
    lappend specialList "nullEncap_vprn_exSpokeMplsLdpOverRsvp"
    lappend specialList "nullEncap_vprn_exSpokeMplsLsp"
    lappend specialList "nullEncap_vprn_exSpoke3107"

    log_msg NOTICE "setupList to select random setupCase for filterType $filterType = $specialList"
    set setupList [lindex $specialList [random [llength $specialList]]]

    set setupType "${filterType}_${setupList}"

    # config

    handlePacket -action reset -portList all -scheduler sequential

    if {[filterTCAM_getGlobals $setupType ] != "OK"} {
        log_msg ERROR "unable to find correct parameters for $setupType"
        return FAILED
    }

    log_msg INFO " --- Config --- "
    lappend res [filterTCAM_test $setupType -test "" -config true -trafficTest true -cleanup false]
    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Config Result: [lindex $res end]"

    # create filter

    log_msg INFO "Create $filterType Filter"
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterRowStatus 1 "createAndGo"]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Create Filter Result: [lindex $res end]"

    # add entry and set action to forward

    log_msg INFO "Add Entry"
    lappend res [Dut-$opt(dut) create[getVar1 $filterType]FilterEntries 1 1]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Add Entry Result: [lindex $res end]"

    log_msg INFO "Change Action Of Entry To Forward"
    lappend res [lindex [Dut-$opt(dut) set_ [ list [ list [ Tnm::mib pack t[getVar3 $filterType]FilterParamsAction 1 1] "forward" ]]] 0]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Change Action Result: [lindex $res end]"

    if { $opt(useStream) == "1" } {
        set dstIp "3.3.0.2"
        set srcIp "1.1.0.2"
    } else {
        set dstIp "1.1.0.2"
        set srcIp "3.3.0.2"
    }
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterParamsDestinationIpAddr 1 1 [expr {$filterType=="IP"?"$dstIp":[ipv62MibVal [ipConvert [string tolower $filterType] $dstIp]]}]]
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterParamsDestinationIpMask 1 1 [expr {$filterType=="IP"?"32":[maskConvert [string tolower $filterType] 32]}]]
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterParamsSourceIpAddr 1 1 [expr {$filterType=="IP"?"$srcIp":[ipv62MibVal [ipConvert [string tolower $filterType] $srcIp]]}]]
    lappend res [Dut-$opt(dut) setT[getVar3 $filterType]FilterParamsSourceIpMask 1 1 [expr {$filterType=="IP"?"32":[maskConvert [string tolower $filterType] 32]}]]

    # apply filter

    log_msg INFO "Apply Filter"
    lappend res [filterTCAM_applyFilter $setupType Ingress 1]
    log_msg [expr {[lindex $res end] == "noError"?"INFO":"ERROR"}] "Apply Filter Result: [lindex $res end]"

    # traffic test

    set iteration 1

#    log_msg INFO "Traffic Test:"
#    lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
#    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"
#
#    # check entry hits
#
#    set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
#    set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]
#
#    scan $ixia_port(1) "%d %d %d" chassis card port
#    port get $chassis $card $port
#    set i 1
#    while { ! [stream get $chassis $card $port $i] } {
#        incr i
#        if { $i > 100 } {
#            log_msg ERROR "Found more than 100 streams .. stopping now!"
#            break
#        }
#    }
#    set numStreams [expr $i - 1]
#    log_msg INFO "Found $numStreams stream(s) in Ixia"
#
#    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
#    if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams] } {
#        set result ERROR
#        log_msg ERROR "Filter Hits Check: FAILED!"
#        serviceAwareFilter_printDebug -family $filterType
#    } else {
#        log_msg INFO "Filter Hits Check: PASSED"
#    }

    #########################################
    cliCne Dut-$opt(dut) "/configure service vprn 1 interface itfToIxia3 sap $topoMap(Dut-$opt(dut),2/1/5):1 ingress filter [string tolower $filterType] 1"
    #########################################

    if { $opt(useStream) == "1" } {
        set port1 "1"
        set port3 "3"
        set direction "ingress"
    } elseif { $opt(useStream) == "2" } {
        set port1 "3"
        set port3 "1"
        set direction "egress"
    }

    #ixia check
    scan $ixia_port($port1) "%d %d %d" chassis card port
    ixClearPortStats $chassis $card $port
    stat get allStats $chassis $card $port
    set txNeighborSolicits [stat cget -txNeighborSolicits]
    set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
    set txTotal [expr [stat cget -framesSent] - $txNeighborSolicits - $txNeighborAdvertisements]

    scan $ixia_port($port3) "%d %d %d" chassis card port
    ixClearPortStats $chassis $card $port
    stat get allStats $chassis $card $port
    set rxNeighborSolicits [stat cget -rxNeighborSolicits]
    set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
    set rxTotal [expr [stat cget -framesReceived] - $rxNeighborSolicits - $rxNeighborAdvertisements]

    log_msg INFO "BEFORE /// Sent: $txTotal Received: $rxTotal"

    if {([string match "exSpoke3107*" $itfBind])} {
        set vRtr [Dut-$dut1 getSvcVRouterId $svc1 ]
        set dstMac_13 [Dut-$dut1 getVRtrIfPhysicalAddress $vRtr [ Dut-$dut1 interfaceNameToIfIndex "itfToIxia1" -vRtrID $vRtr]]
    } elseif {([string match "exSpoke*" $itfBind]) || ([string match "autobind*" $itfBind])} {
        set vRtr [Dut-$dut2 getSvcVRouterId $svc1 ]
        set dstMac_13 [Dut-$dut2 getVRtrIfPhysicalAddress $vRtr [ Dut-$dut2 interfaceNameToIfIndex "itfToIxia1" -vRtrID $vRtr]]
    } else {
        set result ERROR
        log_msg ERROR "Unsupported setup?!"
    }
    set dstMac_31 [Dut-$dut3 getTmnxPortMacAddress 1 [Dut-$dut3 convert_port_ifIndex port $port_3_3 ]]

    # stream no. 1
    lappend res [handlePacket -port 1 -dst [ipConvert $filterType 3.3.0.2] -numDest 1 -src [ipConvert $filterType 1.1.0.2] -numSource 1 \
                -damac $dstMac_13 -samac 00:00:01:00:00:01 -dot1q 1 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownload -dma stopStream]

    # stream no. 2
    lappend res [handlePacket -port 3 -dst [ipConvert $filterType 1.1.0.2] -numDest 1 -src [ipConvert $filterType 3.3.0.2] -numSource 1 \
                -damac $dstMac_31 -samac 00:00:01:00:03:03 -dot1q 1 -stream 1 -framesize $opt(framesize) -rawProtocol 6 \
                -packetsPerBurst $opt(burst) -rate $opt(rate) -loop $opt(loops) -action createdownload -dma stopStream]

    after 15000

    scan $ixia_port($port1) "%d %d %d" chassis card port
    stream get $chassis $card $port 1
    stream config  -enable  false
    stream set $chassis $card $port 1
    stream write $chassis $card $port 1

    filterTCAM_ixTestTraffic 1 -direction $direction

    #printDotsWhileWaiting 10

    #ixia check
    scan $ixia_port($port1) "%d %d %d" chassis card port
    stat get allStats $chassis $card $port
    set txNeighborSolicits [stat cget -txNeighborSolicits]
    set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
    set txTotal [expr [stat cget -framesSent ] - $txNeighborSolicits - $txNeighborAdvertisements]

    scan $ixia_port($port3) "%d %d %d" chassis card port
    stat get allStats $chassis $card $port
    set rxNeighborSolicits [stat cget -rxNeighborSolicits]
    set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
    set rxTotal [expr [stat cget -framesReceived ] - $rxNeighborSolicits - $rxNeighborAdvertisements]

    log_msg INFO "AFTER /// Sent: $txTotal Received: $rxTotal"

    if { $txTotal != $rxTotal } {
        set result ERROR
        log_msg ERROR "Traffic test FAILED!"
    } else {
        log_msg INFO "Traffic test PASSED"
    }

    set ingress_hits 0
    set ingress_byte 0
    set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
    set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
    if { $ingress_hits != [expr $opt(rate) * $opt(loops) * $iteration] } {
        set result ERROR
        log_msg ERROR "Filter hits incorrect!"
    } else {
        log_msg INFO "Filter hits correct"
    }

    # cflowd config

    log_msg INFO "=> configure cflowd"
    docli Dut-$opt(dut) "/configure cflowd collector $::TestDB::thisHostIpAddr version 5"
    docli Dut-$opt(dut) "/configure cflowd inactive-timeout 100"
    docli Dut-$opt(dut) "/configure cflowd rate 1"
    docli Dut-$opt(dut) "/configure cflowd"
    puts [cookCliData [Dut-$opt(dut) sendCliCommand "info"]]

    docli Dut-$opt(dut) "/configure filter [string tolower $filterType]-filter 1 entry 1 filter-sample"
    docli Dut-$opt(dut) "/configure filter [string tolower $filterType]-filter 1 entry 1 interface-disable-sample"
    docli Dut-$opt(dut) "/configure filter"
    puts [cookCliData [Dut-$opt(dut) sendCliCommand "info"]]

    set cfIntf true
    set l3Intf true

    #########################################
    #cliCne Dut-$opt(dut) "/configure service vprn 1 interface itfToIxia3 sap 2/1/5:1 ingress filter [string tolower $filterType] 1"
    cliCne Dut-$opt(dut) "/configure service vprn 1 interface itfToIxia3 cflowd-parameters sampling unicast type acl direction both"
    cliCne Dut-$opt(dut) "/configure service vprn 1 interface itfToIxia3"
    puts [cookCliData [Dut-$opt(dut) sendCliCommand "info"]]
    #########################################

    Dut-$opt(dut) sendCliCommand "/clear cflowd"
    Dut-$opt(dut) sendCliCommand "exit all"
    set card [lindex [ split $port_3_2 "/" ] 0]
    set dqStatData_init [docli Dut-$opt(dut) "shell cardcmd $card dqstats" -verbose true]
    if {[regexp "autobind" $itfBind] || [regexp "exSpoke" $itfBind]} {set TcpString "TCPN"} else {set TcpString "TCPA"}
    if {[regexp "$TcpString to CPM\\s+Fwd\\\[hi\\\]=(\[0-9\]+)/" $dqStatData_init match TCPA_init] == 0} { set TCPA_init 0 }
    if {[regexp {IP exc. to CPM\s+Fwd\[hi\]=([0-9]+)/} $dqStatData_init match IPexc_init] == 0} { set IPexc_init 0 }
    log_msg DEBUG "found $TCPA_init pkts in \"$TcpString to CPM\" and $IPexc_init pkts in \"IP exc. to CPM\" queue before checking traffic to CPM"

    # traffic test

    incr iteration

#    log_msg INFO "Traffic Test:"
#    lappend res [filterTCAM_test $setupType -test "" -config false -trafficTest true -cleanup false]
#    log_msg [expr {[lindex $res end] == "PASSED"?"INFO":"ERROR"}] "Traffic Test Result: [lindex $res end]"
#
#    # check entry hits
#
#    set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
#    set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]
#
#    scan $ixia_port(1) "%d %d %d" chassis card port
#    port get $chassis $card $port
#    set i 1
#    while { ! [stream get $chassis $card $port $i] } {
#        incr i
#        if { $i > 100 } {
#            log_msg ERROR "Found more than 100 streams .. stopping now!"
#            break
#        }
#    }
#    set numStreams [expr $i - 1]
#    log_msg INFO "Found $numStreams stream(s) in Ixia"
#
#    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
#    if { $ingress_hits != [expr $opt(pktsPerStream) * $numStreams * 2] } {
#        set result ERROR
#        log_msg ERROR "Filter Hits Check: FAILED!"
#        serviceAwareFilter_printDebug -family $filterType
#    } else {
#        log_msg INFO "Filter Hits Check: PASSED"
#    }

    #ixia check
    scan $ixia_port($port1) "%d %d %d" chassis card port
    ixClearPortStats $chassis $card $port
    stat get allStats $chassis $card $port
    set txNeighborSolicits [stat cget -txNeighborSolicits]
    set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
    set txTotal [expr [stat cget -framesSent] - $txNeighborSolicits - $txNeighborAdvertisements]

    scan $ixia_port($port3) "%d %d %d" chassis card port
    ixClearPortStats $chassis $card $port
    stat get allStats $chassis $card $port
    set rxNeighborSolicits [stat cget -rxNeighborSolicits]
    set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
    set rxTotal [expr [stat cget -framesReceived] - $rxNeighborSolicits - $rxNeighborAdvertisements]

    log_msg INFO "BEFORE /// Sent: $txTotal Received: $rxTotal"

    scan $ixia_port($port1) "%d %d %d" chassis card port
    stream get $chassis $card $port 1
    stream config  -enable  false
    stream set $chassis $card $port 1
    stream write $chassis $card $port 1

    filterTCAM_ixTestTraffic 1 -direction $direction

    #ixia check
    scan $ixia_port($port1) "%d %d %d" chassis card port
    stat get allStats $chassis $card $port
    set txNeighborSolicits [stat cget -txNeighborSolicits]
    set txNeighborAdvertisements [stat cget -txNeighborAdvertisements]
    set txTotal [expr [stat cget -framesSent ] - $txNeighborSolicits - $txNeighborAdvertisements]

    scan $ixia_port($port3) "%d %d %d" chassis card port
    stat get allStats $chassis $card $port
    set rxNeighborSolicits [stat cget -rxNeighborSolicits]
    set rxNeighborAdvertisements [stat cget -rxNeighborAdvertisements]
    set rxTotal [expr [stat cget -framesReceived ] - $rxNeighborSolicits - $rxNeighborAdvertisements]

    log_msg INFO "AFTER /// Sent: $txTotal Received: $rxTotal"

    if { $txTotal != $rxTotal } {
        set result ERROR
        log_msg ERROR "Traffic test FAILED!"
    } else {
        log_msg INFO "Traffic test PASSED"
    }

    set ingress_hits 0
    set ingress_byte 0
    set ingress_hits [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngressHitCount 1 1]
    set ingress_byte [Dut-$opt(dut) getT[getVar3 $filterType]FilterParamsIngrHitByteCount 1 1]

    puts [cookCliData [Dut-$opt(dut) sendCliCommand "show filter [string tolower $filterType] 1"]]
    if { $ingress_hits != [expr $opt(rate) * $opt(loops) * $iteration] } {
        set result ERROR
        log_msg ERROR "Filter hits incorrect!"
    } else {
        log_msg INFO "Filter hits correct"
    }

    # check cflowd

    log_msg INFO "=> evaluate cflowd"
    if { $opt(useStream) == "1" } {
        if {$cfIntf} { cflowd_CnW_numPkts Dut-$opt(dut) 0 }; # cflowd not working for packets going to CPM
    } else {
        if {$cfIntf} { cflowd_CnW_numPkts Dut-$opt(dut) [expr $opt(rate) * $opt(loops)] }; # cflowd not working for packets going to CPM
    }

    # cleanup

    log_msg INFO "Cleanup started."
    log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
    setGlobalVar consoleLogLevel ERROR
    cleanupConfig
    setGlobalVar consoleLogLevel DEBUG
    log_msg INFO "Cleanup finished."

    foreach r $res {
        if { ($r != "PASSED") && ($r != "noError") && ($r != "OK") } {
            set result ERROR
        }
    }

    if { $result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $result
}

proc serviceAwareFilter_insertPoints {args} {

    # create ip-filter (333) + insert point + assign to vprn

    # filterWccpEnhanced_radOverride_runTest -sourceRC vprn -testOptions "IP positive VRF1"

    global testdir logdir ixia_port
    global dutList sdpList svcListList family
    global itfType svcType itfBind itfMode filterType
    global dut1 dut2 dut3 dut4 dut5 ixport1 ixport3
    global port_1_1 port_1_3 port_2_1 port_2_2 port_3_2 port_3_3 port_3_4 port_4_1 port_5_1 port_5_2
    global portType_2_2 portType_3_2 portName_2_2 portName_3_2 sapName_3_2 itfDot1q userTag encapName

    global vprnId vprn2Id vprn3Id vprn4Id static_routes_list

    source $testdir/testsuites/filter/params_file_filter_tcam.tcl
    source $testdir/testsuites/filter/tests/wccp_enhanced_procs.tcl
    source $testdir/testsuites/filter/tests/wccp_enhanced_params.tcl

    source $testdir/testsuites/filter/tests/wccp_procs.tcl
    source $testdir/testsuites/qos/params.tcl

    set opt(debug)          "false"
    set opt(mode)           "regular"
    set opt(testOptions)    ""
    set opt(hostType)       ""
    set opt(setupType)      ""
    set opt(filterType)     ""
    set opt(deconfig)       "true"
    set opt(svcType)        ""
    set opt(debugPrint)     "true"
    set opt(sourceRC)       "vprn"
    
    # @@@@@@@@@@@@@@@@@@@@@@@@@

    set opt(dual)           "false"
    set opt(snmp)           "true"
    set opt(HT)             ""
    set opt(routing_prot)   "ospf"
    set opt(issu)           "false"
    set opt(dest4support)   "false"
    set opt(dest3support)   "false"
    set opt(iteration)      "1"
    set opt(case)           ""
    set opt(dest1RC)        ""
    set opt(dest2RC)        ""
    set opt(dest3RC)        ""
    set opt(dest4RC)        ""
    set opt(secondSap)      ""

    getopt opt $args

    set static_routes_list  ""
    set vprnId              "-1"
    set vprn2Id             "-1"
    set vprn3Id             "-1"
    set vprn4Id             "-1"

    set username            $::TestDB::thisTestBed
    set hostIp              $::TestDB::thisHostIpAddr
    set dir                 "ftp://${username}:tigris@${hostIp}/$logdir/device_logs"
    set config_dir          "ftp://${username}:tigris@${hostIp}/$logdir/device_logs/saved_configs"

    # @@@@@@@@@@@@@@@@@@@@@@@@@

    set testid $::TestDB::currentTestCase
    set Result PASSED

    set testResultFlag "PASSED"
    set setupErrorFlag "NOERROR"

    if { $opt(HT) == "" } {
        set opt(HT) [RP_lrandom "ping unicast"]
    }

    if { $opt(filterType) == "" } {
        set opt(filterType) [expr [random 2]=="0"?"IP":"IPv6"]
    }
    set filterType $opt(filterType)

    if { $opt(testOptions) == "" } {
        set rand [random 3]
        if { $rand == 0 } {
            set opt(testOptions) "$opt(filterType) positive GRT"
        } elseif { $rand == 1 } {
            set opt(testOptions) "$opt(filterType) positive VRF1"
        } else {
            set opt(testOptions) "$opt(filterType) positive VRF2"
        }
    }

    if {$opt(hostType) == ""} {
        ### randomly choose hostType and setupType for ESM test cases
        if { $opt(filterType) == "IP" } {
            set hostType [randomElement "dhcp4 pppoe_4 pppoe_46 arpHost"]
            set opt(hostType) $hostType
            if { $hostType == "arpHost" } {
                set setupType "ethernet_vprnRCO_subsap_CreditCntrl"
            } else {
                set setupType [randomElement "nullEncap_vprnRCO_subsap ethernet_vprnRCO_subsap qinq_vprnRCO_subsap lag_vprnRCO_subsap"]
            }
        } else {
            set hostType [randomElement "dhcp6_IAPD dhcp6_IANA pppoe_6 pppoe_46"]
            set opt(hostType) $hostType
            set setupType [randomElement "nullEncap_vprnRCO_subsap ethernet_vprnRCO_subsap qinq_vprnRCO_subsap lag_vprnRCO_subsap"]
        }
    } else {
        if {$opt(filterType) == "IP"} {
            set hostType $opt(hostType)
            set setupType $opt(setupType)
        } else {
            set hostType $opt(hostType)
            set setupType $opt(setupType)
        }
    }
    
    log_msg INFO "opt(filterType)  = $opt(filterType)"
    log_msg INFO "opt(sourceRC)    = $opt(sourceRC)"
    log_msg INFO "opt(testOptions) = $opt(testOptions)"

    log_msg INFO "####################################################"
    log_msg INFO "Randomly choosed hostType : $hostType"
    log_msg INFO "Randomly choosed setupType: $setupType"
    log_msg INFO "####################################################"
    
#    if {$opt(filterType) == "IP"} {
#        filter_radOverride_runTest $opt(filterType) -hostType $hostTypeIPv4 -select $setupTypeIPv4 -testProc WccpEnhancedESM -testOptions $opt(testOptions) -mode $opt(mode)  
#    } else {
#        filter_radOverride_runTest $opt(filterType) -hostType $hostTypeIPv6 -select $setupTypeIPv6 -testProc WccpEnhancedESM -testOptions $opt(testOptions) -mode $opt(mode)
#    }

    set setupType [filter_radOverride_getSetupType $opt(filterType) $hostType -select $setupType]
    set r [filter_subinsertRadius_baseSetup $setupType -dual $opt(dual) -secondSap $opt(secondSap) -hostType $hostType]
    set numStreams 0

    set ipHost  $subhostIp1
    set macHost $subhostMac1
    set slaName sla1
    if {[regexp {dhcp6} $hostType]} {
        set ipHost [ipConvert Ipv6 $ipHost]
        set slaName sla2 ; # move to sla1 after setting filter
    }

    # add specific host type (arpHost, dhcp4, dhcp6_IANA, pppoe_46, etc ...) + additional config (ipv6, pppoe)
    set r [filter_subinsertRadius_addhost $setupType $hostType $ipHost $macHost $slaName -numStreams $numStreams]
    if {$r != "PASSED"} {
        set Result FAILED
        log_msg ERROR "filter_subinsertRadius_addhost failed for $setupType $hostType $ipHost $macHost $slaName"
        if {$opt(debug) != "false"} { return $Result }
    }
    #log_msg DEBUG "[Dut-$dut3 sendCliCommand {show service active-subscribers}]"

    # @@@@@@@@@@@@@@

    log_msg INFO "testOptions: $opt(testOptions)"  
    
    if {$opt(testOptions) != ""} {    
        set paramsNum [llength $opt(testOptions)]
        set opt(filterType) [lindex $opt(testOptions) 0]
        set opt(case)       [lindex $opt(testOptions) 1]
        switch $paramsNum {
           "3" { set opt(dest1RC)    [lindex $opt(testOptions) 2]}
           "4" { set opt(dest2RC)    [lindex $opt(testOptions) 3]}
           "5" { set opt(dest4RC)    [lindex $opt(testOptions) 4]}
        }
    }
    if {[regexp "vprn" $setupType] == "1" } { set opt(svcType) "vprn"}
    if {[regexp "ies" $setupType] == "1" } { set opt(svcType) "grt"} 
    if {$opt(case) == ""} {
        set opt(case)       [ RP_lrandom "positive collision backward" ]   
    }
    if {$opt(dest1RC) == ""} {
        set opt(dest1RC)    [ RP_lrandom "GRT VRF1 VRF2"]
        if {$opt(case) != "positive"} {
            if {$opt(dest2RC) == ""} {
                set opt(dest2RC)    [ RP_lrandom "GRT VRF1 VRF2" -except $opt(dest1RC)] 
            }
            if {$opt(dest4RC) == ""} {
                set opt(dest4RC)    "GRT" 
            }
        }
    }     
    if {(($opt(dest1RC) == "VRF1") || ($opt(dest2RC) == "VRF1"))} {
        if { ($opt(svcType) != "vprn") } {set vprnId "10"; set vprn3Id "10" } else {set vprnId "1"; set vprn3Id "1"  }
    }
    if {(($opt(dest1RC) == "VRF2") || ($opt(dest2RC) == "VRF2"))} { set vprn2Id "20" }
                    
    if {$opt(case) == "positive"}   {     
        set opt(dest2RC)    "$opt(dest1RC)"      
        set opt(dest3RC)    "$opt(dest1RC)"
        set opt(dest4RC)    "GRT"    
        switch $opt(dest1RC) {
            "GRT" {set opt(RProuter) "Base"}
            "VRF1" {set opt(RProuter) "$vprnId"}
            "VRF2" {set opt(RProuter) "$vprn2Id"}
        }        
    }
    if {$opt(case) == "collision"}  {     
        set opt(dest2RC)    "$opt(dest2RC)"      
        set opt(dest3RC)    "$opt(dest1RC)" 
        set opt(dest4RC)    "GRT"
        switch $opt(dest1RC) {
            "GRT" {set opt(RProuter) "Base"}
            "VRF1" {set opt(RProuter) "$vprnId"}
            "VRF2" {set opt(RProuter) "$vprn2Id"}
        }        
    }
    
    if {$opt(case) == "backward"}   {  set opt(dest2RC)    "$opt(dest2RC)" ;     set opt(dest3RC)    "$opt(dest1RC)"  ; set opt(dest4RC)    "GRT" }
     
    if {[filterTCAM_getGlobals $setupType] != "OK"} {
        log_msg ERROR "Unable to find correct parameters for $setupType"
        set Result FAILED
    } 
    

    # streams with IP options, unles it is pppoe host - pppoe does not support Ip options/hop-by-hop
    # handlePacket has no support for pppoe with fragmentation flags, ip-options, syn/ack, port-nums, icmp-type/code
    # limited set of streams to cover different protocols
    
    handlePacket -portList [list $ixport1 $ixport3] -action reset -scheduler sequential
    if {[regexp {pppoe} $opt(hostType)]} { set opt(pppoe) true } else { set opt(pppoe) false }
    set numStreams [filterTCAM_ixConfigStreams $setupType -ipOptions true -pppoe $opt(pppoe)]
    set streamIdList ""
    for {set i 1} {$i <= $numStreams} {incr i} { lappend streamIdList $i }
    filterTCAM_ixTestTraffic $streamIdList
    RP_set_dut
   
   

    log_msg INFO "Test will be started with following options :\n"
    log_msg INFO "############################################################################################################"
    log_msg INFO "# opt(HT)             $opt(HT)"  
    log_msg INFO "# opt(filterType)     $opt(filterType)"
    log_msg INFO "# opt(svcType)        $opt(svcType)"
    log_msg INFO "# opt(routing_prot)   $opt(routing_prot)"
    log_msg INFO "# opt(dest1RC)        $opt(dest1RC)"
    log_msg INFO "# opt(dest2RC)        $opt(dest2RC)"
    if {$opt(dest3support) == "true" } {log_msg INFO "# opt(dest3RC)        $opt(dest3RC)"}
    if {$opt(dest4support) == "true" } {log_msg INFO "# opt(dest4RC)        $opt(dest4RC)"}    
    if {$vprnId != "-1"} {log_msg INFO "# vprnId              $vprnId"}
    if {$vprn2Id != "-1"} {log_msg INFO "# vprn2Id             $vprn2Id"}
    if {$vprn3Id != "-1"} {log_msg INFO "# vprn3Id             $vprn3Id"}
    if {$vprn4Id != "-1"} {log_msg INFO "# vprn4Id             $vprn4Id"}   
    log_msg INFO "# opt(RProuter)       $opt(RProuter)"
    log_msg INFO "# opt(case)           $opt(case)"
    log_msg INFO "############################################################################################################"
   
    ### make this test run on dhcp4, dhcp6_IANA, pppoe_4, pppoe_6, pppoe_46
    set hostType $opt(hostType)
    if {[regexp {arpHost} $hostType]} { set ixHost  1 } else { set ixHost  0 } ; # second host to remote ixPort in case of arpHost Setup
    if {[regexp {pppoe_46} $hostType]} { set numHost 2 } else { set numHost 1 } ; # 2 hosts in case of pppoe_46
   
    set dualRsc46 false ; # resource difference should always be there - fixed with dts128203
 
    # use subhostIp1,2,3 and subhostMac1,2,3 corresponding with ixia subscriber streams
    set subhostIp [ipConvert $filterType $subhostIp1]
    set sapName $sapName_3_2$encapName
    set slaName sla1
   
    # clear host in order to be able assign filter to sla-profile - otherwise you get snmp error: SLA profile is in use by one or more active subscribers
    filter_subinsert_radius_clearHost $subhostIp -hostType $hostType
   
    RP_rollbackSave $dut3 1
   
   #IOM card compatibility check - IOM3+ support,  
    if { $itfType == "lag" } {
        set iom3 ""
        foreach {port} $port_3_2 {
            if {[Dut-$dut3 isIom3Equipped [lindex [split $port "/"] 0]] != "TRUE"} {
                if {$iom3 == "true"} {set iom3 "none"} else {set iom3 "false"}
            } else {
                if {$iom3 == "false"} {set iom3 "none"} else {set iom3 "true"}
            }
        }
        log_msg NOTICE "iom3 $iom3"
        if {$iom3 == "none"} { log_msg ERROR "testing on lag with mixture of iom3 and non-iom3 ports, Results for action forward router tests could be unpredictable" }
    } else {
        set iom3 [ string tolower [Dut-$dut3 isIom3Equipped [lindex [split $port_3_2 "/"] 0]]]
        if { $iom3 == "false" } {
            log_msg INFO "Used line card is NOT IOM3 and higher - verify, that traffic will be just forwarded and PBR is not taken into account"
        }
    }
    
    #chassis mode compatibility check - for IPv6 D
    set initmode [Dut-$dut3 getTmnxChassisAdminMode 1]
 
    #configuration of system IPs
    if { [RP_configSystemIPs] != "OK" } {set Result "FAILED"}  
    #configuration of dutD, dutE, dutF -interfaces
    if { [RP_configDuts] != "OK" } {set Result "FAILED"}    
    #configuration of interfaces for dest1,2,3,4 on dutC - tested dut 
    if { [RP_configTestedDut $opt(dest1RC) $opt(dest2RC) $opt(dest3RC) $opt(dest4RC) $opt(dest3support) $opt(dest4support) $opt(svcType)] != "OK" } {set Result "FAILED"}  
    #configuration of routes - BGP or OSPF or OSPFv3 or static routes
    if { [RP_configRoutes $opt(dest1RC) $opt(dest2RC) $opt(dest3RC) $opt(dest4RC) $opt(dest3support) $opt(dest4support) $opt(routing_prot)] != "OK" } {set Result "FAILED"}

    if {$opt(dest3support) == "true"} { 
        if { [RP_setMACforARP -dest3RC $opt(dest3RC)] != "OK" } {set Result "FAILED"}
    }
 

    
    if {$filterType == "IP"} { set fTypeList "IP 4"} else { set fTypeList "IPv6 6"}
    # if {[regexp {46} $hostType]} {
      # if {$filterType == "IP"} {
        # set fTypeList "IP 4 IPv6 6"
        # set filterType2 IPv6
      # } else {
        # set fTypeList "IPv6 6 IP 4"
        # set filterType2 IP
      # }
    # }
   
    if {$filterType == "IP"} {
        set fTypeList "IP 4 IPv6 6"
        set filterType2 IPv6
    } else {
        set fTypeList "IPv6 6 IP 4"
        set filterType2 IP
    }


    

    
    #configuration of filter (filters, redirect policy)
    if { [RP_configFilters -dest3supp $opt(dest3support) -dest4supp $opt(dest4support) -IngrEgr true] != "OK" } {set Result "FAILED"}
    log_msg INFO "Modify IP filter 100"
    set r1 [Dut-$dut3 createIpFilterPolicy 100]
    set r2 [Dut-$dut3 setFilterInsert Radius IP 100 1000 100]
    set r3 [Dut-$dut3 setFilterInsert HostShared IP 100 1100 100]
    

    # create also filterType2 filter
    log_msg INFO "Create IPv6 filter 100"
    set r1 [Dut-$dut3 createIpv6FilterPolicy 100]
    set r2 [Dut-$dut3 setFilterInsert Radius IPv6 100 1000 100]
    set r3 [Dut-$dut3 setFilterInsert HostShared IPv6 100 1100 100]
    
    set cmdList ""
    lappend cmdList "/configure filter redirect-policy wccp100 create" 
    lappend cmdList "/configure filter redirect-policy wccp100 no shutdown"
    lappend cmdList "/configure filter redirect-policy wccp100 router $opt(RProuter)"
    lappend cmdList "/configure filter redirect-policy wccp100 create destination [ipConvert [getVar4 $filterType2] $dest1Addr] create no shutdown"
    
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 100 create description Wccp100Ingress"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 100 create entry 1 create match dst-ip [ipConvert [getVar4 $filterType2] $dstIp]/[RP_maskConvert [getVar4 $filterType2] $fullMask]" 
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 100 create entry 1 create action forward redirect-policy wccp100"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 100 create default-action forward"

        
    foreach {cmd} $cmdList {
            log_msg INFO "Dut-$dut3 - $cmd"
            set errMsg [ cookCliData [ Dut-$dut3 sendCliCommand $cmd] ]
            if {$errMsg != ""} { 
                log_msg ERROR "Dut-$dut3: error for CLI-command $cmd - $errMsg" 
                set Result "ERROR"
            }
    }  

    

    # assign filter to sla-profile
    log_msg INFO "Assign filter to sla-profile"
    set direction "Ingress Egress"
    set filterID  100
    foreach {fType fvers} $fTypeList {
        foreach {dirStr dir} "Ing ingress Egr egress" {
            ### SNMP
            log_msg INFO "Trying to associate $dir $fType filter $filterID with sla-profile $slaName"
            set r [Dut-$dut3 setTmnxSLAProf[set dirStr][getVar3 $fType]FilterId $slaName $filterID]
            if {$r != "noError"} {
                log_msg ERROR "failed to associate $dir $fType filter 8 with sla-profile $slaName - returned $r" ; set result FAILED
            }
        }
    }
    
    # #binding filters
    # #ingress filter
    # set r [filterTCAM_applyFilter $setupType Ingress 100]
    # if {$r != "noError"} { set Result "FAILED"}
    # RP_set_dut
    # #egress filter for ICMp unreachable
    # set r [filterTCAM_applyFilter $setupType Egress 100]
    # if {$r != "noError"} { set Result "FAILED"}
    RP_set_dut
    
    #egress to Ixia
    set cmdList ""
    if { $opt(svcType) == "vprn" } {
        if { [regexp (WRvprnRCO) $setupType] } {
            lappend cmdList "/configure service vprn 2000 interface itfToIxia3 sap $port_3_3:$svc1 egress filter [getVar4 $filterType] 300"
            lappend cmdList "/configure service vprn 2000 interface itfToIxia3 sap $port_3_3:$svc1 ingress filter [getVar4 $filterType] 301"
        } elseif { [regexp (vprnRCO_subsap_CreditCntrl) $setupType]} {
            lappend cmdList "/configure service vprn $svc1 subscriber-interface subif_2dsap group-interface grpif_2dsap sap $port_3_3:$svc1 egress filter [getVar4 $filterType] 300"
            lappend cmdList "/configure service vprn $svc1 subscriber-interface subif_2dsap group-interface grpif_2dsap sap $port_3_3:$svc1 ingress filter [getVar4 $filterType] 301"
        } else {
            lappend cmdList "/configure service vprn $svc1 interface itfToIxia3 sap $port_3_3:$svc1 egress filter [getVar4 $filterType] 300"
            lappend cmdList "/configure service vprn $svc1 interface itfToIxia3 sap $port_3_3:$svc1 ingress filter [getVar4 $filterType] 301"
        }
    } else {
        lappend cmdList "/configure service ies $svc1 interface itfToIxia3 sap $port_3_3:$svc1 egress filter [getVar4 $filterType] 300"
        lappend cmdList "/configure service ies $svc1 interface itfToIxia3 sap $port_3_3:$svc1 ingress filter [getVar4 $filterType] 301"
    }  
    foreach cmd $cmdList {
        set errMsg [ cookCliData [ Dut-$dut3 sendCliCommand $cmd] ]
        if {$errMsg != ""} { 
            log_msg ERROR "Dut-$dut3: error for CLI-command $cmd - $errMsg" 
            set Result "ERROR"
        }
    }    
    #egres to dest1,2,3
     if { [RP_applyFilter_Cli $dut3 egress 1 -RC $opt(dest1RC) -intf CD_intf -sap $topoMap(Dut-$dut3,2/1/2)] != "OK" } {set Result "FAILED"}
     if { [RP_applyFilter_Cli $dut3 egress 2 -RC $opt(dest2RC) -intf CE_intf -sap $topoMap(Dut-$dut3,2/1/1)] != "OK" } {set Result "FAILED"}
     if {$opt(dest3support) == "true"} {
        if { [RP_applyFilter_Cli $dut3 egress 3 -RC $opt(dest3RC) -intf CEth1_intf -sap $topoMap(Dut-$dut3,1/1/5) ] != "OK" } {set Result "FAILED"}
     }
     if {$opt(dest4support) == "true"} { 
        if { [RP_applyFilter_Cli $dut3 egress 4 -RC $opt(dest4RC) -intf CEth2_intf -sap $topoMap(Dut-$dut3,2/1/6) ] != "OK" } {set Result "FAILED"}
     }
     if { [RP_applyFilter_Cli $dut6 ingress 61 -RC GRT -intf FD_intf] != "OK" } {set Result "FAILED"}
     if { [RP_applyFilter_Cli $dut6 ingress 62 -RC VRF -intf FE_intf -sap $topoMap(Dut-$dut6,1/1/2)] != "OK" } {set Result "FAILED"}   
     if { [RP_applyFilter_Cli $dut5 ingress 52 -RC GRT -intf EC_intf] != "OK" } {set Result "FAILED"}
     if { [RP_applyFilter_Cli $dut5 ingress 502 -RC GRT -intf EF_intf] != "OK" } {set Result "FAILED"}
     if { [RP_applyFilter_Cli $dut4 ingress 41 -RC GRT -intf DC_intf] != "OK" } {set Result "FAILED"}
     if { [RP_applyFilter_Cli $dut4 ingress 401 -RC GRT -intf DF_intf ] != "OK" } {set Result "FAILED"}
    #End of setup, filter config
   
   
   
   
    #gash_interpreter
  # use shell commands to set radius-cache timeout to smaller value (check with "word sbmRadiusCacheTimeout" in kernel)
    Dut-$dut3 sendCliCommand "shell sbmRadiusCacheSetTimeout 1"
    Dut-$dut3 sendCliCommand "shell cardcmd [Dut-$dut3 findInactiveCpm] sbmRadiusCacheSetTimeout 1"
    # for arp-host also disable min-auth-interval of 1 minute via shellcmd
    Dut-$dut3 sendCliCommand "shell setVar8 arpHostAlwaysReauth 1"
    Dut-$dut3 sendCliCommand "shell cardcmd [Dut-$dut3 findInactiveCpm] setVar8 arpHostAlwaysReauth 1"
    set waitHostSetup    3000
    set waitRadiusCache  3000


    # set debug logging with filters
    Dut-$dut3 sendCliCommand "/configure log log-id 10 from main"
    Dut-$dut3 sendCliCommand "/configure log log-id 10 to memory"




    

    
    
    # log_msg INFO "----------------------------------------------------"
    # log_msg INFO " Host creation with sla filter"
    # log_msg INFO "----------------------------------------------------"

    #gash_interpreter
#    print_console_msg "Clear host before starting test"
#    filter_subinsert_radius_clearHost $subhostIp -hostType $hostType
    after 3000
    print_console_msg "Host setup with sla filter"
    set SubscrFilterString "ingr-v4:-2, egr-v4:-2, ingr-v6:-2, egr-v6:-2"   
    set hostFltr(ingress) 0
    set hostFltr(egress) 0
    set ixStreamNbr $numStreams
  
    #Host creation
    filter_radOverride_changeHost $sapName $subhostIp $subhostMac1 $slaName $hostType "initial authentication" true $ixStreamNbr -filterAttr $SubscrFilterString
    filter_subinsert_checkNumHosts $dut3 [expr $numHost + $ixHost]
    filter_radOverride_checkCliSnmp $hostType $subhostIp $subhostMac1 $slaName $hostFltr(ingress) $hostFltr(egress) 100

    
    log_msg INFO "verifying resources on CPM and IOM are matching for Dut-$dut3"
    set r [ resMgr_verify_resources OK -dut Dut-$dut3 -maxTries 1 ]
    if {$r != "OK"} { log_msg ERROR "resource mismatch between CPM and IOM for Dut-$dut3, found $r" ; set result FAILED }
   
    log_msg INFO "################################################################## " 
    log_msg INFO "################################# radius part"    
    log_msg INFO "################################################################## " 
    #gash_interpreter
    
    log_msg INFO "verifying resources on CPM and IOM are matching for Dut-$dut3"
    set r [ resMgr_verify_resources OK -dut Dut-$dut3 -maxTries 1 ]
    if {$r != "OK"} { log_msg ERROR "resource mismatch between CPM and IOM for Dut-$dut3, found $r" ; set result FAILED }
   
    set cmdList ""
    lappend cmdList "/configure filter redirect-policy wccp2 create" 
    lappend cmdList "/configure filter redirect-policy wccp2 no shutdown"
    lappend cmdList "/configure filter redirect-policy wccp2 router $opt(RProuter)"
    if {$opt(HT)== "ping"} {
        lappend cmdList "/configure filter redirect-policy wccp2 create destination [ipConvert $family $EF_Addr] create ping-test"
    } else {
        lappend cmdList "/configure filter redirect-policy wccp2 create destination [ipConvert $family $EF_Addr] create unicast-rt-test"
    }
    lappend cmdList "/configure filter redirect-policy wccp2 create destination [ipConvert $family $EF_Addr] no shutdown"
    
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create description Wccp120_2Ingress"
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create entry 1 create match dst-ip [ipConvert [getVar4 $filterType] $dstIp]/[RP_maskConvert [getVar4 $filterType] $fullMask]"
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create entry 1 create action forward redirect-policy wccp2"
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create default-action forward"  
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create sub-insert-radius start-entry 1000 count 100"
    lappend cmdList "/configure filter [getVar4 $filterType]-filter 120 create sub-insert-shared-radius start-entry 1100 count 100"
    
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create description Wccp120_100Ingress"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create entry 1 create match dst-ip [ipConvert [getVar4 $filterType2] $dstIp]/[RP_maskConvert [getVar4 $filterType2] $fullMask]"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create entry 1 create action forward redirect-policy wccp100"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create default-action forward" 
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create sub-insert-radius start-entry 1000 count 100"
    lappend cmdList "/configure filter [getVar4 $filterType2]-filter 120 create sub-insert-shared-radius start-entry 1100 count 100"

    foreach {cmd} $cmdList {
            log_msg INFO "Dut-$dut3 - $cmd"
            set errMsg [ cookCliData [ Dut-$dut3 sendCliCommand $cmd] ]
            if {$errMsg != ""} { 
                log_msg ERROR "Dut-$dut3: error for CLI-command $cmd - $errMsg" 
                set Result "ERROR"
            }
    }  
    #is dest of wccp2 active and ready?  
    RP_ActiveDestReachabilityCheck [ip::normalize [ mibVal2Ip [ipConvert $family $EF_Addr]]] wccp2 -method [RP_lrandom "CLI SNMP"]

    log_msg INFO "Clear the host"
    filter_subinsert_radius_clearHost $subhostIp -hostType $hostType

    mysendCli Dut-$dut3 "/configure filter ip-filter 444 create entry 1 create action forward"
    mysendCli Dut-$dut3 "/configure filter ip-filter 444 sub-insert-radius start-entry 100 count 100"
    mysendCli Dut-$dut3 "/configure filter ip-filter 444 sub-insert-shared-radius start-entry 300 count 100"
    mysendCli Dut-$dut3 "/configure filter ipv6-filter 666 create entry 1 create action forward"
    mysendCli Dut-$dut3 "/configure filter ipv6-filter 666 sub-insert-radius start-entry 100 count 100"
    mysendCli Dut-$dut3 "/configure filter ipv6-filter 666 sub-insert-shared-radius start-entry 300 count 100"
    mysendCli Dut-$dut3 "/configure subscriber-mgmt sla-profile sla1 ingress ip-filter 444"
    mysendCli Dut-$dut3 "/configure subscriber-mgmt sla-profile sla1 ingress ipv6-filter 666"
    mysendCli Dut-$dut3 "/configure service vprn 1 network ingress filter ip 444"
    mysendCli Dut-$dut3 "/configure service vprn 1 network ingress filter ipv6 666"
  
    log_msg INFO "----------------------------------------------------"
    log_msg INFO " Create Alc-Ascend-Data-Filter-Host-Spec"
    log_msg INFO "----------------------------------------------------"

    set msgList [list "radius COA" "initial authentication"]
    set nasRuleList ""
    set nasRule(ingress) "permit in ip from any to any"
    set nasRule(egress)  "permit out ip from any to any"
    lappend nasRuleList $nasRule(ingress) $nasRule(egress)
    set attrTestList "" ;
    lappend attrTestList Alc-Ascend-Data-Filter-Host-Spec
    lappend attrTestList $nasRuleList
    set SubscrFilterString "ingr-v4:444, egr-v4:444, ingr-v6:666, egr-v6:666"

    filter_radius_changeHost $sapName $subhostIp $subhostMac1 $slaName $hostType "initial authentication" -ruleList $attrTestList -hostSucceed true -filterList $SubscrFilterString -numStreams $ixStreamNbr

    if { $filterType == "IP" } {
        set cliOut [Dut-$dut3 sendCliCommand "/show filter ip 444"]
        log_msg INFO "$cliOut" -multiline true
    } else {
        set cliOut [Dut-$dut3 sendCliCommand "/show filter ipv6 666"]
        log_msg INFO "$cliOut" -multiline true
    }

    if { [regexp -nocase "Entries *: 1/2/0/0 \\(normal/inserted By Radius/By Cc/By Embedded\\)" $cliOut] && [regexp -nocase "Entry *: 100 *- inserted on ingress by Radius" $cliOut] && [regexp -nocase "Entry *: 101 *- inserted on egress by Radius" $cliOut] } {
        log_msg INFO "Verification of entries inserted by Radius PASSED"
    } else {
        set Result ERROR
        log_msg ERROR "Verification of entries inserted by Radius FAILED!"
    }

    log_msg INFO "----------------------------------------------------"
    log_msg INFO " Create copy of shared sla filter by subinserting shared radius"
    log_msg INFO "----------------------------------------------------"

    set attrTestList "" ;
    lappend attrTestList Alc-NAS-Filter-Rule-Shared
    lappend attrTestList $nasRuleList
    set SubscrFilterString "ingr-v4:444, egr-v4:444, ingr-v6:666, egr-v6:666"

    filter_radius_changeHost $sapName $subhostIp $subhostMac1 $slaName $hostType "initial authentication" -ruleList $attrTestList -hostSucceed true -filterList $SubscrFilterString -numStreams $ixStreamNbr

    if { $filterType == "IP" } {
        set fId 444
        set cliOut [Dut-$dut3 sendCliCommand "/show filter ip filter-type host-common"]
        log_msg INFO "$cliOut" -multiline true
    } else {
        set fId 666
        set cliOut [Dut-$dut3 sendCliCommand "/show filter ipv6 filter-type host-common"]
        log_msg INFO "$cliOut" -multiline true
    }

    if { [regexp -nocase "Host Common $filterType Filters *Total: *2" $cliOut] && [regexp -nocase "$fId:\[0-9\]+ *Auto-created Radius Shared Ingress Filter" $cliOut] && [regexp -nocase "$fId:\[0-9\]+ *Auto-created Radius Shared Egress Filter" $cliOut] } {
        log_msg INFO "Verification of shared filters inserted by Radius PASSED"
    } else {
        set Result ERROR
        log_msg ERROR "Verification of shared filters inserted by Radius FAILED!"
    }

    # cleanup

    log_msg INFO "Clear the host"
    filter_subinsert_radius_clearHost $subhostIp -hostType $hostType

    mysendCli Dut-$dut3 "/configure service vprn 1 network ingress no filter"
    mysendCli Dut-$dut3 "/configure subscriber-mgmt sla-profile sla1 ingress no ip-filter"
    mysendCli Dut-$dut3 "/configure subscriber-mgmt sla-profile sla1 ingress no ipv6-filter"
    mysendCli Dut-$dut3 "/configure filter no ip-filter 444"
    mysendCli Dut-$dut3 "/configure filter no ipv6-filter 666"

    #filter_subinsertRadius_baseCleanup $setupType -dual $opt(dual) -secondSap $opt(secondSap) -hostType $opt(hostType)

    log_msg INFO "Cleanup started."
    log_msg NOTICE "Changing value of consoleLogLevel to ERROR"
    setGlobalVar consoleLogLevel ERROR
    cleanupConfig
    setGlobalVar consoleLogLevel DEBUG
    log_msg INFO "Cleanup finished."

    if { $Result == "PASSED" } {
        log_result PASSED $testid
    } else  {
        log_result FAILED $testid
    }

    return $Result
} 

proc scale_bed_service_aware_filter {args} {
    global ixia_port
    global topoMap

    set opt(maxTime)        600
    set opt(applyFilter)    [lrandom "0 1"]
    set opt(systemFilter)   false

    getopt opt $args

    if {[string tolower [GGV applyFilter]] == "false"} {
        set opt(applyFilter) false
    }

    setGlobalVar logMsgTimestamps true

    set result "OK"
    set testId $::TestDB::currentTestCase
    
    log_msg INFO "______   _______   _______   _______"
    log_msg INFO "|IXIA|   |Dut-D|   |Dut-C|   |Dut-B|"
    log_msg INFO "|    |<->| sdp |<->| s-a |<->| dst |"
    log_msg INFO "|____|   |_____|   |fltr |   |_____|"

    set dutdToIxia {"1/1/1" "2/1/1" "3/1/1" "4/1/1" "5/1/1" "6/1/1" "8/1/2" "8/1/1" "9/1/1" "10/1/1"}
    
    set filenameD "confPortDutD"
    set fileInD [ openConfigFile $filenameD ]

    set filenameC "confPortDutC"
    set fileInC [ openConfigFile $filenameC ]

    set filenameB "confPortDutB"
    set fileInB [ openConfigFile $filenameB ]

    #puts $fileInC "/configure lag 1"
    #puts $fileInC "      mode access"
    puts $fileInC "/configure lag 11"
    puts $fileInC "      mode access"
    puts $fileInC "/configure lag 12"
    puts $fileInC "      mode access"
    puts $fileInC "/configure lag 13"
    puts $fileInC "      mode access"
    #puts $fileInD "/configure lag 1"
    #puts $fileInD "      mode access"

    puts $fileInB "/configure lag 11"
    puts $fileInB "/configure lag 12"
    puts $fileInB "/configure lag 13"
    #puts $fileInB "      mode access"

    set dutDFilterid [expr {int(rand()*65535)+1}]
    set dutCFilterid [expr {int(rand()*65535)+1}]
    while {1} {
        set dutCSystemFilterid [expr {int(rand()*65535)+1}]
        if {$dutCSystemFilterid != $dutCFilterid} {
            break
        }
    }
    if {$opt(systemFilter)} {
        set bkupId $dutCFilterid
        puts $fileInC "/configure filter ip-filter $dutCFilterid create"
        puts $fileInC "     default-action forward"
        set dutCFilterid $dutCSystemFilterid
    }
    set dutBFilterid [expr {int(rand()*65535)+1}]

    if {$opt(systemFilter)} {
        puts $fileInC "/configure filter ip-filter $dutCSystemFilterid create"
        puts $fileInC "         scope system"
        puts $fileInC "     exit"
    }
    puts $fileInB "/configure filter ip-filter $dutBFilterid create"
    puts $fileInB "     default-action forward"
    puts $fileInB "         entry 1 create"
    puts $fileInB "             match protocol udp"
    puts $fileInB "             exit"
    puts $fileInB "            action forward"
    puts $fileInB "         exit"

    puts $fileInD "/configure filter ip-filter $dutDFilterid create"
    puts $fileInD "     default-action forward"

    for {set i 1} {$i < 19} {incr i} {
        puts $fileInD "/configure filter ip-filter $dutDFilterid create entry $i create"
        puts $fileInD "    match protocol udp"
        puts $fileInD "         src-port eq 200$i"
        puts $fileInD "     exit"
        puts $fileInD "     action forward"
    }

    puts $fileInC "/configure filter ip-filter $dutCFilterid create"
    puts $fileInC "     default-action forward"

    for {set i 1} {$i < 15} {incr i} {
        puts $fileInC "/configure filter ip-filter $dutCFilterid create entry $i create"
        puts $fileInC "    match protocol udp"
        puts $fileInC "         src-port eq 200$i"
        puts $fileInC "     exit"
        puts $fileInC "     action forward"
    }

    for {set i 15} {$i < 19} {incr i} {
        puts $fileInC "/configure filter ip-filter $dutCFilterid create entry $i create"
        puts $fileInC "    match protocol udp"
        puts $fileInC "         src-port eq 200$i"
        puts $fileInC "     exit"
        puts $fileInC "     action drop"
    }

    for {set i 1} {$i <= 24} {incr i} {
        puts $fileInC "/configure port $topoMap(Dut-C,2/2/$i)"
        puts $fileInC "  ethernet mode access"
        puts $fileInC "  ethernet autonegotiate limited"
        puts $fileInC "  no shutdown"
        puts $fileInC "/configure lag 11 port $topoMap(Dut-C,2/2/$i)"

        puts $fileInB "/configure port $topoMap(Dut-B,2/2/$i)"
        #puts $fileInB "  ethernet mode access"
        puts $fileInB "  ethernet autonegotiate limited"
        puts $fileInB "  no shutdown"
        puts $fileInB "/configure lag 11 port $topoMap(Dut-B,2/2/$i)"
    }

    for {set i 25} {$i <= 48} {incr i} {
        puts $fileInC "/configure port $topoMap(Dut-C,2/2/$i)"
        puts $fileInC "  ethernet mode access"
        puts $fileInC "  ethernet autonegotiate limited"
        puts $fileInC "  no shutdown"
        puts $fileInC "/configure lag 12 port $topoMap(Dut-C,2/2/$i)"

        puts $fileInB "/configure port $topoMap(Dut-B,2/2/$i)"
        #puts $fileInB "  ethernet mode access"
        puts $fileInB "  ethernet autonegotiate limited"
        puts $fileInB "  no shutdown"
        puts $fileInB "/configure lag 12 port $topoMap(Dut-B,2/2/$i)"
    }

    for {set i 37} {$i <= 60} {incr i} {
        puts $fileInC "/configure port $topoMap(Dut-C,7/2/$i)"
        puts $fileInC "  ethernet mode access"
        puts $fileInC "  ethernet autonegotiate limited"
        puts $fileInC "  no shutdown"
        puts $fileInC "/configure lag 13 port $topoMap(Dut-C,7/2/$i)"

        puts $fileInB "/configure port $topoMap(Dut-B,5/2/$i)"
        #puts $fileInB "  ethernet mode access"
        puts $fileInB "  ethernet autonegotiate limited"
        puts $fileInB "  no shutdown"
        puts $fileInB "/configure lag 13 port $topoMap(Dut-B,5/2/$i)"
    }

    foreach {iomC iomD} "3/2 1/2 4/2 2/2 5/2 5/2 6/2 6/2 7/2 7/2" {
        for {set j 0} {$j < 4} {incr j} {
            for {set i [expr {$j*6+1}]} {$i < [expr {$j*6+7}]} {incr i} {
                puts $fileInC "/configure port $topoMap(Dut-C,${iomC}/$i)"
                #puts $fileInC "  ethernet mode access"
                puts $fileInC "  ethernet autonegotiate limited"
                puts $fileInC "  no shutdown"
                puts $fileInC "/configure lag [expr {$j+1}] port $topoMap(Dut-C,${iomC}/$i)"

                puts $fileInD "/configure port $topoMap(Dut-D,${iomD}/$i)"
                #puts $fileInD "  ethernet mode access"
                puts $fileInD "  ethernet autonegotiate limited"
                puts $fileInD "  no shutdown"
                puts $fileInD "/configure lag [expr {$j+1}] port $topoMap(Dut-D,${iomD}/$i)"
            }
        }
    }

    puts $fileInD "/configure router interface \"linkC-1\""
    puts $fileInD "port lag-1"
    puts $fileInD "address 10.2.0.1/16"
    puts $fileInD "/configure router interface \"linkC-2\""
    puts $fileInD "port lag-2"
    puts $fileInD "address 10.3.0.1/16"
    puts $fileInD "/configure router interface \"linkC-3\""
    puts $fileInD "port lag-3"
    puts $fileInD "address 10.4.0.1/16"
    puts $fileInD "/configure router interface \"linkC-4\""
    puts $fileInD "port lag-4"
    puts $fileInD "address 10.5.0.1/16"
    puts $fileInD "/configure router ecmp 32"
    puts $fileInD "/configure "
    puts $fileInD "     router"
    puts $fileInD "     ospf"
    puts $fileInD "        timers"
    puts $fileInD "            spf-wait 1000 1000 1000"
    puts $fileInD "        exit"
    puts $fileInD "        area 0.0.0.0"
    puts $fileInD "            interface \"system\""
    puts $fileInD "                hello-interval 5"
    puts $fileInD "                dead-interval 15"
    puts $fileInD "                no shutdown"
    puts $fileInD "            exit"
    puts $fileInD "            interface \"linkC-1\""
    puts $fileInD "                hello-interval 5"
    puts $fileInD "                dead-interval 15"
    puts $fileInD "                no shutdown"
    puts $fileInD "            exit"
    puts $fileInD "            interface \"linkC-2\""
    puts $fileInD "                hello-interval 5"
    puts $fileInD "                dead-interval 15"
    puts $fileInD "                no shutdown"
    puts $fileInD "            exit"
    puts $fileInD "            interface \"linkC-3\""
    puts $fileInD "                hello-interval 5"
    puts $fileInD "                dead-interval 15"
    puts $fileInD "                no shutdown"
    puts $fileInD "            exit"
    puts $fileInD "            interface \"linkC-4\""
    puts $fileInD "                hello-interval 5"
    puts $fileInD "                dead-interval 15"
    puts $fileInD "                no shutdown"
    puts $fileInD "            exit"
    puts $fileInD "        exit"
    #puts $fileInD "        segment-routing"
    #puts $fileInD "            shutdown"
    #puts $fileInD "        exit"
    puts $fileInD "        no shutdown"
    puts $fileInD "    exit"
    puts $fileInD "/configure router mpls"
    puts $fileInD "        interface \"system\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-1\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-2\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-3\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-4\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "    exit"
    puts $fileInD "/configure router rsvp"
    puts $fileInD "        interface \"system\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-1\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-2\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-3\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        interface \"linkC-4\""
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        no shutdown"
    puts $fileInD "    exit"
    puts $fileInD "/configure router mpls"
    puts $fileInD "        path \"strict1\""
    puts $fileInD "            hop 1 10.2.0.2 strict"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        path \"strict2\""
    puts $fileInD "            hop 1 10.3.0.2 strict"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        path \"strict3\""
    puts $fileInD "            hop 1 10.4.0.2 strict"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        path \"strict4\""
    puts $fileInD "            hop 1 10.5.0.2 strict"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        lsp \"toC1\""
    puts $fileInD "            to 10.20.1.3"
    puts $fileInD "            retry-timer 20"
    puts $fileInD "            primary \"strict1\""
    puts $fileInD "            exit"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        lsp \"toC2\""
    puts $fileInD "            to 10.20.1.3"
    puts $fileInD "            retry-timer 20"
    puts $fileInD "            primary \"strict2\""
    puts $fileInD "            exit"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        lsp \"toC3\""
    puts $fileInD "            to 10.20.1.3"
    puts $fileInD "            retry-timer 20"
    puts $fileInD "            primary \"strict3\""
    puts $fileInD "            exit"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        lsp \"toC4\""
    puts $fileInD "            to 10.20.1.3"
    puts $fileInD "            retry-timer 20"
    puts $fileInD "            primary \"strict4\""
    puts $fileInD "            exit"
    puts $fileInD "            no shutdown"
    puts $fileInD "        exit"
    puts $fileInD "        no shutdown"
    puts $fileInD "    exit"
    puts $fileInD "/configure router ldp"
    puts $fileInD "        interface-parameters"
    puts $fileInD "        exit"
    puts $fileInD "        targeted-session"
    puts $fileInD "        exit"
    puts $fileInD "        no shutdown"
    puts $fileInD "    exit"

    puts $fileInD "/configure router bgp"
    puts $fileInD "        router-id 10.20.1.1"
    puts $fileInD "        group \"vprn\""
    puts $fileInD "            family vpn-ipv4"
    puts $fileInD "            peer-as 65000"
    puts $fileInD "            neighbor 10.20.1.3"
    puts $fileInD "                peer-as 65000"
    puts $fileInD "            exit"
    puts $fileInD "        exit"
    puts $fileInD "        no shutdown"

    puts $fileInD "/configure router"
    puts $fileInD "      interface \"system\""
    puts $fileInD "        address 10.20.1.1/32"
    puts $fileInD "         no shutdown"
    puts $fileInD "     exit"
    puts $fileInD "     autonomous-system 65000"
    puts $fileInD "/configure system chassis-mode d"
    puts $fileInD "/configure service sdp 21 mpls create"
    puts $fileInD "         description \"Default sdp description\""
    puts $fileInD "         far-end 10.20.1.3"
    puts $fileInD "         lsp \"toC1\""
    puts $fileInD "         lsp \"toC2\""
    puts $fileInD "         lsp \"toC3\""
    puts $fileInD "         lsp \"toC4\""
    puts $fileInD "         keep-alive"
    puts $fileInD "             shutdown"
    puts $fileInD "         exit"
    puts $fileInD "         no shutdown"
    puts $fileInD "     exit"
    puts $fileInD "/configure service vprn 1 customer 1 create"
    puts $fileInD "        autonomous-system 65000"
    puts $fileInD "        route-distinguisher 65000:1"
    puts $fileInD "        vrf-target target:65000:1"
    puts $fileInD "        service-name \"XYZ Vprn 1\""
    puts $fileInD "        spoke-sdp 21 create"
    puts $fileInD "            description \"Description for Sdp Bind 21 for Svc ID 1\""
    puts $fileInD "        exit"
    puts $fileInD "        no shutdown"
    puts $fileInD "    exit"

    set i 1
    foreach p $dutdToIxia {
        set port $topoMap(Dut-D,$p)
        set ip "10.8.$i.1"

        puts $fileInD "/configure port $port ethernet mode access"
        puts $fileInD "/configure port $port no shutdown"
        puts $fileInD "/configure service vprn 1 interface ixia$i create"
        puts $fileInD "     address $ip/24"
        puts $fileInD "sap $port create"
        puts $fileInD "     ingress filter ip $dutDFilterid"
        incr i
    }
    puts $fileInD "/configure lag 1 lacp active"
    puts $fileInD "/configure lag 2 lacp active"
    puts $fileInD "/configure lag 3 lacp active"
    puts $fileInD "/configure lag 4 lacp active"
    puts $fileInD "/configure lag 1 no shutdown"
    puts $fileInD "/configure lag 2 no shutdown"
    puts $fileInD "/configure lag 3 no shutdown"
    puts $fileInD "/configure lag 4 no shutdown"
    puts $fileInD "/configure system load-balancing"
    puts $fileInD "        l4-load-balancing"
    puts $fileInD "        lsr-load-balancing lbl-ip"
    puts $fileInD "        system-ip-load-balancing"

    puts $fileInC "/configure system load-balancing"
    puts $fileInC "        l4-load-balancing"
    puts $fileInC "        lsr-load-balancing lbl-ip"
    puts $fileInC "        system-ip-load-balancing"
    puts $fileInC "/configure lag 1 lacp active"
    puts $fileInC "/configure lag 2 lacp active"
    puts $fileInC "/configure lag 3 lacp active"
    puts $fileInC "/configure lag 4 lacp active"
    puts $fileInC "/configure lag 11 lacp active"
    puts $fileInC "/configure lag 12 lacp active"
    puts $fileInC "/configure lag 13 lacp active"
    puts $fileInC "/configure router ecmp 32"
    puts $fileInC "/configure router interface \"linkD-1\""
    puts $fileInC "port lag-1"
    puts $fileInC "    address 10.2.0.2/16"
    puts $fileInC "/configure router interface \"linkD-2\""
    puts $fileInC "port lag-2"
    puts $fileInC "    address 10.3.0.2/16"
    puts $fileInC "/configure router interface \"linkD-3\""
    puts $fileInC "port lag-3"
    puts $fileInC "    address 10.4.0.2/16"
    puts $fileInC "/configure router interface \"linkD-4\""
    puts $fileInC "port lag-4"
    puts $fileInC "    address 10.5.0.2/16"
    puts $fileInC "/configure" 
    puts $fileInC "    router"
    puts $fileInC "      ospf"
    puts $fileInC "        timers"
    puts $fileInC "            spf-wait 1000 1000 1000"
    puts $fileInC "        exit"
    puts $fileInC "        area 0.0.0.0"
    puts $fileInC "            interface \"system\""
    puts $fileInC "                hello-interval 5"
    puts $fileInC "                dead-interval 15"
    puts $fileInC "                no shutdown"
    puts $fileInC "            exit"
    puts $fileInC "            interface \"linkD-1\""
    puts $fileInC "                hello-interval 5"
    puts $fileInC "                dead-interval 15"
    puts $fileInC "                no shutdown"
    puts $fileInC "            exit"
    puts $fileInC "            interface \"linkD-2\""
    puts $fileInC "                hello-interval 5"
    puts $fileInC "                dead-interval 15"
    puts $fileInC "                no shutdown"
    puts $fileInC "            exit"
    puts $fileInC "            interface \"linkD-3\""
    puts $fileInC "                hello-interval 5"
    puts $fileInC "                dead-interval 15"
    puts $fileInC "                no shutdown"
    puts $fileInC "            exit"
    puts $fileInC "            interface \"linkD-4\""
    puts $fileInC "                hello-interval 5"
    puts $fileInC "                dead-interval 15"
    puts $fileInC "                no shutdown"
    puts $fileInC "            exit"
    puts $fileInC "        exit"
    #puts $fileInC "        segment-routing"
    #puts $fileInC "            shutdown"
    #puts $fileInC "        exit"
    puts $fileInC "        no shutdown"
    puts $fileInC "/configure router mpls"
    puts $fileInC "        interface \"system\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-1\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-2\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-3\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-4\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "/configure router rsvp"
    puts $fileInC "        interface \"system\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-1\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-2\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        no shutdown"
    puts $fileInC "        interface \"linkD-3\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"linkD-4\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "    exit"
    puts $fileInC "/configure router mpls"
    puts $fileInC "        path \"loose\""
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        lsp \"toD\""
    puts $fileInC "            to 10.20.1.1"
    puts $fileInC "            retry-timer 20"
    puts $fileInC "            primary \"loose\""
    puts $fileInC "            exit"
    puts $fileInC "            no shutdown"
    puts $fileInC "        exit"
    puts $fileInC "        no shutdown"
    puts $fileInC "    exit"
    puts $fileInC "/configure router ldp"
    puts $fileInC "        interface-parameters"
    puts $fileInC "        exit"
    puts $fileInC "        targeted-session"
    puts $fileInC "        exit"
    puts $fileInC "        no shutdown"
    puts $fileInC "    exit"
    puts $fileInC "/configure router bgp"
    puts $fileInC "        router-id 10.20.1.3"
    puts $fileInC "        group \"vprn\""
    puts $fileInC "            family vpn-ipv4"
    puts $fileInC "            peer-as 65000"
    puts $fileInC "            neighbor 10.20.1.1"
    puts $fileInC "                peer-as 65000"
    puts $fileInC "            exit"
    puts $fileInC "        exit"
    puts $fileInC "        no shutdown"

    if {$opt(systemFilter)} {
        set dutCFilterid $bkupId
        puts $fileInC "/configure filter system-filter"
        puts $fileInC "         ip $dutCSystemFilterid"
        puts $fileInC "     exit"
        puts $fileInC "/configure filter ip-filter $dutCFilterid create"
        puts $fileInC "         chain-to-system-filter"
        puts $fileInC "     exit"
    }
    puts $fileInC "/configure router"
    puts $fileInC "    interface \"system\""
    puts $fileInC "        address 10.20.1.3/32"
    puts $fileInC "        no shutdown"
    puts $fileInC "    exit"
    puts $fileInC "    autonomous-system 65000"
    puts $fileInC "/configure system chassis-mode d"
    puts $fileInC "/configure service sdp 21 mpls create"
    puts $fileInC "         description \"Default sdp description\""
    puts $fileInC "         far-end 10.20.1.1"
    puts $fileInC "         lsp \"toD\""
    puts $fileInC "         keep-alive"
    puts $fileInC "             shutdown"
    puts $fileInC "         exit"
    puts $fileInC "         no shutdown"
    puts $fileInC "     exit"
    puts $fileInC "/configure service vprn 1 customer 1 create"
    puts $fileInC "        autonomous-system 65000"
    puts $fileInC "        route-distinguisher 65000:1"
    puts $fileInC "        vrf-target target:65000:1"
    puts $fileInC "        interface \"itfToB-1\" create"
    puts $fileInC "            address 192.168.10.1/24"
    puts $fileInC "            sap lag-11 create"
    puts $fileInC "                description \"to-192.168.10.3\""
    puts $fileInC "            exit"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"itfToB-2\" create"
    puts $fileInC "            address 192.168.20.1/24"
    puts $fileInC "            sap lag-12 create"
    puts $fileInC "                description \"to-192.168.20.3\""
    puts $fileInC "            exit"
    puts $fileInC "        exit"
    puts $fileInC "        interface \"itfToB-3\" create"
    puts $fileInC "            address 192.168.30.1/24"
    puts $fileInC "            sap lag-13 create"
    puts $fileInC "                description \"to-192.168.30.3\""
    puts $fileInC "            exit"
    puts $fileInC "        exit"
    if {$opt(applyFilter)} {
        puts $fileInC "        network"
        puts $fileInC "            ingress"
        puts $fileInC "                filter ip $dutCFilterid"
        puts $fileInC "            exit"
        puts $fileInC "        exit"
    }
    puts $fileInC "        service-name \"XYZ Vprn 1\""
    puts $fileInC "        spoke-sdp 21 create"
    puts $fileInC "            description \"Description for Sdp Bind 21 for Svc ID 1\""
    puts $fileInC "        exit"
    puts $fileInC "        no shutdown"
    puts $fileInC "    exit"
    puts $fileInC "/configure lag 1 no shutdown"
    puts $fileInC "/configure lag 2 no shutdown"
    puts $fileInC "/configure lag 3 no shutdown"
    puts $fileInC "/configure lag 4 no shutdown"
    puts $fileInC "/configure lag 11 no shutdown"
    puts $fileInC "/configure lag 12 no shutdown"
    puts $fileInC "/configure lag 13 no shutdown"

    set dstIp1 "192.168.10.3"
    set dstIp2 "192.168.20.3"
    set dstIp3 "192.168.30.3"
    puts $fileInB "/configure lag 11 lacp active"
    puts $fileInB "/configure lag 12 lacp active"
    puts $fileInB "/configure lag 13 lacp active"
    puts $fileInB "/configure lag 11 no shutdown"
    puts $fileInB "/configure lag 12 no shutdown"
    puts $fileInB "/configure lag 13 no shutdown"
    puts $fileInB "/configure router interface \"linkC-1\""
    puts $fileInB "         address ${dstIp1}/24"
    puts $fileInB "         port lag-11"
    puts $fileInB "             ingress"
    puts $fileInB "                 filter ip $dutBFilterid"
    puts $fileInB "             exit"
    puts $fileInB "         exit"
    puts $fileInB "     exit"
    puts $fileInB "/configure router interface \"linkC-2\""
    puts $fileInB "         address ${dstIp2}/24"
    puts $fileInB "         port lag-12"
    puts $fileInB "             ingress"
    puts $fileInB "                 filter ip $dutBFilterid"
    puts $fileInB "             exit"
    puts $fileInB "         exit"
    puts $fileInB "     exit"
    puts $fileInB "/configure router interface \"linkC-3\""
    puts $fileInB "         address ${dstIp3}/24"
    puts $fileInB "         port lag-13"
    puts $fileInB "             ingress"
    puts $fileInB "                 filter ip $dutBFilterid"
    puts $fileInB "             exit"
    puts $fileInB "         exit"
    puts $fileInB "     exit"
    #puts $fileInB "/configure router static-route 192.168.10.0/24 next-hop 192.168.10.1"
    puts $fileInB "/configure router static-route 0.0.0.0/0 next-hop 192.168.10.1"

    set r [ execConfigFile B $fileInB $filenameB -expectFail false -cleanupAfterExec true -execTimeout 500 ]
    if { $r != "OK" } {
        log_msg ERROR "error during exec of config file $filenameB"
        set result FAIL
    }

    set r [ execConfigFile C $fileInC $filenameC -expectFail false -cleanupAfterExec true -execTimeout 500 ]
    if { $r != "OK" } {
        log_msg ERROR "error during exec of config file $filenameC"
        set result FAIL
    }

    set r [ execConfigFile D $fileInD $filenameD -expectFail false -cleanupAfterExec true -execTimeout 500 ]
    if { $r != "OK" } {
        log_msg ERROR "error during exec of config file $filenameD"
        set result FAIL
    }

    #gash_interpreter

    makeIPfilterEntries C $dutCFilterid ingress -iom3 true

    if {! $opt(applyFilter)} {
        Dut-C sendCliCommand "/configure service vprn 1 network ingress filter ip $dutCFilterid" -verbose true
    }

    #makeIPfilterEntries D $dutDFilterid ingress -iom3 true

    sleep 60

    gash_interpreter

    set pattern {DE AD BE EF 44}
    set numFrames "9000000"
    set ixPorts [lrange $::TestTopo::ixiaPortList 6 15]

    filter_subinsert_memLeakChecks "C" start

    foreach dut "C D" {
        log_msg INFO [Dut-$dut sendCliCommand "ping $dstIp1 router 1" -timeout 60]
        log_msg INFO [Dut-$dut sendCliCommand "ping $dstIp2 router 1" -timeout 60]
        log_msg INFO [Dut-$dut sendCliCommand "ping $dstIp3 router 1" -timeout 60]
    }

    set srcIps ""
    #set testFwd [expr {int(rand()*1)+7}]

    while {1} {
        set ipv4 [random_ip]
        
        if {[lsearch $srcIps $ipv4] == -1} {
            lappend srcIps $ipv4
        }
        
        if {[llength $srcIps] >= 10} {
            break
        }
    }

    set srcMacs ""

    while {1} {
        set mac [random_unicast_mac]
        
        if {[lsearch $srcMacs $mac] == -1} {
            lappend srcMacs $mac
        }
        
        if {[llength $srcMacs] >= 10} {
            break
        }
    }

    set dstPorts ""

    while {1} {
        set dstPort [random 65536]
        
        if {[lsearch $dstPorts $dstPort] == -1} {
            lappend dstPorts $dstPort
        }
        
        if {[llength $dstPorts] >= 10} {
            break
        }
    }
    #set allSrcPorts $testEntries
    #if system filter then get back correct id
    if {$opt(systemFilter)} {
        set dutCFilterid $dutCSystemFilterid
    }

    set l 0
    set ipA(1) 0
    set ipA(2) 0
    set ipA(3) 0
    foreach ixPort $ixPorts {
        set port [lindex $dutdToIxia $l]
        set mac_da [getMac Dut-D $port]
        set ip_sa "3.0.0.0"
        set numSource many
        set ip_sa_mode random
        set numSourceMask 8
        set ipId [expr {$l%3+1}]
        if {$ipA($ipId) < 2} {
            set prt [expr {int(rand()*14)+1}]
            set srcPort "200$prt"
            incr ipA($ipId)
        } else {
            set srcPort "200[expr {int(rand()*4)+15}]"
            incr ipA($ipId)
        }
        set ip_da [set dstIp$ipId]
        #set ip_da ".40.1.2"
        set numDestMask 8
        set numDest 1
        set ip_da_mode fixed
        #set Encap_value $Encap_value
        set packet_ps 3000000000
        set patternType patternTypeRandom
        set ipProtocol 17
        set iplengthOverride false
        set rawProtocol udp
        set dstPort [expr {int(rand()*65535)+1}]
        incr l

        set status [handlePacketMF -rawProtocol $rawProtocol -iplengthOverride $iplengthOverride -numsamac random -ipProtocol $ipProtocol -patternType $patternType -port $ixPort -damac $mac_da -src $ip_sa -numSource $numSource -numSourceMask $numSourceMask -numSourceIncrType $ip_sa_mode -dst $ip_da -numDest $numDest -numDestMask $numDestMask -numDestIncrType $ip_da_mode -rate $packet_ps -action createDownload -name "Stream 1" -numsamac [expr {16**12}]]

        set portList [list $ixPort]
        scan $ixPort "%d %d %d" chassis card port
        port get $chassis $card $port

        stream get $chassis $card $port 1
        stream      config  -enable  false
        stream      config  -name    "Stream 1"
        protocol    config  -name    ip
        #ip          config  -sourceIpAddr  1.1.0.2
        #ip          config  -sourceIpAddrMode  ipIdle
        #ip          config  -destIpAddr   3.3.0.2
        ip          config  -fragmentOffset  0
        ip          config  -lastFragment    last
        ip          config  -ipProtocol      udp
        udp         setDefault
        udp         config  -sourcePort   $srcPort
        udp         config  -destPort     $dstPort
        udp         set     $chassis $card $port
        ip          set     $chassis $card $port
        stream      set     $chassis $card $port 1
        stream      write   $chassis $card $port 1
    }

    gash_interpreter
    
    foreach ixPort $ixPorts {
        IXIAstartSendStream $ixPort 1
    }

    set wait 30
    set step 1
    stopwatch_init sw

    while {1} {
        if {[stopwatch_exceeded sw [expr {$step*$wait}]]} {
            Dut-C sendCliCommand "exit all"
            Dut-B sendCliCommand "exit all"
            for {set i 1} {$i <= 18} {incr i} {
                log_msg INFO [Dut-D sendCliCommand "show filter ip $dutDFilterid entry $i"]
                log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
            }
            incr step
        }
    
        if {[stopwatch_exceeded sw $opt(maxTime)]} {
            log_msg INFO "Exceeded $opt(maxTime)s"
            break
        }
    
        incr sample
    }

    foreach dut "C D" {
        set r [filter_subinsert_memLeakChecks $dut check]
        if {$r != "PASSED"} {
            log_msg ERROR "memory leak detected after cleanup, found $r"
            set result FAILED
            if {$opt(debug) != "false"} { return $result }
        }
    }

    foreach ixPort $ixPorts {
        IXIAstopSendStream $ixPort 1
    }

    sleep 20    

    set ingressD 0
    set ingressC 0
    for {set i 1} {$i <= 18} {incr i} {
        log_msg INFO [Dut-D sendCliCommand "show filter ip $dutDFilterid entry $i"]
        incr ingressD [Dut-D getTIPFilterParamsIngressHitCount $dutDFilterid $i]
        log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
        incr ingressC [Dut-C getTIPFilterParamsIngressHitCount $dutCFilterid $i]
    }

    set egressC 0
    for {set i 1} {$i <= 14} {incr i} {
        log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
        incr egressC [Dut-C getTIPFilterParamsIngressHitCount $dutCFilterid $i]
    }

    log_msg INFO [Dut-B sendCliCommand "show filter ip $dutBFilterid entry 1"]
    set ingressB [Dut-B getTIPFilterParamsIngressHitCount $dutBFilterid 1]
    log_msg INFO "Dut-D count: '$ingressD' -> Dut-C count: '$ingressC'"
    if {$ingressD != $ingressC} {
        log_msg ERROR "Some packets were lost."
    }

    log_msg INFO "Dut-C count: '$egressC' -> Dut-B count: '$ingressB'"
    if {$egressC != $ingressB} {
        log_msg ERROR "Some packets were lost."
    }

    if {$opt(systemFilter)} {
        Dut-C sendCliCommand "/environment no more"
        Dut-C sendCliCommand "show filter ip $bkupId"
    }

    gash_interpreter

    foreach ixPort $ixPorts {
        IXIAstartSendStream $ixPort 1
    }

    set wait 30
    set step 1
    stopwatch_init sw

    while {1} {
        if {[stopwatch_exceeded sw [expr {$step*$wait}]]} {
            Dut-C sendCliCommand "exit all"
            Dut-B sendCliCommand "exit all"
            for {set i 1} {$i <= 18} {incr i} {
                log_msg INFO [Dut-D sendCliCommand "show filter ip $dutDFilterid entry $i"]
                log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
            }
            incr step
        }
    
        if {[stopwatch_exceeded sw $opt(maxTime)]} {
            log_msg INFO "Exceeded $opt(maxTime)s"
            break
        }
    
        incr sample
    }

    foreach dut "C D" {
        set r [filter_subinsert_memLeakChecks $dut check]
        if {$r != "PASSED"} {
            log_msg ERROR "memory leak detected after cleanup, found $r"
            set result FAILED
            if {$opt(debug) != "false"} { return $result }
        }
    }

    foreach ixPort $ixPorts {
        IXIAstopSendStream $ixPort 1
    }

    sleep 20    

    set ingressD 0
    set ingressC 0
    for {set i 1} {$i <= 18} {incr i} {
        log_msg INFO [Dut-D sendCliCommand "show filter ip $dutDFilterid entry $i"]
        incr ingressD [Dut-D getTIPFilterParamsIngressHitCount $dutDFilterid $i]
        log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
        incr ingressC [Dut-C getTIPFilterParamsIngressHitCount $dutCFilterid $i]
    }

    set egressC 0
    for {set i 1} {$i <= 14} {incr i} {
        log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
        incr egressC [Dut-C getTIPFilterParamsIngressHitCount $dutCFilterid $i]
    }

    log_msg INFO [Dut-B sendCliCommand "show filter ip $dutBFilterid entry 1"]
    set ingressB [Dut-B getTIPFilterParamsIngressHitCount $dutBFilterid 1]
    log_msg INFO "Dut-D count: '$ingressD' -> Dut-C count: '$ingressC'"
    if {$ingressD != $ingressC} {
        log_msg ERROR "Some packets were lost."
        log_msg INFO "===================== DUT-C stats ====================="
        for {set i 1} {$i <= 10} {incr i} {
            log_msg INFO [Dut-C sendCliCommand "shell cardcmd $i destats"]
            log_msg INFO [Dut-C sendCliCommand "shell cardcmd $i distats"]
            log_msg INFO [Dut-C sendCliCommand "shell cardcmd $i dqstats"]
        }
        log_msg INFO "===================== DUT-D stats ====================="
        for {set i 1} {$i <= 10} {incr i} {
            log_msg INFO [Dut-D sendCliCommand "shell cardcmd $i destats"]
            log_msg INFO [Dut-D sendCliCommand "shell cardcmd $i distats"]
            log_msg INFO [Dut-D sendCliCommand "shell cardcmd $i dqstats"]
        }
        log_msg INFO "======================================================="
    }

    log_msg INFO "Dut-C count: '$egressC' -> Dut-B count: '$ingressB'"
    if {$egressC != $ingressB} {
        log_msg ERROR "Some packets were lost."
    }

    foreach ixPort $ixPorts {
        IXIAstartSendStream $ixPort 1
    }

    global logdir
    set username    $::TestDB::thisTestBed
    set hostIp      $::TestDB::thisHostIpAddr
    set dir         "ftp://${username}:tigris@${hostIp}/$logdir/device_logs"
    set config_dir  "ftp://${username}:tigris@${hostIp}/$logdir/device_logs/saved_configs"

    Dut-D sendCliCommand "/admin save $config_dir/Dut-D-setup.cfg" -extendedTimeout 320  -extendedMatchString "#"

    saveOrRestore delete -dut Dut-D

    Dut-D sendCliCommand "exit all"
    Dut-D sendCliCommand "exec $config_dir/Dut-D-setup.cfg" -extendedTimeout 320 -extendedMatchString "#"
    Dut-D sendCliCommand "exit all"
    Dut-D sendCliCommand "exec $config_dir/Dut-D-setup.cfg" -extendedTimeout 320 -extendedMatchString "#"

    Dut-D sendCliCommand "/admin save $config_dir/Dut-C-setup.cfg" -extendedTimeout 320  -extendedMatchString "#"

    saveOrRestore delete -dut Dut-C

    Dut-D sendCliCommand "exit all"
    Dut-D sendCliCommand "exec $config_dir/Dut-C-setup.cfg" -extendedTimeout 320 -extendedMatchString "#"
    Dut-D sendCliCommand "exit all"
    Dut-D sendCliCommand "exec $config_dir/Dut-C-setup.cfg" -extendedTimeout 320 -extendedMatchString "#"

    sleep 40

    set wait 30
    set step 1

    Dut-C sendCliCommand "/admin reboot standby now"
    sleep 5
    Dut-C CnWRedCardStatus
    Dut-C activitySwitch 

    stopwatch_init sw

    while {1} {
        if {[stopwatch_exceeded sw [expr {$step*$wait}]]} {
            Dut-C sendCliCommand "exit all"
            Dut-B sendCliCommand "exit all"
            for {set i 1} {$i <= 18} {incr i} {
                log_msg INFO [Dut-D sendCliCommand "show filter ip $dutDFilterid entry $i"]
                log_msg INFO [Dut-C sendCliCommand "show filter ip $dutCFilterid entry $i"]
            }
            incr step
        }
    
        if {[stopwatch_exceeded sw $opt(maxTime)]} {
            log_msg INFO "Exceeded $opt(maxTime)s"
            break
        }
    
        incr sample
    }

    saveOrRestore delete
    sleep 5
     
    foreach ixPort $ixPorts {
        IXIAstopSendStream $ixPort 1
    }

    log_msg INFO [Dut-B sendCliCommand "show filter ip $dutBFilterid entry 1"]

    if {$result == "OK"} {
        log_result PASSED $testId
    } else {
        log_result FAILED $testId
    }
}
