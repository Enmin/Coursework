import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
from utils import generate_column_names, get_path
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

train_data_folder = '../data/asl_alphabet_train/asl_alphabet_train/'
IMAGE_DICT = get_path(train_data_folder)
data = []
with mp_hands.Hands(
    static_image_mode=True,
    max_num_hands=2,
    min_detection_confidence=0.5) as hands:
  for key, IMAGE_FILES in IMAGE_DICT.items():
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
      # annotated_image = image.copy()
      for hand_landmarks in results.multi_hand_landmarks:
        row = [file] + np.array([[i.x, i.y, i.z] for i in hand_landmarks.landmark]).flatten().tolist() + [key]
        data.append(row)
        # print('hand_landmarks:', hand_landmarks)
        # print(
        #     f'Index finger tip coordinates: (',
        #     f'{hand_landmarks.landmark[mp_hands.HandLandmark.INDEX_FINGER_TIP].x * image_width}, '
        #     f'{hand_landmarks.landmark[mp_hands.HandLandmark.INDEX_FINGER_TIP].y * image_height})'
        # )
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

df = pd.DataFrame(data, columns=generate_column_names())
print("Resulting data: {} rows {} columns".format(df.shape[0], df.shape[1]))
df.to_csv("../data/pose_data.csv")