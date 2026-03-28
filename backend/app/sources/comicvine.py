# backend/app/sources/comicvine.py
import asyncio
from typing import Any, Optional
import httpx
from loguru import logger
from app.config import settings


class ComicVineSource:
    """ComicVine API for western comics metadata (read-only, no pages)."""

    def __init__(self, client: httpx.AsyncClient) -> None:
        self.client = client
        self.base_url = settings.COMICVINE_API_URL
        self.api_key = settings.COMICVINE_API_KEY

    def _default_params(self) -> dict[str, str]:
        return {
            "api_key": self.api_key,
            "format": "json",
        }

    async def _request(self, url: str, params: Optional[dict] = None) -> dict[str, Any]:
        merged = self._default_params()
        if params:
            merged.update(params)

        for attempt in range(3):
            try:
                resp = await self.client.get(url, params=merged)
                if resp.status_code == 429:
                    retry_after = int(resp.headers.get("retry-after", 5))
                    logger.warning(f"ComicVine rate limited, retrying in {retry_after}s")
                    await asyncio.sleep(retry_after)
                    continue
                if resp.status_code == 404:
                    return {"results": []}
                resp.raise_for_status()
                return resp.json()
            except httpx.HTTPStatusError as e:
                logger.error(f"ComicVine HTTP error {e.response.status_code}: {url}")
                if attempt == 2:
                    return {"results": []}
                await asyncio.sleep(2 * (attempt + 1))
            except httpx.RequestError as e:
                logger.error(f"ComicVine request error: {e}")
                if attempt == 2:
                    return {"results": []}
                await asyncio.sleep(2 * (attempt + 1))
        return {"results": []}

    @staticmethod
    def _parse_volume(item: dict) -> dict[str, Any]:
        publisher = item.get("publisher")
        return {
            "id": f"cv-{item.get('id', '')}",
            "source": "comicvine",
            "title": item.get("name", "Unknown Title"),
            "description": item.get("deck") or item.get("description"),
            "status": None,
            "year": int(item["start_year"]) if item.get("start_year") else None,
            "content_rating": None,
            "tags": [],
            "cover_url": item.get("image", {}).get("medium_url"),
            "author": publisher.get("name") if publisher else None,
            "artist": None,
            "cv_id": item.get("id"),
            "issue_count": item.get("count_of_issues"),
        }

    async def search_manga(
        self, query: str, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        if not self.api_key:
            logger.warning("ComicVine API key not configured")
            return {"data": [], "total": 0, "limit": limit, "offset": offset}

        params = {
            "resources": "volume",
            "query": query,
            "limit": min(limit, 100),
            "offset": offset,
            "field_list": "id,name,deck,description,image,start_year,publisher,count_of_issues",
        }
        data = await self._request(f"{self.base_url}/search/", params=params)
        items = data.get("results", [])
        volumes = [self._parse_volume(item) for item in items if isinstance(item, dict)]
        return {
            "data": volumes,
            "total": data.get("number_of_total_results", len(volumes)),
            "limit": limit,
            "offset": offset,
        }

    async def get_popular(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        if not self.api_key:
            return {"data": [], "total": 0, "limit": limit, "offset": offset}

        params = {
            "sort": "count_of_issues:desc",
            "limit": min(limit, 100),
            "offset": offset,
            "field_list": "id,name,deck,description,image,start_year,publisher,count_of_issues",
        }
        data = await self._request(f"{self.base_url}/volumes/", params=params)
        items = data.get("results", [])
        volumes = [self._parse_volume(item) for item in items if isinstance(item, dict)]
        return {
            "data": volumes,
            "total": data.get("number_of_total_results", len(volumes)),
            "limit": limit,
            "offset": offset,
        }

    async def get_volume_detail(self, cv_id: int) -> dict[str, Any]:
        if not self.api_key:
            return {}

        params = {
            "field_list": "id,name,deck,description,image,start_year,publisher,count_of_issues",
        }
        data = await self._request(f"{self.base_url}/volume/4050-{cv_id}/", params=params)
        item = data.get("results")
        if not item or not isinstance(item, dict):
            return {}
        return self._parse_volume(item)