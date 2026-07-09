from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.notification import NotificationCreate, NotificationResponse, NotificationUpdate
from app.crud.notification import (
    create_notification,
    get_notification,
    get_user_notifications,
    get_unread_notifications,
    mark_as_read,
    mark_all_as_read,
    delete_notification
)
from app.api.v1.routes.auth import get_current_user

router = APIRouter()


# CREATE NOTIFICATION
@router.post("/", response_model=NotificationResponse)
def create_notification_api(
    data: NotificationCreate,
    db: Session = Depends(get_db)
):
    notification = create_notification(
        db,
        title=data.title,
        description=data.description,
        notification_type=data.notification_type,
        user_id=data.user_id,
        complaint_id=data.complaint_id
    )
    return notification


# GET USER NOTIFICATIONS
@router.get("/", response_model=list[NotificationResponse])
def get_notifications(
    authorization: str = None,
    db: Session = Depends(get_db)
):
    user = get_current_user(authorization, db)
    notifications = get_user_notifications(db, user.id)
    return notifications


# GET UNREAD NOTIFICATIONS
@router.get("/unread", response_model=list[NotificationResponse])
def get_unread(
    authorization: str = None,
    db: Session = Depends(get_db)
):
    user = get_current_user(authorization, db)
    notifications = get_unread_notifications(db, user.id)
    return notifications


# GET UNREAD COUNT
@router.get("/unread/count")
def get_unread_count(
    authorization: str = None,
    db: Session = Depends(get_db)
):
    user = get_current_user(authorization, db)
    notifications = get_unread_notifications(db, user.id)
    return {"unread_count": len(notifications)}


# MARK AS READ
@router.put("/{notification_id}/read", response_model=NotificationResponse)
def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db)
):
    notification = mark_as_read(db, notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    return notification


# MARK ALL AS READ
@router.put("/mark-all/read")
def mark_all_notifications_read(
    authorization: str = None,
    db: Session = Depends(get_db)
):
    user = get_current_user(authorization, db)
    count = mark_all_as_read(db, user.id)
    return {"message": f"Marked {count} notifications as read"}


# DELETE NOTIFICATION
@router.delete("/{notification_id}")
def delete_notification_api(
    notification_id: int,
    db: Session = Depends(get_db)
):
    success = delete_notification(db, notification_id)
    if not success:
        raise HTTPException(status_code=404, detail="Notification not found")
    return {"message": "Notification deleted successfully"}
