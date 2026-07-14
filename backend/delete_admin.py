from app.core.database import SessionLocal
from app.models.user import User

db = SessionLocal()
user = db.query(User).filter(User.email == "admin@municipality.gov").first()
if user:
    db.delete(user)
    db.commit()
    print("Old admin deleted.")
else:
    print("No admin found.")
db.close()