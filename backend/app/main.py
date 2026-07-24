from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, engine
from app.core.middleware import LoggingMiddleware
from app.core.exceptions.handlers import register_exception_handlers

from app.api.v1.routes import auth, user, complaint, admin, ai
from app.api.v1 import workers
from app.core.database import SessionLocal
from app.models.worker import Worker
from app.core.security import hash_password


# ==========================================================
# DATABASE INITIALIZATION (Migrations handled by Alembic)
# ==========================================================

# Base.metadata.create_all(bind=engine)


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
    workers.router,
    prefix="/api/v1/workers",
    tags=["Worker"]
)

app.include_router(
    ai.router,
    prefix="/api/v1/ai",
    tags=["AI Detection"]
)


# ==========================================================
# STARTUP EVENT
# ==========================================================

@app.on_event("startup")
def startup_event():
    # Create a temporary test worker for development
    db = SessionLocal()
    try:
        worker_id = "W001"
        existing = db.query(Worker).filter(Worker.worker_id == worker_id).first()
        if not existing:
            print(f"Creating temporary test worker: {worker_id}")
            test_worker = Worker(
                worker_id=worker_id,
                name="Test Worker",
                password=hash_password("password123"),
                phone="9876543210",
                area="Central Zone",
                is_active=True
            )
            db.add(test_worker)
            db.commit()
    except Exception as e:
        print(f"Error creating test worker: {e}")
    finally:
        db.close()


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