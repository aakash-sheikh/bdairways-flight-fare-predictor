import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BDAirwaysApp());
}

class BDAirwaysApp extends StatelessWidget {
  const BDAirwaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDAirways Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
