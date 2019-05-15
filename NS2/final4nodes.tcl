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



set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]


$ns simplex-link $n1 $n0 1Mb 100ms DropTail
$ns simplex-link $n2 $n0 1.414Mb 100ms DropTail
$ns simplex-link $n3 $n0 1Mb 100ms DropTail

$ns simplex-link-op $n1 $n0 orient right
$ns simplex-link-op $n2 $n0 orient right-up
$ns simplex-link-op $n3 $n0 orient up


#Setup a UDP connection

set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a UDP connection

set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2
set null2 [new Agent/Null]
$ns attach-agent $n0 $null2
$ns connect $udp2 $null
$udp2 set fid_ 2

set udp3 [new Agent/UDP]
$ns attach-agent $n3 $udp3
set null3 [new Agent/Null]
$ns attach-agent $n0 $null3
$ns connect $udp3 $null
$udp3 set fid_ 2

#Setup a CBR over UDP connection

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01mb
$cbr set random_ false


set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 0.01mb
$cbr2 set random_ false

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$cbr3 set type_ CBR
$cbr3 set packet_size_ 1000
$cbr3 set rate_ 0.01mb
$cbr3 set random_ false

$ns at 0.1 "$cbr start"
$ns at 0.3 "$cbr2 start"
$ns at 0.5 "$cbr3 start"
$ns at 10 "$cbr stop"
$ns at 10.5 "$cbr2 stop"
$ns at 11 "$cbr3 stop"


#Define a 'finish' procedure

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

#----------How to run----------#

$ns tcpred4.tcl