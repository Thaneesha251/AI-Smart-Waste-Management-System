from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.models.notification import Notification
from app.models.user import User


def create_notification(db: Session, user_id: int, message: str, related_complaint_id: int = None):
    notification = Notification(
        user_id=user_id,
        message=message,
        related_complaint_id=related_complaint_id,
        is_read=False,
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification


def get_user_notifications(db: Session, user_id: int):
    notifications = (
        db.query(Notification)
        .filter(Notification.user_id == user_id)
        .order_by(desc(Notification.created_at))
        .all()
    )
    return notifications


def mark_notification_read(db: Session, notification_id: int, user_id: int):
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == user_id)
        .first()
    )

    if not notification:
        return None

    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification


def mark_all_notifications_read(db: Session, user_id: int):
    notifications = (
        db.query(Notification)
        .filter(Notification.user_id == user_id)
        .all()
    )

    for notification in notifications:
        notification.is_read = True

    db.commit()
    return notifications
