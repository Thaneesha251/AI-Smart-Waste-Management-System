from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class WorkerBase(BaseModel):
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None


class WorkerCreate(WorkerBase):
    pass


class WorkerUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None
    current_task: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class WorkerResponse(WorkerBase):
    id: int
    status: str
    current_task: str
    latitude: float
    longitude: float
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class WorkerStatusUpdate(BaseModel):
    status: str
    current_task: Optional[str] = None
