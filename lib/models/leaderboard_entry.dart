class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.tokens,
    required this.updatedAtIso,
  });

  final String playerName;
  final int score;
  final int tokens;
  final String updatedAtIso;

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'tokens': tokens,
      'updatedAtIso': updatedAtIso,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      tokens: (json['tokens'] as num?)?.toInt() ?? 0,
      updatedAtIso: json['updatedAtIso'] as String? ?? '',
    );
  }
}
