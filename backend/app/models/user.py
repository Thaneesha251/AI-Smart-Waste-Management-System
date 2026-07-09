<<<<<<< HEAD
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from datetime import datetime
from app.core.database import Base
import enum
=======
from sqlalchemy import Column, Integer, String
from app.core.database import Base
>>>>>>> origin/main


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
<<<<<<< HEAD
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), default="officer")  # officer / admin / manager
    is_active = Column(Boolean, default=True)
    theme_preference = Column(String(20), default="light")  # light / dark / system
    notifications_enabled = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
=======
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String, default="user")
>>>>>>> origin/main
