# backend/app/models/__init__.py
from app.models.user import Base, User, Bookmark, ReadingHistory

__all__ = ["Base", "User", "Bookmark", "ReadingHistory"]