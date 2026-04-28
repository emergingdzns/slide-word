import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';
import '../widgets/info_chip.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Player Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      controller.profile.playerName.isEmpty ? 'Not set yet' : controller.profile.playerName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _editName(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Set Player Name'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Theme: ${SlideWordController.themeLabels[controller.profile.selectedTheme]}\nWord length: ${controller.profile.wordLength} letters\n\nCloud auth, logout, and account deletion from Base44 were replaced with local-device storage in this Flutter mobile port.',
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editName(BuildContext context) async {
    final textController = TextEditingController(text: controller.profile.playerName);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Player Name'),
          content: TextField(
            controller: textController,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: 'Enter display name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await controller.setPlayerName(textController.text);
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.profile.playerName.isEmpty ? 'Name cleared.' : 'Player name saved.')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
