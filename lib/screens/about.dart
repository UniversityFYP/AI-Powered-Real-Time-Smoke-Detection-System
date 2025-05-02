import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with back button and centered title
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "About SmokeVision",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/app_hero.png',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Revolutionizing Vehicle Emission Monitoring",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Purpose Section
                const Text(
                  "Our Purpose",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Archivo",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Vehicle Smoke Detection System was born from a vision to create cleaner cities by identifying "
                  "and reducing vehicle pollution. Our AI-powered solution helps authorities "
                  "monitor Vehicle's emissions in real-time, promoting environmental awareness and "
                  "accountability.",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Inter",
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                // Features Section
                const Text(
                  "Key Features",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Archivo",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  "Real-time Detection",
                  "Identifies smoke types instantly using advanced computer vision with high accuracy",
                  Icons.flash_on,
                  const Color(0xFF5367FF),
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  "Detailed Analytics",
                  "Comprehensive reports and historical data visualization for better decision making",
                  Icons.analytics,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  "Vehicle Identification",
                  "Automatically captures license plates for enforcement by using OCR",
                  Icons.car_repair,
                  Colors.green,
                ),

                const SizedBox(height: 32),

                // Technology Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/Icons/ai.svg',
                              width: 28,
                              height: 28,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Powered by AI",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Archivo",
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Our proprietary AI models achieve industry-leading accuracy in "
                        "classifying smoke types, even in challenging weather conditions. The system "
                        "continuously improves through  deep learning and regular updates.",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Inter",
                          color: Color(0xFF4B5563),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Team Section
                const Text(
                  "Meet The Team",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Archivo",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 8), // Initial padding
                      TeamMemberBuilder("Muhammad Mehran Ul Zaman", "Group Leader",
                          "assets/images/Team1.jpg"),
                      const SizedBox(width: 16),
                      TeamMemberBuilder("Muhammad Raza", "Group Member",
                          "assets/images/Team2.jpg"),
                      const SizedBox(width: 16),
                      TeamMemberBuilder("Hannan Jahangir",
                          "Group Member", "assets/images/Team3.jpg"),
                      const SizedBox(width: 8), // End padding
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Call to Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5367FF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Join Our Mission",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000)
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Archivo",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget TeamMemberBuilder(String name, String role, String imagePath) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 140,
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Archivo",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
