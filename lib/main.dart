import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UniPathApp());
}

class UniPathApp extends StatelessWidget {
  const UniPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WelcomeScreen(),
    );
  }
}