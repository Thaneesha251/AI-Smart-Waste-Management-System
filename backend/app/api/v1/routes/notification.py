from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.services.notification_service import (
    create_notification,
    get_user_notifications,
    mark_all_notifications_read,
    mark_notification_read,
)
from app.utils.response import success, error

router = APIRouter(tags=["Notifications"])


@router.get("/")
def list_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    notifications = get_user_notifications(db, current_user.id)
    return success("Notifications fetched successfully", [
        {
            "id": n.id,
            "message": n.message,
            "is_read": n.is_read,
            "related_complaint_id": n.related_complaint_id,
            "created_at": n.created_at,
        }
        for n in notifications
    ])


@router.patch("/{notification_id}/read")
def read_notification(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    notification = mark_notification_read(db, notification_id, current_user.id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    return success("Notification marked as read", {
        "id": notification.id,
        "is_read": notification.is_read,
    })


@router.patch("/read-all")
def read_all_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    mark_all_notifications_read(db, current_user.id)
    return success("All notifications marked as read")
