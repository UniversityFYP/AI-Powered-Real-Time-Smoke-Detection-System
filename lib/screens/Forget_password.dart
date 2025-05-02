import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smokevision_fyp/screens/Reset_password_status.dart';
import 'package:smokevision_fyp/screens/Sign_Up.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordStatusScreen(
              isSuccess: true,
              email: email,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordStatusScreen(
              isSuccess: false,
              email: email,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getErrorMessage(e))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Error: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenPadding = screenWidth < 600 ? 16.0 : 24.0;
    final containerPadding = screenWidth < 600 ? 16.0 : 24.0;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.95 : 600.0;
    final containerHeight = screenHeight * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image with Transparency
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(screenPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: containerWidth,
                  minHeight: containerHeight,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(containerPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "\nForget Password!",
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: "Archivo",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Enter your Email, we will send you \nconfirmation about your email and\n password reset link",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Archivo",
                                color: Color(0xFF9095A0),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInputLabel("Email"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hintText: "Enter email",
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF636AE8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                      color: Colors.white)
                                      : const Text(
                                    "Request For Password Reset",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Inter",
                                  color: Color(0xFF171A1F),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Inter",
                                    color: Color(0xFF636AE8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: "Inter",
        color: Color(0xFF3A3D46),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
        filled: true,
        fillColor: const Color(0xFFE9ECEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF343A40)),
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}