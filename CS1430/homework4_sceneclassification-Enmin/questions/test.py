import numpy as np
a ,b, c = 1, 2, 3
l = [a,b,c,4]
nl = np.array([a,b,c,4])
for i in range(6):
  
  print("L: " + str(id(l[1])))
  print("NP: " + str(id(nl[1])))