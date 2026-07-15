from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate
from app.utils.response import success, error
from app.core.security import hash_password

router = APIRouter()

@router.get("/me", response_model=None)
def get_me(current_user: User = Depends(get_current_user)):
    return success(
        "User profile fetched successfully",
        UserResponse.from_orm(current_user).dict()
    )

@router.put("/me", response_model=None)
def update_me(
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if user_data.fullName is not None:
        current_user.fullName = user_data.fullName
    if user_data.phone is not None:
        current_user.phone = user_data.phone
    if user_data.profileImage is not None:
        current_user.profileImage = user_data.profileImage
    if user_data.area is not None:
        current_user.area = user_data.area
    if user_data.address is not None:
        current_user.address = user_data.address

    if user_data.password is not None:
        current_user.password = hash_password(user_data.password)

    db.commit()
    db.refresh(current_user)

    return success(
        "Profile updated successfully",
        UserResponse.from_orm(current_user).dict()
    )
