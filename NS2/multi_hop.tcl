# Creating new simulator...
set ns [new Simulator]

# Adding Noise to the propagation...
Propagation/Shadowing set pathlossExp_ 2.0  ;# path loss exponent
Propagation/Shadowing set std_db_ 2.0       ;# shadowing deviation (dB)
Propagation/Shadowing set dist0_ 1.0        ;# reference distance (m)
Propagation/Shadowing set seed_ 0           ;# seed for RNG

Phy/WirelessPhy set L_ 5					;#Loss Factor

#Initializing variables...
set val(channel)		Channel/WirelessChannel;	#Channel Type
set val(wiPhy)          Phy/WirelessPhy;			#network interface type WAVELAN DSSS 2.4GHz
set val(propagation)	Propagation/Shadowing;		# radio-propagation model
set val(mac)            Mac/802_11;					# MAC type
set val(inQueue)        Queue/DropTail/PriQueue;   	# interface queue type
set val(linkLayer)      LL;                      	# link layer type
set val(antModel)       Antenna/OmniAntenna;        # antenna model
set val(maxPackets)     500;                        # max packet in ifq
set val(noOfNodes)      4;                         	# number of mobilenodes
set val(rtPrtcl)        AODV;                       # routing protocol
set val(x)  			1000;                       # in metres
set val(y)  			1000;  						# in metres


# Tracing all the transmssions...
set tracefile [open multi_hop.tr w]

# Tracing the co-ordinates for the interface...
set namtrace [open multi_hop.nam w]

$ns trace-all $tracefile
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

create-god $val(noOfNodes)

set channel1 [new $val(channel)]

# Setting Topography...
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

$ns node-config -adhocRouting $val(rtPrtcl) \
		-llType 		$val(linkLayer) \
		-macType 		$val(mac) \
		-ifqType 		$val(inQueue) \
		-ifqLen 		$val(maxPackets) \
		-antType 		$val(antModel) \
		-propType 		$val(propagation) \
		-phyType 		$val(wiPhy) \
		-topoInstance 	$topo \
		-agentTrace 	ON \
		-macTrace 		ON \
		-routerTrace 	ON \
		-movementTrace 	ON \
		-channel 		$channel1 \

# Creating Nodes and setting position...
for {set i 0} {$i < $val(noOfNodes)} {incr i} {
	set n($i) [$ns node]

	$n($i) set X_ [expr $i * 95]
	$n($i) set Y_ 450

	$ns initial_node_pos $n($i) 30
	$n($i) random-motion 0
}

# Movement of nodes...
# $ns at 0.0 "$n(0) setdest 0.001 0.001 10"
# $ns at 0.0 "$n([expr $val(noOfNodes) -1]) setdest 200 0.001 10"

# Setting up source and sink...
set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp

set null [new Agent/Null]
$ns attach-agent $n([expr $val(noOfNodes) -1]) $null

$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set interval_ 0.01
$cbr set random_ 0
$cbr set rate_ 256Kbps
$cbr attach-agent $udp

# data packet generation starting time...
$ns at 0.2 "$cbr start"
# data packet generation complete time...
$ns at 15.0 "$cbr stop"

$ns at 30.0 "finish"

#Define a 'finish' procedure...
proc finish {} {
 
 global ns tracefile namtrace
 $ns flush-trace
 close $tracefile
 close $namtrace

 #Execute NAM on the trace file...
 # exec nam multi_hop.nam &
 exit 0

}

# Simulation Starts...
$ns run

puts "Communication is over"
