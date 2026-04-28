class GameProfile {
  const GameProfile({
    required this.cumulativeScore,
    required this.cumulativeTokens,
    required this.availableHints,
    required this.availableRefresh,
    required this.availableBombs,
    required this.selectedTheme,
    required this.wordLength,
    required this.playerName,
  });

  static const defaults = GameProfile(
    cumulativeScore: 0,
    cumulativeTokens: 0,
    availableHints: 3,
    availableRefresh: 3,
    availableBombs: 3,
    selectedTheme: 'general',
    wordLength: 5,
    playerName: '',
  );

  final int cumulativeScore;
  final int cumulativeTokens;
  final int availableHints;
  final int availableRefresh;
  final int availableBombs;
  final String selectedTheme;
  final int wordLength;
  final String playerName;

  GameProfile copyWith({
    int? cumulativeScore,
    int? cumulativeTokens,
    int? availableHints,
    int? availableRefresh,
    int? availableBombs,
    String? selectedTheme,
    int? wordLength,
    String? playerName,
  }) {
    return GameProfile(
      cumulativeScore: cumulativeScore ?? this.cumulativeScore,
      cumulativeTokens: cumulativeTokens ?? this.cumulativeTokens,
      availableHints: availableHints ?? this.availableHints,
      availableRefresh: availableRefresh ?? this.availableRefresh,
      availableBombs: availableBombs ?? this.availableBombs,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      wordLength: wordLength ?? this.wordLength,
      playerName: playerName ?? this.playerName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cumulativeScore': cumulativeScore,
      'cumulativeTokens': cumulativeTokens,
      'availableHints': availableHints,
      'availableRefresh': availableRefresh,
      'availableBombs': availableBombs,
      'selectedTheme': selectedTheme,
      'wordLength': wordLength,
      'playerName': playerName,
    };
  }

  factory GameProfile.fromJson(Map<String, dynamic> json) {
    return GameProfile(
      cumulativeScore: (json['cumulativeScore'] as num?)?.toInt() ?? 0,
      cumulativeTokens: (json['cumulativeTokens'] as num?)?.toInt() ?? 0,
      availableHints: (json['availableHints'] as num?)?.toInt() ?? 3,
      availableRefresh: (json['availableRefresh'] as num?)?.toInt() ?? 3,
      availableBombs: (json['availableBombs'] as num?)?.toInt() ?? 3,
      selectedTheme: json['selectedTheme'] as String? ?? 'general',
      wordLength: (json['wordLength'] as num?)?.toInt() ?? 5,
      playerName: json['playerName'] as String? ?? '',
    );
  }
}
