import 'package:absensi/ui/attend/attend_screen.dart';
import 'package:absensi/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDONZaPqb1qyj2iCXnvOcG8iUDRridQito',
          appId: '1:414206353974:android:e5e452968b54d43b6bee97',
          messagingSenderId: '414206353974',
          projectId: 'absensi-18348'
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // card theme section
        cardTheme: CardTheme(
          surfaceTintColor: Colors.white,
        ),
        // dialog theme section
        dialogTheme: DialogTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        ),
        // color theme section
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}