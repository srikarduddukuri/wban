#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     50                         ;# number of mobilenodes
set val(rp)     AODV                       ;# routing protocol
set val(x)      1103                      ;# X dimension of topography
set val(y)      599                      ;# Y dimension of topography
set val(stop)   10.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
		-energyModel  "EnergyModel" \
                -initialEnergy 2.5 \
                -txPower 0.1 \
                -rxPower 0.1 \
                -idlePower 0.03 \
                -sleepPower 0.02 \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 50 nodes
set n0 [$ns node]
$n0 set X_ 102
$n0 set Y_ 499
$n0 set Z_ 0.0
$ns initial_node_pos $n0 30


set n1 [$ns node]
$n1 set X_ 202
$n1 set Y_ 499
$n1 set Z_ 0.0
#$n1 color "red"
#$ns at 0.0 "$n1 color red"
$ns initial_node_pos $n1 30
set n2 [$ns node]
$n2 set X_ 302
$n2 set Y_ 499
$n2 set Z_ 0.0
$ns initial_node_pos $n2 30
set n3 [$ns node]
$n3 set X_ 402
$n3 set Y_ 499
$n3 set Z_ 0.0
$ns initial_node_pos $n3 30
set n4 [$ns node]
$n4 set X_ 502
$n4 set Y_ 499
$n4 set Z_ 0.0
$ns initial_node_pos $n4 30
set n5 [$ns node]
$n5 set X_ 102
$n5 set Y_ 399
$n5 set Z_ 0.0
$ns initial_node_pos $n5 30

#===================================
#        Agents Definition        
#===================================

$ns at 0.1 "$n0 label Source"
$ns at 0.1 "$n5 label Destination"



$n1 color "red"
$ns at 0.1 "$n1 color red"
$n5 color "red"
$ns at 0.1 "$n5 color red"

$n0 color "green"
$ns at 0.1 "$n0 color green"

$n1 color "black"
$ns at 0.2 "$n1 color black"
$n5 color "black"
$ns at 0.2 "$n5 color black"


$n2 color "red"
$ns at 0.7 "$n2 color red"
$n3 color "red"
$ns at 0.7 "$n3 color red"


$n2 color "black"
$ns at 1.7 "$n2 color black"
$n3 color "black"
$ns at 1.7 "$n3 color black"









set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n0 $udp
$ns attach-agent $n5 $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 4096
$ns at 0.2 "$cbr start" 



set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n4 $udp
$ns attach-agent $n5 $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 4096
$ns at 0.7 "$cbr start" 




#===================================
#        Applications Definition        
#===================================

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam & 
   
exec xgraph Coven.xg &
exec xgraph Random.xg &
exec xgraph Grid.xg &  
       exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run

