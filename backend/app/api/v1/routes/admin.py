from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.user import User
from app.core.dependencies import get_current_user

router = APIRouter()


# ---------------------------
# GET ALL USERS (ADMIN ONLY)
# ---------------------------
@router.get("/users")
def get_all_users(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    users = db.query(User).all()

    return {
        "status": "success",
        "message": "Users fetched successfully",
        "data": [
            {
                "id": u.id,
                "name": u.name,
                "email": u.email,
                "role": u.role
            }
            for u in users
        ]
    }


# ---------------------------
# GET SYSTEM STATS (ADMIN DASHBOARD)
# ---------------------------
@router.get("/stats")
def get_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_user)
):
    if admin.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    total_users = db.query(User).count()
    admin_users = db.query(User).filter(User.role == "admin").count()
    normal_users = db.query(User).filter(User.role == "user").count()

    return {
        "status": "success",
        "message": "System stats fetched",
        "data": {
            "total_users": total_users,
            "admin_users": admin_users,
            "normal_users": normal_users
        }
    }