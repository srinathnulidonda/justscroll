# backend/app/sources/mangadex.py
import asyncio
from typing import Any, Optional
import httpx
from fastapi import HTTPException
from loguru import logger
from app.config import settings
from app.sources.base import MangaSource

MANGADEX_COVERS = "https://uploads.mangadex.org/covers"


class MangaDexSource(MangaSource):
    def __init__(self, client: httpx.AsyncClient) -> None:
        self.client = client
        self.base_url = settings.MANGADEX_BASE_URL

    async def _request(
        self,
        url: str,
        params: Optional[dict] = None,
        raise_on_404: bool = False,
    ) -> dict[str, Any]:
        for attempt in range(3):
            try:
                resp = await self.client.get(url, params=params)

                if resp.status_code == 429:
                    retry_after = int(resp.headers.get("retry-after", 2))
                    logger.warning(
                        f"MangaDex rate limited, retrying in {retry_after}s"
                    )
                    await asyncio.sleep(retry_after)
                    continue

                if resp.status_code == 404:
                    if raise_on_404:
                        raise HTTPException(
                            status_code=404,
                            detail="Resource not found on MangaDex",
                        )
                    logger.warning(f"MangaDex 404 (non-fatal): {url}")
                    return {"data": [], "total": 0}

                resp.raise_for_status()
                return resp.json()

            except HTTPException:
                raise
            except httpx.HTTPStatusError as e:
                logger.error(
                    f"MangaDex HTTP error {e.response.status_code}: {url}"
                )
                if attempt == 2:
                    raise HTTPException(
                        status_code=502, detail="MangaDex upstream error"
                    )
                await asyncio.sleep(1 * (attempt + 1))
            except httpx.RequestError as e:
                logger.error(f"MangaDex request error: {e}")
                if attempt == 2:
                    raise HTTPException(
                        status_code=502,
                        detail="Failed to connect to MangaDex",
                    )
                await asyncio.sleep(1 * (attempt + 1))
        return {"data": [], "total": 0}

    @staticmethod
    def _extract_title(attrs: dict) -> str:
        title = attrs.get("title", {})
        if "en" in title:
            return title["en"]
        if "ja-ro" in title:
            return title["ja-ro"]
        if title:
            return next(iter(title.values()))
        alt_titles = attrs.get("altTitles", [])
        for alt in alt_titles:
            if "en" in alt:
                return alt["en"]
        return "Unknown Title"

    @staticmethod
    def _extract_description(attrs: dict) -> Optional[str]:
        desc = attrs.get("description", {})
        return desc.get("en") or (next(iter(desc.values()), None) if desc else None)

    @staticmethod
    def _extract_cover_url(manga_id: str, relationships: list) -> Optional[str]:
        for rel in relationships:
            if rel.get("type") == "cover_art":
                filename = rel.get("attributes", {}).get("fileName")
                if filename:
                    return f"{MANGADEX_COVERS}/{manga_id}/{filename}.256.jpg"
        return None

    @staticmethod
    def _extract_person(relationships: list, person_type: str) -> Optional[str]:
        for rel in relationships:
            if rel.get("type") == person_type:
                name = rel.get("attributes", {}).get("name")
                if name:
                    return name
        return None

    @staticmethod
    def _extract_tags(attrs: dict) -> list[str]:
        tags = []
        for tag in attrs.get("tags", []):
            name = tag.get("attributes", {}).get("name", {})
            tag_name = name.get("en")
            if tag_name:
                tags.append(tag_name)
        return tags

    @staticmethod
    def _extract_group(relationships: list) -> Optional[str]:
        for rel in relationships:
            if rel.get("type") == "scanlation_group":
                return rel.get("attributes", {}).get("name")
        return None

    @staticmethod
    def _extract_mal_id(attrs: dict) -> Optional[int]:
        links = attrs.get("links", {})
        mal = links.get("mal")
        if mal:
            try:
                return int(mal)
            except (ValueError, TypeError):
                pass
        return None

    def _parse_manga(self, item: dict) -> dict[str, Any]:
        attrs = item.get("attributes", {})
        rels = item.get("relationships", [])
        manga_id = item["id"]
        return {
            "id": manga_id,
            "source": "mangadex",
            "title": self._extract_title(attrs),
            "description": self._extract_description(attrs),
            "status": attrs.get("status"),
            "year": attrs.get("year"),
            "content_rating": attrs.get("contentRating"),
            "tags": self._extract_tags(attrs),
            "cover_url": self._extract_cover_url(manga_id, rels),
            "author": self._extract_person(rels, "author"),
            "artist": self._extract_person(rels, "artist"),
            "mal_id": self._extract_mal_id(attrs),
        }

    def _parse_chapter(self, item: dict) -> dict[str, Any]:
        attrs = item.get("attributes", {})
        rels = item.get("relationships", [])
        external_url = attrs.get("externalUrl")
        pages = attrs.get("pages", 0)
        return {
            "id": item["id"],
            "chapter": attrs.get("chapter"),
            "title": attrs.get("title"),
            "volume": attrs.get("volume"),
            "pages": pages,
            "language": attrs.get("translatedLanguage", "en"),
            "published_at": attrs.get("publishAt"),
            "scanlation_group": self._extract_group(rels),
            "external_url": external_url,
            "readable": pages > 0 and not external_url,
        }

    async def search_manga(
        self, query: str, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        params = {
            "title": query,
            "limit": min(limit, 100),
            "offset": offset,
            "includes[]": ["cover_art"],
            "order[relevance]": "desc",
            "contentRating[]": ["safe", "suggestive", "erotica"],
        }
        data = await self._request(f"{self.base_url}/manga", params=params)
        mangas = [self._parse_manga(item) for item in data.get("data", [])]
        return {
            "data": mangas,
            "total": data.get("total", 0),
            "limit": limit,
            "offset": offset,
        }

    async def get_popular(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        params = {
            "limit": min(limit, 100),
            "offset": offset,
            "includes[]": ["cover_art"],
            "order[followedCount]": "desc",
            "contentRating[]": ["safe", "suggestive"],
            "hasAvailableChapters": "true",
        }
        data = await self._request(f"{self.base_url}/manga", params=params)
        mangas = [self._parse_manga(item) for item in data.get("data", [])]
        return {
            "data": mangas,
            "total": data.get("total", 0),
            "limit": limit,
            "offset": offset,
        }

    async def get_latest_updates(
        self, limit: int = 20, offset: int = 0
    ) -> dict[str, Any]:
        chapter_params: dict[str, Any] = {
            "limit": min(limit * 3, 100),
            "offset": 0,
            "order[publishAt]": "desc",
            "includes[]": ["manga"],
            "translatedLanguage[]": ["en"],
            "contentRating[]": ["safe", "suggestive"],
        }
        chapter_data = await self._request(
            f"{self.base_url}/chapter", params=chapter_params
        )
        seen_ids: set[str] = set()
        manga_ids: list[str] = []
        for ch in chapter_data.get("data", []):
            for rel in ch.get("relationships", []):
                if rel.get("type") == "manga":
                    mid = rel["id"]
                    if mid not in seen_ids:
                        seen_ids.add(mid)
                        manga_ids.append(mid)
                    break
            if len(manga_ids) >= limit:
                break

        if not manga_ids:
            return {"data": [], "total": 0, "limit": limit, "offset": offset}

        manga_params: dict[str, Any] = {
            "ids[]": manga_ids[offset : offset + limit],
            "includes[]": ["cover_art", "author", "artist"],
            "limit": limit,
            "contentRating[]": ["safe", "suggestive"],
        }
        manga_data = await self._request(
            f"{self.base_url}/manga", params=manga_params
        )
        id_order = {mid: i for i, mid in enumerate(manga_ids)}
        mangas = [self._parse_manga(item) for item in manga_data.get("data", [])]
        mangas.sort(key=lambda m: id_order.get(m["id"], 999))
        return {
            "data": mangas,
            "total": len(seen_ids),
            "limit": limit,
            "offset": offset,
        }

    async def get_manga_detail(self, manga_id: str) -> dict[str, Any]:
        params = {"includes[]": ["cover_art", "author", "artist"]}
        data = await self._request(
            f"{self.base_url}/manga/{manga_id}",
            params=params,
            raise_on_404=True,
        )
        item = data.get("data")
        if not item:
            return {}
        return self._parse_manga(item)

    async def get_mal_id(self, manga_id: str) -> Optional[int]:
        params = {"includes[]": ["cover_art"]}
        data = await self._request(
            f"{self.base_url}/manga/{manga_id}", params=params
        )
        item = data.get("data")
        if not item:
            return None
        attrs = item.get("attributes", {})
        return self._extract_mal_id(attrs)

    async def get_chapters(
        self,
        manga_id: str,
        lang: str = "en",
        limit: int = 10000,
        offset: int = 0,
    ) -> dict[str, Any]:
        """Fetch ALL readable chapters with auto-pagination."""
        all_chapters: list[dict[str, Any]] = []
        current_offset = offset
        api_total = 0
        max_per_request = 500

        while len(all_chapters) < limit:
            batch_size = min(max_per_request, limit - len(all_chapters))
            params: dict[str, Any] = {
                "translatedLanguage[]": [lang],
                "order[chapter]": "asc",
                "limit": batch_size,
                "offset": current_offset,
                "includes[]": ["scanlation_group"],
                "contentRating[]": ["safe", "suggestive", "erotica"],
                # Tell MangaDex to exclude external-only chapters
                "includeExternalUrl": "0",
                "includeEmptyPages": "0",
            }

            data = await self._request(
                f"{self.base_url}/manga/{manga_id}/feed", params=params
            )

            api_total = data.get("total", 0)
            batch_raw = data.get("data", [])
            batch = [self._parse_chapter(item) for item in batch_raw]
            all_chapters.extend(batch)

            if not batch:
                break
            if len(batch) < batch_size:
                break
            if current_offset + len(batch) >= api_total:
                break

            current_offset += len(batch)
            await asyncio.sleep(0.4)

        # ── Safety net: filter in Python too ──
        # Remove chapters with 0 pages or external URL (in case API params didn't work)
        before_filter = len(all_chapters)
        readable_chapters = [
            ch for ch in all_chapters
            if ch.get("pages", 0) > 0 and ch.get("readable", True)
        ]
        filtered_out = before_filter - len(readable_chapters)

        if filtered_out > 0:
            logger.info(
                f"Filtered out {filtered_out} unreadable chapters "
                f"for manga {manga_id} ({before_filter} total → "
                f"{len(readable_chapters)} readable)"
            )

        # Deduplicate by chapter number (keep first occurrence per number)
        seen_chapters: set[str] = set()
        unique_chapters: list[dict[str, Any]] = []
        for ch in readable_chapters:
            ch_num = ch.get("chapter") or ch.get("id")
            if ch_num not in seen_chapters:
                seen_chapters.add(ch_num)
                unique_chapters.append(ch)

        if len(unique_chapters) != len(readable_chapters):
            logger.info(
                f"Deduplicated chapters for {manga_id}: "
                f"{len(readable_chapters)} → {len(unique_chapters)}"
            )

        logger.info(
            f"Chapters for {manga_id}: {api_total} on API, "
            f"{before_filter} fetched, {len(unique_chapters)} readable+unique"
        )

        return {
            "data": unique_chapters,
            "total": len(unique_chapters),
            "limit": len(unique_chapters),
            "offset": offset,
        }

    async def get_pages(
        self, chapter_id: str, quality: str = "data"
    ) -> dict[str, Any]:
        data = await self._request(
            f"{self.base_url}/at-home/server/{chapter_id}",
            raise_on_404=True,
        )
        base_url = data.get("baseUrl", "")
        chapter_data = data.get("chapter", {})
        chapter_hash = chapter_data.get("hash", "")
        filenames = chapter_data.get(
            quality if quality in ("data", "dataSaver") else "data", []
        )
        quality_path = "data-saver" if quality == "dataSaver" else quality
        pages = [
            f"{base_url}/{quality_path}/{chapter_hash}/{fn}" for fn in filenames
        ]
        return {"pages": pages, "quality": quality}