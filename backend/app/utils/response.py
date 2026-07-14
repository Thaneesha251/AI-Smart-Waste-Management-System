from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from typing import Any, Optional


# ---------------------------
# SUCCESS RESPONSE
# ---------------------------
def success(message: str = "Success", data: Optional[Any] = None, status_code: int = 200):
    return JSONResponse(
        status_code=status_code,
        content={
            "success": True,
            "message": message,
            "data": jsonable_encoder(data)
        }
    )


# ---------------------------
# ERROR RESPONSE
# ---------------------------
def error(message: str = "Something went wrong", status_code: int = 400, data: Optional[Any] = None):
    return JSONResponse(
        status_code=status_code,
        content={
            "success": False,
            "message": message,
            "data": jsonable_encoder(data)
        }
    )