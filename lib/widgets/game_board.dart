import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(controller.gridSize, (col) {
            return Expanded(
              child: IconButton(
                onPressed: () => controller.rotateColumn(col, -1),
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
            );
          }),
        ),
        for (var row = 0; row < controller.gridSize; row++)
          Row(
            children: [
              IconButton(
                onPressed: () => controller.rotateRow(row, -1),
                icon: const Icon(Icons.keyboard_arrow_left),
              ),
              Expanded(
                child: Row(
                  children: List.generate(controller.gridSize, (col) {
                    final cell = controller.grid[row][col];
                    final position = GridPosition(row, col);
                    final selected = controller.selectedPositions.contains(position);
                    final highlighted = controller.highlightedPositions.contains(position);

                    Color background = Colors.white12;
                    if (selected) {
                      background = Colors.orangeAccent.withOpacity(0.75);
                    } else if (highlighted) {
                      background = Colors.lightBlueAccent.withOpacity(0.45);
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: background,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => controller.tapCell(row, col),
                            child: Text(
                              cell.char,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              IconButton(
                onPressed: () => controller.rotateRow(row, 1),
                icon: const Icon(Icons.keyboard_arrow_right),
              ),
            ],
          ),
        Row(
          children: List.generate(controller.gridSize, (col) {
            return Expanded(
              child: IconButton(
                onPressed: () => controller.rotateColumn(col, 1),
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            );
          }),
        ),
      ],
    );
  }
}
