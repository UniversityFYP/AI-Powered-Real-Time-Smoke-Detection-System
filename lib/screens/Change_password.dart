import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../MainAppWrapper.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _CreateNewPasswordPageState createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _oldPasswordError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  bool _isLoading = false;

  void _toggleOldPasswordVisibility() {
    setState(() {
      _isOldPasswordVisible = !_isOldPasswordVisible;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> ChangePassword() async {
    final oldPassword = _oldPasswordController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _oldPasswordError = oldPassword.isEmpty ? "Old password is required" : '';
      _passwordError = _validatePassword(password);
      _confirmPasswordError =
          _validateConfirmPassword(password, confirmPassword);
    });

    if (_oldPasswordError.isEmpty &&
        _passwordError.isEmpty &&
        _confirmPasswordError.isEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // First reauthenticate with the old password
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: oldPassword,
          );
          await user.reauthenticateWithCredential(cred);

          // Then update the password
          await user.updatePassword(password);
          _showSuccessPopup();
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Error changing password';
        if (e.code == 'wrong-password') {
          errorMessage = 'The old password you entered is incorrect.';
          setState(() {
            _oldPasswordError = errorMessage;
          });
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
          setState(() {
            _passwordError = errorMessage;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter";
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return "Password must contain at least one lowercase letter";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one number";
    }
    return '';
  }

  String _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return "Confirm password is required";
    }
    if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return '';
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFF535CE8)),
            const SizedBox(height: 16),
            const Text(
              "Success",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your password has been successfully changed!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
                /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainAppWrapper()),
                );

                 */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF535CE8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget PasswordFieldBuilder(
      String label,
      String hintText,
      TextEditingController controller,
      bool isVisible,
      VoidCallback toggleVisibility,
      String error, {
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "Inter",
            color: Color(0xFF171A1F),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
            filled: true,
            fillColor: const Color(0xFFE9ECEF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14.0 : 16.0,
              horizontal: 16.0,
            ),
            prefixIcon:
            const Icon(Icons.lock_outline, color: Color(0xFF343A40)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF343A40),
              ),
              onPressed: toggleVisibility,
            ),
            errorText: error.isNotEmpty ? error : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
              vertical: 16.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenSize.width * 0.95 : 600.0,
                  minHeight: screenSize.height * 0.9,
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


                  padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50,),
                      Row(
                        children: [
                          IconButton(
                            iconSize: isSmallScreen ? 28.0 : 32.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 13,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Create New Password",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18.0 : 24.0,
                                    fontFamily: "Archivo",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Create new password to log in",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    color: Color(0xFF9095A0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      PasswordFieldBuilder(
                        "Old Password",
                        "Enter old password",
                        _oldPasswordController,
                        _isOldPasswordVisible,
                        _toggleOldPasswordVisibility,
                        _oldPasswordError,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      PasswordFieldBuilder(
                        "New Password",
                        "Enter new password",
                        _passwordController,
                        _isPasswordVisible,
                        _togglePasswordVisibility,
                        _passwordError,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      PasswordFieldBuilder(
                        "Confirm New Password",
                        "Confirm new password",
                        _confirmPasswordController,
                        _isConfirmPasswordVisible,
                        _toggleConfirmPasswordVisibility,
                        _confirmPasswordError,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : ChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF636AE8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14.0 : 16.0,
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16.0 : 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}