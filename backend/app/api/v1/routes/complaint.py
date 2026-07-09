from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.complaint import ComplaintCreate, ComplaintUpdate, ComplaintResponse
from app.crud import complaint as crud_complaint
from typing import List

router = APIRouter()

@router.post("/", status_code=201)
def create_new_complaint(data: ComplaintCreate, db: Session = Depends(get_db)):
    return crud_complaint.create_complaint(db, data)

@router.get("/", response_model=List[ComplaintResponse])
def read_all_complaints(db: Session = Depends(get_db)):
    return crud_complaint.get_all_complaints(db)

@router.get("/citizen/{citizen_id}", response_model=List[ComplaintResponse])
def read_citizen_complaints(citizen_id: int, db: Session = Depends(get_db)):
    return crud_complaint.get_citizen_complaints(db, citizen_id)

@router.get("/{complaint_id}", response_model=ComplaintResponse)
def read_complaint(complaint_id: int, db: Session = Depends(get_db)):
    db_complaint = crud_complaint.get_complaint(db, complaint_id)
    if not db_complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return db_complaint

@router.put("/{complaint_id}", response_model=ComplaintResponse)
def update_existing_complaint(complaint_id: int, data: ComplaintUpdate, db: Session = Depends(get_db)):
    db_complaint = crud_complaint.update_complaint(db, complaint_id, data)
    if not db_complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return db_complaint

@router.delete("/{complaint_id}")
def delete_existing_complaint(complaint_id: int, db: Session = Depends(get_db)):
    success = crud_complaint.delete_complaint(db, complaint_id)
    if not success:
        raise HTTPException(status_code=404, detail="Complaint not found")
    return {"message": "Complaint deleted successfully"}
