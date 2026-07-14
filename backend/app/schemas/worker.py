# app/schemas/worker.py

from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class WorkerBase(BaseModel):
    name: str
    email: EmailStr
    phone: str
    zone: Optional[str] = None
    is_verified: Optional[bool] = False


class WorkerCreate(WorkerBase):
    user_id: int


class WorkerUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    zone: Optional[str] = None
    status: Optional[str] = None
    is_verified: Optional[bool] = None


class WorkerStatusUpdate(BaseModel):
    status: str


class WorkerLocationUpdate(BaseModel):
    latitude: float
    longitude: float


class WorkerResponse(WorkerBase):
    id: int
    user_id: int
    status: str
    current_job_id: Optional[int]
    latitude: Optional[float]
    longitude: Optional[float]
    last_location_update: Optional[datetime]
    complaints_completed: int
    average_rating: float
    is_verified: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class WorkerListResponse(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    zone: Optional[str]
    status: str
    complaints_completed: int
    average_rating: float
    is_verified: bool
    latitude: Optional[float]
    longitude: Optional[float]
    last_location_update: Optional[datetime]

    class Config:
        from_attributes = True