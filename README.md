# Slide Word Flutter

This folder contains a Flutter mobile conversion of the React/Base44 PWA from `word-weaver-main`.

Notes:
- Gameplay, themes, word lengths, points, tokens, hints, refreshes, and bombs are implemented in Flutter.
- Profile and leaderboard data are stored locally with `SharedPreferences`.
- Base44 auth and cloud sync were replaced with on-device persistence because the original web-specific backend/client setup does not map directly into a standalone mobile build.

Primary entry point:
- `lib/main.dart`
