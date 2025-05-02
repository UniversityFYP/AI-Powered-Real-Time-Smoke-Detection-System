import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smokevision_fyp/screens/main_screens/dashboard_screen.dart';
import 'package:smokevision_fyp/screens/main_screens/Diagnosis.dart';
import 'package:smokevision_fyp/screens/main_screens/Histroy.dart';
import 'package:smokevision_fyp/screens/main_screens/Live.dart';
import 'package:smokevision_fyp/screens/main_screens/Statistics.dart';
import 'package:smokevision_fyp/screens/main_screens/Upload.dart';
import 'package:smokevision_fyp/screens/main_screens/User.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String Ip;
  final String Port;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.Ip,
    required this.Port,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('live.svg', 'Live', 0),
          _buildNavItem('Diagnosis.svg', 'Diagnosis', 1),
          _buildNavItem('upload.svg', 'Upload', 2),
          _buildNavItem('Dashboard.svg', 'Dashboard', 3),
          _buildNavItem('Stat.svg', 'Statistics', 4),
          _buildNavItem('History.svg', 'History', 5),
          _buildNavItem('profile.svg', 'Profile', 6),
        ],
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, int index) {
    bool isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/Icons/$icon',
            width: 28,
            color: isActive
                ? const Color(0xFF8C91F0) // Active color
                : const Color.fromARGB(255, 86, 93, 109), // Default color
            semanticsLabel: label,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF8C91F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final String Ip;
  final String Port;

  const MainNavigationWrapper({
    super.key,
    required this.Ip,
    required this.Port,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 3;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LiveDetectionPage(IpAdress: widget.Ip, PortNo: widget.Port),
      const DiagnosisPage(),
      UploadPage(IpAdress: widget.Ip, PortNo: widget.Port), // no const
      const DashboardPage(),
      const StatisticsPage(),
      const HistoryPage(),
      UserPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        Ip: widget.Ip,
        Port: widget.Port,
      ),
    );
  }
}
