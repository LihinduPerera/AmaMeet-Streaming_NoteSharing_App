import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
          if (state is AuthAuthenticated) {
            final student = state.student;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[400],
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    infoTile("Name", student.name),
                    const SizedBox(height: 16),
                    infoTile("Email", student.email),
                    const SizedBox(height: 16),
                    infoTile("Class ID", student.classId),
                    const Spacer(),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/landingScreen',
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          backgroundColor: buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Text("No User Data Found !!"),
            );
          }
        },
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            )),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
