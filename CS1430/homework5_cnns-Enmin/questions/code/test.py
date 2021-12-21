import numpy as np
a = [[1,2], [3,4], [5,6]]
b = [[3,4,5]]
r = np.dot(b, a)
c = [[10, 10]]
r = r + c
ax = np.expand_dims(np.sum(r), axis=0)
print(np.array([1,2,3]) * 2)