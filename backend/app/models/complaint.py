from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func

from app.core.database import Base
from app.models.enums import ComplaintStatus


class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=False)
    status = Column(
        String(50),
        nullable=False,
        default=ComplaintStatus.PENDING.value,
        index=True
    )
    priority = Column(String(50), default="low")
    category = Column(String(100), nullable=True)
    tags = Column(String(255), nullable=True)
    assigned_worker_id = Column(Integer, ForeignKey("workers.id"), nullable=True, index=True)
    before_photo_url = Column(String(500), nullable=True)
    after_photo_url = Column(String(500), nullable=True)
    is_verified = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())