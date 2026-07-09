from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, ForeignKey
from datetime import datetime
from app.core.database import Base
import enum


class NotificationType(str, enum.Enum):
    complaint_assigned = "complaint_assigned"
    complaint_resolved = "complaint_resolved"
    complaint_updated = "complaint_updated"
    worker_status = "worker_status"
    system_alert = "system_alert"


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    notification_type = Column(String(50), nullable=False)
    is_read = Column(Boolean, default=False)
    complaint_id = Column(Integer, ForeignKey("complaints.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
