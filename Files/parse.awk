BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants
    header_bytes = 20;
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    energy_receive = $22;
    energy_transmit = $20;
    

    if(event == "D" || event == "r" || event == "s"){
        sub(/^_*/, "", node);
        sub(/_*$/, "", node);

        if(start_time > time_sec) {
            start_time = time_sec;
        }

        if (layer == "AGT" && packet_type == "tcp") {
            
            if(event == "s") {
                sent_time[packet_id] = time_sec;
                sent_packets += 1;
                energy_cost[node] = energy_receive + energy_transmit
            }

            else if(event == "r") {
                delay = time_sec - sent_time[packet_id];
                total_delay += delay;
                bytes = (packet_bytes - header_bytes);
                received_bytes += bytes;
                received_packets += 1;
                energy_cost[node] = energy_receive + energy_transmit
            }
        }
        if (packet_type == "tcp" && event == "D") {
            dropped_packets += 1;
        }

        if(time_sec > end_time){
            end_time = time_sec;
        }
    }
}


END {
    simulation_time = end_time - start_time;
    throughput = (received_bytes * 8) / simulation_time;
    average_delay = (total_delay / received_packets);
    delivery_ratio = (received_packets / sent_packets);
    drop_ratio = (dropped_packets / sent_packets);
    
    total_energy = 0;
    nodeCount = 0;
    for (node in energy_cost) {
        total_energy+=energy_cost[node];
        nodeCount+=1;
    }
    average_energy = total_energy / nodeCount;


    # print "Sent Packets: ", sent_packets;
    # print "Dropped Packets: ", dropped_packets;
    # print "Received Packets: ", received_packets;

    # print "-------------------------------------------------------------";
    # print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    # print "Average Delay: ", (total_delay / received_packets), "seconds";
    # print "Delivery ratio: ", (received_packets / sent_packets);
    # print "Drop ratio: ", (dropped_packets / sent_packets);

    print  sent_packets","dropped_packets","received_packets","throughput","average_delay","delivery_ratio","drop_ratio","average_energy;

}