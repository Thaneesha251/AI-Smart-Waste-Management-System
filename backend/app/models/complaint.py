from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func

from app.core.database import Base
from app.models.enums import ComplaintStatus


class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=False)
    location = Column(String(255), nullable=True)
    area = Column(String(255), nullable=True)
    zone = Column(String(100), nullable=True)

    status = Column(
        String(50),
        nullable=False,
        default=ComplaintStatus.PENDING.value
    )

    priority = Column(String(50), default="Medium")
    wasteType = Column(String(100), default="General")
    assignedAuthority = Column(String(255), default="City Municipality")
    expectedResolution = Column(DateTime(timezone=True), nullable=True)
    imageUrl = Column(String(500), nullable=True)
    afterImageUrl = Column(String(500), nullable=True)

    worker_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())