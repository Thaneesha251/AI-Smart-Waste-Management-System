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
<<<<<<< HEAD
    update_complaint,
    delete_complaint,
    search_complaints,
    assign_worker_to_complaint,
    release_worker_from_complaint
=======
    update_complaint_status
>>>>>>> origin/main
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


<<<<<<< HEAD
# DELETE
@router.delete("/{complaint_id}")
def delete_complaint_api(complaint_id: int, db: Session = Depends(get_db)):
    success = delete_complaint(db, complaint_id)
    if not success:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return {"message": "Complaint deleted successfully"}


# SEARCH
@router.get("/search/{query}")
def search_complaints_api(query: str, db: Session = Depends(get_db)):
    complaints = search_complaints(db, query)
    if not complaints:
        return {"results": [], "message": "No complaints found."}
    return {"results": complaints, "count": len(complaints)}


# ASSIGN WORKER
@router.post("/{complaint_id}/assign/{worker_id}")
def assign_worker_api(
    complaint_id: int,
    worker_id: int,
    db: Session = Depends(get_db)
):
    complaint = assign_worker_to_complaint(db, complaint_id, worker_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return complaint


# RELEASE WORKER
@router.post("/{complaint_id}/release")
def release_worker_api(complaint_id: int, db: Session = Depends(get_db)):
    complaint = release_worker_from_complaint(db, complaint_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return complaint
=======
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
>>>>>>> origin/main
