# backend/app/redis_client.py
import json
from typing import Any, Optional
import redis.asyncio as aioredis
from slowapi import Limiter
from slowapi.util import get_remote_address
from loguru import logger
from app.config import settings

limiter = Limiter(key_func=get_remote_address)


class RedisManager:
    def __init__(self) -> None:
        self.redis: Optional[aioredis.Redis] = None

    async def connect(self) -> None:
        try:
            self.redis = aioredis.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                max_connections=20,
            )
            await self.redis.ping()
            logger.info("Redis connected")
        except Exception as e:
            logger.warning(f"Redis connection failed: {e}. Caching disabled.")
            self.redis = None

    async def disconnect(self) -> None:
        if self.redis:
            await self.redis.close()
            logger.info("Redis disconnected")

    async def get_cached(self, key: str) -> Optional[Any]:
        if not self.redis:
            return None
        try:
            data = await self.redis.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            logger.warning(f"Redis GET error for {key}: {e}")
            return None

    async def set_cached(self, key: str, data: Any, ttl: int = 600) -> None:
        if not self.redis:
            return
        try:
            await self.redis.set(key, json.dumps(data, default=str), ex=ttl)
        except Exception as e:
            logger.warning(f"Redis SET error for {key}: {e}")

    async def delete_cached(self, key: str) -> None:
        if not self.redis:
            return
        try:
            await self.redis.delete(key)
        except Exception as e:
            logger.warning(f"Redis DELETE error for {key}: {e}")


redis_manager = RedisManager()