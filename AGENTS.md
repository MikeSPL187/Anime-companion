# AGENTS.md — ani_app
> Anime companion / tracker app for Android.
> This file is the single source of truth for all AI agents working on this codebase.
> Read this file completely before making any changes.

---

## 1. PRODUCT IDENTITY

This is a **personal-first anime companion app**, not a streaming app and not a social network.

The product has two layers:

- **Catalog layer** — search, browse, anime details, franchise, schedule (remote data)
- **Personal layer** — library statuses, favorites, watch progress, notes, personal schedule (local data)

The UI always presents a **merge** of both layers. The personal layer is the _reason_ the app exists.

### What this app is NOT:
- Not a streaming app. No video player. No fake player UI.
- Not a social app. No comments, chat, forums, friend lists, or social feed.
- Not a manga app (v1).
- Not a cloud-sync platform. No backend auth. No user accounts.
- Not a recommendation engine. No ML. No AI recommendations in v1.

---

## 2. TECH STACK

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (latest stable) |
| State management | Riverpod (riverpod_annotation + code generation) |
| Navigation | GoRouter |
| HTTP client | Dio |
| Local database | Drift (SQLite) |
| Image loading | cached_network_image |
| Preferences | shared_preferences |
| Platform | Android-first |

**Primary data source:** AniLibria project / AniLiberty API v1 (`anilibria.top/api/docs/v1`)
Previous API versions (v2 and earlier) are deprecated. All remote implementation targets the current v1 surface only.
**Architecture:** provider-agnostic, local-first.

---

## 3. PROJECT STRUCTURE

```
lib/
  app/          # App-level wiring only: app.dart, router.dart, navigation_shell.dart, theme/, bootstrap/
  core/         # Technical infrastructure: Dio, Drift, error mapping, cache policy, pagination, logging
  domain/       # Pure product entities: models, repository contracts, enums, domain rules
  data/         # Repository implementations, DTOs, mappers, remote/local data sources, cache logic
  features/     # Screen-level logic: home/, search/, details/, library/, schedule/, settings/
  shared/       # Reusable UI primitives: cards, chips, badges, skeletons, empty states
```

### Rules per layer:
- `domain/` has **zero dependencies** on Flutter, Dio, Drift, or any external package.
- `domain/` does NOT contain cache-related models. Cache metadata lives in `data/cache/` or `core/cache/`.
- `features/` contains only screen-specific providers and widgets. No business logic.
- Business/domain logic lives in `domain/` or dedicated domain service classes.
- Do not put API call logic in Riverpod providers. Providers call repositories. Repositories call data sources.

---

## 4. DOMAIN MODELS — CANONICAL DEFINITIONS

### Remote catalog entities

**AnimeSummary** — used in all list surfaces (search results, browse, library cards)
- id, alias, title, altTitle?, posterUrl, type (AnimeType), year?, season (AnimeSeason?), isOngoing, publishDay (PublishDay?), ageRating (AgeRating?), favoritesCount, episodesTotal?, episodesAired?, updatedAt?

`episodesTotal` — planned total episode count; may be null for ongoing or unknown-length series.
`episodesAired` — count of episodes confirmed released by the provider; null if provider does not supply this field. Never infer or calculate episodesAired from publishDay alone.

**AnimeDetails** — used in detail screen only
- Composes AnimeSummary. Adds: description?, genres, episodes (list), membersCount?, blockedByGeo, blockedByCopyright, averageEpisodeDurationSec?

**FranchiseEntry**
- franchiseId, releaseId, sortOrder? (nullable), embedded AnimeSummary
- Ordering: `sortOrder` (if present) → `year` ascending → `releaseId` ascending (stable tiebreaker). Never display in arbitrary order.

**ScheduleItem**
- releaseId, title, posterUrl, publishDay, isOngoing

### Local user entities

**LibraryEntry**
- animeId, status (LibraryStatus), isFavorite, createdAt, updatedAt, lastInteractedAt, note?
- `updatedAt` = status changed
- `lastInteractedAt` = meaningful user action only: status change, +1 episode, manual progress set, note edit, favorite toggle. Passively opening a details screen does NOT update lastInteractedAt.

**WatchProgress**
- animeId, watchedEpisodes, lastWatchedEpisode?, updatedAt

**SearchHistoryEntry**
- query, usedAt

### Enums

```
AnimeType:       tv, movie, ova, ona, special, unknown
AnimeSeason:     winter, spring, summer, fall
PublishDay:      monday, tuesday, wednesday, thursday, friday, saturday, sunday
AgeRating:       g, pg, pg13, r, rPlus, rx, unknown
LibraryStatus:   watching, planned, completed, postponed, dropped
```

### Title resolution policy

When mapping provider fields to display titles, always follow this rule:

| UI role | Field to use |
|---------|-------------|
| Primary display title | Russian / main name from provider |
| Secondary / subtitle | English name, shown only if different from primary |
| Routing / search index | alias (internal only, never shown as user-facing title) |

The `alias` field is used only for URL path parameters and search indexing. It must never appear as a visible title in the UI. If a provider returns both a Russian name and an English name, the Russian name is always primary. If only one name is available, use it as primary regardless of language.

---

## 5. DRIFT DATABASE SCHEMA

**Schema version: 1.** Always increment `schemaVersion` and add `onUpgrade` migration when changing tables. Never modify table structure without a migration — Drift will throw on schema mismatch.

### Tables:
- `library_entries` — PK: anime_id. Columns: status TEXT, is_favorite INTEGER, created_at INTEGER, updated_at INTEGER, last_interacted_at INTEGER, note TEXT nullable
- `watch_progress_entries` — PK: anime_id. Columns: watched_episodes INTEGER default 0, last_watched_episode INTEGER nullable, updated_at INTEGER
- `search_history_entries` — PK: query. Columns: used_at INTEGER
- `cached_summary_lists` — PK: cache_key. Columns: payload TEXT (JSON), fetched_at INTEGER
- `cached_release_details` — PK: anime_id. Columns: payload TEXT (JSON), fetched_at INTEGER
- `cached_franchise_data` — PK: release_id. Columns: payload TEXT (JSON), fetched_at INTEGER
- `cached_schedule_data` — PK: scope ('now'|'week'). Columns: payload TEXT (JSON), fetched_at INTEGER

The `note` column is present from v1 of the schema. Its UI surface is deferred to late v1, but the column must exist in the table from day one to avoid a schema migration later.

---

## 6. CACHE POLICY

All TTL values are defined in `core/cache/cache_policy.dart`. Do not hardcode TTL values anywhere else.

| Resource | TTL |
|----------|-----|
| schedule/now | 15 minutes |
| schedule/week | 6 hours |
| release details | 24 hours |
| summary lists (search, browse) | 4 hours |
| franchise data | 12 hours |

### Stale-while-revalidate strategy

This is the required caching behavior for all screens that display remote data:

1. On screen load: read from local cache immediately and display it (even if stale).
2. If cache is stale (per TTL) or absent: trigger a background network fetch.
3. On successful fetch: write to cache and update the UI reactively.
4. On fetch failure with valid cache: show stale data + freshness label indicating age.
5. On fetch failure with no cache: show error state with retry action.

Do not block the UI waiting for a network response if cached data is available. Do not silently show stale data without a freshness label when TTL has expired.

### Freshness label

Format: "Обновлено N мин назад" / "Обновлено N ч назад" — small, secondary text color, tappable to force refresh.
On fetch error: "Не удалось обновить. Данные от [datetime]".
Show on: Schedule screen header, Home personal schedule block.

---

## 7. REPOSITORY CONTRACTS

All repositories are interfaces in `domain/repositories/`. Implementations are in `data/repositories/`.

**CatalogRepository**
- `search(String query, {int page})` → PaginatedResult\<AnimeSummary\>
- `getOngoing({int page})` → PaginatedResult\<AnimeSummary\>
- `getLatest({int page})` → PaginatedResult\<AnimeSummary\>
- `getByGenre(String genre, {int page})` → PaginatedResult\<AnimeSummary\>
- `getDetails(String animeId)` → AnimeDetails
- `getByIdOrAlias(String idOrAlias)` → AnimeDetails — resolves by numeric id OR alias string; used by GoRouter deep links

**FranchiseRepository** — getByReleaseId

**ScheduleRepository** — getToday, getWeek, lastFetchedAt(scope)

**LibraryRepository** — watchAll (Stream), watchByStatus (Stream), getByAnimeId, setStatus, toggleFavorite, removeFromLibrary, updateNote

**ProgressRepository** — getProgress, watchProgress (Stream), incrementEpisode, setEpisode, clearProgress
The repository implementation is responsible for enforcing all progress constraints (see Section 9). UI and providers must not duplicate this validation.

**SearchHistoryRepository** — getRecent({int limit = 10}), saveQuery, removeQuery, clearAll
Maximum stored entries: 20. When a new query is saved and the count exceeds 20, remove the oldest entry by `usedAt`. Deduplication: saving an existing query updates its `usedAt` timestamp instead of creating a duplicate.

**SettingsRepository** — themeMode, refreshBehavior, clearCache

---

## 8. RIVERPOD RULES

### Provider hierarchy (top to bottom, no skipping):
```
Infrastructure (Dio, DB) → Repositories → Domain logic providers → Feature providers → Widget
```

### Rules:
1. **Widgets never call repositories directly.** Always through providers.
2. **No business logic in providers.** Providers compose; logic lives in domain layer or service classes.
3. **Use StreamProvider for Library and Progress** — these need reactive updates across screens.
4. **Use FutureProvider for remote data** — catalog, details, franchise, schedule.
5. **Use Provider (sync) for derived/computed data** — urgency ranking, personal schedule filter, next action resolver.
6. **Separate fetch and ranking.** `urgencyRankedWatchingProvider` reads from `watchingEntriesProvider` and computes order. It does NOT fetch data itself.
7. **Family providers require simple, comparable keys** — use animeId (String) or SearchParams (data class with equality).
8. **Use `select()` in high-frequency rebuild contexts.** In Library list cards, watch only the specific progress field needed:
   ```dart
   // Correct — rebuilds only when watchedEpisodes changes for this animeId
   final watched = ref.watch(
     progressProvider(animeId).select((p) => p?.watchedEpisodes ?? 0)
   );
   // Wrong — rebuilds the entire list card on any progress change
   final progress = ref.watch(progressProvider(animeId));
   ```
   This rule applies wherever a list renders many cards that each observe a family provider.

---

## 9. BUSINESS RULES — DO NOT BREAK THESE

### airedEpisodes definition

`airedEpisodes` is the count of episodes confirmed as released, as reported by the provider.
- Source: `episodesAired` field from AniLiberty API response only.
- Never infer airedEpisodes from `publishDay` or air schedule math. publishDay indicates the weekday episodes release, not how many have released.
- If `episodesAired` is absent from the provider response, treat it as unknown. Do not substitute `episodesTotal`.
- `gapCount = max(0, airedEpisodes - watchedEpisodes)` — only computable when `episodesAired` is known.
- When `episodesAired` is unknown, treat `gapCount` as unknown. Do not default to 0.

### Progress rules

The `ProgressRepository` implementation enforces all constraints below. UI layers and providers must not duplicate this logic.

- `watchedEpisodes` cannot be incremented beyond `episodesTotal` when total is known.
- `status = completed` cannot coexist with `watchedEpisodes < episodesTotal` when total is known.
- `status = dropped` entries do NOT appear on Home and do NOT appear in Continue/Watching surfaces.
- When `episodesTotal` is unknown, incrementing is permitted without an upper bound.
- `incrementEpisode()` must update `lastInteractedAt` on `LibraryEntry` in the same transaction.

### Urgency ranking for "Смотрю" list (priority order, highest first):
1. Airing + `gapCount > 0` (provider confirms aired episodes, user is behind) — ordered by gap size descending
2. Airing + `gapCount == 0` (user is caught up, waiting for next episode)
3. Completed series (finished airing) + user hasn't finished watching
4. Airing but `episodesAired` unknown — cannot compute gap, treat as uncertain
5. Fallback: by `lastInteractedAt` descending

### Next action resolver — deterministic, no ambiguity:

| State | Action shown |
|-------|-------------|
| Not in library | "Добавить" |
| planned | "Начать смотреть" |
| watching + `gapCount > 0` | "+1 эпизод" (show gap count in label) |
| watching + `gapCount == 0`, airing | "Ждём следующий эпизод" (no action button) |
| watching + `episodesAired` unknown, airing | "+1 эпизод" (no gap indicator) |
| watching + completed series + `watchedEpisodes < episodesTotal` | "+1 эпизод" |
| watching + completed series + `watchedEpisodes == episodesTotal` | "Пометить просмотренным" |
| watching + completed series + `episodesTotal` unknown | "+1 эпизод" (no auto-complete trigger) |
| completed | "Открыть франшизу" (only if franchise exists; otherwise no action shown) |
| dropped | No action surface on Home. Appears in Library[Брошено] only. |

There is no "or" in next action rules. Each state maps to exactly one outcome.

### Blocked content:
- Show `blockedByGeo` / `blockedByCopyright` entries in catalog and search as normal cards.
- On Details screen: show amber warning banner "Контент может быть недоступен в вашем регионе".
- Library statuses and progress tracking remain fully functional for blocked content.

### Franchise ordering:
- Sort order cascade: `sortOrder` (if present) → `year` ascending → `releaseId` ascending (stable tiebreaker).
- Never display franchise entries in arbitrary or API-returned order.
- Show local LibraryStatus badge on each franchise entry.

### Popularity signal:
- Display `favoritesCount` from the provider as the popularity indicator.
- Label with a heart icon (♥). Do NOT use the words "рейтинг" or "оценка".
- Do not display a numeric score unless a confirmed dedicated score field exists in the provider response.

---

## 10. UI CONTRACT

### Navigation structure:
- Bottom navigation: Home / Search / Library / Schedule
- Settings accessible via icon in AppBar (not a bottom tab)
- Details is a deep route (`/anime/:id`), not a tab

### Card surfaces — required information:
- Anime card (in lists): posterUrl, primary title, type, year, favoritesCount (♥), localStatus badge if in library
- Anime card (in Library): posterUrl, primary title, progress (N/M), urgency indicator, +1 button (for Watching)

### Home screen sections:
1. **"Продолжить"** — Watching entries, urgency-ranked, with +1 action. Hidden entirely if empty.
2. **"Моё расписание"** — Today and upcoming week, only for Watching + Favorite entries. Freshness label.
3. **"Что открыть дальше"** — Priority: (a) franchise continuation after completed titles, (b) planned entries with `lastInteractedAt` older than 7 days. Hidden entirely if no candidates. Do not fill with generic catalog content.

### Library segments (tabs or chips):
Смотрю → Хочу посмотреть → Просмотрено → Отложено → Брошено

"Смотрю" has urgency sorting by default. All segments have per-segment empty states.

### Anime Details layout order:
1. Hero: poster (left) + primary title + secondary title + type/year/season + CTA + favorite toggle + ♥ count + ongoing badge + age rating
2. Metadata strip: genres, episodes count/progress context, publishDay, avg duration
3. Description (collapsed by default, expand on tap)
4. Franchise / related (ordered per franchise ordering rule, with local status badges and quick-add)
5. Additional: membersCount, blocked warning if applicable, freshness info

### Empty states — every key screen must have one:
- Library (all empty): "Найди первое аниме и добавь в список" + CTA to Search
- Library[Смотрю] empty but [Хочу посмотреть] not: "Готов начать? Загляни в свой список желаний" + CTA
- Schedule (no personal entries): "Добавь аниме в «Смотрю», чтобы видеть своё расписание"
- Search (no results): "Ничего не найдено по запросу «{query}»"
- Library[Брошено] empty: show nothing (no empty state needed)

### Skeletons:
- All async-loading surfaces must have skeleton states.
- Skeletons match the exact layout shape of the loaded content.
- Do not use spinners as primary loading state.

### Image loading contract

All poster images use `cached_network_image`. Every usage must specify:
- `placeholder`: an AnimeSkeleton widget matching the poster aspect ratio (2:3)
- `errorWidget`: a static fallback widget — grey container with a centered film-reel icon, matching the poster aspect ratio

Do not use different placeholder or error widgets in different parts of the app. Define a shared `AnimePosterImage` widget in `shared/` and use it everywhere. Never use `Image.network` directly.

---

## 11. WHAT NOT TO DO — HARD RULES

These are non-negotiable. Do not implement, suggest, or scaffold:

- **No video player of any kind.** No media_kit, no video_player, no fake playback UI.
- **No social features.** No comments, ratings aggregation, friend lists, follow, feed.
- **No backend auth.** No Firebase Auth, no user accounts, no login screen.
- **No cloud sync.** No Firestore, no Supabase, no remote library storage.
- **No AI/ML recommendations.** No embedding, no similarity engine.
- **No push notifications in v1.** Schedule reminders deferred to v1.1.
- **No custom color themes.** System dark/light only.
- **No manga content.** Deferred entirely.
- **No "anime of the day" random widget.** Not personal, not useful.
- **No user-defined rating/score field.** Without social layer it serves no purpose.
- **No enterprise abstractions.** No use-case classes for every single operation. Repository methods are sufficient for v1.
- **No swipe-to-delete in Library.** Use long press → context menu or explicit status change UI.
- **No `Image.network` directly.** Always use the shared `AnimePosterImage` widget.
- **No progress validation in UI or providers.** All constraints enforced in `ProgressRepository` only.

---

## 12. IMPLEMENTATION PHASES

Current phase: **Phase 1 — Foundation + Contracts**

| Phase | Focus | Key deliverables |
|-------|-------|-----------------|
| 1 | Foundation | App shell, theme, router, Dio client, Drift + migrations, domain models, repository interfaces, cache policy, pagination primitive, error model, `AnimePosterImage` widget stub |
| 2 | Local user layer | Drift table implementations, LibraryRepository, ProgressRepository, SearchHistoryRepository, domain validators |
| 3 | Search + Browse | Search screen, result cards, local status overlay, recent searches, pagination, browse slices |
| 4 | Anime Details + Franchise | Details fetch, hero section, metadata, description, franchise block, CTA resolver, blocked content UX |
| 5 | Library operational | Segmented library, urgency sorting, quick +1, status transitions, library search, per-segment empty states |
| 6 | Home re-entry | Watching section, personal schedule preview, "what next" section, dropped exclusion, caught-up state |
| 7 | Schedule screen | Week view, grouped by day, personal filter, today focus, freshness label, manual refresh |
| 8 | Polish + Trust | Skeletons, error recovery, stale indicators, performance, offline fallback UX |

**Do not build Phase N+2 features while working on Phase N.**

### Phase 1 — explicit scope boundary

Phase 1 contains ONLY:
- Flutter app bootstrap, MaterialApp, theme (dark primary, system light/dark toggle)
- GoRouter shell with empty Scaffold placeholders for each route
- Dio client setup and interceptors (logging, timeout, error mapping)
- Drift database class, all table definitions, schemaVersion = 1, migration scaffolding (empty onUpgrade)
- All domain model classes and enums
- All repository interfaces (abstract classes only, zero implementations)
- `CachePolicy` constants in `core/cache/cache_policy.dart`
- `PaginatedResult<T>` wrapper in `core/pagination/`
- `AppError` sealed class and error mapping scaffold in `core/error/`
- `AnimePosterImage` widget stub in `shared/` (placeholder and error state, no network call yet)

Phase 1 does NOT contain:
- Any remote API call implementations
- Any JSON parsing or DTO mapping
- Any Drift repository implementations
- Any screen logic beyond empty Scaffold placeholders
- Any Riverpod feature providers beyond infrastructure (Dio, DB)
- Any business logic or domain validators

---

## 13. ERROR MODEL

Errors are represented as a sealed class `AppError` in `core/error/app_error.dart`.

```
AppError
  ├── NetworkError(message, statusCode?)   — HTTP or connectivity failure
  ├── NotFoundError(resourceId)            — 404 or empty provider response
  ├── ParseError(message)                  — JSON mapping failure
  ├── CacheError(message)                  — Drift read/write failure
  └── UnknownError(cause)                  — fallback
```

Rules:
- All repository implementations catch raw exceptions and map them to `AppError` subtypes.
- Providers surface errors via `AsyncValue.error(AppError, stackTrace)`.
- UI reads `AsyncValue` and maps `AppError` subtypes to user-facing messages in Russian.
- `ParseError` must log the full raw payload in debug mode for diagnostics.
- Never show raw exception messages or stack traces to the user.

---

## 14. CODE QUALITY RULES

- **No dead code.** If a feature is deferred, create the interface only. Leave implementations for the appropriate phase.
- **Null safety.** All code must be fully null-safe. No `!` operator without an inline comment explaining why it's guaranteed safe.
- **Error handling.** All remote calls must surface errors through `AsyncValue` or `AppError`. Raw exceptions must not reach the UI.
- **No magic strings.** Route paths, cache scope keys, and any string constants used as identifiers must be defined as constants.
- **No God providers.** If a provider exceeds ~80 lines, split it.
- **Optimistic updates with undo.** All quick actions (+1, status change) update local state immediately and show an undo Snackbar (4–5 seconds). On undo, revert the Drift write.
- **`select()` in list cards.** Any widget inside a list that observes a family provider must use `select()` to watch only the specific field it needs. See Section 8 for example.
- **Russian language.** All user-facing strings are in Russian. No English text in the UI. String constants can be inline in v1; no i18n library required.
- **Transactions for multi-table writes.** Any operation that writes to more than one Drift table (e.g., `incrementEpisode` updating both `watch_progress_entries` and `library_entries.last_interacted_at`) must use a Drift transaction.

---

## 15. TESTING EXPECTATIONS (v1)

- Domain model methods: unit tests for `WatchProgress.gapCount`, `isCompleted`, `isAhead`
- Urgency ranking: unit tests covering all priority branches including unknown `episodesAired`
- Next action resolver: unit tests for every state in the resolver table (Section 9)
- Progress validators: unit tests for over-increment prevention, inconsistent-state prevention, unknown-total behavior
- Repository implementations: integration tests using in-memory Drift database
- No UI tests required in v1

---

## 16. DATA SOURCE NOTES

**AniLiberty API v1** (`anilibria.top/api/docs/v1`) is the primary and only data source in v1.
"AniLibria" is the project/brand name. "AniLiberty" is the current API surface name. Do not confuse them or reference deprecated API versions.

Confirmed available from AniLiberty v1:
- Release catalog with search and browse
- Release details: description, genres, episodes list, members, ongoing flag, publishDay, ageRating, favoritesCount, blockedByGeo, blockedByCopyright
- Franchise data with release associations
- Schedule endpoints (now, week)
- Random release

**Not confirmed / do not assume:**
- Numeric score/rating field — use `favoritesCount` as popularity signal only
- `episodesAired` as a distinct field — map from provider response only if present; never derive from schedule
- Realtime/WebSocket updates — use pull-based stale-while-revalidate only
- Explicit franchise `sortOrder` — implement the three-level fallback (sortOrder → year → releaseId)
- Exact episode air times — `publishDay` is available; exact time is unreliable

**Architecture is provider-agnostic.** All AniLiberty-specific logic lives behind repository interfaces in `data/`. Future data sources are added without touching `domain/` or `features/`.

---

*Last updated: April 2026*
*Project: ani_app*
