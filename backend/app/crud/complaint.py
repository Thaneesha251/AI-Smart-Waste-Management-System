from sqlalchemy.orm import Session
from app.models.complaint import Complaint, ComplaintStatus
from app.schemas.complaint import ComplaintCreate, ComplaintUpdate
from app.ai.engine import analyze_complaint


# CREATE
def create_complaint(db: Session, data: ComplaintCreate):
    ai_result = analyze_complaint(data.description)

    complaint = Complaint(
        title=data.title,
        description=data.description,
        location=data.location,
        status=ComplaintStatus.pending
    )

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return {
        "complaint": complaint,
        "ai_analysis": ai_result
    }


# READ ALL
def get_all_complaints(db: Session):
    return db.query(Complaint).all()


# READ ONE (THIS WAS MISSING → YOUR ERROR)
def get_complaint(db: Session, complaint_id: int):
    return db.query(Complaint).filter(Complaint.id == complaint_id).first()


# UPDATE
def update_complaint(db: Session, complaint_id: int, data: ComplaintUpdate):
    complaint = get_complaint(db, complaint_id)

    if not complaint:
        return None

    if data.title is not None:
        complaint.title = data.title

    if data.description is not None:
        complaint.description = data.description

    if data.location is not None:
        complaint.location = data.location

    if data.status is not None:
        complaint.status = data.status

    db.commit()
    db.refresh(complaint)

    return complaint


# DELETE
def delete_complaint(db: Session, complaint_id: int):
    complaint = get_complaint(db, complaint_id)

    if not complaint:
        return False

    db.delete(complaint)
    db.commit()

    return True