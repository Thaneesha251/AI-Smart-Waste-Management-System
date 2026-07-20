from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime

from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    message = Column(String(1000), nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    related_complaint_id = Column(Integer, ForeignKey("complaints.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
