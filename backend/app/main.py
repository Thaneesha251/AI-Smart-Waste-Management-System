from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
import os
from app.core.database import Base, engine
from app.core.middleware import LoggingMiddleware
from app.core.exceptions.handlers import register_exception_handlers

from app.models import user, complaint, worker, enums, notification

from app.api.v1.routes import auth, complaint as complaint_routes, admin, ai
from app.api.v1.routes import workers, notification as notification_routes


Base.metadata.create_all(bind=engine)


def ensure_complaint_indexes():
    with engine.begin() as connection:
        connection.execute(text("CREATE INDEX IF NOT EXISTS ix_complaints_status ON complaints (status)"))
        connection.execute(text("CREATE INDEX IF NOT EXISTS ix_complaints_assigned_worker_id ON complaints (assigned_worker_id)"))
        connection.execute(text("CREATE INDEX IF NOT EXISTS ix_complaints_created_at ON complaints (created_at)"))


ensure_complaint_indexes()


app = FastAPI(
    title="AI Smart Waste Management System",
    version="1.0.0",
    description="Backend API for smart waste tracking, complaints, and AI-based management"
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Static file uploads
os.makedirs("app/static/uploads/complaints", exist_ok=True)
app.mount("/static", StaticFiles(directory="app/static"), name="static")

register_exception_handlers(app)
app.add_middleware(LoggingMiddleware)


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

app.include_router(
    notification_routes.router,
    prefix="/api/v1/notifications",
    tags=["Notifications"]
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