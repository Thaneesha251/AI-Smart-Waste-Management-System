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
