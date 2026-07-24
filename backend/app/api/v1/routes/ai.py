from fastapi import APIRouter, UploadFile, File, Depends
import shutil
import os
from datetime import datetime

from app.core.dependencies import get_current_user
from app.services.ai_service import AIService
from app.utils.response import success, error

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

ai_service = AIService()


@router.post("/predict")
def predict_waste(
    file: UploadFile = File(...),
    user=Depends(get_current_user)
):
    # Ensure directory exists
    os.makedirs(UPLOAD_DIR, exist_ok=True)

    # Generate unique filename to avoid collisions
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = ai_service.predict_waste(file_path)

    if result["status"] == "error":
        return error(result["message"])

    # Add image_url to the prediction results
    prediction = result["prediction"]
    prediction["image_url"] = f"/uploads/{filename}"

    # Standardized response format
    return success(
        "Prediction completed",
        prediction
    )
