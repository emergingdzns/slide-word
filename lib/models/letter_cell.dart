class LetterCell {
  const LetterCell({
    required this.id,
    required this.char,
  });

  final int id;
  final String char;

  LetterCell copyWith({
    int? id,
    String? char,
  }) {
    return LetterCell(
      id: id ?? this.id,
      char: char ?? this.char,
    );
  }
}
