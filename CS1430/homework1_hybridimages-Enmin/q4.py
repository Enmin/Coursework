import time 
import matplotlib.pyplot as plt
from skimage import io, img_as_float32
#use to rescale+resize image
from skimage.transform import rescale, resize
#use to convolve/correlate image
from scipy.ndimage import correlate
import numpy as np

#This reads in image and converts to a floating point format
# 1) TODO - replace PATH with the actual path to the 
#    downloaded RISDance.jpg image linked above
image = img_as_float32(io.imread('./questions/RISDance.jpg'))

# 2) TODO - change the image size so it starts at 8MPix 
#    use one of the imported libraries
original_image = resize(image, (4096, 2048))

# 3) TODO - iterate through odd numbers from 3 to 15
#   (inclusive!!) these will represent your filter sizes
#   (3x3,5x5,7x7, etc.), for each filter size you will...
for kernel_size in range(3, 16, 2):

    #because for each loop you are resizing your image, you 
    #want to start each loop w/the original image size
    shrinking_image = original_image 
    
    #these lists will hold the values you plot
    image_sizes = [] #x axis
    times = [] #y axis

    #while image size is bigger than .25MPx
    while(shrinking_image.size > 250000):
    
    	# 4) TODO - create your kernel. Your kernel can hold
    	#    any values, as the kernel values shouldn't 
    	#    affect computation time. The size of the kernel
    	#    must be kernel_size x kernel_size
        kernel = np.array([[1 for _ in range(kernel_size)] for _ in range(kernel_size)])
        
        #5) TODO - reduce your image size. You can choose by 
        # what increments to reduce your image.
        shrinking_image = rescale(shrinking_image, (0.25, 0.25, 1))

        #gets the current time (in seconds)
        start = time.time() 
        
        # 6) TODO - use one of the imported libraries to do 
        # your correlation/convolution on the image. You can 
        # choose which operation to perform.
        conv = correlate(shrinking_image, np.array([kernel, kernel, kernel]))
        
        
        #gets the current time (in seconds)
        end = time.time() 
        
        #7) TODO - figure out what values to append, and 
        #   append them here
        image_sizes.append(shrinking_image.size)
        times.append(end - start)
    
    #each filter size will be plotted as a separate line, in 
    #a multi-line 2-dimensional graph
    plt.plot(image_sizes, times, label=str(kernel.size))

#plot
plt.xlabel('image size (pixels)')
plt.ylabel('operation time (seconds)')
plt.legend(title="filter sizes (pixels)")
plt.show()