from fastapi import APIRouter, Depends, HTTPException
<<<<<<< HEAD
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.user import UserCreate, UserResponse, UserUpdate
from app.crud.user import create_user, get_user_by_email, get_user, update_user
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta
import jwt

router = APIRouter()

SECRET_KEY = "your-secret-key-change-this-in-production"
ALGORITHM = "HS256"


def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(days=7)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except:
        return None


def get_current_user(authorization: str = None, db: Session = Depends(get_db)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        token = authorization.replace("Bearer ", "")
        payload = verify_token(token)
        if payload is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        user_id = payload.get("sub")
        user = get_user(db, user_id)
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid token")


# REGISTER
@router.post("/register", response_model=UserResponse)
def register(data: UserCreate, db: Session = Depends(get_db)):
    existing_user = get_user_by_email(db, data.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user = create_user(db, data)
    return user


# LOGIN
@router.post("/login")
def login(email: str, password: str, db: Session = Depends(get_db)):
    user = get_user_by_email(db, email)
    if not user or not check_password_hash(user.password_hash, password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": user.id})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role,
            "theme_preference": user.theme_preference
        }
    }


# GET CURRENT USER
@router.get("/me", response_model=UserResponse)
def get_current_user_endpoint(
    authorization: str = None,
    db: Session = Depends(get_db)
):
    return get_current_user(authorization, db)


# UPDATE USER SETTINGS
@router.put("/settings", response_model=UserResponse)
def update_user_settings(
    data: UserUpdate,
    authorization: str = None,
    db: Session = Depends(get_db)
):
    user = get_current_user(authorization, db)
    updated_user = update_user(db, user.id, data)
    return updated_user


# LOGOUT
@router.post("/logout")
def logout():
    return {"message": "Logged out successfully"}
=======
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
>>>>>>> origin/main
