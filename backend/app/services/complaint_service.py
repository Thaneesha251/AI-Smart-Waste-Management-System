from sqlalchemy.orm import Session
from datetime import datetime

from app.models.complaint import Complaint
from app.models.enums import ComplaintStatus


from app.schemas.complaint import ComplaintCreate

# ---------------------------
# CREATE COMPLAINT
# ---------------------------
def create_complaint(db: Session, user_id: int, data: ComplaintCreate):
    complaint = Complaint(
        user_id=user_id,
        title=data.title,
        description=data.description,
        location=data.location,
        area=data.area,
        zone=data.zone,
        priority=data.priority,
        wasteType=data.wasteType,
        imageUrl=data.image_url, # Map from snake_case schema to CamelCase model
        status=ComplaintStatus.PENDING.value
    )

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return complaint


# ---------------------------
# GET USER COMPLAINTS
# ---------------------------
def get_user_complaints(db: Session, user_id: int):
    return (
        db.query(Complaint)
        .filter(Complaint.user_id == user_id)
        .order_by(Complaint.created_at.desc())
        .all()
    )


# ---------------------------
# GET ALL COMPLAINTS (ADMIN/WORKER)
# ---------------------------
def get_all_complaints(db: Session):
    return (
        db.query(Complaint)
        .order_by(Complaint.created_at.desc())
        .all()
    )


# ---------------------------
# UPDATE COMPLAINT STATUS
# ---------------------------
def update_complaint_status(db: Session, complaint_id: int, status):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return None

    # Normalize status
    if isinstance(status, ComplaintStatus):
        complaint.status = status.value
    else:
        complaint.status = str(status)

    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }


# ---------------------------
# WORKER: ACCEPT COMPLAINT
# ---------------------------
def accept_complaint(db: Session, complaint_id: int, worker_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    # Use assigned_worker_id (new)
    complaint.assigned_worker_id = worker_id
    # Also set legacy worker_id for now if needed, but primary is assigned_worker_id
    complaint.status = ComplaintStatus.ASSIGNED.value
    complaint.assigned_at = datetime.utcnow()
    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)
    return complaint


# ---------------------------
# WORKER: START COMPLAINT
# ---------------------------
def start_complaint(db: Session, complaint_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    complaint.status = ComplaintStatus.IN_PROGRESS.value
    complaint.started_at = datetime.utcnow()
    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)
    return complaint


# ---------------------------
# WORKER: COMPLETE COMPLAINT
# ---------------------------
def complete_complaint(db: Session, complaint_id: int, after_image_url: str):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    complaint.status = ComplaintStatus.COMPLETED.value
    complaint.afterImageUrl = after_image_url
    complaint.completed_at = datetime.utcnow()
    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)
    return complaint
