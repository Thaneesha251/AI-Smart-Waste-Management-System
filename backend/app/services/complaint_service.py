from sqlalchemy.orm import Session
from datetime import datetime

from app.models.complaint import Complaint
from app.models.enums import ComplaintStatus
from app.models.worker import Worker


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
    status_str = status.value if isinstance(status, ComplaintStatus) else status
    complaint.status = status_str

    # Auto-release worker if resolved or rejected
    if status_str in [ComplaintStatus.RESOLVED.value, ComplaintStatus.REJECTED.value]:
        if complaint.assigned_worker_id:
            worker = db.query(Worker).filter(Worker.id == complaint.assigned_worker_id).first()
            if worker:
                worker.status = "online"
                worker.current_job_id = None
                if status_str == ComplaintStatus.RESOLVED.value:
                    worker.complaints_completed = (worker.complaints_completed or 0) + 1
                db.add(worker)

    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }
# ---------------------------
# UPDATE COMPLAINT (general fields)
# ---------------------------
def update_complaint(db: Session, complaint_id: int, title: str = None, description: str = None):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return None

    if title is not None:
        complaint.title = title
    if description is not None:
        complaint.description = description

    complaint.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "title": complaint.title,
        "description": complaint.description,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }


# ---------------------------
# DELETE COMPLAINT
# ---------------------------
def delete_complaint(db: Session, complaint_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return False

    db.delete(complaint)
    db.commit()

    return True


# ---------------------------
# SEARCH COMPLAINTS
# ---------------------------
def search_complaints(db: Session, query: str):
    complaints = (
        db.query(Complaint)
        .filter(
            (Complaint.title.ilike(f"%{query}%")) |
            (Complaint.description.ilike(f"%{query}%")) |
            (Complaint.category.ilike(f"%{query}%"))
        )
        .order_by(Complaint.created_at.desc())
        .all()
    )

    return [
        {
            "id": c.id,
            "title": c.title,
            "description": c.description,
            "status": c.status,
            "category": c.category,
            "priority": c.priority,
            "created_at": c.created_at
        }
        for c in complaints
    ]


# ---------------------------
# ASSIGN WORKER TO COMPLAINT
# ---------------------------
def assign_worker_to_complaint(db: Session, complaint_id: int, worker_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        return None

    # Update old worker if any was assigned
    if complaint.assigned_worker_id:
        old_worker = db.query(Worker).filter(Worker.id == complaint.assigned_worker_id).first()
        if old_worker:
            old_worker.status = "online"
            old_worker.current_job_id = None
            db.add(old_worker)

    # Assign new worker
    complaint.assigned_worker_id = worker_id
    complaint.status = ComplaintStatus.IN_PROGRESS.value
    complaint.updated_at = datetime.utcnow()

    # Update worker status
    worker.status = "on-job"
    worker.current_job_id = complaint_id

    db.add(complaint)
    db.add(worker)
    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "assigned_worker_id": complaint.assigned_worker_id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }


# ---------------------------
# REASSIGN WORKER TO COMPLAINT
# ---------------------------
def reassign_worker_to_complaint(db: Session, complaint_id: int, worker_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    new_worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not new_worker:
        return None

    # Release old worker
    if complaint.assigned_worker_id:
        old_worker = db.query(Worker).filter(Worker.id == complaint.assigned_worker_id).first()
        if old_worker:
            old_worker.status = "online"
            old_worker.current_job_id = None
            db.add(old_worker)

    # Assign new worker
    complaint.assigned_worker_id = worker_id
    complaint.status = ComplaintStatus.IN_PROGRESS.value
    complaint.updated_at = datetime.utcnow()

    # Update new worker status
    new_worker.status = "on-job"
    new_worker.current_job_id = complaint_id

    db.add(complaint)
    db.add(new_worker)
    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "assigned_worker_id": complaint.assigned_worker_id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }


# ---------------------------
# RELEASE WORKER FROM COMPLAINT
# ---------------------------
def release_worker_from_complaint(db: Session, complaint_id: int):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        return None

    # Release worker
    if complaint.assigned_worker_id:
        worker = db.query(Worker).filter(Worker.id == complaint.assigned_worker_id).first()
        if worker:
            worker.status = "online"
            worker.current_job_id = None
            db.add(worker)

    complaint.assigned_worker_id = None
    complaint.status = ComplaintStatus.PENDING.value
    complaint.updated_at = datetime.utcnow()

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "assigned_worker_id": complaint.assigned_worker_id,
        "status": complaint.status,
        "updated_at": complaint.updated_at
    }