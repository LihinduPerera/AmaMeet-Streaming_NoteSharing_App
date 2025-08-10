import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          if (state is AuthAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.of(context)
                            .pushReplacementNamed('/login');
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
}
