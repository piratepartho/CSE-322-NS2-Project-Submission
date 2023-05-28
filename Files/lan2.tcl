
set val(stop)   40.0                         ;# time of simulation end
set num [lindex $argv 0]
set name [lindex $argv 1]

if {$name eq "default"} {
    set tcpAgentName "Agent/TCP"
} else {
    set tcpAgentName "Agent/TCP/$name"
}


set ns [new Simulator]

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

set filename "data-$name.csv"
set file [open $filename "a"]
puts -nonewline $file "$num,"

set err_module [new ErrorModel/Uniform 0.05 pkt]
$err_module drop-target [new Agent/Null]

set left [$ns node]
set right [$ns node]

$ns duplex-link $left $right 1Mb 100ms DropTail
$ns queue-limit $left $right 50
$ns lossmodel $err_module $left $right

for {set i 0} { $i < $num } { incr i } {
   set node($i) [$ns node]
   $ns duplex-link $node($i) $left 1000.0Mb 1ms DropTail
   $ns queue-limit $node($i) $left 50

   set node($i+$num) [$ns node]
   $ns duplex-link $node($i+$num) $right 1000.0Mb 10ms DropTail
   $ns queue-limit $node($i+$num) $right 50

   set tcp($i) [new $tcpAgentName]
   $ns attach-agent $node($i) $tcp($i)

   set tcpsink($i) [new Agent/TCPSink]
   $ns attach-agent $node($i+$num) $tcpsink($i)

   $ns connect $tcp($i) $tcpsink($i)
   $tcp($i) set packetSize_ 1000
   $tcp($i) set fid_ $i

   set ftp($i) [new Application/FTP]
#    $ftp($i) set
   $ftp($i) attach-agent $tcp($i) 
   
   $ns at 1.0 "$ftp($i) start"
   $ns at 39.0 "$ftp($i) stop"
}

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
$ns  at  0.0  "plotWindow $tcp(0)  $outfile"

proc finish {} {
    puts "Simulation Ending"
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
