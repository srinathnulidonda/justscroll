<div align="center">

<img src="https://raw.githubusercontent.com/srinathnulidonda/justscroll/main/web/src/assets/logo.png" alt="JustScroll" height="60" />

<br />

# ✦ JustScroll Mobile

**Native manga reading experience for Android & iOS**

Flutter app delivering a premium manga reader with offline-ready caching, smooth animations, and cross-platform performance.

<br />

![Flutter](https://img.shields.io/badge/Flutter_3.24-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart_3.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-1E88E5?style=for-the-badge&logo=flutter&logoColor=white)
![GoRouter](https://img.shields.io/badge/GoRouter-4285F4?style=for-the-badge&logo=google&logoColor=white)

<br />

[Features](#-features) · [Screenshots](#-screenshots) · [Download](#-download) · [Quick Start](#-quick-start) · [Architecture](#-architecture) · [Components](#-component-library)
<br />

---

</div>

## ◆ Download

<table>
<tr>
<td width="50%">

### 📱 Android

| Source | Download |
|:-------|:---------|
| GitHub Releases (ARM64) | [justscroll-v1.0.0-arm64.apk](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-arm64.apk) ✦ Recommended |
| GitHub Releases (Legacy) | [justscroll-v1.0.0-legacy.apk](https://github.com/srinathnulidonda/justscroll/releases/download/v1.0.0/justscroll-v1.0.0-legacy.apk) |
| Google Drive | [justscroll-v1.0.0-arm64.apk](https://drive.google.com/file/d/1itP7SCk5OTgMyM0O15-Dq-hyTtrDqJKP/view?usp=sharing) |

> Download → Enable *Install from unknown sources* → Open & install

**Minimum:** Android 5.0 (API 21) &nbsp;|&nbsp; **Target:** Android 14 (API 34) &nbsp;|&nbsp; **Size:** ~19.5 MB

</td>
<td width="50%">

### 🍎 iOS

iOS build coming soon.

Flutter supports iOS out of the box — the app is fully cross-platform and ready to compile for iOS with:

```bash
flutter build ios --release
```

> Requires macOS with Xcode 15+ and an Apple Developer account.

</td>
</tr>
</table>

<br />

## ◆ Features

<table>
<tr>
<td width="50%">

### 📖 Chapter Reader
- **Single page** mode with PageView & tap zones
- **Continuous long strip** mode with smooth scroll
- Left-to-right / Right-to-left direction support
- Pinch-to-zoom with InteractiveViewer (1×–3×)
- Keyboard navigation (arrow keys, space, escape)
- Auto-hiding UI with 4-second timeout
- Page slider with monospace counter
- Chapter selector bottom sheet
- Previous / Next chapter navigation
- Background color options (black, dark, white)
- Image quality toggle (high / data saver)
- Immersive mode (SystemUiMode.immersiveSticky)
- Auto-save reading progress to server

</td>
<td width="50%">

### 🔍 Discover & Browse
- Popular & latest manga feeds from MangaDex
- 25+ genre filters with auto-scrolling toolbar
- Full-text search with paginated results
- Deduplicated results across MangaDex, Jikan & ComicVine
- Pull-to-refresh on all data pages
- Responsive grid layouts (2→6 columns)

</td>
</tr>
<tr>
<td width="50%">

### 📚 Manga Detail
- Hero banner with blurred cover backdrop
- Source & status badges (MangaDex, MAL, ComicVine)
- Score, members, chapters, year stat cards
- Expandable synopsis with HTML stripping
- Clickable genre & tag chips
- Searchable & sortable chapter list with "Load more"
- Character grid with role badges & avatars
- Tabbed interface (Chapters / Characters)
- Bookmark toggle with optimistic UI
- Start Reading button (first readable chapter)

</td>
<td width="50%">

### 👤 User System
- JWT authentication with automatic token refresh
- Login & registration with field validation
- Bookmark library with cover grid & delete
- Reading history with chapter resume
- Profile dashboard with stats & quick actions
- Continue Reading section (last 4 entries)
- Saved Manga horizontal scroll (last 6)
- Theme toggle (light / dark)
- Reader settings (quality, mode)
- Sign out with confirmation
- Protected routes with login redirect

</td>
</tr>
<tr>
<td width="50%">

### 🎨 Design System
- Light & dark themes with `AppColorsExtension`
- Inter font family throughout
- Custom UI primitives: Button, Badge, Card, Input, Skeleton, Tabs
- Toast notification system with animations
- Glassmorphism-style navigation
- Fade page transitions (180ms)
- Consistent 12px border radius language
- `RepaintBoundary` optimization on heavy widgets

</td>
<td width="50%">

### ⚡ Performance
- `CachedNetworkImage` with disk + memory caching
- Image proxy through backend for CORS/hotlink bypass
- Memory-constrained cache sizes (DPR-aware)
- `RepaintBoundary` on grids, images, navigation
- Lazy chapter pagination (20 visible, load more)
- `addRepaintBoundaries: true` on GridView
- `addAutomaticKeepAlives: false` for memory efficiency
- Skeleton loading states for all async content
- Immersive system UI in reader mode

</td>
</tr>
</table>

<br />

## ◆ Screenshots

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

<br />

## ◆ Tech Stack

| Layer | Technology | Purpose |
|:------|:-----------|:--------|
| **Framework** | Flutter 3.24 | Cross-platform native UI |
| **Language** | Dart 3.5 | Null-safe, strongly typed |
| **State** | Riverpod 2.0 | Reactive state management with providers |
| **Routing** | GoRouter | Declarative routing, deep links, shell routes |
| **HTTP** | Dio | HTTP client with auth interceptors & token refresh |
| **Images** | CachedNetworkImage | Disk & memory image caching with placeholders |
| **Storage** | SharedPreferences | Tokens, theme, reader settings persistence |
| **Config** | flutter_dotenv | Environment variables from `.env` |
| **Sharing** | share_plus + url_launcher | Share sheet & external links |

<br />

## ◆ Quick Start

### Prerequisites

```
Flutter SDK ≥ 3.24
Dart SDK ≥ 3.5
Android Studio / Xcode
Backend API running (local or remote)
```

### Install & Run

```bash
# Navigate to mobile
cd mobile

# Install dependencies
flutter pub get

# Create environment file
echo "API_URL=http://localhost:8000" > .env

# Run on connected device / emulator
flutter run

# Or build release APK
flutter build apk --split-per-abi --release
```

### Environment Variables

```env
# Backend API URL
API_URL=http://localhost:8000
```

<br />

## ◆ Architecture

### State Management

```
┌─────────────────────────────────────────────────────────┐
│                      Widget Tree                        │
│                                                         │
│   ┌──────────────────┐   ┌───────────────────────────┐  │
│   │  FutureProvider  │   │   StateNotifierProvider   │  │
│   │  .family         │   │                           │  │
│   │                  │   │   AuthNotifier            │  │
│   │  Manga detail    │   │   ReaderNotifier          │  │
│   │  Chapters        │   │   ThemeNotifier           │  │
│   │  Characters      │   │   ToastNotifier           │  │
│   │  Bookmarks       │   │   NavigationHistory       │  │
│   │  History         │   │                           │  │
│   │  Search results  │   │                           │  │
│   │  (server state)  │   │   (client state)          │  │
│   └────────┬─────────┘   └─────────┬─────────────────┘  │
│            │                       │                    │
│            ▼                       ▼                    │
│      ApiClient (Dio)        SharedPreferences           │
│      ↕                      (tokens, settings)          │
│   Backend API                                           │
└─────────────────────────────────────────────────────────┘
```

### Provider Architecture

| Provider | Type | Purpose |
|:---------|:-----|:--------|
| `authStoreProvider` | `StateNotifierProvider` | Auth state, login/register/logout |
| `readerStoreProvider` | `StateNotifierProvider` | Quality, mode, page, UI toggle |
| `themeNotifierProvider` | `StateNotifierProvider` | Light/dark theme mode |
| `toastProvider` | `StateNotifierProvider` | Toast notification queue |
| `navigationHistoryProvider` | `StateNotifierProvider` | Back navigation stack |
| `routerProvider` | `Provider` | GoRouter instance |
| `themeModeProvider` | `Provider` | Current ThemeMode |
| `_mangaProvider` | `FutureProvider.family` | Manga detail by ID |
| `_chaptersProvider` | `FutureProvider.family` | Chapters by manga ID |
| `_charactersProvider` | `FutureProvider.family` | Characters by manga ID |
| `_pagesProvider` | `FutureProvider.family` | Chapter pages by ID + quality |
| `_bookmarksProvider` | `FutureProvider` | User bookmarks |
| `_historyProvider` | `FutureProvider` | Reading history |
| `_homePopularProvider` | `FutureProvider` | Popular manga (home) |
| `_homeLatestProvider` | `FutureProvider` | Latest updates (home) |
| `_discoverProvider` | `FutureProvider.family` | Discover tab + offset |
| `_searchProvider` | `FutureProvider.family` | Search query + offset |

### Navigation

```
┌─────────────────────────────────────────────────────────┐
│                     GoRouter                            │
│                                                         │
│   ShellRoute (AppLayout: Navbar + MobileNav)            │
│   ├── /                    → HomePage                   │
│   ├── /discover            → DiscoverPage               │
│   ├── /search?q=           → SearchPage                 │
│   ├── /manga/:id           → MangaDetailPage            │
│   ├── /login?redirect=     → LoginPage                  │
│   ├── /register?redirect=  → RegisterPage               │
│   ├── /bookmarks           → BookmarksPage      🔒     │
│   ├── /history             → HistoryPage        🔒     │
│   └── /profile             → ProfilePage        🔒     │
│                                                         │
│   Root Route (no shell — fullscreen)                    │
│   └── /read/:chapterId?manga=  → ReaderPage             │
│                                                         │
│   Error → NotFoundPage (404)                            │
│                                                         │
│   🔒 = Protected (redirects to /login?redirect=)       │
└─────────────────────────────────────────────────────────┘
```

### Image Pipeline

```
Original Image URL (MangaDex CDN / MAL / ComicVine)
                    │
                    ▼
Backend Proxy  (/api/v1/proxy/image?url=...)
  • Domain allowlist validation
  • Strips hotlink restrictions
                    │
                    ▼
CachedNetworkImage (OptimizedImage component)
  • Disk cache (up to 600×900)
  • Memory cache (DPR-aware sizing)
  • Skeleton placeholder → fade-in (200ms)
  • Broken image fallback icon
```

### Authentication Flow

```
┌──────────┐                              ┌──────────┐
│  App     │                              │  Backend  │
└────┬─────┘                              └────┬─────┘
     │                                         │
     │  POST /auth/login {user, pass}          │
     │────────────────────────────────────────▶│
     │                                         │
     │    { access_token, refresh_token }      │
     │◀────────────────────────────────────────│
     │                                         │
     │  Store in SharedPreferences             │
     │  Update AuthState                       │
     │                                         │
     │  GET /user/bookmarks                    │
     │  Header: Bearer {access_token}          │
     │────────────────────────────────────────▶│
     │                                         │
     │  ── 401 (token expired) ──              │
     │                                         │
     │  POST /auth/refresh {refresh_token}     │
     │────────────────────────────────────────▶│ (automatic via Dio interceptor)
     │                                         │
     │    { new access_token, refresh_token }  │
     │◀────────────────────────────────────────│
     │                                         │
     │  Retry original request with new token  │
     │────────────────────────────────────────▶│
     │                                         │
     │  If refresh fails → clear tokens,       │
     │  reset AuthState, redirect to /login    │
```

### Back Navigation

```
Android back button / gesture
         │
         ▼
didPopRoute() in JustScrollApp
         │
         ▼
NavigationHistoryNotifier
  ├── Has history? → pop & go to previous path
  ├── Not on home? → go to /
  └── On home? → "Press back again to exit" toast
         │         (2-second window)
         └── Second press → SystemNavigator.pop()
```

<br />

## ◆ Component Library

### UI Primitives

| Component | File | Variants / Features |
|:----------|:-----|:--------------------|
| **AppButton** | `ui/button.dart` | `primary` `secondary` `outline` `ghost` `destructive` `link` · sizes: `sm` `md` `lg` · loading state · icon + trailing icon · full width |
| **AppBadge** | `ui/badge.dart` | `primary` `secondary` `outline` · custom bg/text colors · configurable font size |
| **AppCard** | `ui/card.dart` | Bordered card with configurable padding |
| **AppInput** | `ui/input.dart` | Label, hint, prefix icon, error state, password toggle, onSubmitted |
| **Skeleton** | `ui/skeleton.dart` | Shimmer animation · `MangaGridSkeleton` · `DetailSkeleton` · configurable shape |
| **AppTabs** | `ui/tabs.dart` | Icon + label + optional count badge · animated underline indicator |

### Common Components

| Component | File | Purpose |
|:----------|:-----|:--------|
| **OptimizedImage** | `common/optimized_image.dart` | CachedNetworkImage with proxy, DPR-aware sizing, skeleton + error fallback |
| **EmptyState** | `common/empty_state.dart` | Icon + title + description + optional action button |
| **ErrorBoundary** | `common/error_boundary.dart` | Error catch with retry button |
| **GenreToolbar** | `common/genre_toolbar.dart` | Horizontal scroll, 25 genres, auto-scroll to active chip |
| **ShareSheet** | `common/share_sheet.dart` | Bottom sheet: copy link, Twitter, WhatsApp, Telegram, native share |
| **ToastOverlay** | `common/toast.dart` | Slide + scale + fade entry, progress bar, swipe-to-dismiss, max 3 visible |

### Layout Components

| Component | File | Purpose |
|:----------|:-----|:--------|
| **AppLayout** | `layout/layout.dart` | Scaffold with Navbar + content + conditional MobileNav |
| **AppNavbar** | `layout/navbar.dart` | Logo, search (inline desktop / expandable mobile), theme toggle, user menu |
| **MobileNav** | `layout/mobile_nav.dart` | Floating bottom bar: Home, Discover, Library, Profile · auth-aware |

### Manga Components

| Component | File | Purpose |
|:----------|:-----|:--------|
| **MangaCard** | `manga/manga_card.dart` | Cover with status/score overlays, title, author, year, 2 tag chips |
| **MangaGrid** | `manga/manga_grid.dart` | Responsive grid (2–6 cols), skeleton loading, empty state |
| **ChapterList** | `manga/chapter_list.dart` | Search + sort, readable vs external, "Load more" pagination |
| **CharacterCard** | `manga/character_card.dart` | Avatar + name + role badge, responsive CharacterGrid |
| **ReaderView** | `manga/reader_view.dart` | Full reader: single/continuous, LTR/RTL, settings sheet, chapter selector |

<br />

## ◆ Reader Implementation

The reader (`ReaderView`) is the most complex component in the app. Here's how it works:

### Modes

| Mode | Widget | Behavior |
|:-----|:-------|:---------|
| **Single Page** | `PageView.builder` | Swipe or tap to navigate. Left 25% = prev, right 25% = next, center = toggle UI |
| **Continuous** | `ListView.builder` | Vertical scroll through all pages. End-of-chapter card with nav buttons |

### Tap Zones (Single Page)

```
┌──────────────────────────────────────┐
│          │              │            │
│  ◀ PREV  │   TOGGLE UI  │  NEXT ▶   │
│   25%    │     50%      │   25%      │
│          │              │            │
└──────────────────────────────────────┘
```

### Settings Panel

| Setting | Options |
|:--------|:--------|
| Image Quality | High (`data`) · Data Saver (`dataSaver`) |
| Reading Mode | Single Page · Long Strip |
| Direction | Left → Right · Right → Left (single mode only) |
| Background | Black · Dark · White |

### Keyboard Controls

| Key | Action |
|:----|:-------|
| `←` Arrow Left | Previous page |
| `→` Arrow Right | Next page |
| `Space` | Next page |
| `Escape` | Close settings / exit reader |

<br />

## ◆ API Client

The `ApiClient` (Dio) handles all network communication:

### Interceptors

```
Request → Attach Bearer token (if auth flag set)
Response → Pass through
Error 401 → Try refresh token → Retry original request
           → If refresh fails → Clear tokens, force logout
```

### Endpoints

| Method | Path | Auth | Description |
|:-------|:-----|:----:|:------------|
| `POST` | `/api/v1/auth/register` | — | Create account |
| `POST` | `/api/v1/auth/login` | — | Sign in |
| `POST` | `/api/v1/auth/refresh` | — | Refresh tokens |
| `GET` | `/api/v1/manga/search` | — | Search manga |
| `GET` | `/api/v1/manga/popular` | — | Popular titles |
| `GET` | `/api/v1/manga/latest-updates` | — | Latest updates |
| `GET` | `/api/v1/manga/{id}` | — | Manga detail |
| `GET` | `/api/v1/manga/{id}/chapters` | — | Chapter list |
| `GET` | `/api/v1/manga/{id}/characters` | — | Characters |
| `GET` | `/api/v1/chapters/{id}/pages` | — | Page URLs |
| `GET` | `/api/v1/user/bookmarks` | ✓ | List bookmarks |
| `POST` | `/api/v1/user/bookmarks/{id}` | ✓ | Add bookmark |
| `DELETE` | `/api/v1/user/bookmarks/{id}` | ✓ | Remove bookmark |
| `GET` | `/api/v1/user/history` | ✓ | Reading history |
| `POST` | `/api/v1/user/history` | ✓ | Update progress |

<br />

## ◆ Theming

### Color System

Dual theme support using `AppColorsExtension`:

| Token | Light | Dark |
|:------|:------|:-----|
| Background | `#FFFFFF` | `#09090B` |
| Foreground | `#0A0A0F` | `#FAFAFA` |
| Primary | `#5B4CD5` | `#7C6DE8` |
| Secondary | `#F1F1F5` | `#27272A` |
| Muted | `#F1F1F5` | `#27272A` |
| Muted Foreground | `#71717A` | `#A1A1AA` |
| Border | `#E4E4E7` | `#27272A` |
| Destructive | `#EF4444` | `#DC2626` |
| Card | `#FFFFFF` | `#111114` |

### Accent Colors

| Name | Hex | Usage |
|:-----|:----|:------|
| Amber 500 | `#F59E0B` | Scores, warnings, hiatus status |
| Emerald 500 | `#10B981` | Ongoing status, success, chapters stat |
| Blue 500 | `#3B82F6` | Members stat, completed status, MAL source |
| Violet 500 | `#8B5CF6` | Year stat, latest quick action |
| Orange 500 | `#F97316` | MangaDex source badge |
| Red 500 | `#EF4444` | Errors, cancelled status |

<br />

## ◆ Known Issues

| Issue | Workaround |
|:------|:-----------|
| RTL scroll jump in continuous mode | Use single page mode |
| Special characters in search may fail | Use simpler terms |
| Share sheet fails on some older devices | Copy URL manually |
| History limited to 100 entries | — |
| No offline reading yet | — |
| iOS not available yet | Use [web version](https://justscroll.vercel.app) |

<br />

## ◆ Build & Release

### Debug

```bash
flutter run                            # Debug on connected device
flutter run --debug                    # Explicit debug mode
```

### Release APK

```bash
flutter build apk --release            # Fat APK (all architectures)
flutter build apk --split-per-abi      # Split APKs (smaller per device)
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires macOS + Xcode)

```bash
flutter build ios --release
```

<br />

## ◆ Dependencies

| Package | Version | Purpose |
|:--------|:--------|:--------|
| `flutter_riverpod` | ^2.0.0 | State management |
| `go_router` | ^14.0.0 | Declarative routing |
| `dio` | ^5.0.0 | HTTP client with interceptors |
| `cached_network_image` | ^3.3.0 | Image caching (disk + memory) |
| `shared_preferences` | ^2.2.0 | Local key-value storage |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `share_plus` | ^9.0.0 | Native share sheet |
| `url_launcher` | ^6.2.0 | Open external URLs |

<br />

## ◆ Data Sources

All content is fetched in real-time from third-party APIs via the JustScroll backend. No manga content is stored or distributed by this app.

| Source | Data Provided |
|:-------|:-------------|
| [MangaDex](https://api.mangadex.org) | Manga metadata, chapters, page images |
| [Jikan (MAL)](https://api.jikan.moe/v4) | Scores, members, characters |
| [ComicVine](https://comicvine.gamespot.com/api) | Western comics metadata |

<br />

## ◆ Scripts

| Command | Description |
|:--------|:------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run on device/emulator |
| `flutter build apk --release` | Build release APK |
| `flutter build apk --split-per-abi` | Build split APKs |
| `flutter build appbundle` | Build AAB for Play Store |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run tests |
| `flutter clean` | Clean build artifacts |
| `dart format lib/` | Format all Dart code |

<br />

---
<div align="center">

**Part of the [JustScroll](../readme.md) platform**

Built with Flutter, Riverpod & Dart.

</div>