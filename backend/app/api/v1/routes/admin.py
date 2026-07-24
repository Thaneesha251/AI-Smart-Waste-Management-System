from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import hash_password
from app.models.user import User
from app.models.worker import Worker
from app.models.complaint import Complaint, ComplaintStatus
from app.schemas.worker import WorkerAssignment, WorkerCreate, WorkerUpdate, WorkerResetPassword, WorkerResponse
from app.schemas.user import UserResponse
from app.core.dependencies import get_current_user
from app.utils.response import success, error
from datetime import datetime

router = APIRouter(tags=["Admin"])


# ---------------------------
# GET ALL USERS (ADMIN ONLY)
# ---------------------------
@router.get("/users")
def get_all_users(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    users = db.query(User).all()

    return success(
        "Users fetched successfully",
        [UserResponse.model_validate(u).model_dump() for u in users]
    )


# ---------------------------
# GET SYSTEM STATS (ADMIN DASHBOARD)
# ---------------------------
@router.get("/stats")
def get_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    total_users = db.query(User).count()
    admin_users = db.query(User).filter(User.role == "admin").count()
    normal_users = db.query(User).filter(User.role == "user").count()
    citizen_users = db.query(User).filter(User.role == "citizen").count()
    workers_count = db.query(Worker).count()
    total_complaints = db.query(Complaint).count()

    return success(
        "System stats fetched",
        {
            "total_users": total_users,
            "admin_users": admin_users,
            "normal_users": normal_users,
            "citizen_users": citizen_users,
            "total_workers": workers_count,
            "total_complaints": total_complaints
        }
    )


# ---------------------------
# ASSIGN WORKER TO COMPLAINT
# ---------------------------
@router.post("/assign-worker")
def assign_worker(
    data: WorkerAssignment,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    complaint = db.query(Complaint).filter(Complaint.id == data.complaintId).first()
    if not complaint:
        return error("Complaint not found", status_code=404)

    worker = db.query(Worker).filter(Worker.id == data.workerId).first()
    if not worker:
        return error("Worker not found", status_code=404)

    complaint.assigned_worker_id = worker.id
    complaint.status = ComplaintStatus.ASSIGNED.value
    complaint.assigned_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)

    return success(
        "Worker assigned successfully",
        {
            "complaintId": complaint.id,
            "workerId": worker.id,
            "status": complaint.status
        }
    )


# ---------------------------
# CREATE WORKER
# ---------------------------
@router.post("/create-worker")
def create_worker(
    data: WorkerCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    existing_worker = db.query(Worker).filter(Worker.worker_id == data.worker_id).first()
    if existing_worker:
        return error("Worker ID already exists", status_code=400)

    new_worker = Worker(
        worker_id=data.worker_id,
        name=data.name,
        password=hash_password(data.password),
        phone=data.phone,
        email=data.email,
        area=data.area,
        is_active=data.is_active
    )

    db.add(new_worker)
    db.commit()
    db.refresh(new_worker)

    return success(
        "Worker created successfully",
        WorkerResponse.model_validate(new_worker).model_dump()
    )


# ---------------------------
# LIST ALL WORKERS
# ---------------------------
@router.get("/workers")
def list_workers(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    workers = db.query(Worker).all()
    return success(
        "Workers fetched successfully",
        [WorkerResponse.model_validate(w).model_dump() for w in workers]
    )


# ---------------------------
# GET WORKER DETAILS
# ---------------------------
@router.get("/workers/{id}")
def get_worker(
    id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    worker = db.query(Worker).filter(Worker.id == id).first()
    if not worker:
        return error("Worker not found", status_code=404)

    return success(
        "Worker details fetched successfully",
        WorkerResponse.model_validate(worker).model_dump()
    )


# ---------------------------
# UPDATE WORKER
# ---------------------------
@router.put("/workers/{id}")
def update_worker(
    id: int,
    data: WorkerUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    worker = db.query(Worker).filter(Worker.id == id).first()
    if not worker:
        return error("Worker not found", status_code=404)

    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(worker, key, value)

    db.commit()
    db.refresh(worker)

    return success(
        "Worker updated successfully",
        WorkerResponse.model_validate(worker).model_dump()
    )


# ---------------------------
# DELETE WORKER (SOFT DELETE/DEACTIVATE)
# ---------------------------
@router.delete("/workers/{id}")
def delete_worker(
    id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    worker = db.query(Worker).filter(Worker.id == id).first()
    if not worker:
        return error("Worker not found", status_code=404)

    worker.is_active = False
    db.commit()

    return success("Worker deactivated successfully")


# ---------------------------
# RESET WORKER PASSWORD
# ---------------------------
@router.put("/workers/{id}/reset-password")
def reset_worker_password(
    id: int,
    data: WorkerResetPassword,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        return error("Admin access required", status_code=403)

    worker = db.query(Worker).filter(Worker.id == id).first()
    if not worker:
        return error("Worker not found", status_code=404)

    worker.password = hash_password(data.new_password)
    db.commit()

    return success("Worker password reset successfully")
