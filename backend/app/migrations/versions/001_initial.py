# backend/app/migrations/versions/001_initial.py
"""initial tables

Revision ID: 001
Revises:
Create Date: 2024-01-01 00:00:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("username", sa.String(length=50), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=True, server_default="true"),
        sa.Column("created_at", sa.DateTime(), nullable=True, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=True, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_users_username"), "users", ["username"], unique=True)
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)

    op.create_table(
        "bookmarks",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("manga_id", sa.String(length=255), nullable=False),
        sa.Column("manga_title", sa.String(length=500), nullable=False),
        sa.Column("cover_url", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "manga_id", name="uq_user_manga_bookmark"),
    )
    op.create_index(op.f("ix_bookmarks_user_id"), "bookmarks", ["user_id"])
    op.create_index(op.f("ix_bookmarks_manga_id"), "bookmarks", ["manga_id"])

    op.create_table(
        "reading_history",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("manga_id", sa.String(length=255), nullable=False),
        sa.Column("chapter_id", sa.String(length=255), nullable=False),
        sa.Column("manga_title", sa.String(length=500), nullable=False),
        sa.Column("chapter_number", sa.String(length=50), nullable=True),
        sa.Column("page_number", sa.Integer(), nullable=True, server_default="1"),
        sa.Column("updated_at", sa.DateTime(), nullable=True, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "chapter_id", name="uq_user_chapter_history"),
    )
    op.create_index(op.f("ix_reading_history_user_id"), "reading_history", ["user_id"])
    op.create_index(op.f("ix_reading_history_manga_id"), "reading_history", ["manga_id"])


def downgrade() -> None:
    op.drop_table("reading_history")
    op.drop_table("bookmarks")
    op.drop_table("users")