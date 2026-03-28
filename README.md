<div align="center">

<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/logo.png" alt="JustScroll" height="60" />

<br />

**Discover, read, and track your favorite manga — beautifully.**

A full-stack manga reader platform with web, mobile, and a powerful aggregation backend.

<br />

[![Backend](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](./backend)
[![Frontend](https://img.shields.io/badge/Web-React_18-61DAFB?style=for-the-badge&logo=react&logoColor=black)](./web)
[![Mobile](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](./mobile)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](./LICENSE)
<br />

<a href="https://justscroll.vercel.app">
  <img src="https://img.shields.io/badge/Live_Demo-justscroll.vercel.app-5B4CD5?style=for-the-badge&logo=vercel&logoColor=white" alt="Live Demo" />
</a>
&nbsp;&nbsp;
<a href="https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk">
  <img src="https://img.shields.io/badge/Android_APK-v1.0.0-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
</a>

<br />

[Screenshots](#-screenshots) · [Features](#-features) · [Download](#-download) · [Quick Start](#-quick-start) · [Architecture](#-architecture) · [API Reference](#-api-reference)
<br />

---

</div>

<br />

## ◆ About

JustScroll aggregates manga, manhwa, and comics from multiple sources into a single, polished reading experience. No content is hosted — everything is fetched in real-time from third-party APIs, proxied for performance, and cached for speed.

Three clients. One backend. Thousands of titles.

<br />

## ◆ Screenshots

### Web — Desktop

<table>
<tr>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-home.png" alt="Home Page" />
<p align="center"><strong>Home</strong> — Popular & Latest with genre filters</p>
</td>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-discover.png" alt="Discover Page" />
<p align="center"><strong>Discover</strong> — Tabbed browsing with pagination</p>
</td>
</tr>
<tr>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-detail.png" alt="Manga Detail" />
<p align="center"><strong>Manga Detail</strong> — Stats, chapters & characters</p>
</td>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-reader.png" alt="Chapter Reader" />
<p align="center"><strong>Reader</strong> — Fullscreen with settings panel</p>
</td>
</tr>
<tr>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-profile.png" alt="Profile Page" />
<p align="center"><strong>Profile</strong> — Dashboard with stats & settings</p>
</td>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/desktop-search.png" alt="Search Page" />
<p align="center"><strong>Search</strong> — Full-text search with results grid</p>
</td>
</tr>
</table>

### Mobile

<table>
<tr>
<td width="25%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/mobile/assets/screenshots/mobile-home.png" alt="Home" />
<p align="center"><strong>Home</strong></p>
</td>
<td width="25%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/mobile/assets/screenshots/mobile-detail.png" alt="Detail" />
<p align="center"><strong>Manga Detail</strong></p>
</td>
<td width="25%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/mobile/assets/screenshots/mobile-reader.png" alt="Reader" />
<p align="center"><strong>Reader</strong></p>
</td>
<td width="25%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/mobile/assets/screenshots/mobile-profile.png" alt="Profile" />
<p align="center"><strong>Profile</strong></p>
</td>
</tr>
</table>


### Themes

<table>
<tr>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/theme-dark.png" alt="Dark Theme" />
<p align="center"><strong>Dark Mode</strong></p>
</td>
<td width="50%">
<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/screenshots/theme-light.png" alt="Light Theme" />
<p align="center"><strong>Light Mode</strong></p>
</td>
</tr>
</table>

<br />

## ◆ Download

<table>
<tr>
<td width="50%">

### 🌐 Web

Open in any modern browser — no installation required.

<a href="https://justscroll.vercel.app"><strong>justscroll.vercel.app →</strong></a>

<br />

Supports Chrome 90+, Firefox 90+, Safari 15+, Edge 90+

</td>
<td width="50%">

### 📱 Android

| Source | Download |
|:-------|:---------|
| GitHub (ARM64) | [justscroll-v1.0.0-arm64.apk](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk) ✦ Recommended |
| GitHub (Legacy) | [justscroll-v1.0.0-legacy.apk](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-legacy.apk) |
| Google Drive | [justscroll-v1.0.0-arm64.apk](https://drive.google.com/file/d/1itP7SCk5OTgMyM0O15-Dq-hyTtrDqJKP/view?usp=sharing) |

> Download → Enable *Install from unknown sources* → Open & install

</td>
</tr>
</table>

<details>
<summary><strong>Release History</strong></summary>

<br />

| Version | Date | Changes | Download |
|:--------|:-----|:--------|:---------|
| **v1.0.0** | Dec 2025 | Initial release — reader, bookmarks, auth, multi-source | [ARM64 APK](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk) · [Legacy APK](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-legacy.apk) · [Drive](https://drive.google.com/file/d/1itP7SCk5OTgMyM0O15-Dq-hyTtrDqJKP/view?usp=sharing) |

All releases → [github.com/srinathnulidonda/justscroll/releases](https://github.com/srinathnulidonda/justscroll/releases)

</details>

<br />

## ◆ Features

<table>
<tr>
<td width="50%">

### 📚 Multi-Source Aggregation
- **MangaDex** — metadata, chapters, page images
- **Jikan (MAL)** — scores, members, characters
- **ComicVine** — western comics metadata
- Automatic deduplication across sources
- Graceful fallbacks on source failures

</td>
<td width="50%">

### 📖 Full-Featured Reader
- Single page & continuous long strip modes
- Left-to-right / Right-to-left direction
- Pinch zoom & keyboard navigation
- Auto-hiding toolbar with scroll detection
- Quality toggle (high / data saver)
- Chapter navigator & progress slider
- Auto-save reading progress

</td>
</tr>
<tr>
<td width="50%">

### 🔍 Discover & Search
- Popular & latest manga feeds
- 25+ genre filters with horizontal toolbar
- Full-text search with paginated results
- Unified results from all sources

</td>
<td width="50%">

### 👤 User System
- JWT authentication with auto-refresh
- Bookmark library with cover grid
- Reading history with chapter resume
- Profile dashboard with stats & settings
- Protected routes with redirect

</td>
</tr>
<tr>
<td width="50%">

### ⚡ Performance
- Redis caching with versioned keys (10m–24h TTL)
- Image proxy with domain allowlist
- Connection pooling (20 DB / 100 HTTP)
- Lazy loading & skeleton states
- CachedNetworkImage on mobile

</td>
<td width="50%">

### 🎨 Design
- Light & dark themes with system detection
- Glassmorphism navigation
- Framer Motion animations (web)
- Smooth transitions (mobile)
- Responsive: mobile → tablet → desktop
- Adaptive grids (2→6 columns)

</td>
</tr>
</table>

<br />

## ◆ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          JustScroll                                  │
│                                                                      │
│    ┌────────────┐   ┌────────────┐   ┌────────────┐                  │
│    │   React    │   │  Flutter   │   │  (Future)  │                  │
│    │    Web     │   │   Mobile   │   │  Desktop   │                  │
│    └─────┬──────┘   └─────┬──────┘   └─────┬──────┘                  │
│          │                │                │                         │
│          └────────────────┼────────────────┘                         │
│                           │                                          │
│                    ┌──────▼──────┐                                   │
│                    │   FastAPI   │                                   │
│                    │   Backend   │                                   │
│                    └──────┬──────┘                                   │
│                           │                                          │
│             ┌─────────────┼─────────────┐                            │
│             ▼             ▼             ▼                            │
│        PostgreSQL      Redis       External APIs                     │
│        (users)        (cache)    (MangaDex, MAL,                     │
│                                   ComicVine)                         │
└──────────────────────────────────────────────────────────────────────┘
```

<br />

## ◆ Tech Stack

### Backend

| Technology | Purpose |
|:-----------|:--------|
| FastAPI | Async API framework with auto-generated docs |
| PostgreSQL + SQLAlchemy 2.0 | User data, bookmarks, reading history |
| Redis | Response caching, rate limiting |
| httpx | Async HTTP client for source APIs |
| PyJWT + bcrypt | Token-based auth, password hashing |
| Pydantic v2 | Request/response validation |

### Web Frontend

| Technology | Purpose |
|:-----------|:--------|
| React 18 + Vite 6 | Component architecture, fast HMR |
| Tailwind CSS 3 | Utility-first styling with design tokens |
| Zustand | Lightweight client state management |
| TanStack React Query | Server state, caching, background refetch |
| Framer Motion | Layout animations, page transitions |
| Radix UI | Accessible dropdown, dialog, tabs, tooltip |

### Mobile App

| Technology | Purpose |
|:-----------|:--------|
| Flutter 3.24 + Dart 3.5 | Cross-platform native UI |
| Riverpod | Reactive state management |
| GoRouter | Declarative routing with deep links |
| Dio | HTTP client with auth interceptors |
| CachedNetworkImage | Disk & memory image caching |

<br />

## ◆ Project Structure

```
justscroll/
│
├── backend/                  # FastAPI API server
│   ├── app/
│   │   ├── auth/             # JWT, bcrypt, route guards
│   │   ├── models/           # SQLAlchemy ORM models
│   │   ├── routers/          # API endpoints
│   │   ├── schemas/          # Pydantic request/response models
│   │   ├── services/         # Business logic + cache layer
│   │   └── sources/          # MangaDex, Jikan, ComicVine adapters
│   └── main.py
│
├── web/                      # React SPA (Vercel)
│   └── src/
│       ├── components/       # UI primitives, layout, manga
│       ├── pages/            # Route pages
│       ├── stores/           # Zustand state stores
│       └── lib/              # API client, hooks, utilities
│
├── mobile/                   # Flutter app (Android / iOS)
│   └── lib/
│       ├── components/       # UI primitives, layout, manga
│       ├── pages/            # Route pages
│       ├── stores/           # Riverpod providers
│       ├── models/           # Dart data classes
│       └── services/         # API client, config, utilities
│
├── LICENSE
├── readme.md
└── .gitignore
```

<br />

## ◆ Quick Start

### Prerequisites

```
Python ≥ 3.11          Node.js ≥ 18          Flutter SDK ≥ 3.24
PostgreSQL ≥ 15        npm or yarn           Dart SDK ≥ 3.5
Redis ≥ 7
```

### Manual Setup

<details>
<summary><strong>Backend</strong></summary>

```bash
cd backend
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env              # Edit with your credentials
alembic upgrade head
uvicorn main:app --reload --port 8000
```

API → `http://localhost:8000` · Swagger → `http://localhost:8000/docs`

</details>

<details>
<summary><strong>Web Frontend</strong></summary>

```bash
cd web
npm install
echo "VITE_API_URL=http://localhost:8000" > .env
npm run dev                       # → http://localhost:5173
```

</details>

<details>
<summary><strong>Mobile App</strong></summary>

```bash
cd mobile
flutter pub get
echo "API_URL=http://localhost:8000" > .env
flutter run
```

</details>

### Docker

```bash
git clone https://github.com/srinathnulidonda/justscroll.git
cd justscroll

cp backend/.env.example backend/.env    # Configure credentials

docker compose up -d

# API      → http://localhost:8000
# Swagger  → http://localhost:8000/docs
```

> **Note:** The web frontend is deployed separately on Vercel. For local web development, follow the manual setup above.

<br />

## ◆ Environment Variables

Create `backend/.env`:

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/justscroll

# Cache
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-256-bit-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,https://justscroll.vercel.app

# External APIs
COMICVINE_API_KEY=your-comicvine-key

# Logging
LOG_LEVEL=INFO
```

<br />

## ◆ API Reference

| Method | Endpoint | Auth | Description |
|:-------|:---------|:----:|:------------|
| `POST` | `/api/v1/auth/register` | — | Create account |
| `POST` | `/api/v1/auth/login` | — | Sign in |
| `POST` | `/api/v1/auth/refresh` | — | Refresh tokens |
| `GET` | `/api/v1/manga/search?q=` | — | Search across all sources |
| `GET` | `/api/v1/manga/popular` | — | Popular titles |
| `GET` | `/api/v1/manga/latest-updates` | — | Latest updates |
| `GET` | `/api/v1/manga/{id}` | — | Manga detail |
| `GET` | `/api/v1/manga/{id}/chapters` | — | Chapter list |
| `GET` | `/api/v1/manga/{id}/characters` | — | Characters |
| `GET` | `/api/v1/chapters/{id}/pages` | — | Chapter pages |
| `GET` | `/api/v1/user/bookmarks` | ✓ | User bookmarks |
| `POST` | `/api/v1/user/bookmarks/{id}` | ✓ | Add bookmark |
| `DELETE` | `/api/v1/user/bookmarks/{id}` | ✓ | Remove bookmark |
| `GET` | `/api/v1/user/history` | ✓ | Reading history |
| `POST` | `/api/v1/user/history` | ✓ | Update progress |
| `GET` | `/api/v1/proxy/image?url=` | — | Proxy image |
| `GET` | `/health` | — | Health check |

Interactive documentation → [Swagger UI](http://localhost:8000/docs)

<br />

## ◆ Deployment

| Service | Platform | URL |
|:--------|:---------|:----|
| **Web App** | Vercel | [justscroll.vercel.app](https://justscroll.vercel.app) |
| **Backend API** | Render | `your-render-url.onrender.com` |
| **API Docs** | Render | `your-render-url.onrender.com/docs` |
| **Database** | Render | Managed PostgreSQL |
| **Cache** | Render | Managed Redis |
| **Android** | GitHub Releases | [Download v1.0.0](https://github.com/srinathnulidonda/justscroll/releases/tag/v1.0.0) |

> Replace `your-render-url.onrender.com` with your actual Render deployment URL once deployed.

<br />

## ◆ Data Sources

All content is fetched in real-time from third-party APIs. JustScroll does not host, store, or distribute any manga, comic, or copyrighted content.

| Source | Data Provided |
|:-------|:-------------|
| [MangaDex](https://api.mangadex.org) | Manga metadata, chapters, page images |
| [Jikan (MAL)](https://api.jikan.moe/v4) | Scores, members, characters |
| [ComicVine](https://comicvine.gamespot.com/api) | Western comics metadata |

<br />

## ◆ Documentation

| Document | Description |
|:---------|:------------|
| [`backend/readme.md`](./backend/readme.md) | API architecture, caching strategy, database schema, deployment |
| [`web/readme.md`](./web/readme.md) | Frontend features, design system, component library, state management |
| [`mobile/readme.md`](./mobile/readme.md) | Mobile app features, reader implementation, navigation, build instructions |

<br />

## ◆ License

This project is licensed under the [MIT License](./LICENSE).

<br />

## ◆ Links

| | |
|:--|:--|
| 🌐 **Web App** | [justscroll.vercel.app](https://justscroll.vercel.app) |
| 📦 **Source Code** | [github.com/srinathnulidonda/justscroll](https://github.com/srinathnulidonda/justscroll) |
| 📱 **APK (ARM64)** | [v1.0.0 Release](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk) |
| 📱 **APK (Legacy)** | [v1.0.0 Legacy](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-legacy.apk) |
| 📱 **APK (Drive)** | [Google Drive](https://drive.google.com/file/d/1itP7SCk5OTgMyM0O15-Dq-hyTtrDqJKP/view?usp=sharing) |
| 📖 **API Docs** | [Swagger UI](http://localhost:8000/docs) |

<br />

---

<div align="center">

<br />

**JustScroll** — Scroll. Discover. Repeat.

<br />

<a href="https://justscroll.vercel.app">
  <img src="https://img.shields.io/badge/Open_Web_App-justscroll.vercel.app-5B4CD5?style=for-the-badge&logo=vercel&logoColor=white" />
</a>
&nbsp;
<a href="https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk">
  <img src="https://img.shields.io/badge/Download_APK-v1.0.0-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
</a>
&nbsp;
<a href="https://github.com/srinathnulidonda/justscroll">
  <img src="https://img.shields.io/badge/View_Source-GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
</a>

<br />

Made with ❤️ using FastAPI, React, Flutter & lots of manga.

© 2025 [srinathnulidonda](https://github.com/srinathnulidonda)

</div>