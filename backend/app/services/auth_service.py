from app.core.security import hash_password, verify_password, create_access_token
from app.models.user import User


def register_user(db, user_data):
    user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        role="officer"
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db, email, password):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password_hash):
        return None
    return user


def get_user_profile(db, user_id):
    return db.query(User).filter(User.id == user_id).first()


def update_user_profile(db, user_id, data):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None

    if "email" in data:
        new_email = data["email"]
        if new_email is not None:
            existing_user = db.query(User).filter(User.email == new_email).first()
            if existing_user and existing_user.id != user_id:
                return "email_taken"

    allowed_fields = {"name", "email", "theme_preference"}
    for field in allowed_fields:
        if field in data and data[field] is not None:
            setattr(user, field, data[field])

    db.commit()
    db.refresh(user)
    return user


def generate_token(user):
    return create_access_token({
        "user_id": user.id,
        "role": user.role
    })