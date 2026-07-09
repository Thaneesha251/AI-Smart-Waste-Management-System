from sqlalchemy import Column, Integer, String, DateTime, Text, Enum, Boolean, Float, ForeignKey
from datetime import datetime
from app.core.database import Base
import enum


class ComplaintStatus(str, enum.Enum):
    pending = "pending"
    in_progress = "in_progress"
    resolved = "resolved"
    cancelled = "cancelled"


class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)

    # Basic complaint data
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    location = Column(String(255), nullable=True)

    # Workflow status
    status = Column(Enum(ComplaintStatus), default=ComplaintStatus.pending)

    # AI-generated fields (NEW)
    priority = Column(String(50), default="low")   # low / medium / high
    category = Column(String(100), nullable=True)  # garbage / drainage / etc.
    tags = Column(String(255), nullable=True)      # comma-separated tags

    # Worker assignment
    assigned_worker_id = Column(Integer, ForeignKey("workers.id"), nullable=True)

    # Timestamp
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)