from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from fastapi import UploadFile, File, Form
from app.utils.file_upload import save_complaint_photo
from app.services.complaint_service import update_complaint_photo

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.rbac import require_admin, require_role

from app.models.user import User
from app.schemas.complaint import ComplaintAssign, ComplaintStatusUpdate
from app.services.complaint_service import (
    create_complaint,
    get_user_complaints,
    get_all_complaints,
    get_filtered_complaints,
    update_complaint,
    delete_complaint,
    search_complaints,
    assign_worker_to_complaint,
    reassign_worker_to_complaint,
    release_worker_from_complaint,
    update_complaint_status
)
from app.services.complaint_service import get_pending_verifications
from app.services.complaint_service import verify_complaint
from pydantic import BaseModel

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
# DELETE COMPLAINT
# ---------------------------
@router.delete("/{complaint_id}")
def delete_complaint_api(
    complaint_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin", "officer"))
):
    deleted = delete_complaint(db, complaint_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return success("Complaint deleted successfully")


# ---------------------------
# SEARCH COMPLAINTS
# ---------------------------
@router.get("/search/{query}")
def search_complaints_api(query: str, db: Session = Depends(get_db)):
    complaints = search_complaints(db, query)
    if not complaints:
        return success("No complaints found", {"results": [], "count": 0})
    return success("Complaints found", {"results": complaints, "count": len(complaints)})



# ---------------------------
# ASSIGN WORKER (ADMIN/OFFICER ONLY)
# ---------------------------
@router.post("/{complaint_id}/assign")
def assign_worker_api(
    complaint_id: int,
    data: ComplaintAssign,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin", "officer"))
):
    complaint = assign_worker_to_complaint(db, complaint_id, data.worker_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint or worker not found")
    return success("Worker assigned successfully", complaint)


# ---------------------------
# UPLOAD COMPLAINT PHOTO          
# ---------------------------
@router.post("/{complaint_id}/upload-photo")
def upload_complaint_photo(
    complaint_id: int,
    type: str = Form(..., description="before or after"),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin", "officer", "worker"))
):
    if type not in ("before", "after"):
        raise HTTPException(status_code=400, detail="type must be 'before' or 'after'")
    from app.models.complaint import Complaint as ComplaintModel
    complaint = db.query(ComplaintModel).filter(ComplaintModel.id == complaint_id).first()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    url = save_complaint_photo(file, complaint_id, type)
    updated = update_complaint_photo(db, complaint_id, type, url)
    return success(
        f"{type.capitalize()} photo uploaded successfully",
        updated
    )


# ---------------------------
# REASSIGN WORKER (ADMIN/OFFICER ONLY)
# ---------------------------
@router.put("/{complaint_id}/reassign")
def reassign_worker_api(
    complaint_id: int,
    data: ComplaintAssign,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin", "officer"))
):
    complaint = reassign_worker_to_complaint(db, complaint_id, data.worker_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint or worker not found")
    return success("Worker reassigned successfully", complaint)


# ---------------------------
# UNASSIGN WORKER (ADMIN/OFFICER ONLY)
# ---------------------------
@router.delete("/{complaint_id}/assign")
def unassign_worker_api(
    complaint_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin", "officer"))
):
    complaint = release_worker_from_complaint(db, complaint_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return success("Worker unassigned successfully", complaint)


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
    status: str = Query(None),
    zone: str = Query(None),
    worker_id: int = Query(None),
    date_from: str = Query(None),
    date_to: str = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    user: User = Depends(require_admin)
):
    complaints = get_filtered_complaints(
        db,
        status=status,
        zone=zone,
        worker_id=worker_id,
        date_from=date_from,
        date_to=date_to,
        skip=skip,
        limit=limit,
    )
    return success("All complaints fetched", complaints)



# ---------------------------
# GET PENDING VERIFICATIONS (ADMIN/OFFICER ONLY)
# ---------------------------
@router.get("/verifications")
def pending_verifications(
    db: Session = Depends(get_db),
    user: User = Depends(require_role("admin", "officer"))
):
    verifications = get_pending_verifications(db)
    if not verifications:
        return success("No pending verifications", {"results": [], "count": 0})
    return success("Pending verifications fetched", {"results": verifications, "count": len(verifications)})



# ---------------------------
# VERIFY COMPLAINT (ADMIN/OFFICER ONLY)
# ---------------------------


class VerifyBody(BaseModel):
    approved: bool


@router.patch("/{complaint_id}/verify")
def verify_complaint_api(
    complaint_id: int,
    body: VerifyBody,
    db: Session = Depends(get_db),
    user: User = Depends(require_role("admin", "officer"))
):
    result = verify_complaint(db, complaint_id, body.approved)
    if not result:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return success("Complaint verification updated", result)


# ---------------------------
# UPDATE COMPLAINT STATUS
# ---------------------------
@router.put("/status/{complaint_id}")
def update_status(
    complaint_id: int,
    data: ComplaintStatusUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    from app.models.complaint import Complaint as ComplaintModel
    from app.models.worker import Worker as WorkerModel
    from app.models.enums import ComplaintStatus

    complaint = db.query(ComplaintModel).filter(ComplaintModel.id == complaint_id).first()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")

    current_status = complaint.status
    new_status = data.status

    # Define allowed transitions
    ALLOWED_TRANSITIONS = {
        ComplaintStatus.PENDING.value: {ComplaintStatus.IN_PROGRESS.value, ComplaintStatus.REJECTED.value},
        ComplaintStatus.IN_PROGRESS.value: {ComplaintStatus.RESOLVED.value, ComplaintStatus.PENDING.value, ComplaintStatus.REJECTED.value},
        ComplaintStatus.RESOLVED.value: set(),
        ComplaintStatus.REJECTED.value: set(),
    }

    # Validate transition
    if new_status != current_status:
        if current_status not in ALLOWED_TRANSITIONS or new_status not in ALLOWED_TRANSITIONS[current_status]:
            raise HTTPException(
                status_code=400,
                detail=f"Illegal status transition from {current_status} to {new_status}"
            )

        # Validate authorization
        if new_status in [ComplaintStatus.IN_PROGRESS.value, ComplaintStatus.RESOLVED.value]:
            is_assigned_worker = False
            if user.role == "worker":
                worker_record = db.query(WorkerModel).filter(WorkerModel.user_id == user.id).first()
                if worker_record and complaint.assigned_worker_id == worker_record.id:
                    is_assigned_worker = True
            
            if user.role != "admin" and not is_assigned_worker:
                raise HTTPException(
                    status_code=403,
                    detail="Only the assigned worker or an admin can move complaint to in_progress or resolved"
                )

        elif new_status == ComplaintStatus.REJECTED.value:
            if user.role not in ["admin", "officer"]:
                raise HTTPException(
                    status_code=403,
                    detail="Only admins or officers can reject complaints"
                )

        elif new_status == ComplaintStatus.PENDING.value:
            if user.role not in ["admin", "officer"]:
                raise HTTPException(
                    status_code=403,
                    detail="Only admins or officers can set status to pending"
                )

    updated = update_complaint_status(db, complaint_id, new_status)
    return success("Complaint status updated", updated)
