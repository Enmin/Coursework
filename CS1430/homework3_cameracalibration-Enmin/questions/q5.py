import numpy as np

q = [[0,0,1,1],
              [1,1,0,0],
              [1.5,0.5,0,0],
              [0,0,1.5,0.5],
              [2,1,0,0],
              [0,0,2,1],
              [2.5,2,0,0],
              [0,0,2.5,2]]
b1 = np.array([1.3,-0.3,0.5,1.1,0.3,1.8,-0.3,2.6])
b2 = [[1.3],[-0.3],[0.5],[1.1],[0.3],[1.8],[-0.3],[2.6]]
m = np.linalg.lstsq(q,b1, rcond=None)[0]
n = np.linalg.lstsq(q,b2, rcond=None)[0]
# n = np.dot(np.linalg.inv(np.dot(q.T, q)), np.dot(q.T, b))
print(m, n)