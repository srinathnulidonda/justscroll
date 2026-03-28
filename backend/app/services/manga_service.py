# backend/app/services/manga_service.py
import hashlib
from typing import Any
import httpx
from loguru import logger
from app.sources.aggregator import MangaAggregator
from app.redis_client import redis_manager

CACHE_TTL_SEARCH = 600
CACHE_TTL_MANGA = 3600
CACHE_TTL_CHAPTERS = 1800
CACHE_TTL_PAGES = 900
CACHE_TTL_POPULAR = 1800
CACHE_TTL_LATEST = 600
CACHE_TTL_CHARACTERS = 86400

# Bump version when chapter filtering logic changes to invalidate old cache
_CACHE_VERSION = "v2"


def _cache_key(prefix: str, *args: Any) -> str:
    raw = ":".join(str(a) for a in args)
    hashed = hashlib.md5(raw.encode()).hexdigest()
    return f"manga:{_CACHE_VERSION}:{prefix}:{hashed}"


class MangaService:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self.aggregator = MangaAggregator(client)

    async def search(
        self, query: str, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        key = _cache_key("search", query, limit, offset)
        cached = await redis_manager.get_cached(key)
        if cached:
            logger.debug(f"Cache hit: {key}")
            return cached
        result = await self.aggregator.search_manga(query, limit, offset)
        await redis_manager.set_cached(key, result, CACHE_TTL_SEARCH)
        return result

    async def get_popular(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        key = _cache_key("popular", limit, offset)
        cached = await redis_manager.get_cached(key)
        if cached:
            return cached
        result = await self.aggregator.get_popular(limit, offset)
        await redis_manager.set_cached(key, result, CACHE_TTL_POPULAR)
        return result

    async def get_latest_updates(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        key = _cache_key("latest", limit, offset)
        cached = await redis_manager.get_cached(key)
        if cached:
            return cached
        result = await self.aggregator.get_latest_updates(limit, offset)
        await redis_manager.set_cached(key, result, CACHE_TTL_LATEST)
        return result

    async def get_manga_detail(self, manga_id: str) -> dict[str, Any]:
        key = _cache_key("detail", manga_id)
        cached = await redis_manager.get_cached(key)
        if cached:
            return cached
        result = await self.aggregator.get_manga_detail(manga_id)
        if result:
            await redis_manager.set_cached(key, result, CACHE_TTL_MANGA)
        return result

    async def get_chapters(
        self,
        manga_id: str,
        lang: str = "en",
        limit: int = 500,
        offset: int = 0,
    ) -> dict[str, Any]:
        all_key = _cache_key("ch_readable", manga_id, lang)
        cached = await redis_manager.get_cached(all_key)

        if cached:
            logger.debug(f"Chapters cache hit: {all_key}")
            all_chapters = cached.get("data", [])
            total = cached.get("total", 0)
        else:
            logger.info(
                f"Fetching all readable chapters for {manga_id} (lang={lang})"
            )
            result = await self.aggregator.get_all_chapters(manga_id, lang)
            all_chapters = result.get("data", [])
            total = result.get("total", len(all_chapters))

            # Cache even if empty (to avoid re-fetching constantly)
            await redis_manager.set_cached(
                all_key,
                {"data": all_chapters, "total": total},
                CACHE_TTL_CHAPTERS,
            )

        return {
            "data": all_chapters,
            "total": total,
            "limit": total,
            "offset": 0,
        }

    async def get_characters(self, manga_id: str) -> dict[str, Any]:
        key = _cache_key("characters", manga_id)
        cached = await redis_manager.get_cached(key)
        if cached:
            logger.debug(f"Characters cache hit: {key}")
            return cached
        result = await self.aggregator.get_characters(manga_id)
        if result.get("data"):
            await redis_manager.set_cached(key, result, CACHE_TTL_CHARACTERS)
        return result

    async def get_pages(
        self, chapter_id: str, quality: str = "data"
    ) -> dict[str, Any]:
        key = _cache_key("pages", chapter_id, quality)
        cached = await redis_manager.get_cached(key)
        if cached:
            return cached
        result = await self.aggregator.get_pages(chapter_id, quality)
        await redis_manager.set_cached(key, result, CACHE_TTL_PAGES)
        return result