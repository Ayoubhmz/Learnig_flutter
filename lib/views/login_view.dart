
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_options.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;


  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  print('Signed in: ${userCredential.user?.email}');
                  print(userCredential.user);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Signed in: ${userCredential.user?.email}'),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  // Print the raw code so you can see what the platform returns
                  print('FirebaseAuthException code: ${e.code}, message: ${e.message}');
                  // Handle common variants (web may use 'auth/wrong-password')
                  if (e.code == 'user-not-found' || e.code == 'auth/user-not-found') {
                    const msg = 'No user found for that email.';
                    print(msg);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(msg)));
                  } else if (e.code == 'wrong-password' || e.code == 'auth/wrong-password') {
                    const msg = 'Wrong password provided for that user.';
                    print(msg);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(msg)));
                  } else {
                    final msg = 'Authentication failed: ${e.code}';
                    print(msg);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (e) {
                  // Catch any other errors and surface them
                  print('Unexpected error during sign in: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
  }

  

 
}