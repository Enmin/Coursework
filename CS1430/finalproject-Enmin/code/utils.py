import cv2
import os
from collections import defaultdict

def increase_brightness(img, value=150):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    lim = 255 - value
    v[v > lim] = 255
    v[v <= lim] += value

    final_hsv = cv2.merge((h, s, v))
    img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return img

def get_path(folder):
    files = defaultdict(list)
    for sub_folder in os.listdir(folder):
        cur = os.path.join(folder, sub_folder)
        for i in os.listdir(cur):
            files[sub_folder] += [os.path.join(cur+'/', i)]
    return files

def generate_column_names():
    keypoints = ['WRIST', 'THUMB_CMC', 'THUMB_MCP', 'THUMB_IP', 'THUMB_TIP',
'INDEX_FINGER_MCP', 'INDEX_FINGER_PIP', 'INDEX_FINGER__DIP', 'INDEX_FINGER_TIP',
'MIDDLE_FINGER_MCP', 'MIDDLE_FINGER_PIP', 'MIDDLE_FINGER_DIP', 'MIDDLE_FINGER_TIP',
'RING_FINGER_MCP', 'RING_FINGER_PIP', 'RING_FINGER_DIP', 'RING_FINGER_TIP',
'PINKY_MCP', 'PINKY_PIP', 'PINKY_DIP', 'PINKY_TIP']
    coordinates = ['x', 'y', 'z']
    column_names = [k + '_' + c for k in keypoints for c in coordinates]
    return ['image_name'] + column_names + ['label']