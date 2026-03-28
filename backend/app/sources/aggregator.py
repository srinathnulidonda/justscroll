# backend/app/sources/aggregator.py
import asyncio
from typing import Any
import httpx
from loguru import logger
from app.sources.mangadex import MangaDexSource
from app.sources.jikan import JikanSource
from app.sources.comicvine import ComicVineSource


def _deduplicate(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen: set[str] = set()
    unique: list[dict[str, Any]] = []
    for item in items:
        item_id = item.get("id", "")
        if item_id not in seen:
            seen.add(item_id)
            unique.append(item)
    return unique


class MangaAggregator:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self.mangadex = MangaDexSource(client)
        self.jikan = JikanSource(client)
        self.comicvine = ComicVineSource(client)

    async def _gather_results(
        self,
        tasks: list,
        source_names: list[str],
        method_name: str,
        limit: int,
        offset: int,
    ) -> dict[str, Any]:
        results = await asyncio.gather(*tasks, return_exceptions=True)

        merged: list[dict[str, Any]] = []
        total = 0
        for i, result in enumerate(results):
            name = source_names[i]
            if isinstance(result, Exception):
                logger.warning(
                    f"Source {name} failed during {method_name}: {result}"
                )
                continue
            merged.extend(result.get("data", []))
            total += result.get("total", 0)

        merged = _deduplicate(merged)

        return {
            "data": merged[:limit],
            "total": total,
            "limit": limit,
            "offset": offset,
        }

    async def search_manga(
        self, query: str, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        per_source = max(limit // 3, 5)
        tasks = [
            self.mangadex.search_manga(query, per_source, offset),
            self.jikan.search_manga(query, per_source, offset),
            self.comicvine.search_manga(query, per_source, offset),
        ]
        return await self._gather_results(
            tasks,
            ["mangadex", "jikan", "comicvine"],
            "search_manga",
            limit,
            offset,
        )

    async def get_popular(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        per_source = max(limit // 3, 5)
        tasks = [
            self.mangadex.get_popular(per_source, offset),
            self.jikan.get_popular(per_source, offset),
            self.comicvine.get_popular(per_source, offset),
        ]
        return await self._gather_results(
            tasks,
            ["mangadex", "jikan", "comicvine"],
            "get_popular",
            limit,
            offset,
        )

    async def get_latest_updates(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        return await self.mangadex.get_latest_updates(limit, offset)

    async def get_manga_detail(self, manga_id: str) -> dict[str, Any]:
        if manga_id.startswith("mal-"):
            try:
                mal_id = int(manga_id.replace("mal-", ""))
                return await self.jikan.get_manga_detail(mal_id)
            except (ValueError, Exception) as e:
                logger.error(f"Jikan detail error: {e}")
                return {}
        elif manga_id.startswith("cv-"):
            try:
                cv_id = int(manga_id.replace("cv-", ""))
                return await self.comicvine.get_volume_detail(cv_id)
            except (ValueError, Exception) as e:
                logger.error(f"ComicVine detail error: {e}")
                return {}
        else:
            return await self.mangadex.get_manga_detail(manga_id)

    async def get_characters(self, manga_id: str) -> dict[str, Any]:
        """
        Fetch characters for any manga source.
        - mal-{id}: directly call Jikan
        - MangaDex UUID: look up MAL ID first, then call Jikan
        - cv-{id}: not supported (return empty)
        """
        mal_id: int | None = None

        if manga_id.startswith("mal-"):
            try:
                mal_id = int(manga_id.replace("mal-", ""))
            except ValueError:
                return {"data": [], "total": 0}

        elif manga_id.startswith("cv-"):
            logger.info("Characters not available for ComicVine sources")
            return {"data": [], "total": 0}

        else:
            # MangaDex UUID → look up MAL ID from MangaDex links
            logger.info(
                f"Looking up MAL ID for MangaDex manga {manga_id}"
            )
            mal_id = await self.mangadex.get_mal_id(manga_id)
            if not mal_id:
                logger.warning(
                    f"No MAL ID found for MangaDex manga {manga_id}"
                )
                return {"data": [], "total": 0}

        logger.info(f"Fetching characters from Jikan for MAL ID {mal_id}")
        return await self.jikan.get_manga_characters(mal_id)

    async def get_all_chapters(
        self, manga_id: str, lang: str = "en"
    ) -> dict[str, Any]:
        if manga_id.startswith(("mal-", "cv-")):
            return {"data": [], "total": 0}
        return await self.mangadex.get_chapters(manga_id, lang, limit=10000)

    async def get_chapters(
        self,
        manga_id: str,
        lang: str = "en",
        limit: int = 10000,
        offset: int = 0,
    ) -> dict[str, Any]:
        if manga_id.startswith(("mal-", "cv-")):
            return {"data": [], "total": 0, "limit": limit, "offset": offset}
        return await self.mangadex.get_chapters(manga_id, lang, limit, offset)

    async def get_pages(
        self, chapter_id: str, quality: str = "data"
    ) -> dict[str, Any]:
        return await self.mangadex.get_pages(chapter_id, quality)