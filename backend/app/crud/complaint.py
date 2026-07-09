from sqlalchemy.orm import Session
from app.models.complaint import Complaint, ComplaintStatus
from app.schemas.complaint import ComplaintCreate, ComplaintUpdate
from app.ai.engine import analyze_complaint


# CREATE
def create_complaint(db: Session, data: ComplaintCreate):
    try:
        ai_result = analyze_complaint(data.description)
    except Exception as e:
        ai_result = {}

    category_val = "general"
    classification = ai_result.get("classification")
    if isinstance(classification, dict):
        category_val = classification.get("category", "general")
    elif isinstance(classification, str):
        category_val = classification

    complaint = Complaint(
        citizen_id=data.citizen_id,
        title=data.title,
        description=data.description,
        location_name=data.location_name,
        latitude=data.latitude,
        longitude=data.longitude,
        image_url=data.image_url,
        audio_url=data.audio_url,
        status=ComplaintStatus.pending,
        priority=ai_result.get("priority", "low"),
        category=category_val,
        tags=",".join(ai_result.get("tags", [])) if ai_result.get("tags") else None
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

# READ BY CITIZEN
def get_citizen_complaints(db: Session, citizen_id: int):
    return db.query(Complaint).filter(Complaint.citizen_id == citizen_id).all()


# READ ONE
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

    if data.location_name is not None:
        complaint.location_name = data.location_name

    if data.latitude is not None:
        complaint.latitude = data.latitude

    if data.longitude is not None:
        complaint.longitude = data.longitude

    if data.status is not None:
        complaint.status = data.status

    if data.priority is not None:
        complaint.priority = data.priority

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


# SEARCH
def search_complaints(db: Session, query: str):
    """Search complaints by ID or category (waste type)"""
    # Try to search by ID first
    try:
        complaint_id = int(query.strip().lstrip('#'))
        complaint = get_complaint(db, complaint_id)
        if complaint:
            return [complaint]
    except (ValueError, TypeError):
        pass
    
    # Search by category/waste type (case-insensitive, partial match)
    query_lower = query.lower()
    complaints = db.query(Complaint).filter(
        Complaint.category.ilike(f"%{query_lower}%")
    ).all()
    
    return complaints


# WORKER ASSIGNMENT
def assign_worker_to_complaint(db: Session, complaint_id: int, worker_id: int):
    complaint = get_complaint(db, complaint_id)
    if not complaint:
        return None
    
    complaint.assigned_worker_id = worker_id
    complaint.status = ComplaintStatus.in_progress
    db.add(complaint)
    db.commit()
    db.refresh(complaint)
    
    return complaint


def get_active_complaints_for_worker(db: Session, worker_id: int):
    """Get all active complaints assigned to a worker"""
    active_statuses = [ComplaintStatus.pending, ComplaintStatus.in_progress]
    return db.query(Complaint).filter(
        Complaint.assigned_worker_id == worker_id,
        Complaint.status.in_(active_statuses)
    ).all()


def release_worker_from_complaint(db: Session, complaint_id: int):
    """Release worker from a complaint"""
    complaint = get_complaint(db, complaint_id)
    if not complaint:
        return None
    
    complaint.assigned_worker_id = None
    db.add(complaint)
    db.commit()
    db.refresh(complaint)
    
    return complaint