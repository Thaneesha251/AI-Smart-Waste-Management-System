import numpy as np
import tensorflow as tf

from app.ai.utils.labels import LABELS
from app.ai.utils.preprocess import load_and_preprocess_image


MODEL_PATH = "app/ai/models/garbage_model.h5"

model = tf.keras.models.load_model(MODEL_PATH)


def predict_waste(image_path: str):
    img = load_and_preprocess_image(image_path)

    predictions = model.predict(img)
    class_index = np.argmax(predictions)

    return {
        "category": LABELS[class_index],
        "confidence": float(np.max(predictions))
    }