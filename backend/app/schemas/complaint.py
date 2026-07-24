from pydantic import BaseModel, Field, computed_field
from typing import Optional
from datetime import datetime
from app.schemas.user import UserResponse

# ---------------- CREATE ----------------
class ComplaintCreate(BaseModel):
    title: str
    description: str
    location: Optional[str] = None
    area: Optional[str] = None
    zone: Optional[str] = None
    priority: Optional[str] = "Medium"
    wasteType: Optional[str] = "General"
    image_url: Optional[str] = Field(None, alias="imageUrl")

    model_config = {
        "populate_by_name": True
    }

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

    # Database fields
    imageUrl: Optional[str] = Field(None, exclude=True)
    afterImageUrl: Optional[str] = Field(None, exclude=True)

    @computed_field
    @property
    def image_url(self) -> Optional[str]:
        return self.imageUrl

    @computed_field
    @property
    def after_image_url(self) -> Optional[str]:
        return self.afterImageUrl

    user_id: int
    assigned_worker_id: Optional[int] = None
    assigned_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

    model_config = {
        "from_attributes": True,
        "populate_by_name": True
    }

class ComplaintDetailResponse(ComplaintResponse):
    user: Optional[UserResponse] = None
