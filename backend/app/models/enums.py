import enum


class ComplaintStatus(str, enum.Enum):
    PENDING = "PENDING"
    ASSIGNED = "ASSIGNED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    RESOLVED = "RESOLVED"
    CANCELLED = "CANCELLED"
