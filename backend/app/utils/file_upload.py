import os
import uuid
from pathlib import Path
from fastapi import UploadFile, HTTPException

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp"}
ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

UPLOAD_BASE_DIR = Path("app/static/uploads/complaints")


def validate_image_file(file: UploadFile) -> None:
    """Validate file extension and MIME type before saving."""
    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else ""
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(status_code=400, detail="Invalid file content type")


def save_complaint_photo(file: UploadFile, complaint_id: int, photo_type: str) -> str:
    """
    Saves an uploaded photo to local disk under a per-complaint folder
    using a UUID-based filename, and returns the public URL path.

    Storage is abstracted here intentionally — if you migrate to
    S3/Cloudinary later, only this function needs to change. The API
    contract (returned URL string) stays identical.
    """
    validate_image_file(file)

    # Read into memory once to check real size (content-length header can be spoofed)
    file.file.seek(0, os.SEEK_END)
    size = file.file.tell()
    file.file.seek(0)
    if size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large. Max size is 5MB")

    ext = file.filename.rsplit(".", 1)[-1].lower()
    unique_name = f"{photo_type}_{uuid.uuid4().hex}.{ext}"

    complaint_dir = UPLOAD_BASE_DIR / str(complaint_id)
    complaint_dir.mkdir(parents=True, exist_ok=True)

    file_path = complaint_dir / unique_name
    with open(file_path, "wb") as buffer:
        buffer.write(file.file.read())

    # Public URL served via StaticFiles mount (see main.py)
    return f"/static/uploads/complaints/{complaint_id}/{unique_name}"