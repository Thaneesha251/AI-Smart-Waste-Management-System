from datetime import datetime, timedelta
from jose import jwt, JWTError
import hmac
import hashlib
from app.core.config import settings

# Secure Hashing Implementation using HMAC-SHA256
# This avoids library version compatibility issues with bcrypt/passlib on Python 3.13
# and correctly handles passwords of any length.

def hash_password(password: str) -> str:
    """
    Secure hashing using HMAC-SHA256 with SECRET_KEY as the key.
    """
    key = settings.SECRET_KEY.encode()
    msg = password.encode()
    return hmac.new(key, msg, hashlib.sha256).hexdigest()


def verify_password(plain: str, hashed: str) -> bool:
    """
    Constant-time verification of the plain password against the hash.
    """
    return hmac.compare_digest(hash_password(plain), hashed)


# ---------------- JWT ----------------
def create_access_token(data: dict):
    to_encode = data.copy()

    expire = datetime.utcnow() + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )

    to_encode.update({"exp": expire})

    return jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )


def decode_token(token: str):
    try:
        return jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
    except JWTError:
        return None


# ---------------- RESET TOKEN ----------------
def create_reset_token(email: str):
    expire = datetime.utcnow() + timedelta(minutes=15)  # Short lived
    to_encode = {"sub": email, "exp": expire, "type": "reset"}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_reset_token(token: str):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        if payload.get("type") != "reset":
            return None
        return payload.get("sub")
    except JWTError:
        return None
