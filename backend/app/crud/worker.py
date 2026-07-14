# app/crud/worker.py

from sqlalchemy.orm import Session
from app.models.worker import Worker
from app.schemas.worker import WorkerCreate, WorkerUpdate
from sqlalchemy import desc
from typing import List, Optional


def create_worker(db: Session, worker: WorkerCreate) -> Worker:
    db_worker = Worker(
        user_id=worker.user_id,
        name=worker.name,
        email=worker.email,
        phone=worker.phone,
        zone=worker.zone,
        is_verified=worker.is_verified
    )
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def get_worker(db: Session, worker_id: int) -> Optional[Worker]:
    return db.query(Worker).filter(Worker.id == worker_id).first()


def get_worker_by_email(db: Session, email: str) -> Optional[Worker]:
    return db.query(Worker).filter(Worker.email == email).first()


def get_all_workers(db: Session, skip: int = 0, limit: int = 100) -> List[Worker]:
    return db.query(Worker).offset(skip).limit(limit).all()


def get_workers_by_zone(db: Session, zone: str, skip: int = 0, limit: int = 100) -> List[Worker]:
    return db.query(Worker).filter(Worker.zone == zone).offset(skip).limit(limit).all()


def get_workers_by_status(db: Session, status: str, skip: int = 0, limit: int = 100) -> List[Worker]:
    return db.query(Worker).filter(Worker.status == status).offset(skip).limit(limit).all()


def update_worker(db: Session, worker_id: int, worker_update: WorkerUpdate) -> Optional[Worker]:
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return None
    
    update_data = worker_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_worker, field, value)
    
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def update_worker_status(db: Session, worker_id: int, status: str) -> Optional[Worker]:
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return None
    
    db_worker.status = status
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def update_worker_location(db: Session, worker_id: int, latitude: float, longitude: float) -> Optional[Worker]:
    from datetime import datetime
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return None
    
    db_worker.latitude = latitude
    db_worker.longitude = longitude
    db_worker.last_location_update = datetime.utcnow()
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def delete_worker(db: Session, worker_id: int) -> bool:
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return False
    
    db.delete(db_worker)
    db.commit()
    return True


def get_workers_stats(db: Session) -> dict:
    total_workers = db.query(Worker).count()
    online_workers = db.query(Worker).filter(Worker.status == "online").count()
    on_job_workers = db.query(Worker).filter(Worker.status == "on-job").count()
    verified_workers = db.query(Worker).filter(Worker.is_verified == True).count()
    
    return {
        "total_workers": total_workers,
        "online_workers": online_workers,
        "on_job_workers": on_job_workers,
        "verified_workers": verified_workers
    }