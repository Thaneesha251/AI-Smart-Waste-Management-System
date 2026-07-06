from typing import List, Any


def paginate(data: List[Any], page: int = 1, size: int = 10):
    start = (page - 1) * size
    end = start + size

    return {
        "items": data[start:end],
        "page": page,
        "size": size,
        "total": len(data)
    }