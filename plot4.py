import sys
import os
from pylab import *
import numpy as np
from mpl_toolkits.mplot3d import Axes3D

ext = "State1"

data = ["cluster2Layer"]

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
                if name == "cluster2Layer":
                    Direct.append([x,y,dead])

groundx_axisActive = []
groundy_axisActive = []

groundx_axisDead = []
groundy_axisDead = []

size = len(Direct) / 2
size = int(size)
for i in range(0,size):
    if (Direct[i][2] == 0):
        groundx_axisActive.append(Direct[i][0])
        groundy_axisActive.append(Direct[i][1])
    else:
        groundx_axisDead.append(Direct[i][0])
        groundy_axisDead.append(Direct[i][1])
    

layer2X_axisActive = []
layer2Y_axisActive = []

layer2X_axisDead = []
layer2Y_axisDead = []

for i in range(size,2*size):
    if (Direct[i][2] == 0):
        layer2X_axisActive.append(Direct[i][0])
        layer2Y_axisActive.append(Direct[i][1])
    else:
        layer2X_axisDead.append(Direct[i][0])
        layer2Y_axisDead.append(Direct[i][1])
        
#print size
# print(len(x_axisActive))
# print(len(y_axisActive))

#size = len(Modified) + 100000

# plot(x_axisActive, y_axisActive, '-r', label='Active')
# plot(x_axisActive, y_axisActive, '-r', label='Dead')

plt.subplot(1, 2, 1)
plt.scatter(groundx_axisActive,groundy_axisActive, c='blue')
plt.scatter(groundx_axisDead,groundy_axisDead, c='red')
xlabel('x-axis')
ylabel('y-axis')	
legend()

plt.subplot(1, 2, 2)
plt.scatter(layer2X_axisActive,layer2Y_axisActive, c='blue')
plt.scatter(layer2X_axisDead,layer2Y_axisDead, c='red')
xlabel('x-axis')
ylabel('y-axis')	
legend()
show()
