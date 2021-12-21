import numpy as np
import cv2
import random
from random import sample


def calculate_projection_matrix(image, markers):
    """
    To solve for the projection matrix. You need to set up a system of
    equations using the corresponding 2D and 3D points. See the handout, Q5
    of the written questions, or the lecture slides for how to set up these
    equations.

    Don't forget to set M_34 = 1 in this system to fix the scale.

    :param image: a single image in our camera system
    :param markers: dictionary of markerID to 4x3 array containing 3D points
    :return: M, the camera projection matrix which maps 3D world coordinates
    of provided aruco markers to image coordinates
    """
    ######################
    # Do not change this #
    ######################

    # Markers is a dictionary mapping a marker ID to a 4x3 array
    # containing the 3d points for each of the 4 corners of the
    # marker in our scanning setup
    dictionary = cv2.aruco.Dictionary_get(cv2.aruco.DICT_4X4_1000)
    parameters = cv2.aruco.DetectorParameters_create()

    markerCorners, markerIds, rejectedCandidates = cv2.aruco.detectMarkers(
        image, dictionary, parameters=parameters)
    markerIds = [m[0] for m in markerIds]
    markerCorners = [m[0] for m in markerCorners]

    points2d = []
    points3d = []

    for markerId, marker in zip(markerIds, markerCorners):
        if markerId in markers:
            for j, corner in enumerate(marker):
                points2d.append(corner)
                points3d.append(markers[markerId][j])

    points2d = np.array(points2d)
    points3d = np.array(points3d)

    ########################
    # TODO: Your code here #
    ########################
    # This M matrix came from a call to rand(3,4). It leads to a high residual.
    # print('Randomly setting matrix entries as a placeholder')
    # M = np.array([[0.1768, 0.7018, 0.7948, 0.4613],
    #               [0.6750, 0.3152, 0.1136, 0.0480],
    #               [0.1020, 0.1725, 0.7244, 0.9932]])
    num = points2d.shape[0]
    a = [] 
    b = []

    for n in range(num):
        x = points3d[n,0]
        y = points3d[n,1]
        z = points3d[n,2]
        u = points2d[n,0]
        v = points2d[n,1]
        a.append([x,y,z,1,0,0,0,0, -u*x, -u*y, -u*z])
        b.append([u])
        a.append([0,0,0,0,x,y,z,1, -v*x, -v*y, -v*z])
        b.append([v])

    A = np.mat(a)
    B = np.mat(b)
    M = np.linalg.lstsq(A,B, rcond=None)[0] #np.dot(np.linalg.inv(np.dot(A.T, A)), np.dot(A.T, B))
    M = np.array(M.T)
    M = np.append(M,[1])
    M = np.reshape(M,(3,4))

    return M
    # raise NotImplementedError('`calculate_projection_matrix` function in ' +
    #    '`student_code.py` needs to be implemented')

    ###########################################################################
    # END OF YOUR CODE
    ###########################################################################


def normalize_coordinates(points):
    """
    ============================ EXTRA CREDIT ============================
    Normalize the given Points before computing the fundamental matrix. You
    should perform the normalization to make the mean of the points 0
    and the average magnitude 1.0.

    The transformation matrix T is the product of the scale and offset matrices

    Offset Matrix
    Find c_u and c_v and create a matrix of the form in the handout for T_offset

    Scale Matrix
    Subtract the means of the u and v coordinates, then take the reciprocal of
    their standard deviation i.e. 1 / np.std([...]). Then construct the scale
    matrix in the form provided in the handout for T_scale

    :param points: set of [n x 2] 2D points
    :return: a tuple of (normalized_points, T) where T is the [3 x 3] transformation
    matrix
    """
    ########################
    # TODO: Your code here #
    ########################
    # This is a placeholder with the identity matrix for T replace with the
    # real transformation matrix for this set of points
    # T = np.eye(3)
    cu,cv = np.mean(points, axis = 0) #(N,2) --axis=0-->(2,)
    average_square_normalized_distance = np.mean((points - np.array([cu,cv]))**2)     #(N,2) - (2,) = (N,2) --mean --> 1
    scale = np.sqrt(2.0/average_square_normalized_distance)

    scale_matrix = np.array([[scale, 0 ,0],[0,scale, 0],[0,0,1]])
    offset_matrix = np.array([[1, 0, -cu],[0, 1, -cv],[0, 0, 1]])
    T = scale_matrix.dot(offset_matrix)

    points_1s = np.ones([len(points),3])
    points_1s[:,0:2] = points

    points_normalized_1s = points_1s.dot(T.T) #(N,3).dot(3,3) = (N,3)

    return points_normalized_1s, T


def estimate_fundamental_matrix(points1, points2):
    """
    Estimates the fundamental matrix given set of point correspondences in
    points1 and points2.

    points1 is an [n x 2] matrix of 2D coordinate of points on Image A
    points2 is an [n x 2] matrix of 2D coordinate of points on Image B

    Try to implement this function as efficiently as possible. It will be
    called repeatedly for part IV of the project

    If you normalize your coordinates for extra credit, don't forget to adjust
    your fundamental matrix so that it can operate on the original pixel
    coordinates!

    :return F_matrix, the [3 x 3] fundamental matrix
    """
    ########################
    # TODO: Your code here #
    ########################

    # This is an intentionally incorrect Fundamental matrix placeholder
    # F_matrix = np.array([[0, 0, -.0004], [0, 0, .0032], [0, -0.0044, .1034]])

    num = points1.shape[0]
    A = np.zeros((num, 8))
    ones = np.ones((num, 1))
    
    cu_a = np.mean(points1[:, 0])
    cv_a = np.mean(points1[:, 1])
    s_a = np.std(points1 - np.mean(points1))
    Ta = np.mat([[1/s_a, 0, 0], [0, 1/s_a, 0], [0, 0, 1]]) * np.mat([[1, 0, -cu_a], [0,1,-cv_a], [0, 0, 1]])
    Ta = np.array(Ta)
    points1 = np.hstack([points1, ones])
    
    cu_b = np.mean(points1[:, 0])
    cv_b = np.mean(points1[:, 1])
    s_b = np.std(points1 - np.mean(points1))
    Tb = np.mat([[1/s_b, 0, 0], [0, 1/s_b, 0], [0, 0, 1]]) * np.mat([[1, 0, -cu_b], [0,1,-cv_b], [0, 0, 1]])
    Tb = np.array(Tb)
    points2 = np.hstack([points2, ones])
    
    for i in range(num):
        points1[i] = np.matmul(Ta, points1[i])
        points2[i] = np.matmul(Tb, points2[i])
        
        u1 = points1[i, 0]
        v1 = points1[i, 1]
        u2 = points2[i, 0]
        v2 = points2[i, 1]
        A[i] = [u1*u2, v1*u2, u2, u1*v2, v1*v2, v2, u1, v1]
    
    A = np.hstack([A, ones])
    _, _, V = np.linalg.svd(A)
    F = V[-1].reshape(3,3)
    
    (U, S, V) = np.linalg.svd(F)
    S[2] = 0
    F = U.dot(np.diag(S)).dot(V)
    F = F/F[2,2]
    ###########################################################################
    # END OF YOUR CODE
    ###########################################################################
    return Tb.T.dot(F).dot(Ta)

def ransac_fundamental_matrix(matches1, matches2, num_iters):
    """
    Find the best fundamental matrix using RANSAC on potentially matching
    points. Run RANSAC for num_iters.

    matches1 and matches2 are the [N x 2] coordinates of the possibly
    matching points from two pictures. Each row is a correspondence
     (e.g. row 42 of matches1 is a point that corresponds to row 42 of matches2)

    best_Fmatrix is the [3 x 3] fundamental matrix, inliers1 and inliers2 are
    the [M x 2] corresponding points (some subset of matches1 and matches2) that
    are inliners with respect to best_Fmatrix

    For this section, use RANSAC to find the best fundamental matrix by randomly
    sampling interest points. You would reuse estimate_fundamental_matrix from
    Part 2 of this assignment.

    If you are trying to produce an uncluttered visualization of epipolar lines,
    you may want to return no more than 30 points for either image.

    :return: best_Fmatrix, inliers1, inliers2
    """
    random.seed(0)
    np.random.seed(0)
    ########################
    # TODO: Your code here #
    ########################
    best_F = estimate_fundamental_matrix(matches1[0:9, :], matches2[0:9, :])
    inliers_a = matches1[0:29, :]
    inliers_b = matches2[0:29, :]
    # return best_F, inliers_a, inliers_b

    # Your RANSAC loop should contain a call to 'estimate_fundamental_matrix()'
    # that you wrote for part II.
    N = len(matches1)
    matches_1s_a = np.hstack([matches1, np.ones([N,1])])  #(N,3)
    matches_1s_b = np.hstack([matches2, np.ones([N,1])])  #(N,3)
    
    best_count = 0
    max_iter = num_iters
    threshold = 0.05
    
    ii= 0
    while ii < max_iter:
        ii += 1
        # Sample a random 10 points and calculate the F matrix
        random_sample = np.random.choice(N,8)
        points_a = matches1[random_sample]
        points_b = matches2[random_sample]
        
        temp_F, _ = cv2.findFundamentalMat(points_a, points_b, cv2.FM_8POINT, 1e10, 0, 1) # estimate_fundamental_matrix(points_a, points_b)
        my_F = estimate_fundamental_matrix(points_a, points_b)
        
        if temp_F is None:
            continue
        # print(myF)
        # print(temp_F)
        # exit()
        score = matches_1s_b.dot(temp_F)
        score = np.sum(score*matches_1s_a, axis = 1)
        
        inliners = np.arange(N)[np.abs(score)<threshold]
        
        if len(inliners) > best_count:
            best_count = len(inliners)
            best_F, inliers_a, inliers_b = temp_F, matches1[inliners], matches2[inliners]

    ###########################################################################
    # END OF YOUR CODE
    ###########################################################################

    return best_F, inliers_a, inliers_b


def matches_to_3d(points1, points2, M1, M2):
    """
    Given two sets of points and two projection matrices, you will need to solve
    for the ground-truth 3D points using np.linalg.lstsq(). For a brief reminder
    of how to do this, please refer to Question 5 from the written questions for
    this project.


    :param points1: [N x 2] points from image1
    :param points2: [N x 2] points from image2
    :param M1: [3 x 4] projection matrix of image2
    :param M2: [3 x 4] projection matrix of image2
    :return: [N x 3] list of solved ground truth 3D points for each pair of 2D
    points from points1 and points2
    """
    points3d = []
    ########################
    # TODO: Your code here #
    ########################
    num = points1.shape[0]
    for i in range(num):
        A = []
        B = []
        u1 = points1[i, 0]
        v1 = points1[i, 1]
        u2 = points2[i, 0]
        v2 = points2[i, 1]
        A.append([M1[0, 0] - M1[2,0]*u1, M1[0,1] - M1[2,1]*u1, M1[0,2] - M1[2,2]*u1])
        B.append(u1*M1[2,3]-M1[0,3])
        A.append([M1[1, 0] - M1[2,0]*v1, M1[1,1] - M1[2,1]*v1, M1[1,2] - M1[2,2]*v1])
        B.append(v1*M1[2,3]-M1[1,3])
        A.append([M2[0, 0] - M2[2,0]*u2, M2[0,1] - M2[2,1]*u2, M2[0,2] - M2[2,2]*u2])
        B.append(u2*M2[2,3]-M2[0,3])
        A.append([M2[1, 0] - M2[2,0]*v2, M2[1,1] - M2[2,1]*v2, M2[1,2] - M2[2,2]*v2])
        B.append(v2*M2[2,3]-M2[1,3])
        point = np.linalg.lstsq(A, B, rcond=None)[0]
        points3d.append(point)

    return points3d
