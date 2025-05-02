import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smokevision_fyp/screens/Sign_In.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FormKey = GlobalKey<FormState>();  // Form key for validation
  bool ObScurePassword = true; // Toggle for hiding/showing password
  bool Agree_To_Terms = false; //Terms accept krna zarori ha

  final TextEditingController UsernameController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final TextEditingController ConfirmPasswordController = TextEditingController();

  bool _isLoading = false;

  //SignUp Logic

  Future<void> SignUp() async {
    if (!FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: EmailController.text.trim(),
        password: PasswordController.text.trim(),
      );

      // 2. Update user profile with display name
      await credential.user!.updateDisplayName(UsernameController.text.trim());

      // 3. Save additional data to Firestore
      await _saveUserDataToFirestore(credential.user!);

      // 4. Send verification email
      await credential.user!.sendEmailVerification();

      if (mounted) {

        AccountCreationSuccessPopup();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //How we save data into Firebase

  Future<void> _saveUserDataToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'username': UsernameController.text.trim(),
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Rollback auth creation if Firestore fails
      await user.delete();
      rethrow;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      default:
        message = 'Sign up failed: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleGenericError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }

  @override
  void dispose() {
    UsernameController.dispose();
    EmailController.dispose();
    PasswordController.dispose();
    ConfirmPasswordController.dispose();
    super.dispose();
  }

  void AccountCreationSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFF535CE8)),
            const SizedBox(height: 16),
            const Text("Success",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Your account has been successfully registered"
                "Check your inbox and Verify your Email Address",
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF535CE8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child:
                  const Text("Sign In", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm2() {
    if (FormKey.currentState!.validate() && Agree_To_Terms) {
      //_showSuccessPopup();
      SignUp();
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
                    key: FormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          "\nWelcome",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: "Archivo",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Archivo",
                            color: Color(0xFF9095A0),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Username Field
                        SignUpInputLabelBuilder("Username"),
                        const SizedBox(height: 8),
                        SignUpTextFieldBuilder(
                          hintText: "Enter Username",
                          prefixIcon: Icons.person_2_outlined,
                          controller: UsernameController,
                          validator: validateUsername,
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        SignUpInputLabelBuilder("Email"),
                        const SizedBox(height: 8),
                        SignUpTextFieldBuilder(
                          hintText: "Enter email",
                          prefixIcon: Icons.email_outlined,
                          controller: EmailController,
                          validator: validateEmail,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        SignUpInputLabelBuilder("Password"),
                        const SizedBox(height: 8),
                        SignUpPasswordFieldBuilder(),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        SignUpInputLabelBuilder("Confirm Password"),
                        const SizedBox(height: 8),
                        SignUpTextFieldBuilder(
                          hintText: "Confirm password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: ConfirmPasswordController,
                          validator: (value) => validateConfirmPassword(
                              value, PasswordController.text),
                        ),

                        const SizedBox(height: 16),

                        // Terms & Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: Agree_To_Terms,
                              onChanged: (bool? value) {
                                setState(() {
                                  Agree_To_Terms = value ?? false;
                                });
                              },
                            ),
                            const Text("I agree to the ",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Inter",
                                    color: Colors.black)),
                            GestureDetector(
                              onTap: () => _showTermsAndConditions(context),
                              child: const Text("Terms & Conditions",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Inter",
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Sign Up Button
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm2,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF636AE8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Sign Up",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),


                      /*
                        // Log in As Guest Button
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MainAppWrapperGuest()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF636AE8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text("Log in as guest",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ),


                       */



                        const SizedBox(height: 24), // Fixed spacing

                        // OR CONTINUE WITH
                        /*
                        const Center(
                          child: Text(
                            "OR CONTINUE WITH",
                            style: TextStyle(
                                color: Color(0xFF6E7787),
                                fontSize: 12, // Fixed font size
                                fontFamily: "Inter",
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16), // Fixed spacing

                        // Social Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHoverIcon("assets/icons/google1.svg"),
                            const SizedBox(width: 16), // Fixed spacing
                            _buildHoverIcon("assets/icons/facebook1.svg"),
                            const SizedBox(width: 16), // Fixed spacing
                            _buildHoverIcon("assets/icons/apple.svg"),
                          ],
                        ),

                         */
                        const SizedBox(height: 24),

                        // Already have an account? Sign in
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? ",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Inter",
                                    color: Color(0xFF171A1F))),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInPage()),
                                  );
                                },
                                child: const Text("Sign In",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Inter",
                                        color: Color(0xFF636AE8),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
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

  // Function to create an input label
  Widget SignUpInputLabelBuilder(String label) {
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

  // Function to create a text field
  Widget SignUpTextFieldBuilder({
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? ObScurePassword : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
        filled: true,
        fillColor: const Color(0xFFE9ECEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF343A40)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    ObScurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF343A40)),
                onPressed: () =>
                    setState(() => ObScurePassword = !ObScurePassword),
              )
            : null,
      ),
      validator: validator,
    );
  }

  // Function to create password field
  Widget SignUpPasswordFieldBuilder() {
    return SignUpTextFieldBuilder(
      hintText: "Enter password",
      prefixIcon: Icons.lock_outline,
      isPassword: true,
      controller: PasswordController,
      validator: validatePassword,
    );
  }
  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers and underscores';
    }
    return null;
  }
  // Email validation method
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

  // Password validation method
  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Include letters and numbers';
    }
    return null;
  }

  // Confirm password validation method
  String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Show Terms & Conditions dialog
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: "1. Data Usage\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "We collect and store data to improve your experience. Your data will not be shared without your consent.\n\n",
                ),
                TextSpan(
                  text: "2. Account Security\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "You are responsible for maintaining the confidentiality of your account credentials.\n\n",
                ),
                TextSpan(
                  text: "3. Prohibited Activities\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Unauthorized access, spamming, or other misuse is prohibited.\n\n",
                ),
                TextSpan(
                  text: "4. Termination\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "We reserve the right to suspend or terminate your account for violations of these terms.\n\n",
                ),
                TextSpan(
                  text: "5. User Responsibilities\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Users must provide accurate information and update it as necessary.\n\n",
                ),
                TextSpan(
                  text: "6. Intellectual Property\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "All content within the app is the property of the company. Unauthorized reproduction is prohibited.\n\n",
                ),
                TextSpan(
                  text: "7. Updates\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "We may update these policies. Continued use of the app means you accept the changes.\n",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Function to create a hoverable social icon
  Widget _buildHoverIcon(String assetPath) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: SvgPicture.asset(assetPath, width: 32, height: 32),
      ),
    );
  }
}
