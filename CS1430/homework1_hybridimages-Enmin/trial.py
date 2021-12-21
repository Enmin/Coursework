from scipy import ndimage
import matplotlib.pyplot as plt
from skimage import io
import numpy as np

kernel = np.array([[1, 1, -1, -1],
                [1,  1, -1, -1],
                [1, 1, -1, -1],
                [1, 1, -1, -1]])
#I =  io.imread('./questions/q3img0.png')
I = a = np.array([[1, 1, 0, 0],
              [1, 1, 0, 0],
              [1, 1, 0, 0],
              [1, 1, 0, 0]])
cor =  ndimage.correlate(I, kernel)
cov = ndimage.convolve(I, kernel)
plt.imshow( I )
plt.savefig("original.png")
plt.imshow( cov )
plt.savefig("convolve.png")
plt.imshow( cor )
plt.savefig("correlate.png")