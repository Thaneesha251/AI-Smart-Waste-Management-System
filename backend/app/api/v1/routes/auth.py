from typing import Literal, Optional

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.services.auth_service import authenticate_user, generate_token, get_user_profile, update_user_profile
from app.utils.response import success, error

router = APIRouter()


class UpdateProfileRequest(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    theme_preference: Optional[Literal["light", "dark"]] = None


# ---------------------------
# LOGIN
# ---------------------------
@router.post("/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = authenticate_user(db, form_data.username, form_data.password)

    if not user:
        return error("Invalid credentials", status_code=401)

    token = generate_token(user)

    return success(
        "Login successful",
        {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "name": user.name,
                "email": user.email,
                "role": user.role
            }
        }
    )


# ---------------------------
# GET CURRENT USER PROFILE
# ---------------------------
@router.get("/me")
def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user = get_user_profile(db, current_user.id)

    if not user:
        return error("User profile not found", status_code=404)

    return success(
        "User profile fetched successfully",
        {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role,
            "theme_preference": user.theme_preference,
            "notifications_enabled": user.notifications_enabled,
        }
    )


# ---------------------------
# UPDATE CURRENT USER PROFILE
# ---------------------------
@router.put("/me")
def update_my_profile(
    payload: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    update_data = {
        key: value for key, value in payload.dict(exclude_unset=True).items()
        if value is not None
    }

    if not update_data:
        return error("No profile fields provided", status_code=400)

    updated_user = update_user_profile(db, current_user.id, update_data)

    if updated_user == "email_taken":
        return error("Email is already taken by another user", status_code=409)

    if not updated_user:
        return error("User profile not found", status_code=404)

    return success(
        "User profile updated successfully",
        {
            "id": updated_user.id,
            "name": updated_user.name,
            "email": updated_user.email,
            "role": updated_user.role,
            "theme_preference": updated_user.theme_preference,
            "notifications_enabled": updated_user.notifications_enabled,
        }
    )