# Anime Companion

Android-first anime companion and tracker app built with Flutter.

This is a personal-first companion product, not a streaming app. It helps a user search the anime catalog, open details, keep a local library, track watch progress, see a personal re-entry Home surface, review a personal schedule preview, and manage trust/settings controls.

## What This Is Not

- No video player or fake playback UI.
- No social feed, comments, friends, or ratings system.
- No backend auth, cloud sync, or remote library storage.
- No recommendation, random, or storefront-style discovery surface.
- No manga support in v1.

## Current V1 Baseline

Implemented product surfaces:

- Search and browse foundation over AniLiberty API v1.
- Anime Details with local status, favorite, progress context, blocked-content warning, and franchise block.
- Local Library with status segments, progress context, quick `+1`, status changes, and local filtering.
- Local presentation snapshots for personal surfaces.
- Home re-entry dashboard with Continue, My Schedule, and What Next sections.
- Personal-first Schedule screen with grouped week view, freshness, and manual refresh.
- Settings trust/control surface for theme mode, cache clearing, search history clearing, and data source transparency.

Intentionally deferred:

- Backend accounts, auth, sync, and remote library storage.
- Push reminders.
- Recommendations, random feeds, social features, and storefront rails.
- Full release signing and distribution pipeline.

## Data Source And Data Truth

Remote catalog data comes from the AniLibria project / AniLiberty API v1. Older API versions are not targeted.

The app is local-first for personal data:

- Library status, favorite state, progress, notes, and search history are stored locally.
- Presentation snapshots support local personal surfaces, but they are not a full remote catalog mirror.
- Remote schedule/details/list data uses the existing repository/cache contracts; UI must not invent missing provider fields.
- Popularity is shown only through provider favorites count. There is no fake rating or score.

## Architecture

The codebase follows the layer boundaries in `AGENTS.md`:

```text
lib/
  app/          app wiring, router, navigation shell, theme
  core/         technical infrastructure: Dio, Drift, cache, errors
  domain/       pure models, enums, repository contracts, domain rules
  data/         DTOs, mappers, data sources, repository implementations
  features/     screen-scoped providers and widgets
  shared/       reusable UI primitives
```

Important rules for review:

- Domain contracts remain the source of truth.
- Providers orchestrate data; repositories own reads/writes.
- Progress validation lives in `ProgressRepository`, not in widgets/providers.
- Local user layer is the authority for status, favorite, and progress.
- Snapshots are presentation support only.
- No `Image.network`; use shared `AnimePosterImage`.

## Run Locally

Prerequisites:

- Flutter stable SDK
- Android SDK / emulator or Android device

Setup:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Build a debug APK:

```bash
flutter build apk --debug
```

The project is Android-first. Other platforms are not part of the current v1 baseline.

## Manual Smoke Testing

Use `docs/smoke_test.md` for the current v1 smoke checklist before review, merge, or APK handoff.

## Review Notes

This repository is currently prepared as a v1 baseline for review and manual smoke testing. Keep changes inside the accepted architecture:

- Do not add new product surfaces during hardening/review cleanup.
- Do not add backend/auth/sync.
- Do not introduce recommendations, random feeds, storefront rails, social behavior, or video playback.
- Do not turn local snapshots into a full catalog mirror.
- Do not add fake schedule timing, fake ratings, or inferred provider truth.
