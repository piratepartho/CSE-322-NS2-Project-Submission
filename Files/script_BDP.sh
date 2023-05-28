ProtocolName=("default" "Elastic" "ElasticMod")


# rm error.txt

for name in ${ProtocolName[@]}; do
    rm data-$name.csv
    echo "nodes,sent_packet,dropped_packet,received_packet,throughput,delay,delievery_ratio,drop_ratio" >> data-$name.csv 
    for node in 100 150 200 250 300
    do
    ns lan2.tcl $node $name || {
        echo "ERROR $node $name" >> error.txt 
    }
    awk -f bdpParse.awk out.tr >> data-$name.csv
    done
done

python plotBDP.py 5 "${ProtocolName[*]}"
