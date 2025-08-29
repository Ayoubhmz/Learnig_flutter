import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
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
                  final userCredential = 
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                  );
                  print('User registered: $userCredential');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registered: ${userCredential.user?.email}')),
                  );
                } on FirebaseAuthException catch (e) {
                  print('FirebaseAuthException code: ${e.code}, message: ${e.message}');
                  if (e.code == 'weak-password' || e.code == 'auth/weak-password') {
                    const msg = 'The password provided is too weak.';
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(msg)));
                  } else if (e.code == 'email-already-in-use' || e.code == 'auth/email-already-in-use') {
                    const msg = 'The account already exists for that email.';
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(msg)));
                  } else {
                    final msg = 'Authentication error: ${e.code}';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (e) {
                  print('Exception: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
                  
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login/' , (route) => false);
                },
                child: const Text('Already registered? Login here!'),
              ),
            ],
          ),
    );
  }
}