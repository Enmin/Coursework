import cv2
import mediapipe as mp
import numpy as np
import os
import pandas as pd
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

def get_path(folder):
    files = []
    for img in os.listdir(folder):
        if img[-3:] == 'jpg':
            cur = os.path.join(folder, img)
            files.append(cur)
    return files

train_data_folder = '../data/test/'
IMAGE_FILES = get_path(train_data_folder)
print(IMAGE_FILES)
detected = 0
with mp_hands.Hands(
    static_image_mode=True,
    max_num_hands=2,
    min_detection_confidence=0.5) as hands:
  for idx, file in enumerate(IMAGE_FILES):
    # Read an image, flip it around y-axis for correct handedness output (see
    # above).
    image = cv2.flip(cv2.imread(file), 1)
    # Convert the BGR image to RGB before processing.
    results = hands.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

    # Print handedness and draw hand landmarks on the image.
    # print('Handedness:', results.multi_handedness)
    if not results.multi_hand_landmarks:
      continue
    image_height, image_width, _ = image.shape
    annotated_image = image.copy()
    detected += 1
        # mp_drawing.draw_landmarks(
        #     annotated_image,
        #     hand_landmarks,
        #     mp_hands.HAND_CONNECTIONS,
        #     mp_drawing_styles.get_default_hand_landmarks_style(),
        #     mp_drawing_styles.get_default_hand_connections_style())
      # cv2.imwrite(
      #     './tmp/annotated_image' + str(idx) + '.png', cv2.flip(annotated_image, 1))
      # Draw hand world landmarks.
      # if not results.multi_hand_world_landmarks:
      #   continue
      # for hand_world_landmarks in results.multi_hand_world_landmarks:
      #   mp_drawing.plot_landmarks(
      #     hand_world_landmarks, mp_hands.HAND_CONNECTIONS, azimuth=5)
print("acc: {}".format(detected / len(IMAGE_FILES)))