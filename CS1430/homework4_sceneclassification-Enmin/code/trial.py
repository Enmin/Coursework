import numpy as np
import matplotlib
import time
from matplotlib import pyplot as plt
from helpers import progressbar
from skimage import io
from skimage.io import imread
from skimage.color import rgb2grey
from skimage.feature import hog
from skimage.transform import resize
from scipy.spatial.distance import cdist

def get_tiny_images(image_paths):
    #TODO: Implement this function!
    output = []
    for image_path in image_paths:
        image = imread(image_path)
        if len(image.shape) > 2:
            image = rgb2grey(image)
        image = resize(image, output_shape=(64, 64), anti_aliasing=True)
        output.append(image)

    return np.array(output)

# res = get_tiny_images([r'..\data\train\Bedroom\image_0002.jpg'])
# io.imshow(res[0])
# plt.show()

def build_vocab():
    num_imgs = 1000
    for i in progressbar(range(num_imgs), "Loading ...", num_imgs):
        pass

build_vocab()