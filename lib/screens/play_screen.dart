import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/info_chip.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          if (controller.showHowToPlay) {
            _showHowToPlay(context);
          } else if (controller.showNoMoves) {
            _showNoMoves(context);
          } else if (controller.showWin) {
            _showWinDialog(context);
          }
        });

        return controller.showGame ? _buildGame(context) : _buildStart(context);
      },
    );
  }

  Widget _buildStart(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Slide Word',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rotate rows and columns until target words line up.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoChip(
                  label: 'Points',
                  value: controller.profile.cumulativeScore.toString(),
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoChip(
                  label: 'Tokens',
                  value: controller.profile.cumulativeTokens.toString(),
                  icon: Icons.local_atm,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            icon: Icons.play_arrow,
            label: 'Start Playing',
            onPressed: controller.beginGame,
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            icon: Icons.palette_outlined,
            label: 'Word Theme',
            onPressed: () => _showThemePicker(context),
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            icon: Icons.straighten,
            label: 'Word Length',
            onPressed: () => _showLengthPicker(context),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InfoChip(
                          label: 'Hints',
                          value: controller.profile.availableHints.toString(),
                          icon: Icons.lightbulb_outline,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoChip(
                          label: 'Refresh',
                          value: controller.profile.availableRefresh.toString(),
                          icon: Icons.refresh,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoChip(
                          label: 'Bombs',
                          value: controller.profile.availableBombs.toString(),
                          icon: Icons.brightness_high,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Theme: ${SlideWordController.themeLabels[controller.profile.selectedTheme]}\nWord length: ${controller.profile.wordLength} letters',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    final remainingTargets = controller.targetWords.where((word) => !controller.foundWords.contains(word)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.backToStart,
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Slide Word',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => _showLengthPicker(context),
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label: 'Session',
                value: '${controller.sessionPoints} pts',
                icon: Icons.stars,
                color: Colors.orangeAccent,
              ),
              InfoChip(
                label: 'Tokens',
                value: controller.sessionTokens.toString(),
                icon: Icons.local_atm,
                color: Colors.amber,
              ),
              InfoChip(
                label: 'Remaining',
                value: controller.remainingWords.toString(),
                icon: Icons.flag_outlined,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GameBoard(controller: controller),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: controller.useHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text('Hint (${controller.profile.availableHints})'),
              ),
              FilledButton.icon(
                onPressed: controller.useRefresh,
                icon: const Icon(Icons.refresh),
                label: Text('Refresh (${controller.profile.availableRefresh})'),
              ),
              FilledButton.icon(
                onPressed: controller.armBomb,
                icon: const Icon(Icons.brightness_high),
                label: Text('Bomb (${controller.profile.availableBombs})'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target Words',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.targetWords.map((word) {
                      final found = controller.foundWords.contains(word);
                      return Chip(
                        backgroundColor: found ? Colors.green.withOpacity(0.25) : Colors.white10,
                        label: Text(
                          word,
                          style: TextStyle(
                            color: found ? Colors.greenAccent : Colors.white,
                            decoration: found ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (remainingTargets.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Still hunting: ${remainingTargets.join(', ')}',
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                controller.message,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B0E31),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: SlideWordController.themeLabels.entries.map((entry) {
              final selected = controller.profile.selectedTheme == entry.key;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.orangeAccent : Colors.white54,
                ),
                title: Text(entry.value),
                onTap: () async {
                  Navigator.of(context).pop();
                  await controller.changeTheme(entry.key);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showLengthPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B0E31),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: SlideWordController.supportedWordLengths.map((length) {
              final selected = controller.profile.wordLength == length;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.orangeAccent : Colors.white54,
                ),
                title: Text('$length letters'),
                subtitle: Text('${length + 2} x ${length + 2} board'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await controller.changeWordLength(length);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showHowToPlay(BuildContext context) async {
    controller.dismissHowToPlay();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
            'Rotate rows and columns to align letters. Tap letters in a single row or column to build a word. Target words award points and tokens, and clear words give quick token gains without counting toward the puzzle.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Let\'s play'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNoMoves(BuildContext context) async {
    controller.dismissNoMoves();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Moves Left'),
          content: const Text(
            'This board no longer contains the letters needed for a target word or a clear word. Use a refresh, a bomb, or return to the start page for a new board.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWinDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Puzzle Complete'),
          content: Text(
            '${controller.sessionPoints} points and ${controller.sessionTokens} tokens were added to your profile.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.commitWinAndContinue();
              },
              child: const Text('Next puzzle'),
            ),
          ],
        );
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
