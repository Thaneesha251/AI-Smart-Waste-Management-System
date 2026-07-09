from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# ---------------- CREATE ----------------
class ComplaintCreate(BaseModel):
    title: str
    description: str
    location: Optional[str] = None


# ---------------- UPDATE ----------------
class ComplaintUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    status: Optional[str] = None


# ---------------- RESPONSE ----------------
class ComplaintResponse(BaseModel):
    id: int
    title: str
    description: str
    location: Optional[str]
    status: str
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True