// ignore_for_file: avoid_print, use_build_context_synchronously, dead_code


import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/notes_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verifyEmail_view.dart';
import 'dart:developer' as devtools show log;



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      //home: const RegisterView(),
      //home: const LoginView(),
      routes: {
        '/register/': (context) => const RegisterView(),
        '/login/': (context) => const LoginView(),
        '/verifyEmail/': (context) => const VerifyEmailView(),
        '/notes/': (context) => const NotesView(),
      },

    )
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user!= null) {
                if (user.isEmailVerified) {
                  devtools.log('User is logged in and email is verified');
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView(); 
              }           
            default:
              return const CircularProgressIndicator();
          }
        },  
      );
  }
}










