import 'package:flutter/material.dart';

import 'screens/slide_word_app.dart';
import 'services/slide_word_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await SlideWordController.create();
  runApp(SlideWordApp(controller: controller));
}
