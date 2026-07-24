from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class WorkerBase(BaseModel):
    worker_id: str
    name: str
    phone: Optional[str] = None
    email: Optional[str] = None
    area: Optional[str] = None
    is_active: bool = True

class WorkerCreate(WorkerBase):
    password: str

class WorkerLogin(BaseModel):
    worker_id: str
    password: str

class WorkerResponse(WorkerBase):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class WorkerUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    area: Optional[str] = None
    is_active: Optional[bool] = None

class WorkerResetPassword(BaseModel):
    new_password: str

class WorkerAssignment(BaseModel):
    complaintId: int
    workerId: int
