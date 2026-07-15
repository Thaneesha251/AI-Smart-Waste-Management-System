from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.rbac import require_admin

from app.models.user import User
from app.models.complaint import Complaint, ComplaintStatus
from app.services.complaint_service import (
    create_complaint,
    get_user_complaints,
    get_all_complaints,
    update_complaint_status
)

from app.utils.response import success, error

from app.schemas.complaint import ComplaintCreate, ComplaintResponse, ComplaintUpdate

router = APIRouter(prefix="", tags=["Complaints"])


# ---------------------------
# CREATE COMPLAINT (USER)
# ---------------------------
@router.post("/create")
def create(
    data: ComplaintCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    complaint = create_complaint(db, user.id, data)

    return success(
        "Complaint created successfully",
        ComplaintResponse.from_orm(complaint).dict()
    )


# ---------------------------
# GET USER COMPLAINTS
# ---------------------------
@router.get("/my")
def my_complaints(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    complaints = get_user_complaints(db, user.id)
    return success("User complaints fetched", [ComplaintResponse.from_orm(c).dict() for c in complaints])


# ---------------------------
# ADMIN/WORKER - GET ALL COMPLAINTS
# ---------------------------
@router.get("/all")
def all_complaints(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    if user.role not in ["admin", "worker", "municipality"]:
        return error("Unauthorized access", status_code=403)

    complaints = get_all_complaints(db)
    return success("All complaints fetched", [ComplaintResponse.from_orm(c).dict() for c in complaints])


# ---------------------------
# UPDATE COMPLAINT (USER)
# ---------------------------
@router.put("/update/{complaint_id}")
def update(
    complaint_id: int,
    data: ComplaintUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return error("Complaint not found", status_code=404)

    if complaint.user_id != user.id:
        return error("Unauthorized to update this complaint", status_code=403)

    # Apply updates
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(complaint, key, value)

    db.commit()
    db.refresh(complaint)

    return success("Complaint updated successfully", ComplaintResponse.from_orm(complaint).dict())


# ---------------------------
# CANCEL COMPLAINT (USER)
# ---------------------------
@router.put("/cancel/{complaint_id}")
def cancel_complaint(
    complaint_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return error("Complaint not found", status_code=404)

    if complaint.user_id != user.id:
        return error("Unauthorized to cancel this complaint", status_code=403)

    if complaint.status != ComplaintStatus.PENDING.value:
        return error("Only pending complaints can be cancelled", status_code=400)

    complaint.status = ComplaintStatus.CANCELLED.value
    db.commit()
    db.refresh(complaint)

    return success("Complaint cancelled successfully", ComplaintResponse.from_orm(complaint).dict())


# ---------------------------
# ADMIN - UPDATE STATUS
# ---------------------------
@router.put("/status/{complaint_id}")
def update_status(
    complaint_id: int,
    status: str,
    db: Session = Depends(get_db),
    user: User = Depends(require_admin)
):
    updated = update_complaint_status(db, complaint_id, status)

    if not updated:
        return error("Complaint not found", status_code=404)

    return success("Complaint status updated", updated)
