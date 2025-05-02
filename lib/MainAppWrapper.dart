import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:smokevision_fyp/screens/main_screens/dashboard_screen.dart';
import 'package:smokevision_fyp/screens/main_screens/Diagnosis.dart';
import 'package:smokevision_fyp/screens/main_screens/Histroy.dart';
import 'package:smokevision_fyp/screens/main_screens/Live.dart';
import 'package:smokevision_fyp/screens/main_screens/Statistics.dart';
import 'package:smokevision_fyp/screens/main_screens/Upload.dart';
import 'package:smokevision_fyp/screens/main_screens/User.dart';
import 'package:smokevision_fyp/screens/nav_bar/custom_navbar.dart';

class MainAppWrapper extends StatefulWidget {
  final String Ip;
  final String Port;


  const MainAppWrapper({super.key,required this.Ip, required this.Port});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  int _currentIndex = 3; // Start with Dashboard (index 3)

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      LiveDetectionPage(IpAdress: widget.Ip, PortNo: widget.Port), // Index 0
      const DiagnosisPage(),
      UploadPage(IpAdress: widget.Ip, PortNo: widget.Port), // Index 2
      const DashboardPage(), // Index 3
      const StatisticsPage(),
      const HistoryPage(), // Index 5
      const UserPage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        Ip: widget.Ip,Port: widget.Port,
      ),
    );
  }
}