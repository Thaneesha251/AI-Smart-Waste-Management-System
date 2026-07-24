from app.core.database import SessionLocal
from app.models.user import User
from app.models.worker import Worker
from app.core.security import hash_password

db = SessionLocal()

def create_or_update_user(email, fullName, password, role):
    user = db.query(User).filter(User.email == email).first()
    if user:
        user.fullName = fullName
        user.password = hash_password(password)
        user.role = role
        print(f"User {email} updated.")
    else:
        user = User(
            email=email,
            fullName=fullName,
            password=hash_password(password),
            role=role
        )
        db.add(user)
        print(f"User {email} created.")
    db.commit()

def create_or_update_worker(worker_id, name, password):
    worker = db.query(Worker).filter(Worker.worker_id == worker_id).first()
    if worker:
        worker.name = name
        worker.password = hash_password(password)
        print(f"Worker {worker_id} updated.")
    else:
        worker = Worker(
            worker_id=worker_id,
            name=name,
            password=hash_password(password)
        )
        db.add(worker)
        print(f"Worker {worker_id} created.")
    db.commit()

# Create Admin
create_or_update_user("admin@test.com", "System Admin", "admin123", "admin")
# Create Citizen
create_or_update_user("citizen@test.com", "Normal Citizen", "citizen123", "citizen")
# Create Worker
create_or_update_worker("W001", "Test Worker", "worker123")

db.close()
