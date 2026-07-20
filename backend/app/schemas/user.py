from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    name: str = Field(..., max_length=255)
    email: EmailStr = Field(..., max_length=255)
    role: str = Field(default="officer", max_length=50)


class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=128)


class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    email: Optional[EmailStr] = Field(None, max_length=255)
    role: Optional[str] = Field(None, max_length=50)
    theme_preference: Optional[str] = None
    notifications_enabled: Optional[bool] = None


class UserResponse(UserBase):
    id: int
    theme_preference: str
    notifications_enabled: bool
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserCreate(BaseModel):
    name: str = Field(..., max_length=255)
    email: EmailStr = Field(..., max_length=255)
    password: str = Field(..., min_length=8, max_length=128)


class UserLogin(BaseModel):
    email: EmailStr = Field(..., max_length=255)
    password: str = Field(..., min_length=8, max_length=128)


class UserResponse(BaseModel):
    id: int
    name: str = Field(..., max_length=255)
    email: EmailStr = Field(..., max_length=255)
    role: str = Field(..., max_length=50)

    class Config:
        from_attributes = True
