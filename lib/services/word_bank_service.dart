import 'dart:convert';

import 'package:flutter/services.dart';

class WordBankService {
  const WordBankService(this.wordsByTheme);

  final Map<String, Map<int, List<String>>> wordsByTheme;

  static Future<WordBankService> load() async {
    final raw = await rootBundle.loadString('assets/data/word_bank.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final bank = <String, Map<int, List<String>>>{};

    for (final entry in decoded.entries) {
      final lengths = entry.value as Map<String, dynamic>;
      bank[entry.key] = {
        for (final lengthEntry in lengths.entries)
          int.parse(lengthEntry.key): List<String>.from(lengthEntry.value as List<dynamic>),
      };
    }

    return WordBankService(bank);
  }

  List<String> wordsFor(String theme, int length) {
    return wordsByTheme[theme]?[length] ??
        wordsByTheme['general']?[length] ??
        const [];
  }

  List<String> get themes => wordsByTheme.keys.toList();
}
