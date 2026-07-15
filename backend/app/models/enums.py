import enum


class ComplaintStatus(str, enum.Enum):
    PENDING = "pending"
    ASSIGNED = "assigned"
    IN_PROGRESS = "inProgress"
    RESOLVED = "resolved"
    CANCELLED = "cancelled"