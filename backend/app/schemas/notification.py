from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class NotificationBase(BaseModel):
    title: str
    description: str
    notification_type: str
    complaint_id: Optional[int] = None


class NotificationCreate(NotificationBase):
    user_id: Optional[int] = None


class NotificationResponse(NotificationBase):
    id: int
    user_id: Optional[int]
    is_read: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None
