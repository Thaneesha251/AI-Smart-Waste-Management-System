from sqlalchemy import Column, Integer, String, DateTime, Float, Enum, Boolean
from datetime import datetime
from app.core.database import Base
import enum


class WorkerStatus(str, enum.Enum):
    available = "available"
    assigned = "assigned"
    offline = "offline"


class Worker(Base):
    __tablename__ = "workers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True)
    email = Column(String(255), unique=True, nullable=True)
    phone = Column(String(20), nullable=True)
    status = Column(Enum(WorkerStatus), default=WorkerStatus.available)
    current_task = Column(String(255), default="None")  # Complaint ID or "None"
    latitude = Column(Float, default=11.0168)
    longitude = Column(Float, default=76.9558)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
