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
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

$ns simplex-link $n1 $n0 1Mb 100ms DropTail
$ns simplex-link $n2 $n0 1.414Mb 100ms DropTail
$ns simplex-link $n3 $n0 1Mb 100ms DropTail
$ns simplex-link $n4 $n0 1.414Mb 100ms DropTail
$ns simplex-link $n5 $n0 1Mb 100ms DropTail
$ns simplex-link $n6 $n0 1.414Mb 100ms DropTail
$ns simplex-link $n7 $n0 1Mb 100ms DropTail
$ns simplex-link $n8 $n0 1.414Mb 100ms DropTail

$ns simplex-link-op $n1 $n0 orient right
$ns simplex-link-op $n2 $n0 orient right-up
$ns simplex-link-op $n3 $n0 orient up
$ns simplex-link-op $n4 $n0 orient left-up
$ns simplex-link-op $n5 $n0 orient left
$ns simplex-link-op $n6 $n0 orient left-down
$ns simplex-link-op $n7 $n0 orient down
$ns simplex-link-op $n8 $n0 orient right-down



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

set udp4 [new Agent/UDP]
$ns attach-agent $n4 $udp4
set null4 [new Agent/Null]
$ns attach-agent $n0 $null4
$ns connect $udp4 $null4
$udp4 set fid_ 2

#Setup a UDP connection

set udp5 [new Agent/UDP]
$ns attach-agent $n5 $udp5
set null5 [new Agent/Null]
$ns attach-agent $n0 $null5
$ns connect $udp5 $null
$udp5 set fid_ 2

set udp6 [new Agent/UDP]
$ns attach-agent $n6 $udp6
set null6 [new Agent/Null]
$ns attach-agent $n0 $null6
$ns connect $udp6 $null
$udp6 set fid_ 2

set udp7 [new Agent/UDP]
$ns attach-agent $n7 $udp7
set null7 [new Agent/Null]
$ns attach-agent $n0 $null7
$ns connect $udp7 $null7
$udp7 set fid_ 2

#Setup a UDP connection

set udp8 [new Agent/UDP]
$ns attach-agent $n8 $udp8
set null8 [new Agent/Null]
$ns attach-agent $n0 $null8
$ns connect $udp8 $null
$udp8 set fid_ 2

#Setup a CBR over UDP connection

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.001mb
$cbr set random_ false


set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 0.001mb
$cbr2 set random_ false

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$cbr3 set type_ CBR
$cbr3 set packet_size_ 1000
$cbr3 set rate_ 0.001mb
$cbr3 set random_ false

set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $udp4
$cbr4 set type_ CBR
$cbr4 set packet_size_ 1000
$cbr4 set rate_ 0.001mb
$cbr4 set random_ false

set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $udp5
$cbr5 set type_ CBR
$cbr5 set packet_size_ 1000
$cbr5 set rate_ 0.001mb
$cbr5 set random_ false

set cbr6 [new Application/Traffic/CBR]
$cbr6 attach-agent $udp6
$cbr6 set type_ CBR
$cbr6 set packet_size_ 1000
$cbr6 set rate_ 0.001mb
$cbr6 set random_ false

set cbr7 [new Application/Traffic/CBR]
$cbr7 attach-agent $udp7
$cbr7 set type_ CBR
$cbr7 set packet_size_ 1000
$cbr7 set rate_ 0.001mb
$cbr7 set random_ false

set cbr8 [new Application/Traffic/CBR]
$cbr8 attach-agent $udp8
$cbr8 set type_ CBR
$cbr8 set packet_size_ 1000
$cbr8 set rate_ 0.001mb
$cbr8 set random_ false


$ns at 0.1 "$cbr start"
$ns at 0.2 "$cbr2 start"
$ns at 0.4 "$cbr3 start"
$ns at 0.6 "$cbr4 start"
$ns at 0.8 "$cbr5 start"
$ns at 1 "$cbr6 start"
$ns at 1.2 "$cbr7 start"
$ns at 1.4 "$cbr8 start"

$ns at 0.2 "$cbr stop"
$ns at 0.4 "$cbr2 stop"
$ns at 0.8 "$cbr3 stop"
$ns at 1 "$cbr4 stop"
$ns at 1.2 "$cbr5 stop"
$ns at 1.4 "$cbr6 stop"
$ns at 1.8 "$cbr7 stop"
$ns at 2 "$cbr8 stop"



#Define a 'finish' procedure

proc finish {} {
        global ns file1 file2
        $ns flush-trace
        close $file1
        close $file2
        exec nam Tcpred4.nam &
        exit 0
}

$ns at 20.0 "finish"
$ns run

#----------How to run----------#

$ns tcpred4.tcl