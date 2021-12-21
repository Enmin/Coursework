import numpy as np
img1 = [[[0,1,1], [1,1,1], [1,1,1]],
        [[1,1,1], [1,1,1], [1,1,1]],
        [[1,1,1], [1,1,1], [1,1,1]]]
img1 = np.array(img1)
img2 = 2 * img1
img3 = 3* img1
a = np.array([img1, img2, img3])
m = a[:,:,0]
print(m.flatten())