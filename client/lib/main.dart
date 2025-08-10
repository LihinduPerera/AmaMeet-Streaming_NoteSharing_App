import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:ama_meet/repositories/student_repository.dart';
import 'package:ama_meet/screens/account_page.dart';
import 'package:ama_meet/screens/login_page.dart';
import 'package:ama_meet/screens/page_selection.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final studentRepo = StudentRepository();

  runApp(
    BlocProvider(
      create: (context) => AuthBloc(studentRepo)..add(AppStarted()),
      child: const MyApp(),
    )
  );
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
        '/account': (context) => const AccountPage(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if(state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          } else if (state is AuthAuthenticated) {
            return const PageSelection();
          } else {
            return const LoginPage();
          }
        },
      )
    );
  }
}
