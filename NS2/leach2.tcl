set ns [new Simulator]
#---Open the Trace files---#

set val(energymodel) EnergyModel
set val(initialenergy) 50

set file1 [open Tracfil.tr w]
$ns trace-all $file1

#--Open the NAM trace file----#

set file2 [open Tracfil.nam w]
$ns namtrace-all $file2
#Define different colors for data flows (for NAM)

$ns color 1 Black
$ns color 2 dodgerblue

for { set i 0} {$i < 8} { incr i } {
	set n($i) [$ns node]
}
for { set i 0} {$i < 8} { incr i } {
	set energy($i) 50.0;
}

set cluster_head 0;
set trapow 0.5
set recpow 0.1
set tx_cluster 4
set noofRounds 8
set enermax 0
set timer 0;

#energy consumption for all rounds
$ns simplex-link $n($cluster_head) $n(7) 1Mb 100ms DropTail
$ns simplex-link-op $n($cluster_head) $n(7) orient up
		set udp(7) [new Agent/UDP]
		$ns attach-agent $n($cluster_head) $udp(7)
		set null(7) [new Agent/Null]
		$ns attach-agent $n(7) $null(7)
		$ns connect $udp(7) $null(7)
		$udp(7) set fid_ 2;		
# Assign consbitrate
		set consbitrate(8) [new Application/Traffic/CBR]
		$consbitrate(8) attach-agent $udp(7)
		$consbitrate(8) set type_ CBR
		$consbitrate(8) set packet_size_ 500
		$consbitrate(8) set rate_ 0.01mb
		$consbitrate(8) set random_ false
for  {set k 1} {$k < $noofRounds} {incr k} {	
	for { set i 0} {$i < 7} { incr i } {
		if { $i != $cluster_head} {						
			$ns simplex-link $n($i) $n($cluster_head) 1Mb 100ms DropTail;

		}
	}
#Setup a UDP connection
	for { set i 0} {$i < 7} { incr i} {
		set udp($i) [new Agent/UDP]
		$ns attach-agent $n($i) $udp($i)
		set null($i) [new Agent/Null]
		$ns attach-agent $n($cluster_head) $null($i)
		$ns connect $udp($i) $null($i) 
		$udp($i) set fid_ 2;
	}		
#Setup a CBR over UDP connection
	for { set i 0} {$i < 7} { incr i } {

		set consbitrate($i) [new Application/Traffic/CBR]
		$consbitrate($i) attach-agent $udp($i)
		$consbitrate($i) set type_ CBR
		$consbitrate($i) set packet_size_ 500
		$consbitrate($i) set rate_ 0.01mb
		$consbitrate($i) set random_ false;
	}
	for { set i 0} {$i < 7} { incr i } {
		if { $i != $cluster_head} {			
			
			set  energy($i)  [expr $energy($i) - $trapow];
		} else {
			# energy consumption of cluster head for recieving 
			set energy($cluster_head)  [expr $energy($cluster_head) - [expr $recpow * 6]]
			
		}
	}
#energy consumption for transmitting from cluster head to sink
set energy($cluster_head)  [expr $energy($cluster_head) -  $tx_cluster]
# starting the cluster nodes
		for { set i 0} {$i < 7} { incr i } {
			if { $i != $cluster_head} {						
				$ns at $timer "$consbitrate($i) start"
				set timer  [expr $timer + 0.05 ]
				$ns at $timer "$consbitrate($i) stop"
				set timer  [expr $timer + 0.05 ]		
			}
		}
# starting and stopping the cluster head
		$ns at  $timer "$consbitrate(8) start"
		set timer  [expr $timer + 0.05 ]
		$ns at  $timer "$consbitrate(8) stop"
		set timer  [expr $timer + 0.05 ]
		for { set i 0} {$i < 7} { incr i } {

			if {$energy($i) > $energy($enermax)} {
				set enermax $i;
			}
		}
				
		set cluster_head $enermax		
		puts "$enermax";
$ns simplex-link $n($cluster_head) $n(7) 1Mb 100ms DropTail 
$ns simplex-link-op $n($cluster_head) $n(7) orient up 
#Setup a UDP connection for cluster head to sink

		set udp(7) [new Agent/UDP]
		$ns attach-agent $n($cluster_head) $udp(7)
		set null(7) [new Agent/Null]
		$ns attach-agent $n(7) $null(7)
		$ns connect $udp(7) $null(7)
		$udp(7) set fid_ 2;		
# Assign consbitrate
		set consbitrate(8) [new Application/Traffic/CBR]
		$consbitrate(8) attach-agent $udp(7)
		$consbitrate(8) set type_ CBR
		$consbitrate(8) set packet_size_ 500
		$consbitrate(8) set rate_ 0.01mb
		$consbitrate(8) set random_ false
}
puts "Energyy %.4f, $energy(0)";
puts "Energyy %.4f, $energy(1)";
puts "Energyy %.4f, $energy(2)";
puts "Energyy %.4f, $energy(3)";
puts "Energyy %.4f, $energy(4)";
puts "Energyy %.4f, $energy(5)";
puts "Energyy %.4f, $energy(6)";
puts "Energyy %.4f, $energy(7)";

#Define a 'finish' procedure

proc finish {} {
        global ns file1 file2
        $ns flush-trace
        close $file1
        close $file2
        exec nam Tracfil.nam & 
        exit 0
}

$ns at 12.0 "finish"
$ns run

