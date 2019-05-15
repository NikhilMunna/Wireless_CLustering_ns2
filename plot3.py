import sys
import os
from pylab import *
import numpy as np

ext = "State2"

data = ["cluster"]

Direct = []
#change directory to your directory which can be found out using pwd command on terminal of linux OS
DIR = "D:/Studies/Sem-4/FCOMM/Project/My proj/"
for name in data:
    for file in os.listdir(DIR):
        if file.find(name + ext) >= 0 and file.endswith(".txt"):
            fname = DIR + '/' + file
            for line in open(fname).readlines():
                x = float(line.split()[0])
                y = float(line.split()[1])
                dead = float(line.split()[2])
                if (x == None or y == None or dead == None):
                    print('Error accured')
                if name == "cluster":
                    Direct.append([x,y,dead])


x_axisActive = []
y_axisActive = []

x_axisDead = []
y_axisDead = []

size = len(Direct)
for i in range(0,size):
    if (Direct[i][2] == 0):
        x_axisActive.append(Direct[i][0])
        y_axisActive.append(Direct[i][1])
    else:
        x_axisDead.append(Direct[i][0])
        y_axisDead.append(Direct[i][1])
    
#print size
# print(len(x_axisActive))
# print(len(y_axisActive))

#size = len(Modified) + 100000

# plot(x_axisActive, y_axisActive, '-r', label='Active')
# plot(x_axisActive, y_axisActive, '-r', label='Dead')
plt.scatter(x_axisActive,y_axisActive, c='blue')
plt.scatter(x_axisDead,y_axisDead, c='red')
xlabel('x-axis')
ylabel('y-axis')	
legend()
show()


