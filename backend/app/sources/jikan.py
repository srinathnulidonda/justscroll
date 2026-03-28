# backend/app/sources/jikan.py
import asyncio
from typing import Any, Optional
import httpx
from loguru import logger
from app.config import settings


class JikanSource:
    """MyAnimeList manga metadata via Jikan v4 (read-only, no chapters/pages)."""

    def __init__(self, client: httpx.AsyncClient) -> None:
        self.client = client
        self.base_url = settings.JIKAN_API_URL

    async def _request(self, url: str, params: Optional[dict] = None) -> dict[str, Any]:
        for attempt in range(3):
            try:
                resp = await self.client.get(url, params=params)
                if resp.status_code == 429:
                    retry_after = int(resp.headers.get("retry-after", 4))
                    logger.warning(f"Jikan rate limited, retrying in {retry_after}s")
                    await asyncio.sleep(retry_after)
                    continue
                if resp.status_code == 404:
                    return {"data": []}
                resp.raise_for_status()
                return resp.json()
            except httpx.HTTPStatusError as e:
                logger.error(f"Jikan HTTP error {e.response.status_code}: {url}")
                if attempt == 2:
                    return {"data": []}
                await asyncio.sleep(2 * (attempt + 1))
            except httpx.RequestError as e:
                logger.error(f"Jikan request error: {e}")
                if attempt == 2:
                    return {"data": []}
                await asyncio.sleep(2 * (attempt + 1))
        return {"data": []}

    @staticmethod
    def _parse_manga(item: dict) -> dict[str, Any]:
        genres = [g.get("name", "") for g in item.get("genres", [])]
        genres += [g.get("name", "") for g in item.get("themes", [])]
        genres += [g.get("name", "") for g in item.get("demographics", [])]
        return {
            "id": f"mal-{item.get('mal_id', '')}",
            "source": "mal",
            "title": item.get("title", "Unknown Title"),
            "description": item.get("synopsis"),
            "status": item.get("status"),
            "year": item.get("year"),
            "content_rating": item.get("rating"),
            "tags": [g for g in genres if g],
            "cover_url": item.get("images", {}).get("jpg", {}).get("large_image_url"),
            "author": (
                item["authors"][0].get("name") if item.get("authors") else None
            ),
            "artist": None,
            "mal_id": item.get("mal_id"),
            "score": item.get("score"),
            "members": item.get("members"),
        }

    @staticmethod
    def _parse_character(item: dict) -> dict[str, Any]:
        char = item.get("character", {})
        images = char.get("images", {})
        jpg = images.get("jpg", {})
        webp = images.get("webp", {})
        return {
            "mal_id": char.get("mal_id"),
            "name": char.get("name", "Unknown"),
            "url": char.get("url"),
            "image_url": (
                jpg.get("image_url")
                or webp.get("image_url")
            ),
            "role": item.get("role", "Supporting"),
        }

    async def search_manga(
        self, query: str, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        page = (offset // limit) + 1 if limit > 0 else 1
        params = {
            "q": query,
            "limit": min(limit, 25),
            "page": page,
            "type": "manga",
            "sfw": "true",
        }
        data = await self._request(f"{self.base_url}/manga", params=params)
        items = data.get("data", [])
        pagination = data.get("pagination", {})
        mangas = [self._parse_manga(item) for item in items]
        return {
            "data": mangas,
            "total": pagination.get("items", {}).get("total", len(mangas)),
            "limit": limit,
            "offset": offset,
        }

    async def get_popular(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        page = (offset // limit) + 1 if limit > 0 else 1
        params = {
            "limit": min(limit, 25),
            "page": page,
            "type": "manga",
            "order_by": "members",
            "sort": "desc",
            "sfw": "true",
        }
        data = await self._request(f"{self.base_url}/manga", params=params)
        items = data.get("data", [])
        pagination = data.get("pagination", {})
        mangas = [self._parse_manga(item) for item in items]
        return {
            "data": mangas,
            "total": pagination.get("items", {}).get("total", len(mangas)),
            "limit": limit,
            "offset": offset,
        }

    async def get_manga_detail(self, mal_id: int) -> dict[str, Any]:
        data = await self._request(f"{self.base_url}/manga/{mal_id}/full")
        item = data.get("data")
        if not item:
            return {}
        return self._parse_manga(item)

    async def get_manga_characters(self, mal_id: int) -> dict[str, Any]:
        """Fetch characters for a manga from Jikan."""
        data = await self._request(f"{self.base_url}/manga/{mal_id}/characters")
        items = data.get("data", [])
        characters = [self._parse_character(item) for item in items]

        # Sort: Main characters first, then Supporting
        role_order = {"Main": 0, "Supporting": 1}
        characters.sort(key=lambda c: role_order.get(c["role"], 2))

        return {
            "data": characters,
            "total": len(characters),
        }