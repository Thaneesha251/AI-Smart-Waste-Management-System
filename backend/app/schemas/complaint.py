from pydantic import BaseModel
from typing import Optional
from app.models.complaint import ComplaintStatus


class ComplaintCreate(BaseModel):
    title: str
    description: str
    location: Optional[str] = None


class ComplaintUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    status: Optional[ComplaintStatus] = None


class ComplaintResponse(BaseModel):
    id: int
    title: str
    description: str
    location: Optional[str]
    status: ComplaintStatus
    created_at: str

    class Config:
        from_attributes = True