from sqlalchemy.orm import Session
from datetime import datetime

from app.models.complaint import Complaint
from app.models.enums import ComplaintStatus


# ---------------------------
# CREATE COMPLAINT
# ---------------------------
def create_complaint(db: Session, user_id: int, title: str, description: str):
    complaint = Complaint(
        user_id=user_id,
        title=title,
        description=description,
        status=ComplaintStatus.PENDING.value,
        created_at=datetime.utcnow()
    )

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return complaint


# ---------------------------
# GET USER COMPLAINTS
# ---------------------------
def get_user_complaints(db: Session, user_id: int):
    complaints = (
        db.query(Complaint)
        .filter(Complaint.user_id == user_id)
        .order_by(Complaint.created_at.desc())
        .all()
    )

    return [
        {
            "id": c.id,
            "title": c.title,
            "description": c.description,
            "status": c.status,
            "created_at": c.created_at,
            "updated_at": c.updated_at
        }
        for c in complaints
    ]


# ---------------------------
# GET ALL COMPLAINTS (ADMIN)
# ---------------------------
def get_all_complaints(db: Session):
    complaints = (
        db.query(Complaint)
        .order_by(Complaint.created_at.desc())
        .all()
    )

    return [
        {
            "id": c.id,
            "user_id": c.user_id,
            "title": c.title,
            "description": c.description,
            "status": c.status,
            "created_at": c.created_at,
            "updated_at": c.updated_at
        }
        for c in complaints
    ]


# ---------------------------
# UPDATE COMPLAINT STATUS
# ---------------------------
def update_complaint_status(db: Session, complaint_id: int, status):
    """
    status can be:
    - ComplaintStatus enum
    - or raw string (for safety from API layer)
    """

    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return None

    # Normalize status
    if isinstance(status, ComplaintStatus):
        complaint.status = status.value
    else:
        complaint.status = status

    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }