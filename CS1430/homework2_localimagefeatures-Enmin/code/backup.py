def get_features(image, x, y, feature_width):
    x, y = y, x
    
    size = int(feature_width//4)

    # Calculate the Ix, Iy gradient vector
    Ix = cv2.Sobel(image, cv2.CV_32F, 1, 0, ksize=5)
    Iy = cv2.Sobel(image, cv2.CV_32F, 0, 1, ksize=5)
    
    # Calculate the descriptors
    descriptors = np.zeros((x.shape[0], 128))
    
    for i,(kx, ky)  in enumerate(zip(x,y)):
        descriptors[i] = single_128_feature_vector(Ix, Iy, int(kx), int(ky), size)
    
    return descriptors

    #############################################################################
    #                             END OF YOUR CODE                              #
    #############################################################################

def single_128_feature_vector(Ix, Iy, kx, ky, size):
    descriptor = []
    for ix in range(-2,2):
        for iy in range(-2,2):
            locx , locy =  kx + ix*size, ky + iy*size
            histogram8 = np.zeros(8)
            for x in range(size):
                for y in range(size):
                    indx = int(locx)
                    indy = int(locy)
                    mag = np.sqrt(Ix[indx+x, indy+y]**2 + Iy[indx+x, indy+y]**2)
                    phase = np.arctan2(Iy[indx+x, indy+y],Ix[indx+x, indy+y])*180/np.pi

                    phase = phase + 360 if phase<0 else phase  # convert from -180 --> 180 to 0 to 360
                    left =  int(phase//45)  
                    right = int(phase//45 + 1)  # if phase>325, right = 360

                    pixel_histogram = np.zeros(9)  # padding 360 deg at the end to transform to [...,225,270,325,360]
                    # Separate the vector into 2 nearby angles
                    pixel_histogram[right] =mag*(phase-45*left)/45
                    pixel_histogram[left] =mag*(45*right-phase)/45
                    pixel_histogram[0] += pixel_histogram[8]  # If the right = 8 or phase = 360, then it is equivalent to add to 0

                    histogram8 = histogram8 + pixel_histogram[:8]
            descriptor.append(histogram8)

    descriptor = np.array(descriptor).flatten()

    #Normalize the descriptor
    descriptor = descriptor / np.linalg.norm(descriptor) 
    descriptor = np.clip(descriptor, 0, 0.2)
    descriptor = descriptor / np.linalg.norm(descriptor)

    return descriptor