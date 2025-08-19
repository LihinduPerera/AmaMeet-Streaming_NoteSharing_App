// import 'package:ama_meet/blocs/auth/auth_bloc.dart';
// import 'package:ama_meet/utils/snackbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController _idOrEmailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFeeedf2),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthFailure) {
//             showSnackBar(context, state.message);
//           }
//           if (state is AuthAuthenticated) {
//             Navigator.pushReplacementNamed(context, '/pageSelection');
//           }
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * .9,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Lottie.asset(
//                               'assets/animations/hellow_world.json',
//                               width: MediaQuery.of(context).size.width,
//                               fit: BoxFit.fitWidth,
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               children: const [
//                                 Text(
//                                   "Log In",
//                                   style: TextStyle(
//                                     fontSize: 25,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * .9,
//                               child: TextFormField(
//                                 controller: _idOrEmailController,
//                                 validator: (value) =>
//                                     value!.isEmpty ? "Enter ID or Email" : null,
//                                 decoration: const InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   label: Text("ID or Email"),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * .9,
//                         child: TextFormField(
//                           controller: _passwordController,
//                           validator: (value) => value!.length < 8
//                               ? "Password must be at least 8 characters"
//                               : null,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             label: Text("Password"),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         height: 60,
//                         width: MediaQuery.of(context).size.width * .9,
//                         child: ElevatedButton(
//                           onPressed: state is AuthLoading
//                               ? null
//                               : () {
//                                   if (formKey.currentState!.validate()) {
//                                     context.read<AuthBloc>().add(
//                                           LoginRequested(
//                                             _idOrEmailController.text.trim(),
//                                             _passwordController.text.trim(),
//                                           ),
//                                         );
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color.fromARGB(255, 219, 197, 74)
//                                 .withOpacity(0.6),
//                             foregroundColor: Colors.black,
//                           ),
//                           child: state is AuthLoading
//                               ? const CircularProgressIndicator()
//                               : const Text("Login", style: TextStyle(fontSize: 16)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
