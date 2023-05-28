set name [lindex $argv 0]
if {$name eq "default"} {
    set tcpAgentName "Agent/TCP"
} else {
    set tcpAgentName "Agent/TCP/$name"
}


set val(stop)   40.0                         ;# time of simulation end




set val(stop)   40.0                         ;# time of simulation end

set ns [new Simulator]

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 12 nodes
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]
set n15 [$ns node]

proc UniformErr {} {
    set err [new ErrorModel/Uniform ]
}

#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n4 $n9 1000.0Mb 10ms DropTail
$ns queue-limit $n4 $n9 50
$ns duplex-link $n9 $n5 1000.0Mb 10ms DropTail
$ns queue-limit $n9 $n5 50
$ns duplex-link $n6 $n9 1000.0Mb 10ms DropTail
$ns queue-limit $n6 $n9 50
$ns duplex-link $n7 $n9 1000.0Mb 10ms DropTail
$ns queue-limit $n7 $n9 50
$ns duplex-link $n8 $n9 1000.0Mb 10ms DropTail
$ns queue-limit $n8 $n9 50
$ns duplex-link $n10 $n11 1000.0Mb 10ms DropTail
$ns queue-limit $n10 $n11 50
$ns duplex-link $n10 $n12 1000.0Mb 10ms DropTail
$ns queue-limit $n10 $n12 50
$ns duplex-link $n10 $n13 1000.0Mb 10ms DropTail
$ns queue-limit $n10 $n13 50
$ns duplex-link $n10 $n14 1000.0Mb 10ms DropTail
$ns queue-limit $n10 $n14 50
$ns duplex-link $n10 $n15 1000.0Mb 10ms DropTail
$ns queue-limit $n10 $n15 50
$ns duplex-link $n9 $n10 .1Mb 10ms DropTail
$ns queue-limit $n9 $n10 50

#Give node position (for NAM)
$ns duplex-link-op $n4 $n9 orient right-down
$ns duplex-link-op $n9 $n5 orient left-up
$ns duplex-link-op $n6 $n9 orient right
$ns duplex-link-op $n7 $n9 orient right-up
$ns duplex-link-op $n8 $n9 orient right-up
$ns duplex-link-op $n10 $n11 orient right-up
$ns duplex-link-op $n10 $n12 orient right-up
$ns duplex-link-op $n10 $n13 orient right-up
$ns duplex-link-op $n10 $n14 orient right-down
$ns duplex-link-op $n10 $n15 orient right-down
$ns duplex-link-op $n9 $n10 orient right

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp3 [new $tcpAgentName]
$ns attach-agent $n4 $tcp3
set sink13 [new Agent/TCPSink]
$ns attach-agent $n11 $sink13
$ns connect $tcp3 $sink13
$tcp3 set packetSize_ 1000

#Setup a TCP connection
set tcp4 [new $tcpAgentName]
$ns attach-agent $n5 $tcp4
set sink14 [new Agent/TCPSink]
$ns attach-agent $n12 $sink14
$ns connect $tcp4 $sink14
$tcp4 set packetSize_ 1000

#Setup a TCP connection
set tcp5 [new $tcpAgentName]
$ns attach-agent $n6 $tcp5
set sink15 [new Agent/TCPSink]
$ns attach-agent $n13 $sink15
$ns connect $tcp5 $sink15
$tcp5 set packetSize_ 1000

#Setup a TCP connection
set tcp6 [new $tcpAgentName]
$ns attach-agent $n7 $tcp6
set sink16 [new Agent/TCPSink]
$ns attach-agent $n14 $sink16
$ns connect $tcp6 $sink16
$tcp6 set packetSize_ 1000

#Setup a TCP connection
set tcp7 [new $tcpAgentName]
$ns attach-agent $n8 $tcp7
set sink17 [new Agent/TCPSink]
$ns attach-agent $n15 $sink17
$ns connect $tcp7 $sink17
$tcp7 set packetSize_ 1000


#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp3
$ns at 1.0 "$ftp2 start"
$ns at 39.0 "$ftp2 stop"

#Setup a FTP Application over TCP connection
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp4
$ns at 1.0 "$ftp3 start"
$ns at 39.0 "$ftp3 stop"

#Setup a FTP Application over TCP connection
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp5
$ns at 1.0 "$ftp4 start"
$ns at 39.0 "$ftp4 stop"

#Setup a FTP Application over TCP connection
set ftp5 [new Application/FTP]
$ftp5 attach-agent $tcp6
$ns at 1.0 "$ftp5 start"
$ns at 39.0 "$ftp5 stop"

#Setup a FTP Application over TCP connection
set ftp6 [new Application/FTP]
$ftp6 attach-agent $tcp7
$ns at 1.0 "$ftp6 start"
$ns at 39.99 "$ftp6 stop"



proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now,$cwnd"
   $ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
}

set outfile [open  "congestion-$name.csv"  w]
puts $outfile "time,cwnd"
$ns  at  0.0  "plotWindow $tcp3  $outfile"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    # exec nam out.nam &
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
