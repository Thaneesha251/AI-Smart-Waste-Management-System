from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.core.database import Base, engine
from app.core.middleware import LoggingMiddleware
from app.core.exceptions.handlers import register_exception_handlers

from app.api.v1.routes import auth, complaint, admin


# ==========================================================
# DATABASE INITIALIZATION (Development Only)
# ==========================================================

Base.metadata.create_all(bind=engine)


# ==========================================================
# CREATE FASTAPI APPLICATION
# ==========================================================

app = FastAPI(
    title="AI Smart Waste Management System",
    description="Backend API for Smart Waste Management",
    version="1.0.0"
)


# ==========================================================
# REGISTER GLOBAL EXCEPTION HANDLERS
# ==========================================================

register_exception_handlers(app)


# ==========================================================
# MIDDLEWARE
# ==========================================================

app.add_middleware(LoggingMiddleware)


# ==========================================================
# STATIC FILES (UPLOADS)
# ==========================================================

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


# ==========================================================
# ROUTERS
# ==========================================================

app.include_router(
    auth.router,
    prefix="/api/v1/auth",
    tags=["Authentication"]
)

app.include_router(
    complaint.router,
    prefix="/api/v1/complaints",
    tags=["Complaints"]
)

app.include_router(
    admin.router,
    prefix="/api/v1/admin",
    tags=["Admin"]
)


# ==========================================================
# ROOT
# ==========================================================

@app.get("/", tags=["Root"])
def root():
    return {
        "success": True,
        "message": "AI Smart Waste Management Backend is Running",
        "version": "1.0.0"
    }


# ==========================================================
# HEALTH CHECK
# ==========================================================

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "success": True,
        "status": "Healthy"
    }