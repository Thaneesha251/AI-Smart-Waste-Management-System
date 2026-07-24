from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.user import User
from app.models.worker import Worker

bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

    role = payload.get("role")
    user_id = payload.get("user_id")

    if role == "worker":
        worker = db.query(Worker).filter(Worker.id == user_id).first()
        if not worker:
            raise HTTPException(status_code=401, detail="Worker not found")
        return worker

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    return user


def get_current_worker(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

    if payload.get("role") != "worker":
        raise HTTPException(status_code=403, detail="Not authorized as worker")

    worker = db.query(Worker).filter(Worker.id == payload.get("user_id")).first()

    if not worker:
        raise HTTPException(status_code=401, detail="Worker not found")

    return worker
