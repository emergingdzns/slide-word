import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';
import 'account_screen.dart';
import 'leaderboard_screen.dart';
import 'play_screen.dart';
import 'store_screen.dart';

class SlideWordShell extends StatefulWidget {
  const SlideWordShell({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  State<SlideWordShell> createState() => _SlideWordShellState();
}

class _SlideWordShellState extends State<SlideWordShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      PlayScreen(controller: widget.controller),
      StoreScreen(controller: widget.controller),
      LeaderboardScreen(controller: widget.controller),
      AccountScreen(controller: widget.controller),
    ];

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF35135C), Color(0xFF140921)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: pages[_currentIndex],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: const Color(0xFF140921),
            indicatorColor: const Color(0x33F97316),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Play'),
              NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Store'),
              NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Leaders'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
            ],
          ),
        );
      },
    );
  }
}
