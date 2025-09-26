import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:learningdart/firebase_options.dart';
import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/auth_user.dart';


class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw Exception('User creation failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password' || e.code == 'auth/weak-password') {
        throw Exception('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use' || e.code == 'auth/email-already-in-use') {
          throw Exception('The account already exists for that email.');
        } else {
          throw Exception('Authentication error: ${e.code}');
        }
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  @override
  
  AuthUser? get currentUser{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
      }else{
        return null;
      }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password
    }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw Exception('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'auth/user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password' || e.code == 'auth/wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else {
        throw Exception('Authentication failed: ${e.code}');
      }
    } catch (e) {
      throw Exception('Unexpected error during sign in: $e');
    }
    
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw Exception('No user logged in');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await user.sendEmailVerification();
    }else{
      throw Exception('No user logged in');
    }
    
  }
  
  @override
  Future<void> initialize() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      );
  }   

}