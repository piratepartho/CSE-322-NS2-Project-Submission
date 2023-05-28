set name [lindex $argv 3]
if {$name eq "default"} {
    set tcpAgentName "Agent/TCP"
} else {
    set tcpAgentName "Agent/TCP/$name"
}

set speed [lindex $argv 4]
set packetSize [lindex $argv 5]
set tx [lindex $argv 6]
puts $tx

set ns [new Simulator]

set topoSize [lindex $argv 0]

set val(nn) 40
set val(nn) [lindex $argv 1]

set val(nf) 20
set val(nf) [lindex $argv 2]

set filename "data-$name.csv"
set file [open $filename "a"]
puts -nonewline $file "$topoSize,$val(nn),$val(nf),$speed,$tx,"

set simulationTime 30

set packetSize [lindex $argv 5]

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11            ;# MAC type
set val(rp)           DSDV                     ;# ad-hoc routing protocol 
# =======================================================================

set trace_file [open trace.tr w]
$ns trace-all $trace_file

set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file $topoSize $topoSize

set topo [new Topography]
$topo load_flatgrid $topoSize $topoSize 

set outfile [open "congestion-$name.csv" w]
puts $outfile "time,cwnd"

set rng [new RNG]
$rng seed 7

set pt [Phy/WirelessPhy set Pt_]
set pt [expr $pt * $tx * $tx * $tx * $tx]
Phy/WirelessPhy set Pt_ $pt


create-god $val(nn)

proc UniformErr {} {
    set err [new ErrorModel/Uniform 0.05 pkt]
    return $err
}

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF \
                -energyModel EnergyModel \
                -initialEnergy 1000 \
                -IncomingErrProc UniformErr \
                -OutgoingErrProc UniformErr \

# create nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    $node($i) set X_ [ $rng uniform 0.0 $topoSize ]
    $node($i) set Y_ [ $rng uniform 0.0 $topoSize ]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20
    $ns at 0.0 "$node($i) setdest [$rng uniform 0.0 $topoSize] [$rng uniform 0.0 $topoSize] $speed"
} 



for {set i 0} {$i < $val(nf)} {incr i} {
    set dest [expr int(floor([$rng uniform 0 $val(nn)]))]
    set src $dest
    while {$src == $dest} {
        set src [expr int(floor([$rng uniform 0 $val(nn)]))]
    }
    # puts "source ($src) $dest"


    set tcp [new $tcpAgentName]
    $ns attach-agent $node($src) $tcp
    # $tcp set maxseq_ $packetSize
    $tcp attach $trace_file
    $tcp tracevar cwnd_

    set sink [new Agent/TCPSink]
    $ns attach-agent $node($dest) $sink 

    if {$i eq 1} {
        $ns  at  0.0  "plotWindow $tcp $outfile"
    }

    $ns connect $tcp $sink
    $tcp set fid_ $i

    set ftp [new Application/FTP]
    $ftp attach-agent $tcp

    # $e set packetSize_ 150
    # $e set burst_time_ 500ms
    # $e set idle_time_ 500ms
    # $e set rate_ 100k
    
    $ns at 0.0 "$ftp start"
    $ns at 50.0 "$ftp stop"
    }



# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $simulationTime "$node($i) reset"
}

proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

# the data is recorded in a file called congestion.xg (this can be plotted # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
   puts  $outfile  "$now,$cwnd"
   $ns at [expr $now+0.05] "plotWindow $tcpSource  $outfile"
}


# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at $simulationTime+.01 "finish"
$ns at $simulationTime+.01 "halt_simulation"



# Run simulation
# puts "Simulation starting"
$ns run

# area,nodes,flows,throughput,delay,delievery_ratio,drop_ratio
# }