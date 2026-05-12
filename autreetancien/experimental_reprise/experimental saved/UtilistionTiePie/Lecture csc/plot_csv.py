import csv
import matplotlib.pyplot as plt
import sys
import os 

sys.path.append(os.path.abspath("/home/manip/Documents/UtilistionTiePie"))

t_index = []
Ch1 = []; 
Ch2 = [];
with open('OscilloscopeBlock.csv','r') as f:
	reader = csv.reader(f,delimiter=':')
	n = 0 #numero de la ligne
	for row in reader:
		row = row[0] # recuperer la string 
		row = row.split(',') # cree la liste 
		if n>1 : # la premier ligne c est des titres
			t_index.append(int(row[0]))
			Ch1.append(float(row[1]))
			Ch1.append(float(row[2]))
		n=n+1
	#end for
#end lecture


plt.plot(Ch1)
plt.show()
			
		
