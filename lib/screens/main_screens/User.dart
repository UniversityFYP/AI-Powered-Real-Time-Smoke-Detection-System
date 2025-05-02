import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smokevision_fyp/screens/Sign_In.dart';
import 'package:smokevision_fyp/screens/Change_password.dart';
import '../Change_username.dart';
class UserPage extends StatefulWidget {
  const UserPage({super.key});


  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<void> SignOut_ToSignIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
        ),
      );
    }
  }
// Delete Acccount Logic
  /*
  Future<void> DeleteUserAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. First delete Firestore data
        await _deleteUserData(user.uid);

        // 3. Navigate to login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
              (route) => false,
        );
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account and all data deleted')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error deleting account';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Please reauthenticate before deleting your account.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  //Delete UserData
  Future<void> _deleteUserData(String userId) async {
    try {
      // Reference to the user's document
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // First check if document exists
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // Delete only the user's document
        await userDocRef.delete();
        debugPrint('User document deleted successfully');
      } else {
        debugPrint('No user document found to delete');
      }

    } catch (e) {
      debugPrint('Error deleting user data: $e');
      // Continue with auth deletion even if Firestore fails
    }
  }


  void AccountDeletionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Archivo',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF9095A0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DeleteUserAccount(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
*/

  Widget BuildListTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 25 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF636AE8)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 14,
              horizontal: 16,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: isTablet ? 24 : 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontFamily: 'Archivo',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171A1F),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isTablet ? 56 : 48,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            : null,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get username with fallbacks
          final username = snapshot.hasData
              ? snapshot.data!['username'] ?? user?.displayName ?? 'Guest'
              : user?.displayName ?? 'Guest';

          return Column(
            children: [
              SizedBox(height: isTablet ? 20 : 16),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 24 : 20,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          CircleAvatar(
                            radius: isTablet ? 48 : 40,
                            backgroundColor: const Color(0xFFE5E7EB),
                            child: Icon(
                              Icons.person,
                              size: isTablet ? 48 : 40,
                              color: const Color(0xFF9095A0),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontFamily: 'Archivo',
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF171A1F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              user?.email ?? 'guest@smokevision.com',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9095A0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                          BuildListTile(
                            context: context,
                            title: 'Change Username',
                            icon: Icons.person_2_outlined,
                            color: Colors.white, // Text color is now handled by the button
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangeUserNamePage()),
                            ),
                          ),
                          BuildListTile(
                            context: context,
                            title: 'Change Password',
                            icon: Icons.lock_reset,
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangePasswordPage()),
                            ),
                          ),
                          BuildListTile(
                            context: context,
                            title: 'Log out',
                            icon: Icons.logout,
                            color: Colors.white,
                            onTap: () => SignOut_ToSignIn(context),
                          ),
                          SizedBox(height: mediaQuery.padding.bottom + 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}