# backend/app/routers/manga.py
from fastapi import APIRouter, Request, Query, HTTPException
from loguru import logger
from app.schemas.manga import (
    MangaListResponse,
    MangaResponse,
    ChapterListResponse,
    CharacterListResponse,
)
from app.services.manga_service import MangaService
from app.redis_client import limiter

router = APIRouter()


def _get_service(request: Request) -> MangaService:
    return MangaService(request.app.state.http_client)


@router.get("/search", response_model=MangaListResponse)
@limiter.limit("60/minute")
async def search_manga(
    request: Request,
    q: str = Query(..., min_length=1, max_length=200),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    svc = _get_service(request)
    return await svc.search(q, limit, offset)


@router.get("/popular", response_model=MangaListResponse)
@limiter.limit("60/minute")
async def popular_manga(
    request: Request,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    svc = _get_service(request)
    return await svc.get_popular(limit, offset)


@router.get("/latest-updates", response_model=MangaListResponse)
@limiter.limit("60/minute")
async def latest_updates(
    request: Request,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    svc = _get_service(request)
    return await svc.get_latest_updates(limit, offset)


@router.get("/{manga_id}/chapters", response_model=ChapterListResponse)
@limiter.limit("60/minute")
async def manga_chapters(
    request: Request,
    manga_id: str,
    lang: str = Query("en"),
    limit: int = Query(500, ge=1, le=10000),
    offset: int = Query(0, ge=0),
):
    logger.info(f"Chapters requested: manga_id={manga_id}, lang={lang}")
    svc = _get_service(request)
    result = await svc.get_chapters(manga_id, lang, limit, offset)

    chapter_count = len(result.get("data", []))
    if chapter_count == 0:
        logger.warning(
            f"No readable chapters found for {manga_id} (lang={lang}). "
            f"Chapters may be external-only or licensed/removed."
        )

    return result


@router.get("/{manga_id}/characters", response_model=CharacterListResponse)
@limiter.limit("60/minute")
async def manga_characters(
    request: Request,
    manga_id: str,
):
    logger.info(f"Characters requested: manga_id={manga_id}")
    svc = _get_service(request)
    result = await svc.get_characters(manga_id)
    return result


@router.get("/{manga_id}", response_model=MangaResponse)
@limiter.limit("60/minute")
async def manga_detail(request: Request, manga_id: str):
    logger.info(f"Detail requested: manga_id={manga_id}")
    svc = _get_service(request)
    try:
        result = await svc.get_manga_detail(manga_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"manga_detail error: {e}")
        raise HTTPException(
            status_code=502, detail="Failed to fetch manga details"
        )
    if not result:
        raise HTTPException(status_code=404, detail="Manga not found")
    return result