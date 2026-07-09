import os
from typing import Dict


class AIService:

    def __init__(self):
        # Later: load YOLO / ML model here
        pass

    def predict_waste(self, image_path: str) -> Dict:

        if not os.path.exists(image_path):
            return {
                "status": "error",
                "message": "Image not found"
            }

        # MOCK PREDICTION (Phase 3 placeholder)
        return {
            "status": "success",
            "prediction": {
                "waste_type": "plastic",
                "confidence": 0.92,
                "recyclable": True
            }
        }