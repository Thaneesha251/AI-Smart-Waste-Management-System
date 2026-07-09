from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.complaint import ComplaintCreate, ComplaintUpdate
from app.crud.complaint import (
    create_complaint,
    get_complaint,
    get_all_complaints,
    update_complaint,
    delete_complaint,
    search_complaints,
    assign_worker_to_complaint,
    release_worker_from_complaint
)

router = APIRouter()


# CREATE
@router.post("/create")
def create_complaint_api(data: ComplaintCreate, db: Session = Depends(get_db)):
    return create_complaint(db, data)


# READ ALL
@router.get("/")
def get_all_complaints_api(db: Session = Depends(get_db)):
    return get_all_complaints(db)


# READ BY ID
@router.get("/{complaint_id}")
def get_complaint_api(complaint_id: int, db: Session = Depends(get_db)):
    complaint = get_complaint(db, complaint_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return complaint


# UPDATE
@router.put("/{complaint_id}")
def update_complaint_api(
    complaint_id: int,
    data: ComplaintUpdate,
    db: Session = Depends(get_db)
):
    complaint = update_complaint(db, complaint_id, data)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return complaint


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