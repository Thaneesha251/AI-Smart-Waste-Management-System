from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from typing import Any, Optional


# ---------------------------
# SUCCESS RESPONSE
# ---------------------------
def success(message: str = "Success", data: Optional[Any] = None, status_code: int = 200):
    return JSONResponse(
        status_code=status_code,
        content=jsonable_encoder({
            "success": True,
            "message": message,
            "data": data
        })
    )


# ---------------------------
# ERROR RESPONSE
# ---------------------------
def error(message: str = "Error", status_code: int = 400, data: Optional[Any] = None):
    return JSONResponse(
        status_code=status_code,
        content=jsonable_encoder({
            "success": False,
            "message": message,
            "data": data
        })
    )


# ---------------------------
# PAGINATED RESPONSE (optional but useful later)
# ---------------------------
def paginated_success(
    message: str,
    data: list,
    page: int,
    limit: int,
    total: int
):
    return JSONResponse(
        status_code=200,
        content={
            "success": True,
            "message": message,
            "data": data,
            "pagination": {
                "page": page,
                "limit": limit,
                "total": total,
                "pages": (total // limit) + (1 if total % limit else 0)
            }
        }
    )