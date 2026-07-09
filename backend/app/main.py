from fastapi import FastAPI
from app.api.v1.routes import complaint
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
    version="1.0.0",
    description="Backend API for smart waste tracking, complaints, and AI-based management"
)

# Include routers with proper versioning + prefix
app.include_router(
    complaint.router,
    prefix="/api/v1/complaints",
    tags=["Complaints"]
)
app.include_router(
    notification.router,
    prefix="/api/v1/notifications",
    tags=["Notifications"]
)
app.include_router(
    worker.router,
    prefix="/api/v1/workers",
    tags=["Workers"]
)
app.include_router(
    stats.router,
    prefix="/api/v1/stats",
    tags=["Stats"]
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