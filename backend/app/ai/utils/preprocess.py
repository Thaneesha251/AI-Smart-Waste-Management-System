import numpy as np
import cv2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input


IMG_SIZE = 224


def load_and_preprocess_image(image_path):
    img = cv2.imread(image_path)

    if img is None:
        raise ValueError("Image not found or invalid format")

    img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    img = np.expand_dims(img, axis=0)
    img = preprocess_input(img)

    return img