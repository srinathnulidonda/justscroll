# backend/app/sources/base.py
from abc import ABC, abstractmethod
from typing import Any


class MangaSource(ABC):
    @abstractmethod
    async def search_manga(self, query: str, limit: int = 20, offset: int = 0) -> dict[str, Any]:
        ...

    @abstractmethod
    async def get_popular(self, limit: int = 20, offset: int = 0) -> dict[str, Any]:
        ...

    @abstractmethod
    async def get_latest_updates(self, limit: int = 20, offset: int = 0) -> dict[str, Any]:
        ...

    @abstractmethod
    async def get_manga_detail(self, manga_id: str) -> dict[str, Any]:
        ...

    @abstractmethod
    async def get_chapters(
        self, manga_id: str, lang: str = "en", limit: int = 100, offset: int = 0
    ) -> dict[str, Any]:
        ...

    @abstractmethod
    async def get_pages(self, chapter_id: str, quality: str = "data") -> dict[str, Any]:
        ...