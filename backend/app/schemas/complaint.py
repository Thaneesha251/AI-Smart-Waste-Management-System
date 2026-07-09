from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.complaint import ComplaintStatus


class ComplaintCreate(BaseModel):
    title: str
    description: str
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    citizen_id: Optional[int] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None


class ComplaintUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: Optional[ComplaintStatus] = None
    priority: Optional[str] = None


class ComplaintResponse(BaseModel):
    id: int
    citizen_id: Optional[int]
    title: str
    description: str
    location_name: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    status: ComplaintStatus
    priority: str
    category: Optional[str]
    tags: Optional[str]
    image_url: Optional[str]
    audio_url: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
