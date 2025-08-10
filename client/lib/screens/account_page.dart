import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ama_meet/utils/colors.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFeeedf2),
        elevation: 0,
        title: const Text("Your Account"),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthAuthenticated) {
            final student = state.student;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    student.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(student.email, style: const TextStyle(color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: buttonColor,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No user data found"));
          }
        },
      ),
    );
  }
}
