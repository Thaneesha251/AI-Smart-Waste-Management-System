from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.core.dependencies import get_db
from app.crud import worker as worker_crud
from app.schemas.worker import (
    WorkerCreate, WorkerUpdate, WorkerResponse, WorkerStatusUpdate,
    WorkerLocationUpdate, WorkerListResponse
)
from app.utils.response import success
from app.core.rbac import require_role

router = APIRouter()


# CREATE WORKER
@router.post("/")
def create_worker(
    worker: WorkerCreate,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin"))
):
    """Create a new worker (Admin only)"""
    existing = worker_crud.get_worker_by_email(db, worker.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    db_worker = worker_crud.create_worker(db, worker)
    return success(
        message="Worker created successfully",
        data=WorkerResponse.model_validate(db_worker).model_dump(mode="json")
    )


# GET ALL WORKERS
@router.get("/")
def list_workers(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    zone: str = Query(None),
    status: str = Query(None),
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin", "officer"))
):
    """List all workers with optional filtering"""
    if zone:
        workers = worker_crud.get_workers_by_zone(db, zone, skip, limit)
    elif status:
        workers = worker_crud.get_workers_by_status(db, status, skip, limit)
    else:
        workers = worker_crud.get_all_workers(db, skip, limit)

    data = [WorkerListResponse.model_validate(w).model_dump(mode="json") for w in workers]
    return success(message="Workers fetched successfully", data=data)


# GET SINGLE WORKER
@router.get("/{worker_id}")
def get_worker(
    worker_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin", "officer", "worker"))
):
    """Get single worker details"""
    worker = worker_crud.get_worker(db, worker_id)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return success(
        message="Worker fetched successfully",
        data=WorkerResponse.model_validate(worker).model_dump(mode="json")
    )


# UPDATE WORKER
@router.put("/{worker_id}")
def update_worker(
    worker_id: int,
    worker_update: WorkerUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin"))
):
    """Update worker details (Admin only)"""
    worker = worker_crud.update_worker(db, worker_id, worker_update)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return success(
        message="Worker updated successfully",
        data=WorkerResponse.model_validate(worker).model_dump(mode="json")
    )


# UPDATE WORKER STATUS
@router.patch("/{worker_id}/status")
def update_worker_status(
    worker_id: int,
    status_update: WorkerStatusUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin", "worker"))
):
    """Update worker status (online/offline/on-job)"""
    if status_update.status not in ["offline", "online", "on-job"]:
        raise HTTPException(status_code=400, detail="Invalid status")

    worker = worker_crud.update_worker_status(db, worker_id, status_update.status)
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return success(
        message="Worker status updated successfully",
        data=WorkerResponse.model_validate(worker).model_dump(mode="json")
    )


# UPDATE WORKER LOCATION
@router.post("/{worker_id}/location")
def update_location(
    worker_id: int,
    location: WorkerLocationUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("worker", "admin"))
):
    """Update worker GPS location"""
    worker = worker_crud.update_worker_location(
        db, worker_id, location.latitude, location.longitude
    )
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return success(
        message="Location updated successfully",
        data=WorkerResponse.model_validate(worker).model_dump(mode="json")
    )


# DELETE WORKER
@router.delete("/{worker_id}")
def delete_worker(
    worker_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin"))
):
    """Delete a worker (Admin only)"""
    deleted = worker_crud.delete_worker(db, worker_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Worker not found")

    return success(message="Worker deleted successfully")


# GET WORKER PERFORMANCE REPORT
@router.get("/report/performance")
def get_worker_performance_report(
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin", "officer"))
):
    """Get worker performance report ordered by complaints completed"""
    report = worker_crud.get_worker_performance_report(db)
    return success(message="Worker performance report fetched successfully", data=report)


# GET WORKERS STATS
@router.get("/stats/overview")
def get_workers_stats(
    db: Session = Depends(get_db),
    current_user = Depends(require_role("admin", "officer"))
):
    """Get workers statistics"""
    stats = worker_crud.get_workers_stats(db)
    return success(message="Workers stats fetched successfully", data=stats)