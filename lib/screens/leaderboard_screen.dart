import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.leaderboard;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Leaderboard',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'This mobile port stores leaderboard entries locally on the device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              if (entries.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Set a player name in Account and finish a puzzle to appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isCurrentUser =
                          controller.profile.playerName.trim().toLowerCase() == entry.playerName.toLowerCase();
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: index < 3 ? Colors.orange.withOpacity(0.25) : Colors.white10,
                            child: Text('#${index + 1}'),
                          ),
                          title: Text(entry.playerName),
                          subtitle: Text('${entry.tokens} tokens'),
                          trailing: Text(
                            '${entry.score} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          tileColor: isCurrentUser ? Colors.orange.withOpacity(0.12) : null,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
