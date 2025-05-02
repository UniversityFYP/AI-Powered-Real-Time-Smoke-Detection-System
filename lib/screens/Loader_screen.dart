import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smokevision_fyp/screens/Sign_In.dart';

class LoaderPage extends StatefulWidget {
  const LoaderPage({super.key});

  @override
  _LoaderPageState createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to Sign In Page after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/logo.png',
              height: 300,
            ),
            const SizedBox(height: 40),

            // Loading Indicator
            SpinKitFadingCircle(
              color: Colors.cyan.withOpacity(0.5),
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
