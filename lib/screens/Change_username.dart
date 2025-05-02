import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class ChangeUserNamePage extends StatefulWidget {
  const ChangeUserNamePage({super.key});

  @override
  _CreateNewUserNamePageState createState() => _CreateNewUserNamePageState();
}

class _CreateNewUserNamePageState extends State<ChangeUserNamePage> {
  final TextEditingController OldUsernameController = TextEditingController();
  final TextEditingController NewUsernameController = TextEditingController();


  String OldUsernameError = '';
  String UsernameError = '';

  bool _isLoading = false;


  Future<void> ChangeUsername() async {
    final oldUsername = OldUsernameController.text.trim();
    final newUsername = NewUsernameController.text.trim();

    setState(() {
      OldUsernameError = oldUsername.isEmpty ? "Old username is required" : '';
      UsernameError = ValidateUsername(newUsername);
    });

    if (OldUsernameError.isEmpty && UsernameError.isEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final snapshot = await userDocRef.get();

          if (snapshot.exists) {
            final data = snapshot.data();
            final currentUsername = data?['username'];

            if (currentUsername == oldUsername) {
              if (newUsername == oldUsername) {
                setState(() {
                  UsernameError = "New username must be different from the old one.";
                });
              } else {
                await userDocRef.update({'username': newUsername});
                _showSuccessPopup();
              }
            } else {
              setState(() {
                OldUsernameError = "Old username does not match your current username.";
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User document not found.")),
            );
          }
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


  String ValidateUsername(String username) {
    if (username.isEmpty) {
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
              "Your Username has been successfully changed!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
                /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainAppWrapperUpdateUser()),
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
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget TextFieldBuilder(
      String label,
      String hintText,
      TextEditingController controller,
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
                      const SizedBox(height: 100,),
                      Row(
                        children: [
                          IconButton(
                            iconSize: isSmallScreen ? 28.0 : 32.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12,height: 100,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Username",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18.0 : 24.0,
                                    fontFamily: "Archivo",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Create new Username for your Account",
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
                      const SizedBox(height: 10),
                      TextFieldBuilder(
                        "Old Username",
                        "Enter old Username",
                        OldUsernameController,
                        OldUsernameError,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 20),
                      TextFieldBuilder(
                        "New Username",
                        "Enter new Username",
                        NewUsernameController,
                        UsernameError,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : ChangeUsername,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF636AE8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25 ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14.0 : 16.0,
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Change Username",
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
    OldUsernameController.dispose();
    NewUsernameController.dispose();
    super.dispose();
  }
}