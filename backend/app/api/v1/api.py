from fastapi import APIRouter

from app.api.v1.routes import auth, complaint, admin, waste_detection

api_router = APIRouter()

api_router.include_router(
    auth.router,
    prefix='/auth',
    tags=['Authentication']
)

api_router.include_router(
    complaint.router,
    prefix='/complaints',
    tags=['Complaints']
)

api_router.include_router(
    admin.router,
    prefix='/admin',
    tags=['Admin']
)

api_router.include_router(
    waste_detection.router,
    prefix='/waste',
    tags=['Waste Detection']
)