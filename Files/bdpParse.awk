BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    # total_energy_consumed = 0;
    start_time = 1000000;
    end_time = 0;
    # initial_energy = 1000;
    # constants
    header_bytes = 20;
    # total_nodes = nodes;
    # for (i = 0; i < total_nodes; i++) {
    #     energy_consumed[i]=0;
    # }
}


{
    event = $1;
    time_sec = $2;
    from_node = $3;
    to_node = $4;
    packet_type = $5;
    packet_bytes = $6;
    source= $9;
    destination= $10;
    packet_id = $12;


    sub(/^_*/, "", node);
	sub(/_*$/, "", node);

    if(start_time > time_sec) {
        start_time = time_sec;
    }
    
    if (packet_type == "tcp") {
        source=int(source);
        destination=int(destination);
        if(event == "+" && from_node==source) {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        else if(event == "r" && to_node==destination) {
            delay = time_sec - sent_time[packet_id];
            
            total_delay += delay;


            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;

            # print destination","to_node;
            received_packets += 1;
        }
    }

    if (packet_type == "tcp" && event == "d") {
        dropped_packets += 1;
    }
}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;
    throughput=(received_bytes * 8) / simulation_time;
    avg_delay=total_delay / received_packets;
    delivery_ratio=received_packets / sent_packets;
    drop_ratio=dropped_packets / sent_packets;
     
    print  sent_packets","dropped_packets","received_packets","throughput","avg_delay","delivery_ratio","drop_ratio;
    # print "Sent Packets: ", sent_packets;
    # print "Dropped Packets: ", dropped_packets;
    # print "Received Packets: ", received_packets;

    # print "-------------------------------------------------------------";
    # print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    # print "Average Delay: ", (total_delay / received_packets), "seconds";
    # print "Delivery ratio: ", (received_packets / sent_packets);
    # print "Drop ratio: ", (dropped_packets / sent_packets);

}