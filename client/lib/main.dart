import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:ama_meet/repositories/student_repository.dart';
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

  runApp(MyApp(studentRepo: studentRepo));
}

class MyApp extends StatelessWidget {
  final StudentRepository studentRepo;
  const MyApp({super.key, required this.studentRepo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(studentRepo)..add(AppStarted()),
      child: MaterialApp(
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
        home: BlocBuilder<AuthBloc, AuthState>(
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
      ),
    );
  }
}
