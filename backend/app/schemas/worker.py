# app/schemas/worker.py

from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class WorkerBase(BaseModel):
    name: str = Field(..., max_length=255)
    email: EmailStr = Field(..., max_length=255)
    phone: str = Field(..., max_length=20)
    zone: Optional[str] = Field(None, max_length=100)
    is_verified: Optional[bool] = False


class WorkerCreate(WorkerBase):
    user_id: int


class WorkerUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    zone: Optional[str] = Field(None, max_length=100)
    status: Optional[str] = Field(None, max_length=50)
    is_verified: Optional[bool] = None


class WorkerStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(offline|online|on-job)$")


class WorkerLocationUpdate(BaseModel):
    latitude: float
    longitude: float


class WorkerResponse(WorkerBase):
    id: int
    user_id: int
    status: str = Field(..., max_length=50)
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
    name: str = Field(..., max_length=255)
    email: str = Field(..., max_length=255)
    phone: str = Field(..., max_length=20)
    zone: Optional[str] = Field(None, max_length=100)
    status: str = Field(..., max_length=50)
    complaints_completed: int
    average_rating: float
    is_verified: bool
    latitude: Optional[float]
    longitude: Optional[float]
    last_location_update: Optional[datetime]

    class Config:
        from_attributes = True