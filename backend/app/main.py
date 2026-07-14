from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import os
from app.core.database import Base, engine
from app.core.middleware import LoggingMiddleware
from app.core.exceptions.handlers import register_exception_handlers

from app.models import user, complaint, worker, enums

from app.api.v1.routes import auth, complaint as complaint_routes, admin, ai
from app.api.v1.routes import workers


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="AI Smart Waste Management System",
    version="1.0.0",
    description="Backend API for smart waste tracking, complaints, and AI-based management"
)
from fastapi.staticfiles import StaticFiles
import os

# Ensure the upload directory exists at startup
os.makedirs("app/static/uploads/complaints", exist_ok=True)

app.mount("/static", StaticFiles(directory="app/static"), name="static")

register_exception_handlers(app)
app.add_middleware(LoggingMiddleware)

# Create static upload directories if they don't exist
os.makedirs("app/static/uploads/complaints", exist_ok=True)

# Mount static files directory
app.mount("/static", StaticFiles(directory="app/static"), name="static")


app.include_router(
    complaint_routes.router,
    prefix="/api/v1/complaints",
    tags=["Complaints"]
)

app.include_router(
    auth.router,
    prefix="/api/v1/auth",
    tags=["Auth"]
)

app.include_router(
    admin.router,
    prefix="/api/v1/admin",
    tags=["Admin"]
)

app.include_router(
    workers.router,
    prefix="/api/v1/workers",
    tags=["Workers"]
)

app.include_router(
    ai.router,
    prefix="/api/v1/ai",
    tags=["AI"]
)


@app.get("/", tags=["Root"])
def root():
    return {
        "success": True,
        "message": "AI Smart Waste Management Backend is Running",
        "version": "1.0.0"
    }


@app.get("/health", tags=["Health"])
def health_check():
    return {
        "success": True,
        "status": "Healthy"
    }