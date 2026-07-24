from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

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

    # Citizen uploaded image
    imageUrl = Column(String(500), nullable=True)
    before_image = Column(String(500), nullable=True)

    # Worker uploaded image
    afterImageUrl = Column(String(500), nullable=True)
    after_image = Column(String(500), nullable=True)

    # Worker assignment
    worker_id = Column(Integer, ForeignKey("users.id"), nullable=True) # Legacy FK to Users
    assigned_worker_id = Column(Integer, ForeignKey("workers.id"), nullable=True)

    # Timestamps
    started_at = Column(DateTime(timezone=True), nullable=True) # Legacy
    assigned_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    worker = relationship("Worker", foreign_keys=[assigned_worker_id])
