# backend/app/schemas/manga.py
from pydantic import BaseModel
from typing import Optional


class MangaResponse(BaseModel):
    id: str
    source: str = "mangadex"
    title: str
    description: Optional[str] = None
    status: Optional[str] = None
    year: Optional[int] = None
    content_rating: Optional[str] = None
    tags: list[str] = []
    cover_url: Optional[str] = None
    author: Optional[str] = None
    artist: Optional[str] = None
    mal_id: Optional[int] = None
    score: Optional[float] = None
    members: Optional[int] = None
    cv_id: Optional[int] = None
    issue_count: Optional[int] = None


class MangaListResponse(BaseModel):
    data: list[MangaResponse]
    total: int = 0
    limit: int = 20
    offset: int = 0


class ChapterResponse(BaseModel):
    id: str
    chapter: Optional[str] = None
    title: Optional[str] = None
    volume: Optional[str] = None
    pages: int = 0
    language: str = "en"
    published_at: Optional[str] = None
    scanlation_group: Optional[str] = None
    external_url: Optional[str] = None
    readable: bool = True


class ChapterListResponse(BaseModel):
    data: list[ChapterResponse]
    total: int = 0
    limit: int = 100
    offset: int = 0


class PageListResponse(BaseModel):
    pages: list[str]
    quality: str = "data"


class CharacterResponse(BaseModel):
    mal_id: Optional[int] = None
    name: str
    url: Optional[str] = None
    image_url: Optional[str] = None
    role: str = "Supporting"


class CharacterListResponse(BaseModel):
    data: list[CharacterResponse]
    total: int = 0