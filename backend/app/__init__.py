# backend/app/__init__.py
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from loguru import logger
import httpx
import sys

from app.config import settings
from app.database import engine
from app.redis_client import redis_manager, limiter


def setup_logging() -> None:
    logger.remove()
    logger.add(
        sys.stderr,
        level=settings.LOG_LEVEL,
        format=(
            "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan> - "
            "<level>{message}</level>"
        ),
        serialize=False,
    )


async def create_tables() -> None:
    """Create database tables if they don't exist."""
    from app.models import Base
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info("Database tables created/verified")


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    app.state.http_client = httpx.AsyncClient(
        timeout=httpx.Timeout(30.0, connect=10.0),
        limits=httpx.Limits(
            max_connections=100, max_keepalive_connections=20
        ),
        headers={"User-Agent": "MangaReader/1.0"},
        follow_redirects=True,
    )
    await redis_manager.connect()
    await create_tables()  # <-- ADD THIS LINE
    logger.info("Application started successfully")
    yield
    await app.state.http_client.aclose()
    await redis_manager.disconnect()
    await engine.dispose()
    logger.info("Application shutdown complete")


def create_app() -> FastAPI:
    app = FastAPI(
        title="Manga Reader API",
        version="1.0.0",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.state.limiter = limiter
    app.add_exception_handler(
        RateLimitExceeded, _rate_limit_exceeded_handler
    )

    from app.routers import auth, manga, chapters, user, proxy

    app.include_router(
        auth.router, prefix="/api/v1/auth", tags=["auth"]
    )
    app.include_router(
        manga.router, prefix="/api/v1/manga", tags=["manga"]
    )
    app.include_router(
        chapters.router, prefix="/api/v1/chapters", tags=["chapters"]
    )
    app.include_router(
        user.router, prefix="/api/v1/user", tags=["user"]
    )
    app.include_router(
        proxy.router, prefix="/api/v1/proxy", tags=["proxy"]
    )

    @app.get("/")
    async def root():
        return "Hello....! ^_^"

    @app.get("/health")
    async def health_check():
        health = {"status": "ok", "redis": False, "database": False}
        try:
            if redis_manager.redis:
                await redis_manager.redis.ping()
                health["redis"] = True
        except Exception:
            pass
        try:
            from app.database import async_session_factory

            async with async_session_factory() as session:
                from sqlalchemy import text

                await session.execute(text("SELECT 1"))
                health["database"] = True
        except Exception:
            pass
        status_code = (
            200 if health["redis"] and health["database"] else 503
        )
        return JSONResponse(content=health, status_code=status_code)

    @app.exception_handler(Exception)
    async def global_exception_handler(
        request: Request, exc: Exception
    ):
        logger.error(
            f"Unhandled error on {request.method} {request.url}: {exc}"
        )
        return JSONResponse(
            status_code=500,
            content={"detail": "Internal server error"},
        )

    return app