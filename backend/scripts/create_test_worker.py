import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.database import SessionLocal
from app.models.worker import Worker
from app.core.security import hash_password

def create_test_worker():
    db = SessionLocal()

    worker_data = {
        "worker_id": "W001",
        "name": "Ravi Kumar",
        "phone": "9876543210",
        "email": "ravi.kumar@swachhai.gov.in",
        "area": "Anna Nagar",
        "is_active": True,
        "password": "password123"
    }

    print(f"Checking for existing worker with worker_id: {worker_data['worker_id']}")

    # Check if worker exists
    worker = db.query(Worker).filter(Worker.worker_id == worker_data["worker_id"]).first()

    if worker:
        print(f"Worker {worker_data['worker_id']} already exists. Updating record...")
        worker.name = worker_data["name"]
        worker.phone = worker_data["phone"]
        worker.email = worker_data["email"]
        worker.area = worker_data["area"]
        worker.is_active = worker_data["is_active"]
        worker.password = hash_password(worker_data["password"])
    else:
        print(f"Creating new worker {worker_data['worker_id']}...")
        worker = Worker(
            worker_id=worker_data["worker_id"],
            name=worker_data["name"],
            phone=worker_data["phone"],
            email=worker_data["email"],
            area=worker_data["area"],
            is_active=worker_data["is_active"],
            password=hash_password(worker_data["password"])
        )
        db.add(worker)

    try:
        db.commit()
        db.refresh(worker)
        print(f"SUCCESS: Worker '{worker.name}' (ID: {worker.worker_id}) is ready.")
        print(f"DB ID: {worker.id}")
    except Exception as e:
        db.rollback()
        print(f"ERROR: Failed to save worker: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_test_worker()
