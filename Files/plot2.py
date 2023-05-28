from pandas import read_csv
import matplotlib.pyplot as plt
import sys
import os

iter = int(sys.argv[1])
args = sys.argv[2].split(' ')
mac = int(sys.argv[3])

d={}

for protocol in args:
    d[protocol] = read_csv(f"data-{protocol}.csv",delimiter=',')
    d [protocol] ['throughput'] = d [protocol] ['throughput'] / 1024

# for i in d.keys:
#     print(i)

# xLabels = ["Area(m)","# of Nodes", "# of Flows"]
xLabels = ["# of Nodes", "# of Flows","Speed(m/s)","x txRange"]                        
yLabels = ["Thorughput (Kbits/sec)","Delay(sec)","Packet Delievery Ratio","Packet Drop Ratio","Energy Per Node"]
# xHeader = ['area','nodes','flows']
xHeader = ['nodes','flows','speed',"txRange"]
yHeader = ['throughput','delay','delievery_ratio','drop_ratio','avgEnergy']

# if not os.path.exists("images/") == 0 :
#     os.makedirs("images/")

print(type(mac), mac)

if(os.path.exists(f"images/{mac}/") == 0):
    os.makedirs(f"images/{mac}/")


for x in range(len(xLabels)):
    for y in range(len(yLabels)):
        plt.xlabel(xLabels[x])
        plt.ylabel(yLabels[y])
        for protocol in args:
            plt.plot(d[protocol][xHeader[x]][x*iter : x*iter+iter], d[protocol][yHeader[y]][x*iter : x*iter+iter], marker='o',label=str(protocol))
        plt.legend()
        if mac == 154 and xHeader[x] == 'speed':
            print('here')
            plt.clf()
            continue
        plt.savefig(f"images/{mac}/"+yHeader[y]+" vs "+xHeader[x])
        # plt.show()
        plt.clf() 


