set ns [new Simulator]
#---Open the Trace files---#

set file1 [open Tcpred4.tr w]
$ns trace-all $file1

#--Open the NAM trace file----#

set file2 [open Tcpred4.nam w]
$ns namtrace-all $file2

#Define different colors for data flows (for NAM)

$ns color 1 Blue
$ns color 2 Red

set noOfNodes 16

set offset 45

set angle [expr -1*$offset*$noOfNodes/2]

for { set i 0} {$i < 16} { incr i } {
	set n($i) [$ns node]
}


for { set i 0} {$i < 16} { incr i } {

	$ns simplex-link $n($i) $n(0) 1Mb 100ms DropTail;

}

for { set i 0} {$i < 16} { incr i} {
	
	puts "[expr $i * $angle]"
	$ns simplex-link-op $n($i) $n(0) orient [expr $i * 24]deg

}


for { set i 0} {$i < 16} { incr i} {

	set udp($i) [new Agent/UDP]
	$ns attach-agent $n($i) $udp($i)
	set null($i) [new Agent/Null]
	$ns attach-agent $n(0) $null($i)
	$ns connect $udp($i) $null($i)
	$udp($i) set fid_ 2;

}


for { set i 0} {$i < 16} { incr i } {

	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) attach-agent $udp($i)
	$cbr($i) set type_ CBR
	$cbr($i) set packet_size_ 1000
	$cbr($i) set rate_ 0.01mb
	$cbr($i) set random_ false;
}


for { set i 0} {$i < 16} { incr i} {

	$ns at 0.1 "$cbr($i) start";


}






proc finish {} {
        global ns file1 file2
        $ns flush-trace
        close $file1
        close $file2
        exec nam Tcpred4.nam &
        exit 0
}

$ns at 12.0 "finish"
$ns run









$ns tcpred4.tcl
