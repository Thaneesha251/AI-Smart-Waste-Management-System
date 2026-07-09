from fastapi import APIRouter, UploadFile, File, Depends
import shutil
import os

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

    file_path = f"{UPLOAD_DIR}/{file.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = ai_service.predict_waste(file_path)

    if result["status"] == "error":
        return error(result["message"])

    return success(
        "Prediction completed",
        result["prediction"]
    )