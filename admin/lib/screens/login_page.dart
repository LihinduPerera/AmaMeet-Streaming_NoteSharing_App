import 'package:ama_meet_admin/blocs/auth/auth_bloc.dart';
import 'package:ama_meet_admin/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _idOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackBar(context, state.message);
          }
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/pageSelection');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Lottie animation - keep or replace if not present
                            Lottie.asset(
                              'assets/animations/hellow_world.json',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fitWidth,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: TextFormField(
                                controller: _idOrEmailController,
                                validator: (value) =>
                                    value == null || value.isEmpty ? "Enter ID or Email" : null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text("ID or Email"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (value) => value == null || value.length < 8
                              ? "Password must be at least 8 characters"
                              : null,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Password"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width * .9,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            _idOrEmailController.text.trim(),
                                            _passwordController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 219, 197, 74).withOpacity(0.9),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("Login", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Beautiful Google Sign-in button
                      SizedBox(
                        height: 56,
                        width: MediaQuery.of(context).size.width * .9,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(GoogleLoginRequested());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // If you have a local asset for Google logo replace with Image.asset
                              // otherwise use a simple Icon
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 26,
                                width: 26,
                                errorBuilder: (context, error, stack) {
                                  return const Icon(Icons.login, size: 26);
                                },
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // optionally: a small text to navigate to sign-up screen
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
