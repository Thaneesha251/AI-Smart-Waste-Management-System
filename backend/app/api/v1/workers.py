from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import os
import shutil

from app.core.database import get_db
from app.core.security import verify_password, create_access_token
from app.core.dependencies import get_current_worker
from app.models.worker import Worker
from app.models.complaint import Complaint, ComplaintStatus
from app.schemas.worker import WorkerLogin, WorkerResponse
from app.schemas.complaint import ComplaintResponse, ComplaintDetailResponse
from app.utils.response import success, error

router = APIRouter()

UPLOAD_DIR = "uploads/worker"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# ---------------------------
# WORKER LOGIN
# ---------------------------
@router.post("/login", tags=["Worker"])
def worker_login(data: WorkerLogin, db: Session = Depends(get_db)):
    print(f"DEBUG: Worker login attempt for ID: {data.worker_id}")

    worker = db.query(Worker).filter(Worker.worker_id == data.worker_id).first()

    if not worker:
        print(f"DEBUG: Login failed - Worker ID {data.worker_id} not found")
        return error("Invalid worker ID or password", status_code=401)

    print(f"DEBUG: Worker found: {worker.name}. Verifying password...")

    if not verify_password(data.password, worker.password):
        print(f"DEBUG: Login failed - Incorrect password for Worker {data.worker_id}")
        return error("Invalid worker ID or password", status_code=401)

    print(f"DEBUG: Password verified. Generating JWT token...")

    token = create_access_token({
        "user_id": worker.id,
        "worker_id": worker.worker_id,
        "role": "worker"
    })

    print(f"DEBUG: Login successful for Worker: {worker.worker_id}")

    return success(
        "Login successful",
        {
            "access_token": token,
            "token_type": "bearer",
            "worker": WorkerResponse.model_validate(worker).model_dump()
        }
    )

# ---------------------------
# WORKER PROFILE
# ---------------------------
@router.get("/me", tags=["Worker"])
def get_worker_me(current_worker: Worker = Depends(get_current_worker)):
    return success(
        "Worker profile fetched successfully",
        WorkerResponse.model_validate(current_worker).model_dump()
    )

# ---------------------------
# ASSIGNED COMPLAINTS
# ---------------------------
@router.get("/assigned", tags=["Worker"])
def get_assigned_complaints(db: Session = Depends(get_db), current_worker: Worker = Depends(get_current_worker)):
    complaints = db.query(Complaint).filter(
        Complaint.assigned_worker_id == current_worker.id
    ).all()

    # Log the response to verify field existence
    res_data = [ComplaintResponse.model_validate(c).model_dump() for c in complaints]
    print(f"DEBUG: Worker assigned tasks response: {res_data}")

    return success("Assigned complaints fetched", res_data)

# ---------------------------
# COMPLAINT DETAILS
# ---------------------------
@router.get("/complaints/{complaint_id}", tags=["Worker"])
def get_complaint_details(complaint_id: int, db: Session = Depends(get_db), current_worker: Worker = Depends(get_current_worker)):
    complaint = db.query(Complaint).filter(
        Complaint.id == complaint_id,
        Complaint.assigned_worker_id == current_worker.id
    ).first()

    if not complaint:
        return error("Complaint not found or not assigned to you", status_code=404)

    res_data = ComplaintDetailResponse.model_validate(complaint).model_dump()
    print(f"DEBUG: Complaint details response: {res_data}")

    return success(
        "Complaint details fetched",
        res_data
    )

# ---------------------------
# START WORK
# ---------------------------
@router.put("/complaints/{complaint_id}/start", tags=["Worker"])
def start_work(complaint_id: int, db: Session = Depends(get_db), current_worker: Worker = Depends(get_current_worker)):
    complaint = db.query(Complaint).filter(
        Complaint.id == complaint_id,
        Complaint.assigned_worker_id == current_worker.id
    ).first()

    if not complaint:
        return error("Complaint not found", status_code=404)

    # Allow starting even if already in progress or assigned
    if complaint.status not in [ComplaintStatus.ASSIGNED.value, ComplaintStatus.IN_PROGRESS.value]:
        return error(f"Cannot start work. Current status is {complaint.status}", status_code=400)

    print(f"DEBUG: Starting work for complaint {complaint_id}. Current status: {complaint.status}")

    complaint.status = ComplaintStatus.IN_PROGRESS.value
    # Legacy started_at for compatibility if needed
    complaint.started_at = datetime.utcnow()
    db.commit()
    db.refresh(complaint)

    print(f"DEBUG: Work started for complaint {complaint_id}. New status: {complaint.status}")

    return success("Work started", ComplaintResponse.model_validate(complaint).model_dump())

# ---------------------------
# UPLOAD AFTER IMAGE
# ---------------------------
@router.post("/complaints/{complaint_id}/after-image", tags=["Worker"])
def upload_after_image(
    complaint_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_worker: Worker = Depends(get_current_worker)
):
    complaint = db.query(Complaint).filter(
        Complaint.id == complaint_id,
        Complaint.assigned_worker_id == current_worker.id
    ).first()

    if not complaint:
        return error("Complaint not found", status_code=404)

    filename = f"after_{complaint_id}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    print(f"DEBUG: Uploading after-image for complaint {complaint_id}. Status before: {complaint.status}")

    # Store in the CamelCase DB field
    complaint.afterImageUrl = f"/uploads/worker/{filename}"

    # EXPLICITLY DO NOT CHANGE STATUS HERE
    # Keeping it as is, usually it should be IN_PROGRESS

    db.commit()
    db.refresh(complaint)

    print(f"DEBUG: After-image uploaded for complaint {complaint_id}. Status after: {complaint.status}")

    res_data = ComplaintResponse.model_validate(complaint).model_dump()
    return success("After-image uploaded", res_data)

# ---------------------------
# COMPLETE WORK
# ---------------------------
@router.put("/complaints/{complaint_id}/complete", tags=["Worker"])
def complete_work(complaint_id: int, db: Session = Depends(get_db), current_worker: Worker = Depends(get_current_worker)):
    complaint = db.query(Complaint).filter(
        Complaint.id == complaint_id,
        Complaint.assigned_worker_id == current_worker.id
    ).first()

    if not complaint:
        return error("Complaint not found", status_code=404)

    if not complaint.afterImageUrl:
        return error("Cannot complete work without an after-cleaning image", status_code=400)

    print(f"DEBUG: Completing work for complaint {complaint_id}. Status before: {complaint.status}")

    complaint.status = ComplaintStatus.COMPLETED.value
    complaint.completed_at = datetime.utcnow()
    db.commit()
    db.refresh(complaint)

    print(f"DEBUG: Work completed for complaint {complaint_id}. Status after: {complaint.status}")

    res_data = ComplaintResponse.model_validate(complaint).model_dump()
    return success("Work completed successfully", res_data)
