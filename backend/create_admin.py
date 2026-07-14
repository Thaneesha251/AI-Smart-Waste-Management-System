from app.core.database import SessionLocal, Base, engine
from app.models.user import User
from app.core.security import hash_password
from app.models import complaint, worker, enums

Base.metadata.create_all(bind=engine)

db = SessionLocal()

existing = db.query(User).filter(User.email == "admin@municipality.gov").first()

if existing:
    print("Admin already exists!")
else:
    admin = User(
        name="Admin Officer",
        email="admin@municipality.gov",
        password_hash=hash_password("admin123"),
        role="admin"
    )
    db.add(admin)
    db.commit()
    print("Admin created successfully!")
    print("Email: admin@municipality.gov")
    print("Password: admin123")

db.close()