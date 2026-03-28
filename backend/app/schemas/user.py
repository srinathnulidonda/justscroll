# backend/app/schemas/user.py
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class BookmarkCreate(BaseModel):
    manga_title: str
    cover_url: Optional[str] = None


class BookmarkResponse(BaseModel):
    id: int
    manga_id: str
    manga_title: str
    cover_url: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class BookmarkListResponse(BaseModel):
    data: list[BookmarkResponse]
    total: int = 0


class HistoryCreate(BaseModel):
    manga_id: str
    chapter_id: str
    manga_title: str
    chapter_number: Optional[str] = None
    page_number: int = 1


class HistoryResponse(BaseModel):
    id: int
    manga_id: str
    chapter_id: str
    manga_title: str
    chapter_number: Optional[str] = None
    page_number: int
    updated_at: datetime

    model_config = {"from_attributes": True}


class HistoryListResponse(BaseModel):
    data: list[HistoryResponse]
    total: int = 0