from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.rbac import require_admin
from app.models.complaint import Complaint
from app.models.enums import ComplaintStatus
from app.models.worker import Worker
from app.utils.response import success

router = APIRouter()


@router.get("/ping")
def admin_ping(current_user=Depends(get_current_user)):
    return success("Admin route is working")


# ---------------------------
# DASHBOARD SUMMARY CARDS
# ---------------------------
@router.get("/stats/summary")
def get_summary(
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
    total = db.query(Complaint).count()
    pending = db.query(Complaint).filter(Complaint.status == ComplaintStatus.PENDING.value).count()
    resolved = db.query(Complaint).filter(Complaint.status == ComplaintStatus.RESOLVED.value).count()

    active_workers = db.query(Worker).filter(
        Worker.status.in_(["online", "on-job"])
    ).count()

    return success(
        "Summary fetched",
        {
            "total_complaints": total,
            "pending": pending,
            "resolved": resolved,
            "active_workers": active_workers,
            "emergency_alerts": 0,     # placeholder until alert logic is added
        }
    )


# ---------------------------
# WEEKLY STATISTICS (LINE CHART)
# ---------------------------
@router.get("/stats/weekly")
def get_weekly_stats(
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
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
            Complaint.status == ComplaintStatus.RESOLVED.value
        ).count()

        pending_count = complaints_count - resolved_count

        result.append({
            "day": days[day_date.weekday()],
            "Complaints": complaints_count,
            "Resolved": resolved_count,
            "Pending": pending_count,
        })

    return success("Weekly stats fetched", result)


# ---------------------------
# DISTRIBUTION BY CATEGORY (DONUT CHART)
# ---------------------------
@router.get("/stats/distribution")
def get_distribution(
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
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

    return success("Distribution fetched", result)


# ---------------------------
# MONTHLY STATS (ANALYTICS PAGE)
# ---------------------------
@router.get("/stats/monthly")
def get_monthly_stats(
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
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
            Complaint.status == ComplaintStatus.RESOLVED.value
        ).count()

        month_label = datetime.strptime(month_str, "%Y-%m").strftime("%b")
        result.append({
            "month": month_label,
            "complaints": total,
            "resolved": resolved,
        })

    return success("Monthly stats fetched", result)


# ---------------------------
# COMPLAINTS BY ZONE (ANALYTICS PAGE)
# ---------------------------
@router.get("/stats/by-zone")
def get_zone_stats(
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
    # Note: your Complaint model doesn't have a dedicated "zone" field yet,
    # only "category" and free-text "description". Using category as a
    # stand-in grouping until a proper zone/location field is added.
    rows = (
        db.query(Complaint.category, func.count(Complaint.id))
        .group_by(Complaint.category)
        .all()
    )

    result = [
        {"zone": category or "Unknown", "value": count}
        for category, count in rows
    ]
    return success("Zone stats fetched", result)