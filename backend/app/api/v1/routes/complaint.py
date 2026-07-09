from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.rbac import require_admin

from app.models.user import User
from app.services.complaint_service import (
    create_complaint,
    get_user_complaints,
    get_all_complaints,
    update_complaint_status
)

from app.utils.response import success, error

router = APIRouter(prefix="/complaints", tags=["Complaints"])


# ---------------------------
# CREATE COMPLAINT (USER)
# ---------------------------
@router.post("/create")
def create(
    title: str,
    description: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    complaint = create_complaint(db, user.id, title, description)

    return success(
        "Complaint created successfully",
        {
            "id": complaint.id,
            "title": complaint.title,
            "status": complaint.status
        }
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
    return success("User complaints fetched", complaints)


# ---------------------------
# ADMIN - GET ALL COMPLAINTS
# ---------------------------
@router.get("/all")
def all_complaints(
    db: Session = Depends(get_db),
    user: User = Depends(require_admin)
):
    complaints = get_all_complaints(db)
    return success("All complaints fetched", complaints)


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