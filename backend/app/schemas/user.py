from typing import Optional
from pydantic import BaseModel, EmailStr, ConfigDict


# =========================
# REGISTER USER
# =========================
class UserCreate(BaseModel):
    fullName: str
    email: EmailStr
    password: str
    phone: Optional[str] = None
    role: str = "citizen"
    area: Optional[str] = None
    address: Optional[str] = None


# =========================
# LOGIN USER
# =========================
class UserLogin(BaseModel):
    email: EmailStr
    password: str


# =========================
# UPDATE PROFILE
# =========================
class UserUpdate(BaseModel):
    fullName: Optional[str] = None
    phone: Optional[str] = None
    profileImage: Optional[str] = None
    password: Optional[str] = None
    area: Optional[str] = None
    address: Optional[str] = None


# =========================
# CHANGE PASSWORD
# =========================
class ChangePassword(BaseModel):
    currentPassword: str
    newPassword: str


# =========================
# FORGOT PASSWORD
# =========================
class ForgotPasswordRequest(BaseModel):
    email: EmailStr


# =========================
# RESET PASSWORD
# =========================
class ResetPassword(BaseModel):
    newPassword: str


# =========================
# RESPONSE MODEL
# =========================
class UserResponse(BaseModel):
    id: int
    fullName: str
    email: EmailStr
    phone: Optional[str] = None
    role: str
    profileImage: Optional[str] = None
    area: Optional[str] = None
    address: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
