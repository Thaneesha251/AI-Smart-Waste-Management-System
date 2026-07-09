from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.worker import WorkerCreate, WorkerResponse, WorkerUpdate, WorkerStatusUpdate
from app.crud.worker import (
    create_worker,
    get_worker,
    get_all_workers,
    get_available_workers,
    update_worker_status,
    assign_worker_to_complaint,
    release_worker,
    delete_worker
)

router = APIRouter()


# CREATE WORKER
@router.post("/", response_model=WorkerResponse)
def create_worker_api(data: WorkerCreate, db: Session = Depends(get_db)):
    worker = create_worker(db, data.name, data.email, data.phone)
    return worker


# GET ALL WORKERS
@router.get("/", response_model=list[WorkerResponse])
def get_workers(db: Session = Depends(get_db)):
    workers = get_all_workers(db)
    return workers


# GET AVAILABLE WORKERS
@router.get("/available", response_model=list[WorkerResponse])
def get_available(db: Session = Depends(get_db)):
    workers = get_available_workers(db)
    return workers


# GET WORKER BY ID
@router.get("/{worker_id}", response_model=WorkerResponse)
def get_worker_by_id(worker_id: int, db: Session = Depends(get_db)):
    worker = get_worker(db, worker_id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker


# UPDATE WORKER STATUS
@router.put("/{worker_id}/status", response_model=WorkerResponse)
def update_status(
    worker_id: int,
    data: WorkerStatusUpdate,
    db: Session = Depends(get_db)
):
    worker = update_worker_status(db, worker_id, data.status, data.current_task)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker


# ASSIGN WORKER TO COMPLAINT
@router.post("/{worker_id}/assign/{complaint_id}", response_model=WorkerResponse)
def assign_to_complaint(
    worker_id: int,
    complaint_id: int,
    db: Session = Depends(get_db)
):
    worker = assign_worker_to_complaint(db, worker_id, complaint_id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker


# RELEASE WORKER
@router.post("/{worker_id}/release", response_model=WorkerResponse)
def release_worker_api(worker_id: int, db: Session = Depends(get_db)):
    worker = release_worker(db, worker_id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    return worker


# DELETE WORKER
@router.delete("/{worker_id}")
def delete_worker_api(worker_id: int, db: Session = Depends(get_db)):
    success = delete_worker(db, worker_id)
    if not success:
        raise HTTPException(status_code=404, detail="Worker not found")
    return {"message": "Worker deleted successfully"}
