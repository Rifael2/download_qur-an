import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WelcomePage(),
    );
  }
}
