import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_profile.dart';
import '../models/leaderboard_entry.dart';

class StorageService {
  StorageService(this._prefs);

  static const _profileKey = 'slide_word_profile';
  static const _leaderboardKey = 'slide_word_leaderboard';
  final SharedPreferences _prefs;

  GameProfile loadProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return GameProfile.defaults;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return GameProfile.fromJson(decoded);
  }

  Future<void> saveProfile(GameProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  List<LeaderboardEntry> loadLeaderboard() {
    final raw = _prefs.getString(_leaderboardKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => LeaderboardEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLeaderboard(List<LeaderboardEntry> entries) async {
    final data = entries.map((entry) => entry.toJson()).toList();
    await _prefs.setString(_leaderboardKey, jsonEncode(data));
  }
}
