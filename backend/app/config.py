# backend/app/config.py
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    REDIS_URL: str
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    CORS_ORIGINS: str = (
        "http://localhost:5173,"
        "http://localhost:3000,"
        "https://justscroll.vercel.app,"
    )
    LOG_LEVEL: str = "INFO"
    MANGADEX_BASE_URL: str = "https://api.mangadex.org"
    JIKAN_API_URL: str = "https://api.jikan.moe/v4"
    COMICVINE_API_URL: str = "https://comicvine.gamespot.com/api"
    COMICVINE_API_KEY: str = ""
    IMAGE_PROXY_DOMAINS: str = (
        "mangadex.org,uploads.mangadex.org,cmdxd98sb0x3yprd.mangadex.network,"
        "myanimelist.net,cdn.myanimelist.net,"
        "comicvine.gamespot.com"
    )

    @property
    def async_database_url(self) -> str:
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+asyncpg://", 1)
        elif url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        elif not url.startswith("postgresql+asyncpg://"):
            url = f"postgresql+asyncpg://{url}"
        return url

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    @property
    def image_proxy_domains_list(self) -> list[str]:
        return [
            d.strip()
            for d in self.IMAGE_PROXY_DOMAINS.split(",")
            if d.strip()
        ]

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()