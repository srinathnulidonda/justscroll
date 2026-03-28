# backend/app/routers/chapters.py
from fastapi import APIRouter, Request, Query, HTTPException
from loguru import logger
from app.schemas.manga import PageListResponse
from app.services.manga_service import MangaService
from app.redis_client import limiter

router = APIRouter()


@router.get("/{chapter_id}/pages", response_model=PageListResponse)
@limiter.limit("60/minute")
async def chapter_pages(
    request: Request,
    chapter_id: str,
    quality: str = Query("data", pattern="^(data|dataSaver)$"),
):
    svc = MangaService(request.app.state.http_client)

    # Try requested quality first
    try:
        result = await svc.get_pages(chapter_id, quality)
        if result.get("pages"):
            return result
    except HTTPException as e:
        if e.status_code != 404:
            raise
        logger.warning(
            f"Pages not found for chapter {chapter_id} with quality={quality}"
        )

    # Fallback: try the other quality
    fallback_quality = "data" if quality == "dataSaver" else "dataSaver"
    try:
        result = await svc.get_pages(chapter_id, fallback_quality)
        if result.get("pages"):
            logger.info(
                f"Fallback quality {fallback_quality} worked for {chapter_id}"
            )
            return result
    except HTTPException:
        pass

    # Both qualities failed
    raise HTTPException(
        status_code=404,
        detail=(
            "This chapter is not available for reading. "
            "It may be an external chapter or has been removed."
        ),
    )