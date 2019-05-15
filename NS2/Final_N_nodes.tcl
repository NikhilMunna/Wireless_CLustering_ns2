# Creating new simulator...
set ns [new Simulator]

#Initializing variables...
set val(channel)		Channel/WirelessChannel;	#Channel Type
set val(wiPhy)          Phy/WirelessPhy;			#network interface type WAVELAN DSSS 2.4GHz
set val(propagation)	Propagation/TwoRayGround;		# radio-propagation model
set val(mac)            Mac/802_11;					# MAC type
set val(inQueue)        Queue/DropTail/PriQueue;   	# interface queue type
set val(linkLayer)      LL;                      	# link layer type
set val(antModel)       Antenna/OmniAntenna;        # antenna model
set val(maxPackets)     500;                        # max packet in ifq
set val(noOfNodes)      25;                         	# number of mobilenodes
set val(rtPrtcl)        AODV;                       # routing protocol
set val(x)  			5000;                       # in metres
set val(y)  			5000;  						# in metres


# Tracing all the transmssions...
set tracefile [open clustering.tr w]

# Tracing the co-ordinates for the interface...
set namtrace [open clustering.nam w]

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
#for {set i 1} {$i <= $val(noOfNodes)} {incr i} {
#	set n($i) [$ns node]
#	
	
#	$ns initial_node_pos $n($i) 30
#	$n($i) random-motion 0
#}


for { set i 1 } { $i <= [expr $val(noOfNodes)] } { incr i } {
	set n($i) [$ns node]
	puts "$i"
}

set k 1
for {set i 1 } {$i  <= [expr $val(noOfNodes) / 5] } {incr i} {

	$n($k) set X_ [expr $i * 100]
	$n($k) set Y_ 250
	
#	puts "$i"
#	for {set j 1 } {$j  <= [expr $val(noOfNodes) / 5] } {incr j} {
#		
#		incr k
#	}
#	puts "$k"
}



# Movement of nodes...
# $ns at 0.0 "$n(0) setdest 0.001 0.001 10"
# $ns at 0.0 "$n([expr $val(noOfNodes) -1]) setdest 200 0.001 10"

# Setting up source and sink...
for { set i 1} {$i <= $val(noOfNodes)} { incr i} {

	set udp($i) [new Agent/UDP]
	$ns attach-agent $n($i) $udp($i)
	set null($i) [new Agent/Null]
	$ns attach-agent $n(1) $null($i)
	$ns connect $udp($i) $null($i)
	$udp($i) set fid_ 2;

}


for { set i 1} {$i <=  $val(noOfNodes)} { incr i } {

	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) attach-agent $udp($i)
	$cbr($i) set type_ CBR
	$cbr($i) set packet_size_ 512
	$cbr($i) set interval_ 0.01
	$cbr($i) set rate_ 128Kbps
	$cbr($i) set random_ false;
}


for { set i 1} {$i <=  $val(noOfNodes)} { incr i} {

	$ns at 0.1 "$cbr($i) start";


}



for { set i 1} {$i <=  $val(noOfNodes)} { incr i} {

	$ns at 20 "$cbr($i) stop";


}



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

$ns at 30.0 "finish"
$ns run
puts "Communication is over"
