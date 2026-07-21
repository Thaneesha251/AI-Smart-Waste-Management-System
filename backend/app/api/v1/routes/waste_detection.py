from fastapi import APIRouter, UploadFile, File
from pathlib import Path
from ml.inference.priority_engine import assign_priority
import shutil

from ml.inference.detector import WasteDetector

router = APIRouter()

# Load detector once
detector = WasteDetector()

# Folder to store uploaded images
UPLOAD_DIR = Path('uploads')
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post('/detect')
async def detect_waste(file: UploadFile = File(...)):
    file_path = UPLOAD_DIR / file.filename

    # Save uploaded file
    with open(file_path, 'wb') as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run detection
    detections = detector.detect(str(file_path))

    priority_info = assign_priority(detections)

    return {
        'filename': file.filename,
        'detections': detections,
        'priority': priority_info['priority'],
        'priority_score': priority_info['priority_score'],
        'reason': priority_info['reason']
    }