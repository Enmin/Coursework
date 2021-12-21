import cv2
import matplotlib.pyplot as plt
import os
from utils import generate_column_names
import pandas as pd

['WRIST', 'THUMB_CMC', 'THUMB_MCP', 'THUMB_IP', 'THUMB_TIP',
'INDEX_FINGER_MCP', 'INDEX_FINGER_PIP', 'INDEX_FINGER__DIP', 'INDEX_FINGER_TIP',
'MIDDLE_FINGER_MCP', 'MIDDLE_FINGER_PIP', 'MIDDLE_FINGER_DIP', 'MIDDLE_FINGER_TIP',
'RING_FINGER_MCP', 'RING_FINGER_PIP', 'RING_FINGER_DIP', 'RING_FINGER_TIP',
'PINKY_MCP', 'PINKY_PIP', 'PINKY_DIP', 'PINKY_TIP']
a = generate_column_names()
print(a)