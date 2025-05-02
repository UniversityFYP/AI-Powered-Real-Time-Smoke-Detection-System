import 'package:flutter/material.dart';
import 'package:smokevision_fyp/screens/Sign_In.dart';
import 'package:smokevision_fyp/screens/Sign_Up.dart';

class ResetPasswordStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final String email;

  const ResetPasswordStatusScreen({
    super.key,
    required this.isSuccess,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess
                    ? 'Password Reset Link Sent!'
                    : 'Email Not Found',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess
                    ? 'We\'ve sent a password reset link to $email. Please check your inbox.'
                    : 'We don\'t have an account with this email address. Please sign up.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => isSuccess
                            ? const SignInPage()
                            : const SignUpPage(),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF636AE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    isSuccess ? 'Back to Sign In' : 'Go to Sign Up',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}