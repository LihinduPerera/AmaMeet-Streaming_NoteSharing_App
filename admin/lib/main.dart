import 'package:ama_meet_admin/blocs/auth/auth_bloc.dart';
import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/class_note/class_note_bloc.dart';
import 'package:ama_meet_admin/repositories/admin_auth_repository.dart';
import 'package:ama_meet_admin/repositories/note_repository.dart';
import 'package:ama_meet_admin/repositories/class_repository.dart';
import 'package:ama_meet_admin/screens/login_page.dart';
import 'package:ama_meet_admin/screens/page_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ClassesBloc(ClassRepository())),
        BlocProvider(create: (context) => ClassNotesBloc(NoteRepository())),
        BlocProvider(
          create: (context) {
            final authBloc = AuthBloc(adminRepository: AdminAuthRepository());
            // Immediately check auth state
            authBloc.add(AuthCheckRequested());
            return authBloc;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AMA Meet Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const RootDecider(),
        routes: {
          '/pageSelection': (_) => const PageSelection(),
          '/login': (_) => const LoginPage(),
        },
      ),
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const PageSelection();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
