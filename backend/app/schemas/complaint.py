from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

from app.models.enums import ComplaintStatus


# ---------------- CREATE ----------------
class ComplaintCreate(BaseModel):
    title: str = Field(..., max_length=255)
    description: str = Field(..., max_length=2000)
    location: Optional[str] = Field(None, max_length=255)


# ---------------- UPDATE ----------------
class ComplaintUpdate(BaseModel):
    title: Optional[str] = Field(None, max_length=255)
    description: Optional[str] = Field(None, max_length=2000)
    location: Optional[str] = Field(None, max_length=255)
    status: Optional[str] = None


# ---------------- RESPONSE ----------------
class ComplaintResponse(BaseModel):
    id: int
    title: str = Field(..., max_length=255)
    description: str = Field(..., max_length=2000)
    location: Optional[str] = Field(None, max_length=255)
    status: str
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ---------------- ASSIGNMENT ----------------
class ComplaintAssign(BaseModel):
    worker_id: int


# ---------------- STATUS UPDATE ----------------
class ComplaintStatusUpdate(BaseModel):
    status: ComplaintStatus