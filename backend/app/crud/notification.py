from sqlalchemy.orm import Session
from app.models.notification import Notification
from datetime import datetime


def create_notification(
    db: Session,
    title: str,
    description: str,
    notification_type: str,
    user_id: int = None,
    complaint_id: int = None
):
    db_notification = Notification(
        title=title,
        description=description,
        notification_type=notification_type,
        user_id=user_id,
        complaint_id=complaint_id,
        is_read=False
    )
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification


def get_notification(db: Session, notification_id: int):
    return db.query(Notification).filter(Notification.id == notification_id).first()


def get_user_notifications(db: Session, user_id: int, limit: int = 50):
    return db.query(Notification).filter(
        Notification.user_id == user_id
    ).order_by(Notification.created_at.desc()).limit(limit).all()


def get_unread_notifications(db: Session, user_id: int):
    return db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).order_by(Notification.created_at.desc()).all()


def mark_as_read(db: Session, notification_id: int):
    db_notification = get_notification(db, notification_id)
    if not db_notification:
        return None
    
    db_notification.is_read = True
    db_notification.updated_at = datetime.utcnow()
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification


def mark_all_as_read(db: Session, user_id: int):
    notifications = db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).all()
    
    for notification in notifications:
        notification.is_read = True
        notification.updated_at = datetime.utcnow()
        db.add(notification)
    
    db.commit()
    return len(notifications)


def delete_notification(db: Session, notification_id: int):
    db_notification = get_notification(db, notification_id)
    if not db_notification:
        return False
    db.delete(db_notification)
    db.commit()
    return True
