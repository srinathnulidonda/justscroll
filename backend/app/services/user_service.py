# backend/app/services/user_service.py
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, func, desc
from app.models.user import User, Bookmark, ReadingHistory
from app.auth.utils import hash_password, verify_password


class UserService:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def create_user(self, username: str, email: str, password: str) -> User:
        user = User(
            username=username,
            email=email,
            hashed_password=hash_password(password),
        )
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def get_user_by_username(self, username: str) -> Optional[User]:
        result = await self.db.execute(select(User).where(User.username == username))
        return result.scalar_one_or_none()

    async def get_user_by_email(self, email: str) -> Optional[User]:
        result = await self.db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def authenticate(self, username: str, password: str) -> Optional[User]:
        user = await self.get_user_by_username(username)
        if user and verify_password(password, user.hashed_password):
            return user
        return None

    async def get_bookmarks(self, user_id: int) -> dict:
        count_result = await self.db.execute(
            select(func.count()).where(Bookmark.user_id == user_id)
        )
        total = count_result.scalar() or 0
        result = await self.db.execute(
            select(Bookmark)
            .where(Bookmark.user_id == user_id)
            .order_by(desc(Bookmark.created_at))
        )
        bookmarks = result.scalars().all()
        return {"data": bookmarks, "total": total}

    async def add_bookmark(
        self,
        user_id: int,
        manga_id: str,
        manga_title: str,
        cover_url: Optional[str] = None,
    ) -> Bookmark:
        existing = await self.db.execute(
            select(Bookmark).where(
                Bookmark.user_id == user_id, Bookmark.manga_id == manga_id
            )
        )
        bookmark = existing.scalar_one_or_none()
        if bookmark:
            bookmark.manga_title = manga_title
            bookmark.cover_url = cover_url
        else:
            bookmark = Bookmark(
                user_id=user_id,
                manga_id=manga_id,
                manga_title=manga_title,
                cover_url=cover_url,
            )
            self.db.add(bookmark)
        await self.db.commit()
        await self.db.refresh(bookmark)
        return bookmark

    async def remove_bookmark(self, user_id: int, manga_id: str) -> bool:
        result = await self.db.execute(
            delete(Bookmark).where(
                Bookmark.user_id == user_id, Bookmark.manga_id == manga_id
            )
        )
        await self.db.commit()
        return result.rowcount > 0

    async def get_history(self, user_id: int, limit: int = 50) -> dict:
        count_result = await self.db.execute(
            select(func.count()).where(ReadingHistory.user_id == user_id)
        )
        total = count_result.scalar() or 0
        result = await self.db.execute(
            select(ReadingHistory)
            .where(ReadingHistory.user_id == user_id)
            .order_by(desc(ReadingHistory.updated_at))
            .limit(limit)
        )
        history = result.scalars().all()
        return {"data": history, "total": total}

    async def update_history(
        self,
        user_id: int,
        manga_id: str,
        chapter_id: str,
        manga_title: str,
        chapter_number: Optional[str] = None,
        page_number: int = 1,
    ) -> ReadingHistory:
        result = await self.db.execute(
            select(ReadingHistory).where(
                ReadingHistory.user_id == user_id,
                ReadingHistory.chapter_id == chapter_id,
            )
        )
        entry = result.scalar_one_or_none()
        if entry:
            entry.page_number = page_number
            entry.manga_title = manga_title
            entry.chapter_number = chapter_number
        else:
            entry = ReadingHistory(
                user_id=user_id,
                manga_id=manga_id,
                chapter_id=chapter_id,
                manga_title=manga_title,
                chapter_number=chapter_number,
                page_number=page_number,
            )
            self.db.add(entry)
        await self.db.commit()
        await self.db.refresh(entry)
        return entry