set ns [new Simulator]
#---Open the Trace files---#

set val(energymodel) EnergyModel
set val(initialenergy) 100


set file1 [open Tcpred4.tr w]
$ns trace-all $file1

#--Open the NAM trace file----#

set file2 [open Tcpred4.nam w]
$ns namtrace-all $file2

$ns node-config -energyModel $val(energymodel) \
		-initialEnergy $val(initialenergy) \
		-rxPower 35.28e-3 \
		-txPower 31.32e-3 \
		-idlePower 712e-6 \
		-sleepPower 144e-9 

set energ 0;

#Define different colors for data flows (for NAM)

$ns color 1 Blue
$ns color 2 Red


for { set i 0} {$i < 7} { incr i } {
	set n($i) [$ns node]
}



for { set i 0} {$i < 7} { incr i } {

	set energy($i) 100.0;
}

set cluster_head 0;

set tx 0.5
set rx 0.1
set tx_cluster 2.5
set noOfRounds 10
set max 0

set timer 0;

#energy consumption for all rounds


$ns simplex-link $n($cluster_head) $n(6) 1Mb 100ms DropTail

$ns simplex-link-op $n($cluster_head) $n(6) orient up

		set udp(6) [new Agent/UDP]
		$ns attach-agent $n($cluster_head) $udp(6)
		set null(6) [new Agent/Null]
		$ns attach-agent $n(6) $null(6)
		$ns connect $udp(6) $null(6)
		$udp(6) set fid_ 2;

		
# Assign cbr
		set cbr(7) [new Application/Traffic/CBR]
		$cbr(7) attach-agent $udp(6)
		$cbr(7) set type_ CBR
		$cbr(7) set packet_size_ 1000
		$cbr(7) set rate_ 0.01mb
		$cbr(7) set random_ false



for  {set k 1} {$k < $noOfRounds} {incr k} {


		
	for { set i 0} {$i < 6} { incr i } {
		if { $i != $cluster_head} {						
			$ns simplex-link $n($i) $n($cluster_head) 1Mb 100ms DropTail;

		}
	}

		
#	for { set i 0} {$i < 6} { incr i } {
#		if { $i != $cluster_head} {						
#			$ns simplex-link-op $n($i) $n($cluster_head) orient [expr $i * 72]deg
#		}
#	}



		
	#Setup a UDP connection
	for { set i 0} {$i < 6} { incr i} {

		set udp($i) [new Agent/UDP]
		$ns attach-agent $n($i) $udp($i)
		set null($i) [new Agent/Null]
		$ns attach-agent $n($cluster_head) $null($i)
		$ns connect $udp($i) $null($i)
		$udp($i) set fid_ 2;

	}



		
	#Setup a CBR over UDP connection

	for { set i 0} {$i < 6} { incr i } {

		set cbr($i) [new Application/Traffic/CBR]
		$cbr($i) attach-agent $udp($i)
		$cbr($i) set type_ CBR
		$cbr($i) set packet_size_ 1000
		$cbr($i) set rate_ 0.01mb
		$cbr($i) set random_ false;
	}


	for { set i 0} {$i < 6} { incr i } {
		if { $i != $cluster_head} {			
			
			set  energy($i)  [expr $energy($i) - $tx];
		} else {
			# energy consumption of cluster head for recieving 
			set energy($cluster_head)  [expr $energy($cluster_head) - [expr $rx * 5]]

			
		}

	}
#energy consumption for transmitting from cluster head to sink

set energy($cluster_head)  [expr $energy($cluster_head) -  $tx_cluster]

# starting the cluster nodes

		for { set i 0} {$i < 6} { incr i } {
			if { $i != $cluster_head} {						
				$ns at $timer "$cbr($i) start"
				set timer  [expr $timer + 0.2 ]
				$ns at $timer "$cbr($i) stop"
				set timer  [expr $timer + 0.2 ]		
			}
		}
# starting and stopping the cluster head
		$ns at  $timer "$cbr(7) start"
		set timer  [expr $timer + 0.2 ]
		$ns at  $timer "$cbr(7) stop"
		set timer  [expr $timer + 0.2 ]




		for { set i 0} {$i < 6} { incr i } {

			if {$energy($i) > $energy($max)} {
				set max $i;
			}
		}
				
		set cluster_head $max		
		puts "$max";


$ns simplex-link $n($cluster_head) $n(6) 1Mb 100ms DropTail
$ns simplex-link-op $n($cluster_head) $n(6) orient up



#Setup a UDP connection for cluster head to sink

		set udp(6) [new Agent/UDP]
		$ns attach-agent $n($cluster_head) $udp(6)
		set null(6) [new Agent/Null]
		$ns attach-agent $n(6) $null(6)
		$ns connect $udp(6) $null(6)
		$udp(6) set fid_ 2;

		
# Assign cbr
		set cbr(7) [new Application/Traffic/CBR]
		$cbr(7) attach-agent $udp(6)
		$cbr(7) set type_ CBR
		$cbr(7) set packet_size_ 1000
		$cbr(7) set rate_ 0.01mb
		$cbr(7) set random_ false



}


puts "Energyy %.4f, $energy(0)";
puts "Energyy %.4f, $energy(1)";
puts "Energyy %.4f, $energy(2)";
puts "Energyy %.4f, $energy(3)";
puts "Energyy %.4f, $energy(4)";
puts "Energyy %.4f, $energy(5)";

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
