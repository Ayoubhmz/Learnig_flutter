
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/utilities/show_error_dialog.dart';

import 'dart:developer' as devtools show log;


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;  


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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Welcome', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: implement forgot password flow
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password flow not implemented')));
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            if (email.isEmpty || !email.contains('@')) {
                              await showErrorDialog(context, 'Please enter a valid email address.');
                              return;
                            }
                            if (password.isEmpty) {
                              await showErrorDialog(context, 'Please enter your password.');
                              return;
                            }
                            setState(() => _isLoading = true);
                            try {
                              final userCredential = await AuthService.firebase().logIn(
                                email: email,
                                password: password,
                              );
                              devtools.log('is Email verified ?${userCredential.isEmailVerified}');
                              final user = AuthService.firebase().currentUser;
                              if (user?.isEmailVerified == false) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/verifyEmail/' , (route) => false);
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil('/notes/' , (route) => false);
                              }
                            } on FirebaseAuthException catch (e) {
                              // Print the raw code so you can see what the platform returns
                              devtools.log('FirebaseAuthException code: ${e.code}, message: ${e.message}');
                              // Handle common variants (web may use 'auth/wrong-password')
                              if (e.code == 'user-not-found' || e.code == 'auth/user-not-found') {
                                const msg = 'No user found for that email.';
                                devtools.log(msg);
                                await showErrorDialog(
                                  context,
                                  msg,
                                );
                              } else if (e.code == 'wrong-password' || e.code == 'auth/wrong-password') {
                                const msg = 'Wrong password provided for that user.';
                                devtools.log(msg);
                                await showErrorDialog(
                                  context,
                                  msg,
                                );
                              } else {
                                final msg = 'Authentication failed: ${e.code}';
                                devtools.log(msg);
                                await showErrorDialog(
                                  context,
                                  msg,
                                );
                              }
                            } catch (e) {
                              // Catch any other errors and surface them
                              devtools.log('Unexpected error during sign in: $e');
                              await showErrorDialog(
                                context,
                                'An unexpected error occurred. Please try again.',
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isLoading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/register/' , (route) => false);
                    },
                    child: const Text('Not registered yet? Register here!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

