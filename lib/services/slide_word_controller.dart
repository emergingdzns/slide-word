import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_profile.dart';
import '../models/leaderboard_entry.dart';
import '../models/letter_cell.dart';
import '../models/shop_pack.dart';
import 'storage_service.dart';
import 'word_bank_service.dart';

class GridPosition {
  const GridPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) {
    return other is GridPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

class SlideWordController extends ChangeNotifier {
  SlideWordController._({
    required StorageService storage,
    required WordBankService wordBank,
    required GameProfile profile,
    required List<LeaderboardEntry> leaderboard,
  })  : _storage = storage,
        _wordBank = wordBank,
        _profile = profile,
        _leaderboard = leaderboard {
    _syncProfileState();
  }

  static const clearWords = <String>[
    'AND',
    'THE',
    'FOR',
    'BUY',
    'SIP',
    'COW',
    'LEG',
    'JAM',
    'KEY',
    'VAX',
    'ZIT',
    'QUA',
  ];

  static const List<int> supportedWordLengths = [4, 5, 6, 7, 8];

  static const Map<String, String> themeLabels = {
    'general': 'General',
    'animals': 'Animals',
    'food': 'Food',
    'movies': 'Movies',
    'science': 'Science',
    'sports': 'Sports',
  };

  static const List<ShopPack> hintPacks = [
    ShopPack(id: 'h1', amount: 5, cost: 10, label: 'Hints'),
    ShopPack(id: 'h2', amount: 20, cost: 35, label: 'Hints'),
    ShopPack(id: 'h3', amount: 50, cost: 80, label: 'Hints'),
    ShopPack(id: 'h4', amount: 100, cost: 150, label: 'Hints'),
  ];

  static const List<ShopPack> refreshPacks = [
    ShopPack(id: 'r1', amount: 3, cost: 15, label: 'Refreshes'),
    ShopPack(id: 'r2', amount: 8, cost: 30, label: 'Refreshes'),
    ShopPack(id: 'r3', amount: 15, cost: 70, label: 'Refreshes'),
    ShopPack(id: 'r4', amount: 50, cost: 200, label: 'Refreshes'),
  ];

  static const List<ShopPack> bombPacks = [
    ShopPack(id: 'b1', amount: 3, cost: 15, label: 'Bombs'),
    ShopPack(id: 'b2', amount: 8, cost: 30, label: 'Bombs'),
    ShopPack(id: 'b3', amount: 15, cost: 70, label: 'Bombs'),
    ShopPack(id: 'b4', amount: 50, cost: 200, label: 'Bombs'),
  ];

  static Future<SlideWordController> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final wordBank = await WordBankService.load();
    final controller = SlideWordController._(
      storage: storage,
      wordBank: wordBank,
      profile: storage.loadProfile(),
      leaderboard: storage.loadLeaderboard(),
    );
    controller._resetBoardState(notify: false);
    return controller;
  }

  final StorageService _storage;
  final WordBankService _wordBank;
  final Random _random = Random();
  final List<LeaderboardEntry> _leaderboard;

  GameProfile _profile;
  List<List<LetterCell>> _grid = const [];
  List<String> _targetWords = const [];
  List<String> _foundWords = const [];
  List<GridPosition> _selectedPositions = const [];
  List<GridPosition> _highlightedPositions = const [];
  String _message = 'Slide rows and columns to line up words.';
  int _sessionPoints = 0;
  int _sessionTokens = 0;
  int _nextCellId = 0;
  bool _showGame = false;
  bool _bombMode = false;
  bool _showHowToPlay = false;
  bool _showNoMoves = false;
  bool _showWin = false;

  GameProfile get profile => _profile;
  List<List<LetterCell>> get grid => _grid;
  List<String> get targetWords => _targetWords;
  List<String> get foundWords => _foundWords;
  List<GridPosition> get selectedPositions => _selectedPositions;
  List<GridPosition> get highlightedPositions => _highlightedPositions;
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_sortedLeaderboard());
  String get message => _message;
  int get sessionPoints => _sessionPoints;
  int get sessionTokens => _sessionTokens;
  bool get showGame => _showGame;
  bool get bombMode => _bombMode;
  bool get showHowToPlay => _showHowToPlay;
  bool get showNoMoves => _showNoMoves;
  bool get showWin => _showWin;
  int get gridSize => _profile.wordLength + 2;
  int get remainingWords => _targetWords.length - _foundWords.length;

  void _syncProfileState() {
    if (_grid.isEmpty) {
      _grid = _initializeGrid(gridSize);
    }
  }

  List<List<LetterCell>> _initializeGrid(int size) {
    return List.generate(
      size,
      (_) => List.generate(
        size,
        (_) => LetterCell(id: _nextCellId++, char: _randomLetter()),
      ),
    );
  }

  String _randomLetter({String? excluding}) {
    const weights = {
      'E': 10,
      'T': 9,
      'A': 8,
      'O': 8,
      'I': 7,
      'N': 7,
      'S': 6,
      'H': 6,
      'R': 6,
      'D': 4,
      'L': 4,
      'C': 5,
      'U': 4,
      'M': 3,
      'W': 2,
      'F': 2,
      'G': 2,
      'Y': 2,
      'P': 3,
      'B': 1,
      'V': 1,
      'K': 1,
      'J': 1,
      'X': 1,
      'Q': 1,
      'Z': 1,
    };

    final pool = <String>[];
    for (final entry in weights.entries) {
      if (entry.key == excluding) {
        continue;
      }
      pool.addAll(List.filled(entry.value, entry.key));
    }
    return pool[_random.nextInt(pool.length)];
  }

  List<String> _selectRandomWords(int count, int length, String theme) {
    final source = List<String>.from(_wordBank.wordsFor(theme, length));
    source.shuffle(_random);
    return source.take(min(count, source.length)).toList();
  }

  void _resetBoardState({bool notify = true}) {
    _grid = _initializeGrid(gridSize);
    _targetWords = _selectRandomWords(10, _profile.wordLength, _profile.selectedTheme);
    _foundWords = [];
    _selectedPositions = [];
    _highlightedPositions = [];
    _sessionPoints = 0;
    _sessionTokens = 0;
    _bombMode = false;
    _showNoMoves = false;
    _showWin = false;
    _showGame = false;
    _message = 'New puzzle ready. Tap Start Playing when you are ready.';
    if (notify) {
      notifyListeners();
    }
  }

  void startNewSession() {
    _resetBoardState();
  }

  void beginGame() {
    _resetBoardState(notify: false);
    _showGame = true;
    _showHowToPlay = true;
    _message = 'Find the ten target words, or use clear words for quick tokens.';
    notifyListeners();
  }

  void dismissHowToPlay() {
    _showHowToPlay = false;
    notifyListeners();
  }

  Future<void> backToStart() async {
    _showGame = false;
    _sessionPoints = 0;
    _sessionTokens = 0;
    _selectedPositions = [];
    _highlightedPositions = [];
    _bombMode = false;
    _message = 'Session progress cleared. Complete a board to bank points and tokens.';
    notifyListeners();
  }

  Future<void> changeWordLength(int length) async {
    final keepPlaying = _showGame;
    _profile = _profile.copyWith(wordLength: length);
    await _persistProfile();
    _resetBoardState(notify: false);
    _showGame = keepPlaying;
    notifyListeners();
  }

  Future<void> changeTheme(String theme) async {
    final keepPlaying = _showGame;
    _profile = _profile.copyWith(selectedTheme: theme);
    await _persistProfile();
    _resetBoardState(notify: false);
    _showGame = keepPlaying;
    notifyListeners();
  }

  Future<void> setPlayerName(String playerName) async {
    final trimmed = playerName.trim();
    _profile = _profile.copyWith(playerName: trimmed);
    await _persistProfile();
    await _syncLeaderboard();
    notifyListeners();
  }

  Future<void> rotateRow(int rowIndex, int direction, {int spaces = 1}) async {
    final row = List<LetterCell>.from(_grid[rowIndex]);
    for (var i = 0; i < spaces; i++) {
      if (direction > 0) {
        row.insert(0, row.removeLast());
      } else {
        row.add(row.removeAt(0));
      }
    }
    _grid[rowIndex] = row;
    _selectedPositions = [];
    _highlightedPositions = [];
    _bombMode = false;
    _refreshMoveMessage();
    notifyListeners();
  }

  Future<void> rotateColumn(int colIndex, int direction, {int spaces = 1}) async {
    final column = List<LetterCell>.generate(_grid.length, (index) => _grid[index][colIndex]);
    for (var i = 0; i < spaces; i++) {
      if (direction > 0) {
        column.insert(0, column.removeLast());
      } else {
        column.add(column.removeAt(0));
      }
    }
    for (var rowIndex = 0; rowIndex < _grid.length; rowIndex++) {
      _grid[rowIndex][colIndex] = column[rowIndex];
    }
    _selectedPositions = [];
    _highlightedPositions = [];
    _bombMode = false;
    _refreshMoveMessage();
    notifyListeners();
  }

  Future<void> tapCell(int row, int col) async {
    final position = GridPosition(row, col);
    if (_bombMode) {
      await useBombOn(position);
      return;
    }

    if (_selectedPositions.contains(position)) {
      _selectedPositions = _selectedPositions.where((item) => item != position).toList();
      notifyListeners();
      return;
    }

    _selectedPositions = [..._selectedPositions, position];
    _highlightedPositions = [];
    await _checkWord();
    notifyListeners();
  }

  Future<void> _checkWord() async {
    if (_selectedPositions.length < 3) {
      return;
    }

    final isHorizontal = _selectedPositions.every((pos) => pos.row == _selectedPositions.first.row);
    final isVertical = _selectedPositions.every((pos) => pos.col == _selectedPositions.first.col);

    if (!isHorizontal && !isVertical) {
      _message = 'Selections must stay in one row or one column.';
      return;
    }

    final word = _selectedPositions.map((pos) => _grid[pos.row][pos.col].char).join();

    if (clearWords.contains(word) && !_wouldBlockLongerWord(word)) {
      _sessionPoints += word.length;
      _sessionTokens += 1;
      _message = 'Clear word $word found. +${word.length} points and +1 token.';
      _removeLetters(_selectedPositions);
      _selectedPositions = [];
      await _checkWinOrMoves();
      return;
    }

    if (_targetWords.contains(word) && !_foundWords.contains(word)) {
      _foundWords = [..._foundWords, word];
      _sessionPoints += word.length;
      _sessionTokens += 1;
      _message = 'Found $word. ${_foundWords.length}/${_targetWords.length} target words complete.';
      _removeLetters(_selectedPositions);
      _selectedPositions = [];
      await _checkWinOrMoves();
      return;
    }

    _message = '$word is not a scored word right now.';
  }

  bool _wouldBlockLongerWord(String word) {
    final selection = List<GridPosition>.from(_selectedPositions);
    final isHorizontal = selection.every((pos) => pos.row == selection.first.row);
    final sorted = [...selection]
      ..sort((a, b) => isHorizontal ? a.col.compareTo(b.col) : a.row.compareTo(b.row));

    return _targetWords.any((target) {
      if (!target.startsWith(word) || target == word || _foundWords.contains(target)) {
        return false;
      }

      final suffix = target.substring(word.length).split('');
      if (isHorizontal) {
        final row = sorted.first.row;
        final startCol = sorted.first.col;
        final endCol = sorted.last.col;

        final canGoForward = endCol + suffix.length < gridSize &&
            List.generate(suffix.length, (index) => _grid[row][endCol + 1 + index].char)
                .join() ==
                suffix.join();

        final reverseSuffix = suffix.reversed.join();
        final canGoBackward = startCol - suffix.length >= 0 &&
            List.generate(suffix.length, (index) => _grid[row][startCol - 1 - index].char)
                .join() ==
                reverseSuffix;

        return canGoForward || canGoBackward;
      }

      final col = sorted.first.col;
      final startRow = sorted.first.row;
      final endRow = sorted.last.row;
      final canGoDown = endRow + suffix.length < gridSize &&
          List.generate(suffix.length, (index) => _grid[endRow + 1 + index][col].char).join() ==
              suffix.join();

      final reverseSuffix = suffix.reversed.join();
      final canGoUp = startRow - suffix.length >= 0 &&
          List.generate(suffix.length, (index) => _grid[startRow - 1 - index][col].char).join() ==
              reverseSuffix;

      return canGoDown || canGoUp;
    });
  }

  void _removeLetters(List<GridPosition> positions) {
    if (positions.isEmpty) {
      return;
    }

    final horizontal = positions.every((pos) => pos.row == positions.first.row);
    if (horizontal) {
      for (final pos in positions) {
        final col = pos.col;
        for (var row = pos.row; row > 0; row--) {
          _grid[row][col] = _grid[row - 1][col];
        }
        _grid[0][col] = LetterCell(id: _nextCellId++, char: _randomLetter());
      }
      return;
    }

    final col = positions.first.col;
    final clearedRows = positions.map((pos) => pos.row).toSet();
    final remaining = <LetterCell>[];
    for (var row = 0; row < gridSize; row++) {
      if (!clearedRows.contains(row)) {
        remaining.add(_grid[row][col]);
      }
    }

    final replacements = List<LetterCell>.generate(
      clearedRows.length,
      (_) => LetterCell(id: _nextCellId++, char: _randomLetter()),
    );
    final rebuilt = [...replacements, ...remaining];
    for (var row = 0; row < gridSize; row++) {
      _grid[row][col] = rebuilt[row];
    }
  }

  Future<void> useHint() async {
    if (_profile.availableHints <= 0) {
      _message = 'You are out of hints. Visit the Tool Shop for more.';
      notifyListeners();
      return;
    }

    final letterCounts = <String, int>{};
    for (final row in _grid) {
      for (final cell in row) {
        letterCounts[cell.char] = (letterCounts[cell.char] ?? 0) + 1;
      }
    }

    final candidates = [
      ..._targetWords.where((word) => !_foundWords.contains(word)),
      ...clearWords,
    ];

    String? hintWord;
    for (final candidate in candidates) {
      final needed = <String, int>{};
      for (final letter in candidate.split('')) {
        needed[letter] = (needed[letter] ?? 0) + 1;
      }
      final possible = needed.entries.every((entry) => (letterCounts[entry.key] ?? 0) >= entry.value);
      if (possible) {
        hintWord = candidate;
        break;
      }
    }

    if (hintWord == null) {
      _message = 'No hintable word is available on this board.';
      notifyListeners();
      return;
    }

    final used = <GridPosition>{};
    final positions = <GridPosition>[];
    for (final letter in hintWord.split('')) {
      for (var row = 0; row < gridSize; row++) {
        var matched = false;
        for (var col = 0; col < gridSize; col++) {
          final position = GridPosition(row, col);
          if (!used.contains(position) && _grid[row][col].char == letter) {
            used.add(position);
            positions.add(position);
            matched = true;
            break;
          }
        }
        if (matched) {
          break;
        }
      }
    }

    _highlightedPositions = positions;
    _profile = _profile.copyWith(availableHints: _profile.availableHints - 1);
    await _persistProfile();
    _message = 'Hint: look for $hintWord.';
    notifyListeners();
  }

  Future<void> useRefresh() async {
    if (_profile.availableRefresh <= 0) {
      _message = 'You are out of refreshes. Visit the Tool Shop for more.';
      notifyListeners();
      return;
    }

    _profile = _profile.copyWith(availableRefresh: _profile.availableRefresh - 1);
    _grid = _initializeGrid(gridSize);
    _selectedPositions = [];
    _highlightedPositions = [];
    _bombMode = false;
    await _persistProfile();
    _refreshMoveMessage();
    notifyListeners();
  }

  void armBomb() {
    if (_profile.availableBombs <= 0) {
      _message = 'You are out of bombs. Visit the Tool Shop for more.';
      notifyListeners();
      return;
    }

    _bombMode = true;
    _message = 'Bomb armed. Tap a letter to replace every copy of it.';
    notifyListeners();
  }

  Future<void> useBombOn(GridPosition position) async {
    if (!_bombMode) {
      return;
    }

    final targetChar = _grid[position.row][position.col].char;
    for (var col = 0; col < gridSize; col++) {
      final remaining = <LetterCell>[];
      var removed = 0;
      for (var row = 0; row < gridSize; row++) {
        final cell = _grid[row][col];
        if (cell.char == targetChar) {
          removed++;
        } else {
          remaining.add(cell);
        }
      }
      final replacements = List<LetterCell>.generate(
        removed,
        (_) => LetterCell(id: _nextCellId++, char: _randomLetter(excluding: targetChar)),
      );
      final rebuilt = [...replacements, ...remaining];
      for (var row = 0; row < gridSize; row++) {
        _grid[row][col] = rebuilt[row];
      }
    }

    _profile = _profile.copyWith(availableBombs: _profile.availableBombs - 1);
    _bombMode = false;
    _selectedPositions = [];
    _highlightedPositions = [];
    await _persistProfile();
    _message = 'Bombed every $targetChar tile on the board.';
    await _checkWinOrMoves();
    notifyListeners();
  }

  Future<String?> buyPack(String kind, ShopPack pack) async {
    if (_profile.cumulativeTokens < pack.cost) {
      return 'Not enough tokens for this purchase.';
    }

    switch (kind) {
      case 'hints':
        _profile = _profile.copyWith(
          cumulativeTokens: _profile.cumulativeTokens - pack.cost,
          availableHints: _profile.availableHints + pack.amount,
        );
        break;
      case 'refresh':
        _profile = _profile.copyWith(
          cumulativeTokens: _profile.cumulativeTokens - pack.cost,
          availableRefresh: _profile.availableRefresh + pack.amount,
        );
        break;
      case 'bombs':
        _profile = _profile.copyWith(
          cumulativeTokens: _profile.cumulativeTokens - pack.cost,
          availableBombs: _profile.availableBombs + pack.amount,
        );
        break;
      default:
        return 'Unknown purchase type.';
    }

    await _persistProfile();
    _message = 'Purchased ${pack.amount} ${pack.label.toLowerCase()}.';
    notifyListeners();
    return null;
  }

  Future<void> commitWinAndContinue() async {
    if (!_showWin) {
      return;
    }

    _showWin = false;
    startNewSession();
    _showGame = true;
    _message = 'Fresh puzzle loaded. Keep the streak going.';
    notifyListeners();
  }

  void dismissNoMoves() {
    _showNoMoves = false;
    notifyListeners();
  }

  List<LeaderboardEntry> _sortedLeaderboard() {
    final entries = List<LeaderboardEntry>.from(_leaderboard);
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  Future<void> _checkWinOrMoves() async {
    if (_targetWords.isNotEmpty && _foundWords.length == _targetWords.length) {
      _profile = _profile.copyWith(
        cumulativeScore: _profile.cumulativeScore + _sessionPoints,
        cumulativeTokens: _profile.cumulativeTokens + _sessionTokens,
      );
      await _persistProfile();
      await _syncLeaderboard();
      _showWin = true;
      _message = 'Puzzle complete. ${_sessionPoints} points and ${_sessionTokens} tokens banked.';
      return;
    }

    if (!_hasAnyPossibleMove()) {
      _showNoMoves = true;
      _message = 'No moves remain on this board. Use a refresh or start a new puzzle.';
    }
  }

  bool _hasAnyPossibleMove() {
    final letterCounts = <String, int>{};
    for (final row in _grid) {
      for (final cell in row) {
        letterCounts[cell.char] = (letterCounts[cell.char] ?? 0) + 1;
      }
    }

    final candidates = [
      ..._targetWords.where((word) => !_foundWords.contains(word)),
      ...clearWords,
    ];

    for (final word in candidates) {
      final needed = <String, int>{};
      for (final char in word.split('')) {
        needed[char] = (needed[char] ?? 0) + 1;
      }
      final possible = needed.entries.every((entry) => (letterCounts[entry.key] ?? 0) >= entry.value);
      if (possible) {
        return true;
      }
    }
    return false;
  }

  void _refreshMoveMessage() {
    if (_hasAnyPossibleMove()) {
      _message = 'Board moved. ${remainingWords} target words left.';
      _showNoMoves = false;
    } else {
      _showNoMoves = true;
      _message = 'That move left no available words. Try a refresh or bomb.';
    }
  }

  Future<void> _persistProfile() async {
    await _storage.saveProfile(_profile);
  }

  Future<void> _syncLeaderboard() async {
    final name = _profile.playerName.trim();
    if (name.isEmpty) {
      return;
    }

    final index = _leaderboard.indexWhere((entry) => entry.playerName.toLowerCase() == name.toLowerCase());
    final updated = LeaderboardEntry(
      playerName: name,
      score: _profile.cumulativeScore,
      tokens: _profile.cumulativeTokens,
      updatedAtIso: DateTime.now().toIso8601String(),
    );

    if (index >= 0) {
      _leaderboard[index] = updated;
    } else {
      _leaderboard.add(updated);
    }

    await _storage.saveLeaderboard(_leaderboard);
  }

  String exportDebugState() {
    return jsonEncode({
      'profile': _profile.toJson(),
      'targetWords': _targetWords,
      'foundWords': _foundWords,
      'sessionPoints': _sessionPoints,
      'sessionTokens': _sessionTokens,
    });
  }
}
