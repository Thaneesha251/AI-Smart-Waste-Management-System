from sqlalchemy import Column, Integer, String, DateTime, Text, Enum, Float, ForeignKey
from datetime import datetime
from app.core.database import Base
import enum


class ComplaintStatus(str, enum.Enum):
    pending = "pending"
    in_progress = "in_progress"
    resolved = "resolved"


class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)

    # User association
    citizen_id = Column(Integer, ForeignKey("users.id"), nullable=True) # Making nullable for now to avoid breaking existing data if any

    # Basic complaint data
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)

    # Location data
    location_name = Column(String(255), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Workflow status
    status = Column(Enum(ComplaintStatus), default=ComplaintStatus.pending)

    # Media fields
    image_url = Column(String(512), nullable=True)
    audio_url = Column(String(512), nullable=True)

    # AI-generated fields
    priority = Column(String(50), default="low")   # low / medium / high
    category = Column(String(100), nullable=True)  # garbage / drainage / etc.
    tags = Column(String(255), nullable=True)      # comma-separated tags

    # Timestamp
    created_at = Column(DateTime, default=datetime.utcnow)
