ProtocolName=("default" "Elastic" "ElasticMod")

defaultTopo=500
defaultNode=40
defaultFlow=20
defaultSpeed=10
defaultPacket=200
defaultTx=1

# rm error.txt

for name in ${ProtocolName[@]}; do
    rm data-$name.csv
    echo "area,nodes,flows,speed,txRange,sent_packet,dropped_packet,received_packet,throughput,delay,delievery_ratio,drop_ratio,avgEnergy" >> data-$name.csv
    

    for node in 20 40 60 80 100
    do
    ns 1805107.tcl $defaultTopo $node $defaultFlow $name $defaultSpeed $defaultPacket $defaultTx || {
        echo "ERROR $defaultTopo $node $defaultFlow $name $defaultSpeed $defaultPacket $defaultTx" >> error.txt 
    }
    awk -f parse.awk trace.tr  >> data-$name.csv
    done

    for flow in 10 20 30 40 50
    do
    ns 1805107.tcl $defaultTopo $defaultNode $flow $name $defaultSpeed $defaultPacket $defaultTx|| {
        echo "ERROR $defaultTopo $defaultNode $flow $name $defaultSpeed $defaultPacket $defaultTx" >> error.txt 
    }
    awk -f parse.awk trace.tr  >> data-$name.csv
    done

    for speed in 5 10 15 20 25
    do
    ns 1805107.tcl $defaultTopo $defaultNode $defaultFlow $name $speed $defaultPacket $defaultTx || {
        echo "ERROR $defaultTopo $defaultNode $defaultFlow $name $speed $defaultPacket $defaultTx" >> error.txt 
    }
    awk -f parse.awk trace.tr  >> data-$name.csv
    done

    for txRange in 1 2 3 4 5
    do
    ns  1805107.tcl $defaultTopo $defaultNode $defaultFlow $name $defaultSpeed $defaultPacket $txRange || {
        echo "ERROR $defaultTopo $defaultNode $defaultFlow $name $defaultSpeed $defaultPacket $txRange" >> error.txt 
    }
    awk -f parse.awk trace.tr  >> data-$name.csv
    done
done
python plot2.py 5 "${ProtocolName[*]}" 11