from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType

from app.core.database import get_db
from app.core.config import settings
from app.core.dependencies import get_current_user
from app.core.security import (
    hash_password,
    verify_password,
    create_reset_token,
    verify_reset_token,
)

from app.models.user import User

from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserResponse,
    UserUpdate,
    ForgotPasswordRequest,
    ResetPassword,
    ChangePassword,
)

from app.utils.response import success, error


router = APIRouter()


# =====================================================
# EMAIL CONFIGURATION
# =====================================================

conf = ConnectionConfig(
    MAIL_USERNAME=settings.MAIL_USERNAME,
    MAIL_PASSWORD=settings.MAIL_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.MAIL_PORT,
    MAIL_SERVER=settings.MAIL_SERVER,
    MAIL_FROM_NAME=settings.MAIL_FROM_NAME,
    MAIL_STARTTLS=settings.MAIL_STARTTLS,
    MAIL_SSL_TLS=settings.MAIL_SSL_TLS,
    USE_CREDENTIALS=settings.USE_CREDENTIALS,
    VALIDATE_CERTS=settings.VALIDATE_CERTS,
)



# =====================================================
# CREATE JWT TOKEN
# =====================================================

def create_access_token(data: dict):

    token_data = data.copy()

    expire = datetime.utcnow() + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )

    token_data.update({
        "exp": expire
    })


    return jwt.encode(
        token_data,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )



# =====================================================
# REGISTER USER
# =====================================================

@router.post("/register")
def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):

    existing_user = (
        db.query(User)
        .filter(User.email == user_data.email)
        .first()
    )


    if existing_user:
        return error(
            "User already exists",
            status_code=400
        )


    user = User(

        fullName=user_data.fullName,

        email=user_data.email,

        password=hash_password(
            user_data.password
        ),

        phone=user_data.phone,

        role=user_data.role,

        area=user_data.area,

        address=user_data.address,

        profileImage=None
    )


    db.add(user)
    db.commit()
    db.refresh(user)


    return success(
        "User created successfully",
        UserResponse.model_validate(user).model_dump()
    )



# =====================================================
# LOGIN USER
# =====================================================

@router.post("/login")
def login(
    user_data: UserLogin,
    db: Session = Depends(get_db)
):

    user = (
        db.query(User)
        .filter(User.email == user_data.email)
        .first()
    )


    if not user:

        return error(
            "Invalid credentials",
            status_code=401
        )



    if not verify_password(
        user_data.password,
        user.password
    ):

        return error(
            "Invalid credentials",
            status_code=401
        )



    token = create_access_token({

        "user_id": user.id,

        "role": user.role

    })


    return success(

        "Login successful",

        {

            "access_token": token,

            "token_type": "bearer",

            "user":
                UserResponse
                .model_validate(user)
                .model_dump()

        }

    )



# =====================================================
# CHANGE PASSWORD
# =====================================================

@router.put("/change-password")
def change_password(

    data: ChangePassword,

    db: Session = Depends(get_db),

    current_user: User = Depends(get_current_user)

):


    if not verify_password(
        data.currentPassword,
        current_user.password
    ):

        return error(
            "Current password is incorrect",
            status_code=400
        )


    current_user.password = hash_password(
        data.newPassword
    )


    db.commit()


    return success(
        "Password changed successfully"
    )



# =====================================================
# UPDATE PROFILE
# =====================================================

@router.put("/update-profile")
def update_profile(

    user_data: UserUpdate,

    db: Session = Depends(get_db),

    current_user: User = Depends(get_current_user)

):


    if user_data.fullName is not None:
        current_user.fullName = user_data.fullName


    if user_data.phone is not None:
        current_user.phone = user_data.phone


    if user_data.profileImage is not None:
        current_user.profileImage = user_data.profileImage


    if user_data.area is not None:
        current_user.area = user_data.area


    if user_data.address is not None:
        current_user.address = user_data.address



    db.commit()
    db.refresh(current_user)



    return success(

        "Profile updated successfully",

        UserResponse
        .model_validate(current_user)
        .model_dump()

    )



# =====================================================
# FORGOT PASSWORD
# =====================================================

@router.post("/forgot-password")
async def forgot_password(

    request: ForgotPasswordRequest,

    db: Session = Depends(get_db)

):

    user = (
        db.query(User)
        .filter(User.email == request.email)
        .first()
    )


    if not user:

        return error(
            "User with this email does not exist",
            status_code=404
        )


    token = create_reset_token(
        request.email
    )


    html = f"""

    <h2>
    AI Smart Waste Management System
    </h2>

    <p>
    Password reset request received.
    </p>

    <p>
    Reset Token:
    </p>

    <h3>
    {token}
    </h3>

    <p>
    Token expires in 15 minutes.
    </p>

    """



    message = MessageSchema(

        subject="Password Reset",

        recipients=[
            request.email
        ],

        body=html,

        subtype=MessageType.html

    )


    fm = FastMail(conf)


    try:

        await fm.send_message(message)


    except Exception as e:

        return error(
            f"Email sending failed: {str(e)}",
            status_code=500
        )



    return success(
        "Password reset email sent successfully"
    )



# =====================================================
# RESET PASSWORD
# =====================================================

@router.post("/reset-password/{token}")
def reset_password(

    token: str,

    request: ResetPassword,

    db: Session = Depends(get_db)

):


    email = verify_reset_token(token)



    if not email:

        return error(
            "Invalid or expired reset token",
            status_code=400
        )



    user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )



    if not user:

        return error(
            "User not found",
            status_code=404
        )



    user.password = hash_password(
        request.newPassword
    )


    db.commit()



    return success(
        "Password reset successfully"
    )