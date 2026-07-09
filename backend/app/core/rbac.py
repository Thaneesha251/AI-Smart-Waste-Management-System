from fastapi import Depends, HTTPException, status
from app.core.dependencies import get_current_user
from app.models.user import User


# ---------------------------
# ROLE CHECK: ADMIN ONLY
# ---------------------------
def require_admin(user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return user


# ---------------------------
# ROLE CHECK: USER OR ADMIN (optional use later)
# ---------------------------
def require_user(user: User = Depends(get_current_user)):
    if user.role not in ["user", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User access required"
        )
    return user