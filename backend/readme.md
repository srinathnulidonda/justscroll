<div align="center">

<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/logo.png" alt="JustScroll" height="60" />

<br />

# ✦ JustScroll Backend

**High-performance manga aggregation API**

FastAPI backend powering the JustScroll manga reader platform.
<br />

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/Python_3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy_2.0-D71F00?style=for-the-badge&logo=sqlalchemy&logoColor=white)

<br />

[Features](#-features) · [Quick Start](#-quick-start) · [API Reference](#-api-reference) · [Architecture](#-architecture) · [Deployment](#-deployment)
<br />

---
</div>

## ◆ Features

<table>
<tr>
<td width="50%">

### 🔗 Multi-Source Aggregation
- **MangaDex** — Full manga/chapter/page support
- **Jikan (MAL)** — Scores, members, characters
- **ComicVine** — Western comics metadata
- Automatic deduplication across sources
- Graceful fallbacks on source failures

</td>
<td width="50%">

### ⚡ Performance
- Async everywhere (asyncpg, httpx, aioredis)
- Redis caching with versioned keys
- Connection pooling (20 DB / 100 HTTP)
- Background token refresh
- Lazy chapter pagination (500/batch)

</td>
</tr>
<tr>
<td width="50%">

### 🔐 Authentication
- JWT access + refresh tokens
- Bcrypt password hashing
- Automatic token refresh flow
- Protected route dependencies
- Rate limiting per endpoint

</td>
<td width="50%">

### 📚 User Features
- Bookmark library with covers
- Reading history with page resume
- Progress tracking per chapter
- Cascade delete on user removal

</td>
</tr>
<tr>
<td width="50%">

### 🛡️ Security
- CORS whitelist configuration
- Image proxy with domain allowlist
- SQL injection protection (SQLAlchemy ORM)
- Input validation (Pydantic)
- Rate limiting (slowapi)

</td>
<td width="50%">

### 📊 Observability
- Structured logging (Loguru)
- Health check endpoint
- Redis/DB connectivity monitoring
- Request error tracking
- Cache hit/miss logging

</td>
</tr>
</table>

<br />

## ◆ Tech Stack

| Layer | Technology | Purpose |
|:------|:-----------|:--------|
| **Framework** | FastAPI 0.110+ | Async API with auto OpenAPI docs |
| **Runtime** | Python 3.11+ | Modern async/await, type hints |
| **Database** | PostgreSQL 15+ | User data, bookmarks, history |
| **ORM** | SQLAlchemy 2.0 | Async sessions, mapped classes |
| **Cache** | Redis 7+ | Response caching, rate limiting |
| **HTTP Client** | httpx | Async requests to manga sources |
| **Auth** | PyJWT + bcrypt | Token generation, password hashing |
| **Validation** | Pydantic v2 | Request/response schemas |
| **Server** | Uvicorn | ASGI server with hot reload |

<br />

## ◆ Quick Start

### Prerequisites

```
Python ≥ 3.11
PostgreSQL ≥ 15
Redis ≥ 7
```

### Install & Run

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create environment file
cp .env.example .env
# Edit .env with your database credentials

# Run database migrations
alembic upgrade head

# Start development server
python main.py
```

API available at **`http://localhost:8000`**
Swagger docs at **`http://localhost:8000/docs`**

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/justscroll

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-256-bit-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS (comma-separated)
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,https://justscroll.vercel.app

# External APIs (optional)
COMICVINE_API_KEY=your-comicvine-key

# Logging
LOG_LEVEL=INFO
```

<br />

## ◆ API Reference

### Authentication

| Method | Endpoint | Body | Response |
|:-------|:---------|:-----|:---------|
| `POST` | `/api/v1/auth/register` | `{ username, email, password }` | `{ access_token, refresh_token }` |
| `POST` | `/api/v1/auth/login` | `{ username, password }` | `{ access_token, refresh_token }` |
| `POST` | `/api/v1/auth/refresh` | `{ refresh_token }` | `{ access_token, refresh_token }` |

### Manga

| Method | Endpoint | Query Params | Description |
|:-------|:---------|:-------------|:------------|
| `GET` | `/api/v1/manga/search` | `q`, `limit`, `offset` | Search across all sources |
| `GET` | `/api/v1/manga/popular` | `limit`, `offset` | Popular titles (aggregated) |
| `GET` | `/api/v1/manga/latest-updates` | `limit`, `offset` | Recently updated (MangaDex) |
| `GET` | `/api/v1/manga/{id}` | — | Manga details |
| `GET` | `/api/v1/manga/{id}/chapters` | `lang`, `limit`, `offset` | Chapter list (readable only) |
| `GET` | `/api/v1/manga/{id}/characters` | — | Character list (via Jikan) |

### Chapters

| Method | Endpoint | Query Params | Description |
|:-------|:---------|:-------------|:------------|
| `GET` | `/api/v1/chapters/{id}/pages` | `quality` | Page URLs (`data` or `dataSaver`) |

### User (🔒 Requires Auth)

| Method | Endpoint | Body | Description |
|:-------|:---------|:-----|:------------|
| `GET` | `/api/v1/user/bookmarks` | — | List all bookmarks |
| `POST` | `/api/v1/user/bookmarks/{manga_id}` | `{ manga_title, cover_url }` | Add bookmark |
| `DELETE` | `/api/v1/user/bookmarks/{manga_id}` | — | Remove bookmark |
| `GET` | `/api/v1/user/history` | — | Reading history |
| `POST` | `/api/v1/user/history` | `{ manga_id, chapter_id, ... }` | Update progress |

### Proxy

| Method | Endpoint | Query Params | Description |
|:-------|:---------|:-------------|:------------|
| `GET` | `/api/v1/proxy/image` | `url` | Proxy external images |

### Health

| Method | Endpoint | Response |
|:-------|:---------|:---------|
| `GET` | `/health` | `{ status, redis, database }` |

<br />

## ◆ Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Apps                             │
│                   (Web / Mobile / Desktop)                      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FastAPI Backend                            │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │   Routers   │  │  Services   │  │   Sources   │             │
│   │  (auth,     │──│  (manga,    │──│  (mangadex, │             │
│   │   manga,    │  │   user)     │  │   jikan,    │             │
│   │   user)     │  │             │  │   comicvine)│             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│         │                │                │                     │
│         ▼                ▼                ▼                     │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │  Schemas    │  │    Redis    │  │    httpx    │             │
│   │  (Pydantic) │  │   (cache)   │  │  (external) │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│         │                                                       │
│         ▼                                                       │
│   ┌─────────────────────────────────────────────┐               │
│   │              PostgreSQL (SQLAlchemy)        │               │
│   │    users | bookmarks | reading_history      │               │
│   └─────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    External APIs                                │
│   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│   │   MangaDex    │  │  Jikan (MAL)  │  │   ComicVine   │       │
│   │  (chapters,   │  │   (scores,    │  │   (western    │       │
│   │    pages)     │  │  characters)  │  │    comics)    │       │
│   └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

### Source Aggregation

```
                    MangaAggregator
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │ MangaDex │    │  Jikan   │    │ComicVine │
    │  (full)  │    │(metadata)│    │(metadata)│
    └──────────┘    └──────────┘    └──────────┘
          │               │               │
          └───────────────┼───────────────┘
                          ▼
                   Deduplicated &
                   Merged Results
```

### ID Prefixes

| Source | ID Format | Example |
|:-------|:----------|:--------|
| MangaDex | UUID | `a1c7c817-4e59-43b7-9365-09675a149a6f` |
| Jikan (MAL) | `mal-{id}` | `mal-13` |
| ComicVine | `cv-{id}` | `cv-18166` |

### Caching Strategy

| Data Type | Cache Key Pattern | TTL |
|:----------|:------------------|:----|
| Search results | `manga:v2:search:{hash}` | 10 min |
| Popular manga | `manga:v2:popular:{hash}` | 30 min |
| Latest updates | `manga:v2:latest:{hash}` | 10 min |
| Manga detail | `manga:v2:detail:{hash}` | 60 min |
| Chapters | `manga:v2:ch_readable:{hash}` | 30 min |
| Chapter pages | `manga:v2:pages:{hash}` | 15 min |
| Characters | `manga:v2:characters:{hash}` | 24 hr |

> Cache version (`v2`) is bumped when filtering logic changes to auto-invalidate stale data.

### Database Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                            users                                │
├─────────────────────────────────────────────────────────────────┤
│ id              │ SERIAL PRIMARY KEY                            │
│ username        │ VARCHAR(50) UNIQUE NOT NULL                   │
│ email           │ VARCHAR(255) UNIQUE NOT NULL                  │
│ hashed_password │ VARCHAR(255) NOT NULL                         │
│ is_active       │ BOOLEAN DEFAULT TRUE                          │
│ created_at      │ TIMESTAMP DEFAULT NOW()                       │
│ updated_at      │ TIMESTAMP DEFAULT NOW()                       │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────────┐ ┌─────────────────────────────────┐
│         bookmarks           │ │       reading_history           │
├─────────────────────────────┤ ├─────────────────────────────────┤
│ id          │ SERIAL PK     │ │ id            │ SERIAL PK       │
│ user_id     │ FK → users    │ │ user_id       │ FK → users      │
│ manga_id    │ VARCHAR(255)  │ │ manga_id      │ VARCHAR(255)    │
│ manga_title │ VARCHAR(500)  │ │ chapter_id    │ VARCHAR(255)    │
│ cover_url   │ TEXT NULL     │ │ manga_title   │ VARCHAR(500)    │
│ created_at  │ TIMESTAMP     │ │ chapter_number│ VARCHAR(50)     │
├─────────────────────────────┤ │ page_number   │ INTEGER         │
│ UNIQUE(user_id, manga_id)   │ │ updated_at    │ TIMESTAMP       │
└─────────────────────────────┘ ├─────────────────────────────────┤
                                │ UNIQUE(user_id, chapter_id)     │
                                └─────────────────────────────────┘
```

### Authentication Flow

```
┌──────────┐                              ┌──────────┐
│  Client  │                              │  Backend │
└────┬─────┘                              └────┬─────┘
     │                                         │
     │  POST /auth/login {user, pass}          │
     │────────────────────────────────────────▶│
     │                                         │
     │         { access_token (30m),           │
     │           refresh_token (7d) }          │
     │◀────────────────────────────────────────│
     │                                         │
     │  GET /user/bookmarks                    │
     │  Authorization: Bearer {access_token}   │
     │────────────────────────────────────────▶│
     │                                         │
     │         { data: [...] }                 │
     │◀────────────────────────────────────────│
     │                                         │
     │  ─── access_token expires ───           │
     │                                         │
     │  POST /auth/refresh {refresh_token}     │
     │────────────────────────────────────────▶│
     │                                         │
     │         { new access_token,             │
     │           new refresh_token }           │
     │◀────────────────────────────────────────│
     │                                         │
```

### Rate Limits

| Endpoint Group | Limit |
|:---------------|:------|
| Auth (register) | 10/min |
| Auth (login) | 20/min |
| Auth (refresh) | 30/min |
| Manga endpoints | 60/min |
| User endpoints | 120/min |
| Image proxy | 300/min |

<br />

## ◆ Deployment

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose

```yaml
services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:${POSTGRES_PASSWORD:-postgres}@db:5432/justscroll
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY}
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=justscroll
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Railway / Render

1. Connect your GitHub repository
2. Set environment variables in dashboard
3. Deploy with:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Production

| Service | URL |
|:--------|:----|
| **API** | [http://localhost:8000](http://localhost:8000) |
| **Swagger Docs** | [http://localhost:8000/docs](http://localhost:8000/docs) |
| **Health Check** | [http://localhost:8000/health](http://localhost:8000/health) |

```bash
curl http://localhost:8000/health
# { "status": "ok", "redis": true, "database": true }
```

<br />

## ◆ Scripts

| Command | Description |
|:--------|:------------|
| `python main.py` | Start dev server with hot reload |
| `uvicorn main:app --reload` | Alternative dev start |
| `alembic upgrade head` | Run pending migrations |
| `alembic revision --autogenerate -m "msg"` | Generate migration |
| `pytest` | Run test suite |
| `ruff check .` | Lint code |
| `ruff format .` | Format code |

<br />

## ◆ Data Sources

Content is aggregated from third-party APIs. JustScroll does not host any manga/comic content.

| Source | API | Data Provided |
|:-------|:----|:--------------|
| [MangaDex](https://api.mangadex.org) | REST | Manga metadata, chapters, page images |
| [Jikan](https://api.jikan.moe/v4) | REST | MAL scores, members, characters |
| [ComicVine](https://comicvine.gamespot.com/api) | REST | Western comic metadata |

<br />

---
<div align="center">

**Part of the [JustScroll](../README.md) platform**

Built with FastAPI, PostgreSQL & async Python.
</div>