from sqlalchemy import Column, Integer, String
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    fullName = Column(String)
    email = Column(String, unique=True, index=True)
    phone = Column(String, nullable=True)
    password = Column(String)
    role = Column(String, default="citizen")
    profileImage = Column(String, nullable=True)
    area = Column(String, nullable=True)
    address = Column(String, nullable=True)
