from pathlib import Path
from ultralytics import YOLO

# ==========================================================
# Load trained YOLO model
# ==========================================================

# Path: backend/ml/weights/best.pt
MODEL_PATH = Path(__file__).resolve().parents[1] / 'weights' / 'best.pt'

# Load model once
model = YOLO(str(MODEL_PATH))


# ==========================================================
# Resolve confusion between Plastic bag and Plastic bottle
# ==========================================================

def resolve_conflicts(detections):
    """
    If both 'Plastic bag' and 'Plastic bottle' are detected,
    and bottle confidence is reasonably close (> 0.35),
    prefer 'Plastic bottle'.
    """

    has_bag = any(d['class_name'] == 'Plastic bag' for d in detections)
    has_bottle = any(d['class_name'] == 'Plastic bottle' for d in detections)

    if has_bag and has_bottle:
        bag = next(d for d in detections if d['class_name'] == 'Plastic bag')
        bottle = next(d for d in detections if d['class_name'] == 'Plastic bottle')

        print("\\nConflict detected:")
        print(f"Plastic bag confidence    : {bag['confidence']}")
        print(f"Plastic bottle confidence : {bottle['confidence']}")

        if bottle['confidence'] > 0.35:
            print("Resolved as: Plastic bottle")
            return [bottle]

    return detections


# ==========================================================
# Prediction function
# ==========================================================

def predict_waste(image_path: str):
    """
    Run YOLO inference on an image and return detected waste objects.
    Prediction image with bounding boxes is saved automatically.
    """

    results = model(image_path, conf=0.25, save=True)

    detections = []

    for result in results:
        for box in result.boxes:
            cls_id = int(box.cls[0])
            confidence = float(box.conf[0])
            bbox = box.xyxy[0].tolist()

            detections.append({
                'class_id': cls_id,
                'class_name': model.names[cls_id],
                'confidence': round(confidence, 3),
                'bbox': [round(x, 2) for x in bbox]
            })

    detections = resolve_conflicts(detections)

    return detections


# ==========================================================
# Main test block
# ==========================================================

if __name__ == '__main__':

    # Correct path to test image
    test_image = str(
        Path(__file__).resolve().parents[1]
        / 'sample_images'
        / 'test.jpg'
    )

    print(f"Using test image: {test_image}")

    output = predict_waste(test_image)

    print("\\nDetected Waste Objects:")

    if not output:
        print("No waste objects detected")
    else:
        for item in output:
            print(item)

    # Show latest prediction folder
    predict_dirs = sorted(Path('runs/detect').glob('predict*'))
    latest_dir = predict_dirs[-1] if predict_dirs else Path('runs/detect/predict')

    print(f"\\nPrediction image saved in: {latest_dir}")