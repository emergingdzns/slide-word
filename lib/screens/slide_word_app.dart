import 'package:flutter/material.dart';

import '../services/slide_word_controller.dart';
import 'slide_word_shell.dart';

class SlideWordApp extends StatelessWidget {
  const SlideWordApp({
    super.key,
    required this.controller,
  });

  final SlideWordController controller;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFF97316);

    return MaterialApp(
      title: 'Slide Word',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF251046),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        cardTheme: const CardThemeData(
          color: Color(0x332D1450),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: SlideWordShell(controller: controller),
    );
  }
}
