ProtocolName=("default" "Elastic" "ElasticMod")

for i in ${ProtocolName[@]}; do
# echo $i 
    ns cwnd.tcl $i
done

python plot.py "${ProtocolName[*]}"