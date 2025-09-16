import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as devtools show log;
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => __VerifyEmailViewState();
}

class __VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _timer;
  bool _canPress = false;
  bool _isSending = false;
  bool _isSigningOut = false;
  int _secondsLeft = 10;
  @override
  void initState() {
    super.initState();
    // Start a 10 second countdown; enable the button when it reaches 0
    _canPress = false;
    _secondsLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft -= 1;
        } else {
          _secondsLeft = 0;
          _canPress = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined, size: 56, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'Verify your email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A verification email has been sent to',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(email, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _canPress
                        ? 'Didn\'t receive it? You can resend now.'
                        : 'You can resend the email in $_secondsLeft second${_secondsLeft == 1 ? '' : 's'}.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!_canPress || _isSending)
                          ? null
                          : () async {
                              setState(() {
                                _isSending = true;
                              });
                              try {
                                final u = FirebaseAuth.instance.currentUser;
                                await u?.sendEmailVerification();
                                devtools.log('Email verification sent');
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Verification email sent')),
                                );
                                // After sending, disable button again for a short cooldown
                                setState(() {
                                  _isSending = false;
                                  _canPress = false;
                                  _secondsLeft = 10;
                                });
                                _timer?.cancel();
                                _timer = Timer.periodic(const Duration(seconds: 1), (t) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (_secondsLeft > 1) {
                                      _secondsLeft -= 1;
                                    } else {
                                      _secondsLeft = 0;
                                      _canPress = true;
                                      t.cancel();
                                    }
                                  });
                                });
                              } catch (e) {
                                devtools.log('Failed to send verification: $e');
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to send: $e')),
                                );
                                setState(() {
                                  _isSending = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isSending
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Text('Sending...'),
                              ],
                            )
                          : Text(_canPress ? 'Resend verification email' : 'Send verification ($_secondsLeft)s'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSigningOut
                          ? null
                          : () async {
                              setState(() {
                                _isSigningOut = true;
                              });
                              try {
                                await FirebaseAuth.instance.signOut();
                                if (!mounted) return;
                                Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route) => false);
                              } catch (e) {
                                devtools.log('Sign out failed: $e');
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to sign out: $e')),
                                );
                                setState(() {
                                  _isSigningOut = false;
                                });
                              }
                            },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isSigningOut
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Restart (Sign out)'),
                    ),
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