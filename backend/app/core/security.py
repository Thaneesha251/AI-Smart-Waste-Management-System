from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from app.core.config import settings

# passlib's bcrypt handles the 72-byte limit by default by throwing an error
# or truncating depending on configuration. We'll use the default secure setup.
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ---------------- PASSWORD ----------------
def hash_password(password: str) -> str:
    # Ensure password is truncated to 72 bytes for bcrypt safety if extremely long
    # Most user passwords won't hit this, but it prevents the 500 error mentioned.
    safe_password = password[:72]
    return pwd_context.hash(safe_password)


def verify_password(plain: str, hashed: str) -> bool:
    safe_password = plain[:72]
    return pwd_context.verify(safe_password, hashed)


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
