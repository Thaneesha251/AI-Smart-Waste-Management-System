from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# ---------------- CREATE ----------------
class ComplaintCreate(BaseModel):
    title: str
    description: str
    location: Optional[str] = None
    area: Optional[str] = None
    zone: Optional[str] = None
    priority: Optional[str] = "Medium"
    wasteType: Optional[str] = "General"
    imageUrl: Optional[str] = None

# ---------------- UPDATE ----------------
class ComplaintUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[str] = None
    wasteType: Optional[str] = None
    status: Optional[str] = None

class ComplaintResponse(BaseModel):
    id: int
    title: str
    description: str
    location: Optional[str]
    area: Optional[str]
    zone: Optional[str]
    status: str
    priority: str
    wasteType: str
    assignedAuthority: str
    created_at: datetime
    updated_at: Optional[datetime]
    imageUrl: Optional[str]
    afterImageUrl: Optional[str]
    user_id: int
    worker_id: Optional[int] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True
