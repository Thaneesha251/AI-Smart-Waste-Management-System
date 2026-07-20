from sqlalchemy.orm import Session
from datetime import datetime, date, time

from app.models.complaint import Complaint
from app.models.enums import ComplaintStatus
from app.models.worker import Worker
from app.services.notification_service import create_notification


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


def _parse_filter_datetime(value: str, end: bool = False):
    if not value:
        return None

    try:
        parsed_date = date.fromisoformat(value)
        return datetime.combine(parsed_date, time.max if end else time.min)
    except ValueError:
        try:
            return datetime.fromisoformat(value)
        except ValueError:
            return None


def get_filtered_complaints(
    db: Session,
    status: str = None,
    zone: str = None,
    worker_id: int = None,
    date_from: str = None,
    date_to: str = None,
    skip: int = 0,
    limit: int = 20,
):
    query = db.query(Complaint)

    if status:
        query = query.filter(Complaint.status == status)

    if worker_id is not None:
        query = query.filter(Complaint.assigned_worker_id == worker_id)

    if zone:
        query = (
            query.outerjoin(Worker, Complaint.assigned_worker_id == Worker.id)
            .filter(Worker.zone == zone)
        )

    if date_from:
        parsed_from = _parse_filter_datetime(date_from, end=False)
        if parsed_from:
            query = query.filter(Complaint.created_at >= parsed_from)

    if date_to:
        parsed_to = _parse_filter_datetime(date_to, end=True)
        if parsed_to:
            query = query.filter(Complaint.created_at <= parsed_to)

    total = query.order_by(Complaint.created_at.desc()).count()

    complaints = (
        query.order_by(Complaint.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    return {
        "results": [
            {
                "id": c.id,
                "user_id": c.user_id,
                "title": c.title,
                "description": c.description,
                "status": c.status,
                "created_at": c.created_at,
                "updated_at": c.updated_at,
            }
            for c in complaints
        ],
        "total": total,
        "skip": skip,
        "limit": limit,
    }


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

    if complaint.user_id:
        create_notification(
            db,
            complaint.user_id,
            f"Your complaint #{complaint.id} status changed to '{complaint.status}'",
            complaint.id,
        )

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

    if worker.user_id:
        create_notification(
            db,
            worker.user_id,
            f"You have been assigned to complaint #{complaint.id}: {complaint.title}",
            complaint.id,
        )

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


# ---------------------------
# GET PENDING VERIFICATIONS (ADMIN/OFFICER)
# ---------------------------
def get_pending_verifications(db: Session):
    complaints = (
        db.query(Complaint, Worker)
        .outerjoin(Worker, Complaint.assigned_worker_id == Worker.id)
        .filter(Complaint.status == ComplaintStatus.RESOLVED.value)
        .filter(Complaint.before_photo_url.isnot(None))
        .filter(Complaint.after_photo_url.isnot(None))
        .filter(Complaint.is_verified == False)
        .order_by(Complaint.created_at.desc())
        .all()
    )

    results = []
    for c, w in complaints:
        results.append({
            "id": c.id,
            "title": c.title,
            "assigned_worker_id": c.assigned_worker_id,
            "worker_name": w.name if w else None,
            "category": c.category,
            "status": c.status,
            "before_photo_url": c.before_photo_url,
            "after_photo_url": c.after_photo_url,
            "created_at": c.created_at,
        })

    return results


# ---------------------------
# VERIFY COMPLAINT (ADMIN/OFFICER)
# ---------------------------
def verify_complaint(db: Session, complaint_id: int, approved: bool):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return None

    # Approved: mark the complaint as verified
    if approved:
        complaint.is_verified = True
        complaint.updated_at = datetime.utcnow()

        db.add(complaint)
        db.commit()
        db.refresh(complaint)

        if complaint.user_id:
            create_notification(
                db,
                complaint.user_id,
                f"Your complaint #{complaint.id} has been verified",
                complaint.id,
            )

        return {
            "id": complaint.id,
            "is_verified": complaint.is_verified,
            "status": complaint.status,
            "updated_at": complaint.updated_at,
        }

    # Not approved: revert status back to in_progress so worker can redo
    complaint.status = ComplaintStatus.IN_PROGRESS.value
    complaint.is_verified = False
    complaint.updated_at = datetime.utcnow()

    # Restore worker assignment state if there is an assigned worker
    if complaint.assigned_worker_id:
        worker = db.query(Worker).filter(Worker.id == complaint.assigned_worker_id).first()
        if worker:
            worker.status = "on-job"
            worker.current_job_id = complaint.id
            # If complaints_completed was incremented when resolved, try to decrement
            try:
                if worker.complaints_completed and worker.complaints_completed > 0:
                    worker.complaints_completed = worker.complaints_completed - 1
            except Exception:
                pass
            db.add(worker)

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    if complaint.user_id:
        create_notification(
            db,
            complaint.user_id,
            f"Your complaint #{complaint.id} was not verified and set back to in_progress",
            complaint.id,
        )

    return {
        "id": complaint.id,
        "is_verified": complaint.is_verified,
        "status": complaint.status,
        "updated_at": complaint.updated_at,
    }
# ---------------------------
# UPDATE COMPLAINT PHOTO
# ---------------------------
def update_complaint_photo(db: Session, complaint_id: int, photo_type: str, url: str):
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()

    if not complaint:
        return None

    if photo_type == "before":
        complaint.before_photo_url = url
    elif photo_type == "after":
        complaint.after_photo_url = url

    complaint.updated_at = datetime.utcnow()

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return {
        "id": complaint.id,
        "before_photo_url": complaint.before_photo_url,
        "after_photo_url": complaint.after_photo_url,
        "updated_at": complaint.updated_at
    }
