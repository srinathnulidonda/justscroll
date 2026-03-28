# backend/app/routers/proxy.py
from urllib.parse import urlparse
from fastapi import APIRouter, Request, Query, HTTPException
from fastapi.responses import Response
from loguru import logger
from app.redis_client import limiter
from app.config import settings

router = APIRouter()

# Domains that always work regardless of env var
_BUILTIN_DOMAINS = {
    "mangadex.org",
    "uploads.mangadex.org",
    "myanimelist.net",
    "cdn.myanimelist.net",
    "comicvine.gamespot.com",
}

ALLOWED_DOMAINS = _BUILTIN_DOMAINS | set(settings.image_proxy_domains_list)


def _is_allowed_domain(hostname: str | None) -> bool:
    if not hostname:
        return False
    # Exact match
    if hostname in ALLOWED_DOMAINS:
        return True
    # Subdomain match
    for domain in ALLOWED_DOMAINS:
        if hostname.endswith(f".{domain}"):
            return True
    # Dynamic MangaDex CDN subdomains
    if hostname.endswith(".mangadex.network"):
        return True
    return False


@router.get("/image")
@limiter.limit("300/minute")
async def proxy_image(
    request: Request,
    url: str = Query(..., min_length=10),
):
    parsed = urlparse(url)
    if not _is_allowed_domain(parsed.hostname):
        logger.warning(f"Proxy blocked domain: {parsed.hostname}")
        raise HTTPException(
            status_code=400,
            detail=f"Domain not allowed: {parsed.hostname}",
        )

    try:
        client = request.app.state.http_client
        resp = await client.get(url)
        resp.raise_for_status()
        content_type = resp.headers.get("content-type", "image/jpeg")
        return Response(
            content=resp.content,
            media_type=content_type,
            headers={
                "Cache-Control": "public, max-age=86400",
                "Access-Control-Allow-Origin": "*",
            },
        )
    except Exception as e:
        logger.error(f"Image proxy error for {url}: {e}")
        raise HTTPException(status_code=502, detail="Failed to fetch image")