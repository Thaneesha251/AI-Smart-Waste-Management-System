<<<<<<< HEAD
from sqlalchemy import Column, Integer, String, DateTime, Text, Enum, Boolean, Float, ForeignKey
from datetime import datetime
from app.core.database import Base
import enum


class ComplaintStatus(str, enum.Enum):
    pending = "pending"
    in_progress = "in_progress"
    resolved = "resolved"
    cancelled = "cancelled"
=======
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func

from app.core.database import Base
from app.models.enums import ComplaintStatus
>>>>>>> origin/main


class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=False)

    status = Column(
        String(50),
        nullable=False,
        default=ComplaintStatus.PENDING.value
    )

<<<<<<< HEAD
    # AI-generated fields (NEW)
    priority = Column(String(50), default="low")   # low / medium / high
    category = Column(String(100), nullable=True)  # garbage / drainage / etc.
    tags = Column(String(255), nullable=True)      # comma-separated tags

    # Worker assignment
    assigned_worker_id = Column(Integer, ForeignKey("workers.id"), nullable=True)

    # Timestamp
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
=======
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
>>>>>>> origin/main
