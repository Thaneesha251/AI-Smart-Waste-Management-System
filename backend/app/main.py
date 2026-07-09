from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.routes import complaint, stats, auth, notification, worker
from app.core.database import Base, engine

# NOTE: For development only (avoid in production)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="AI Smart Waste Management System",
    version="1.0.0",
    description="Backend API for smart waste tracking, complaints, and AI-based management"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers with proper versioning + prefix
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

# Root endpoint
@app.get("/")
def root():
    return {
        "message": "API Running Successfully",
        "status": "active"
    }