from sqlalchemy.orm import Session
from app.models.worker import Worker, WorkerStatus


def create_worker(db: Session, name: str, email: str = None, phone: str = None):
    db_worker = Worker(name=name, email=email, phone=phone)
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def get_worker(db: Session, worker_id: int):
    return db.query(Worker).filter(Worker.id == worker_id).first()


def get_all_workers(db: Session):
    return db.query(Worker).filter(Worker.is_active == True).all()


def get_available_workers(db: Session):
    """Get workers that are not assigned to active tasks"""
    return db.query(Worker).filter(
        Worker.is_active == True,
        Worker.status == WorkerStatus.available
    ).all()


def update_worker_status(db: Session, worker_id: int, status: WorkerStatus, current_task: str = None):
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return None
    
    db_worker.status = status
    if current_task is not None:
        db_worker.current_task = current_task
    
    db.add(db_worker)
    db.commit()
    db.refresh(db_worker)
    return db_worker


def assign_worker_to_complaint(db: Session, worker_id: int, complaint_id: int):
    """Assign a worker to a complaint and update their status"""
    db_worker = update_worker_status(
        db, 
        worker_id, 
        WorkerStatus.assigned, 
        f"Complaint #{complaint_id}"
    )
    return db_worker


def release_worker(db: Session, worker_id: int):
    """Release a worker from their current task"""
    db_worker = update_worker_status(
        db, 
        worker_id, 
        WorkerStatus.available, 
        "None"
    )
    return db_worker


def delete_worker(db: Session, worker_id: int):
    db_worker = get_worker(db, worker_id)
    if not db_worker:
        return False
    db_worker.is_active = False
    db.add(db_worker)
    db.commit()
    return True
