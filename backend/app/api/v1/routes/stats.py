from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta

from app.core.database import get_db
from app.models.complaint import Complaint, ComplaintStatus

router = APIRouter()


# GET /api/v1/stats/summary
@router.get("/summary")
def get_summary(db: Session = Depends(get_db)):
    total = db.query(Complaint).count()
    pending = db.query(Complaint).filter(Complaint.status == ComplaintStatus.pending).count()
    resolved = db.query(Complaint).filter(Complaint.status == ComplaintStatus.resolved).count()

    return {
        "total_complaints": total,
        "pending": pending,
        "resolved": resolved,
        "active_workers": 0,
        "emergency_alerts": 0,
    }


# GET /api/v1/stats/weekly
@router.get("/weekly")
def get_weekly_stats(db: Session = Depends(get_db)):
    today = datetime.utcnow().date()
    week_start = today - timedelta(days=6)
    days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    result = []
    for i in range(7):
        day_date = week_start + timedelta(days=i)
        next_day = day_date + timedelta(days=1)

        complaints_count = db.query(Complaint).filter(
            Complaint.created_at >= day_date,
            Complaint.created_at < next_day
        ).count()

        resolved_count = db.query(Complaint).filter(
            Complaint.created_at >= day_date,
            Complaint.created_at < next_day,
            Complaint.status == ComplaintStatus.resolved
        ).count()

        pending_count = complaints_count - resolved_count

        result.append({
            "day": days[day_date.weekday()],
            "Complaints": complaints_count,
            "Resolved": resolved_count,
            "Pending": pending_count,
        })

    return result


# GET /api/v1/stats/distribution
@router.get("/distribution")
def get_distribution(db: Session = Depends(get_db)):
    colors = {
        "garbage": "#3b82f6",
        "drainage": "#22c55e",
        "roadside": "#f59e0b",
        "illegal_dumping": "#ef4444",
        "general": "#8b5cf6",
    }

    rows = (
        db.query(Complaint.category, func.count(Complaint.id))
        .group_by(Complaint.category)
        .all()
    )

    result = []
    for category, count in rows:
        cat_name = category or "general"
        result.append({
            "name": cat_name.replace("_", " ").title(),
            "value": count,
            "color": colors.get(cat_name, "#94a3b8"),
        })

    return result


# GET /api/v1/stats/monthly
@router.get("/monthly")
def get_monthly_stats(db: Session = Depends(get_db)):
    rows = (
        db.query(
            func.strftime("%Y-%m", Complaint.created_at).label("month"),
            func.count(Complaint.id).label("total"),
        )
        .group_by("month")
        .order_by("month")
        .all()
    )

    result = []
    for month_str, total in rows:
        resolved = db.query(Complaint).filter(
            func.strftime("%Y-%m", Complaint.created_at) == month_str,
            Complaint.status == ComplaintStatus.resolved
        ).count()

        month_label = datetime.strptime(month_str, "%Y-%m").strftime("%b")
        result.append({
            "month": month_label,
            "complaints": total,
            "resolved": resolved,
        })

    return result


# GET /api/v1/stats/by-zone
@router.get("/by-zone")
def get_zone_stats(db: Session = Depends(get_db)):
    rows = (
        db.query(Complaint.location, func.count(Complaint.id))
        .group_by(Complaint.location)
        .all()
    )

    result = [
        {"zone": location or "Unknown", "value": count}
        for location, count in rows
    ]
    return result