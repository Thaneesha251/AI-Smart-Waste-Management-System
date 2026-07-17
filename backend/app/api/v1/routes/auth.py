from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
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
    create_access_token,
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
        password=hash_password(user_data.password),
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


    if not verify_password(user_data.password, user.password):
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
            "user": UserResponse.model_validate(user).model_dump()
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


    if not verify_password(data.currentPassword, current_user.password):
        return error(
            "Current password is incorrect",
            status_code=400
        )


    current_user.password = hash_password(data.newPassword)
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

    if user_data.password is not None:
        current_user.password = hash_password(user_data.password)


    db.commit()
    db.refresh(current_user)


    return success(
        "Profile updated successfully",
        UserResponse.model_validate(current_user).model_dump()
    )



# =====================================================
# FORGOT PASSWORD
# =====================================================

@router.post("/forgot-password")
async def forgot_password(
    request: ForgotPasswordRequest,
    background_tasks: BackgroundTasks,
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


    token = create_reset_token(request.email)
    # Production-style reset link pointing to the server IP for deep linking
    reset_link = f"http://192.168.137.1:8000/reset-password?token={token}"
    print(f"DEBUG: Password reset link generated for {request.email}: {reset_link}")

    html = f"""
    <html>
    <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f9f9f9; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #E53935; margin: 0; font-size: 28px;">SwachhAI</h1>
                <p style="color: #777; margin: 5px 0 0 0;">Smart Waste Management System</p>
            </div>

            <h2 style="color: #333; font-size: 22px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px;">Password Reset Request</h2>

            <p>Hello,</p>
            <p>We received a request to reset the password for your SwachhAI account. Click the button below to set a new password:</p>

            <div style="text-align: center; margin: 35px 0;">
                <a href="{reset_link}" style="background-color: #E53935; color: #ffffff; padding: 14px 30px; text-decoration: none; font-weight: bold; border-radius: 6px; display: inline-block; font-size: 16px;">Yes, Reset My Password</a>
            </div>

            <p style="color: #666; font-size: 14px;">If the button above doesn't work, copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #E53935; font-size: 12px; background: #fff5f5; padding: 10px; border-radius: 4px;">{reset_link}</p>

            <div style="margin-top: 30px; padding: 15px; background-color: #fff8e1; border-left: 4px solid #ffc107; border-radius: 4px;">
                <p style="margin: 0; font-size: 13px; color: #856404;"><strong>Note:</strong> This link will expire in 15 minutes for security reasons.</p>
            </div>

            <p style="margin-top: 30px; font-size: 14px; color: #666;">If you did not request this reset, please ignore this email or contact support if you have concerns.</p>

            <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="font-size: 11px; color: #999; text-align: center; margin: 0;">&copy; 2024 SwachhAI System. All rights reserved.</p>
        </div>
    </body>
    </html>
    """

    message = MessageSchema(
        subject="Password Reset - AI Smart Waste Management",
        recipients=[request.email],
        body=html,
        subtype=MessageType.html
    )

    fm = FastMail(conf)

    try:
        # Use background tasks for sending email to avoid timeout
        background_tasks.add_task(fm.send_message, message)
        print(f"DEBUG: Email task added for {request.email}")
    except Exception as e:
        print(f"ERROR: Failed to add email task for {request.email}: {str(e)}")
        # We still return success to avoid leaking user info, but log the error


    return success(
        "If the email exists in our system, you will receive a reset token shortly."
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


    user.password = hash_password(request.newPassword)
    db.commit()


    return success(
        "Password reset successfully"
    )
