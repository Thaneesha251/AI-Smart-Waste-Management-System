from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt

from app.core.database import get_db
from app.core.config import settings
from app.models.user import User
from app.utils.response import success, error

router = APIRouter()


# ---------------------------
# CREATE JWT TOKEN
# ---------------------------
def create_access_token(data: dict):
    to_encode = data.copy()

    expire = datetime.utcnow() + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )

    to_encode.update({"exp": expire})

    return jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )


# ---------------------------
# REGISTER USER
# ---------------------------
@router.post("/register")
def register(email: str, password: str, role: str = "user", db: Session = Depends(get_db)):

    existing_user = db.query(User).filter(User.email == email).first()

    if existing_user:
        return error("User already exists")

    user = User(
        email=email,
        password=password,
        role=role
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return success(
        "User created successfully",
        {"id": user.id, "email": user.email}
    )


# ---------------------------
# LOGIN USER
# ---------------------------
@router.post("/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):

    user = db.query(User).filter(User.email == form_data.username).first()

    if not user or user.password != form_data.password:
        return error("Invalid credentials")

    token = create_access_token({
        "user_id": user.id,
        "role": user.role
    })

    return success(
        "Login successful",
        {
            "access_token": token,
            "token_type": "bearer"
        }
    )