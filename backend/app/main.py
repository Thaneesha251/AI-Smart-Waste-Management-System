from fastapi import FastAPI
from app.api.v1.routes import complaint
from app.core.database import Base, engine

# NOTE: For development only (avoid in production)
Base.metadata.create_all(bind=engine)

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

# Root endpoint
@app.get("/")
def root():
    return {
        "message": "API Running Successfully",
        "status": "active"
    }