import 'package:ama_meet/screens/login_page.dart';
import 'package:ama_meet/screens/page_selection.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ama Meet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: buttonColor),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/pageSelection': (context) => const PageSelection(),
      },
      home: PageSelection()
    );
  }
}
