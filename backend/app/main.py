from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, engine
from app.core.middleware import LoggingMiddleware
from app.core.exceptions.handlers import register_exception_handlers

from app.api.v1.routes import auth, user, complaint, admin, ai


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
# CORS MIDDLEWARE
# ==========================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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
    user.router,
    prefix="/api/v1/users",
    tags=["Users"]
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

app.include_router(
    ai.router,
    prefix="/api/v1/ai",
    tags=["AI Detection"]
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