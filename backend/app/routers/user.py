# backend/app/routers/user.py
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.user import User
from app.auth.dependencies import get_current_user
from app.services.user_service import UserService
from app.schemas.user import (
    BookmarkCreate,
    BookmarkResponse,
    BookmarkListResponse,
    HistoryCreate,
    HistoryResponse,
    HistoryListResponse,
)
from app.redis_client import limiter

router = APIRouter()


@router.get("/bookmarks", response_model=BookmarkListResponse)
@limiter.limit("120/minute")
async def get_bookmarks(
    request: Request,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = UserService(db)
    result = await svc.get_bookmarks(user.id)
    return result


@router.post("/bookmarks/{manga_id}", response_model=BookmarkResponse, status_code=201)
@limiter.limit("120/minute")
async def add_bookmark(
    request: Request,
    manga_id: str,
    body: BookmarkCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = UserService(db)
    bookmark = await svc.add_bookmark(user.id, manga_id, body.manga_title, body.cover_url)
    return bookmark


@router.delete("/bookmarks/{manga_id}", status_code=204)
@limiter.limit("120/minute")
async def remove_bookmark(
    request: Request,
    manga_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = UserService(db)
    removed = await svc.remove_bookmark(user.id, manga_id)
    if not removed:
        raise HTTPException(status_code=404, detail="Bookmark not found")
    return None


@router.get("/history", response_model=HistoryListResponse)
@limiter.limit("120/minute")
async def get_history(
    request: Request,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = UserService(db)
    result = await svc.get_history(user.id)
    return result


@router.post("/history", response_model=HistoryResponse, status_code=201)
@limiter.limit("120/minute")
async def update_history(
    request: Request,
    body: HistoryCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = UserService(db)
    entry = await svc.update_history(
        user_id=user.id,
        manga_id=body.manga_id,
        chapter_id=body.chapter_id,
        manga_title=body.manga_title,
        chapter_number=body.chapter_number,
        page_number=body.page_number,
    )
    return entry