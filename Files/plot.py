import sys
import matplotlib.pyplot as plt
import pandas as pd

print(sys.argv[1].split(' '))

for arg in sys.argv[1].split(' '):
    d = pd.read_csv('congestion-'+arg+'.csv',delimiter=',')
    plt.plot(d['time'], d['cwnd'], label=arg)

plt.xlabel('time')
plt.ylabel('cwnd')
plt.legend()
plt.savefig(f"images/cwnd")
plt.show()
