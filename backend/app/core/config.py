from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    SECRET_KEY: str = "super-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # ✅ ADD THIS LINE
    DATABASE_URL: str = "sqlite:///./test.db"

    class Config:
        env_file = ".env"


settings = Settings()