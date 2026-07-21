from pathlib import Path
from ultralytics import YOLO


class WasteDetector:
    def __init__(self):
        # Path to trained model
        model_path = (
            Path(__file__).resolve().parents[1]
            / 'weights'
            / 'best.pt'
        )

        self.model = YOLO(str(model_path))

    def detect(self, image_path: str):
        """
        Run YOLO inference and return detections.
        """

        results = self.model(image_path, conf=0.25)

        detections = []

        for result in results:
            for box in result.boxes:
                cls_id = int(box.cls[0])
                confidence = float(box.conf[0])
                bbox = box.xyxy[0].tolist()

                detections.append({
                    'class_id': cls_id,
                    'class_name': self.model.names[cls_id],
                    'confidence': round(confidence, 3),
                    'bbox': [round(x, 2) for x in bbox]
                })

        return detections