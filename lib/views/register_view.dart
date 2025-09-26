
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import 'package:learningdart/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;


  @override
  void initState() {
    _emailController = TextEditingController(); 
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                      hintText: 'you@example.com',
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
                      hintText: 'Enter a secure password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordStrength(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Re-enter password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            final confirm = _confirmController.text;
                  
                            // Basic validation
                            if (email.isEmpty || !email.contains('@')) {
                              await showErrorDialog(context, 'Please enter a valid email address.');
                              return;
                            }
                            if (password.isEmpty) {
                              await showErrorDialog(context, 'Please enter a password.');
                              return;
                            }
                            if (password != confirm) {
                              await showErrorDialog(context, 'Passwords do not match.');
                              return;
                            }
                            final score = _passwordScore(password);
                            if (password.length < 8 || score < 2) {
                              await showErrorDialog(context, 'Password is too weak. Use at least 8 chars including letters and numbers.');
                              return;
                            }
                  
                            setState(() {
                              _isLoading = true;
                            });
                  
                            try {
                              await AuthService.firebase().createUser(
                                email: email,
                                password: password,
                              );
                              await AuthService.firebase().sendEmailVerification();
                              if (!mounted) return;
                              Navigator.of(context).pushNamed('/verifyEmail/');
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password' || e.code == 'auth/weak-password') {
                                const msg = 'The password provided is too weak.';
                                await showErrorDialog(context, msg);
                              } else if (e.code == 'email-already-in-use' || e.code == 'auth/email-already-in-use') {
                                const msg = 'The account already exists for that email.';
                                await showErrorDialog(context, msg);
                              } else {
                                final msg = 'Authentication error: ${e.code}';
                                await showErrorDialog(context, msg);
                              }
                            } catch (e) {
                              devtools.log('Exception: $e');
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login/' , (route) => false);
                    },
                    child: const Text('Already registered? Login here!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Simple password scoring: length + variety
  int _passwordScore(String p) {
    var score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(p)) score++;
    return score;
  }

  Widget _buildPasswordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) return const SizedBox.shrink();
    final score = _passwordScore(p);
    String label;
    Color color;
    double fraction = (score / 4).clamp(0.0, 1.0);
    if (score <= 1) {
      label = 'Very weak';
      color = Colors.red;
    } else if (score == 2) {
      label = 'Weak';
      color = Colors.orange;
    } else if (score == 3) {
      label = 'Good';
      color = Colors.lightGreen;
    } else {
      label = 'Strong';
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: fraction, color: color, backgroundColor: color.withOpacity(0.2)),
        const SizedBox(height: 6),
        Text('Strength: $label', style: TextStyle(color: color)),
      ],
    );
  }
}