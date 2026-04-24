# V1 Smoke Test Checklist

Run this against a debug APK or `flutter run` build after `flutter analyze` and `flutter test` pass.

## Setup

- Install a fresh debug build or clear app data.
- Confirm the app starts on Home and bottom navigation exposes Home, Search, Library, and Schedule.
- Confirm Settings is reachable from the app bar icon.

## Core Loop

- Search -> Details -> Add:
  - Open Search.
  - Submit a real query.
  - Open a result.
  - Add it to the library.
  - Confirm the local status appears on Details and Search when returning.

- Favorite toggle:
  - On Details, toggle favorite for a library item.
  - Confirm undo feedback appears.
  - Confirm favorite state is reflected on local status chips where visible.

- Library -> +1:
  - Open Library.
  - Move or add an item to "Смотрю".
  - Use `+1`.
  - Confirm progress updates and undo restores the previous progress.

- Home -> Continue:
  - Return to Home with at least one "Смотрю" item.
  - Confirm "Продолжить" appears.
  - Open the title from the Continue card.

- Schedule -> Details:
  - Open Schedule with at least one personal item that appears in the provider schedule.
  - Confirm freshness text is visible.
  - Open a schedule row and verify it routes to Details.

- Settings controls:
  - Change theme mode and restart the app if practical; confirm the choice persists.
  - Clear search history and confirm recent searches disappear.
  - Clear cache and confirm personal library data remains.

## Edge And Trust Checks

- Search empty result shows an honest empty state for the query.
- Details network error shows retry instead of raw exception text.
- Schedule refresh failure with cached data shows stale/failure copy rather than a blank screen.
- Library cards with missing snapshots show a safe fallback, not fake catalog data.
- Franchise block handles empty or single-item data without implying a watch order that is not present.
