import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:ama_meet/screens/components/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showSnackBar(context, state.message);
        }
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/pageSelection',
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Student Index", style: TextStyle(color: Colors.black)),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _idOrEmailController,
                  validator: (value) =>
                      value!.isEmpty ? "Enter ID or Email" : null,
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.person,
                        color: const Color.fromARGB(255, 227, 98, 191)),
                  )),
                ),
              ),
              Text("Password", style: TextStyle(color: Colors.black)),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  validator: (value) => value!.length < 8
                      ? "Password must be at least 8 characters"
                      : null,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.lock,
                        color: const Color.fromARGB(255, 227, 98, 191)),
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: state is AuthLoading
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
                      backgroundColor: const Color.fromARGB(255, 87, 164, 227),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                              bottomLeft: Radius.circular(25)))),
                  label: state is AuthLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text("Sign In", style: TextStyle(color: Colors.white)),
                  icon: state is AuthLoading
                      ? const SizedBox.shrink()
                      : Icon(CupertinoIcons.arrow_right, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
