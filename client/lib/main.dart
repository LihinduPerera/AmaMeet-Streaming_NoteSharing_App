import 'package:ama_meet/repositories/student_repository.dart';
import 'package:ama_meet/screens/login_page.dart';
import 'package:ama_meet/screens/page_selection.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => StudentRepository(),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(context.read<StudentRepository>())..add(AppStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ama Meet',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: buttonColor),
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/pageSelection': (context) => const PageSelection(),
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthFailure,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthAuthenticated) {
            return const PageSelection();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
