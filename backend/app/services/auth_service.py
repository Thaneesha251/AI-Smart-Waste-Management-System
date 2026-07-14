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


def generate_token(user):
    return create_access_token({
        "user_id": user.id,
        "role": user.role
    })