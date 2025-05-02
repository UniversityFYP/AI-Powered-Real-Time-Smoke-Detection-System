import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smokevision_fyp/screens/Forget_password.dart';
import 'package:smokevision_fyp/screens/Sign_Up.dart';

import '../MainAppWrapper.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true; // Toggle for hiding/showing password

  final FormKey = GlobalKey<FormState>(); // Form key for validation

  final TextEditingController EmailController = TextEditingController(); // Controller for email field
  final TextEditingController PasswordController = TextEditingController();
  final TextEditingController IpController = TextEditingController();
  final TextEditingController PortController = TextEditingController(text: '8000');

  bool _isLoading = false;



  Future<void> SignIn() async {
    if (!FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: EmailController.text.trim(),
        password: PasswordController.text.trim(),
      );

      if (mounted) {
        final  ip = IpController.text.trim();
        final port = PortController.text.trim();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  MainAppWrapper(Ip: ip,Port: port,)),
        );
      }
    } on FirebaseAuthException catch (e) {
      AuthErrorHandler(e);
    } catch (e) {
      GenericErrorHandler(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //Handle Auth Errors

  void AuthErrorHandler(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Try again later';
        break;
      default:
        message = 'Login failed: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  //Generic Error Handler
  void GenericErrorHandler(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }


  @override
  void dispose() {
    EmailController.dispose();
    PasswordController.dispose();
    PortController.dispose();
    IpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust padding, container width, and height for mobile and larger screens
    final screenPadding =
        screenWidth < 600 ? 16.0 : 24.0; // Smaller padding for mobile
    final containerPadding =
        screenWidth < 600 ? 16.0 : 24.0; // Smaller padding for mobile
    final containerWidth = screenWidth < 600
        ? screenWidth * 0.9
        : 600.0; // Dynamic container width
    final containerHeight =
        screenHeight * 0.95; // Dynamic container height (70% of screen height)

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image with Transparency
          Opacity(
            opacity: 0.2, // Adjust transparency (0.0 to 1.0)
            child: Container(
              decoration: const BoxDecoration(),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(screenPadding), // Responsive screen padding
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: containerWidth, // Dynamic container width
                  minHeight: containerHeight, // Dynamic container height
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    borderRadius: BorderRadius.circular(16), // XL border radius
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.1), // Drop shadow (XS)
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(
                      containerPadding), // Responsive container padding
                  child: Form(
                    key: FormKey, // Assign the form key
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Space between top and bottom
                      children: [
                        // Top Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              "\nHi!",
                              style: TextStyle(
                                fontSize: 32, // Fixed font size
                                fontFamily: "Archivo",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4), // Fixed spacing
                            const Text(
                              "Welcome back",
                              style: TextStyle(
                                fontSize: 20, // Fixed font size
                                fontFamily: "Archivo",
                                color: Color(0xFF9095A0),
                              ),
                            ),

                            const SizedBox(height: 24), // Fixed spacing

                            // Email Field
                            InputLabelBuilder("Email"),
                            const SizedBox(height: 8), // Fixed spacing
                            SignInTextFieldBuilder(
                              hintText: "Enter email",
                              prefixIcon: Icons.email_outlined,
                              controller: EmailController,
                              validator: validateEmail, // Add email validation
                            ),


                            const SizedBox(height: 16), // Fixed spacing

                            // Password Field
                            InputLabelBuilder("Password"),
                            const SizedBox(height: 8), // Fixed spacing
                            SignInPasswordBuilder(),

                            const SizedBox(height: 16),

                            InputLabelBuilder("IP Address"),

                            const SizedBox(height: 8),

                            NetworkTextFieldBuilder(
                              hintText: "Enter your local Ip address",
                              prefixIcon: Icons.signal_cellular_connected_no_internet_4_bar_sharp,
                              controller: IpController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an IP address';
                                  }
                                  if (!_isValidIpAddress(value)) {
                                    return 'Please enter a valid IPv4 address';
                                  }
                                  return null;
                                }, // Add email validation
                            ),

                            const SizedBox(height: 16),

                            InputLabelBuilder("Port No."),

                            const SizedBox(height: 8),

                            NetworkTextFieldBuilder(
                              hintText: "Enter Port Number:8000",
                              prefixIcon: Icons.connect_without_contact_outlined,
                              controller: PortController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a port number';
                                }
                                final port = int.tryParse(value);
                                if (port == null || port < 1 || port > 65535) {
                                  return 'Please enter a valid port (1-65535)';
                                }
                                return null;
                              }, // Add email validation
                            ),


                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPasswordPage()),
                                  );
                                },
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      color: Color(0xFF676EE8),
                                      fontSize: 14, // Fixed font size
                                      fontFamily: "Inter"),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16), // Fixed spacing

                            // Sign In Button
                            Center(
                              child: SizedBox(
                                width: double
                                    .infinity, // Full width within maxWidth constraint
                                child: ElevatedButton(
                                  onPressed:  _isLoading ? null : SignIn,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF636AE8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                  :const Text(
                                    "Sign in",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24), // Fixed spacing

                            // OR CONTINUE WITH
                            //const Center(
                             // child: Text(
                              //  "OR CONTINUE WITH",
                               // style: TextStyle(
                                //    color: Color(0xFF6E7787),
                                //    fontSize: 12, // Fixed font size
                                //    fontFamily: "Inter",
                                 //   fontWeight: FontWeight.bold),
                             // ),
                           // ),

                           // const SizedBox(height: 16), // Fixed spacing

                            // Social Icons
                           // Row(
                             // mainAxisAlignment: MainAxisAlignment.center,
                             // children: [
                              //  _buildHoverIcon("assets/icons/google1.svg"),
                              //  const SizedBox(width: 16), // Fixed spacing
                              //  _buildHoverIcon("assets/icons/facebook1.svg"),
                             //   const SizedBox(width: 16), // Fixed spacing
                             //   _buildHoverIcon("assets/icons/apple.svg"),
                             // ],
                           // ),
                          ],
                        ),

                        // Bottom Section: "Don't have an account?"
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                    fontSize: 14, // Fixed font size
                                    fontFamily: "Inter",
                                    color: Color(0xFF171A1F)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontSize: 14, // Fixed font size
                                      fontFamily: "Inter",
                                      color: Color(0xFF636AE8),
                                      fontWeight: FontWeight.bold),
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

  // Function to create an input label
  Widget InputLabelBuilder(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16, // Fixed font size
        fontFamily: "Inter",
        color: Color(0xFF3A3D46),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Function to create a text field
  Widget SignInTextFieldBuilder({
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
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF343A40)),

      ),
    );
  }




  Widget NetworkTextFieldBuilder({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.number,
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

      ),
    );
  }


  // Function to create password field
  Widget SignInPasswordBuilder() {
    return TextField(
      controller: PasswordController ,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Enter password",
        hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
        filled: true,
        fillColor: const Color(0xFFE9ECEF),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF343A40)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF343A40)),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
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

  //Network validator
  bool _isValidIpAddress(String value) {
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(value.trim());
  }

}
//Network Validator

