import 'package:ama_meet/controllers/auth_service.dart';
import 'package:ama_meet/pages/login_page.dart';
import 'package:ama_meet/pages/page_selection.dart';
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
      home: StreamBuilder(
        stream: AuthService().authChanges,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(snapshot.hasData) {
              Navigator.pushReplacementNamed(context, '/pageSelection');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
              // Navigator.pushReplacementNamed(context, '/pageSelection');
            }
          });

          // Reutrn CircularProgressIndicator while navigating
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      )
    );
  }
}
