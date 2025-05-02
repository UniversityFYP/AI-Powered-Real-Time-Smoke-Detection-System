import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smokevision_fyp/screens/about.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variables to hold the data
  int totalDetections = 0;
  int blackSmokeCount = 0;
  int graySmokeCount = 0;
  int whiteSmokeCount = 0;
  int blueSmokeCount = 0;
  List<double> blackSmokeLast7Days = List.filled(7, 0.0);
  List<double> graySmokeLast7Days = List.filled(7, 0.0);
  List<double> whiteSmokeLast7Days = List.filled(7, 0.0);
  List<double> blueSmokeLast7Days = List.filled(7, 0.0);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  // Fetch data from Firestore
  Future<void> fetchDataFromFirestore() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('detections').get();

      // Get current date and calculate the date 7 days ago
      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Reset counts and lists
      totalDetections = snapshot.docs.length;
      blackSmokeCount = 0;
      graySmokeCount = 0;
      whiteSmokeCount = 0;
      blueSmokeCount = 0;
      blackSmokeLast7Days = List.filled(7, 0.0);
      graySmokeLast7Days = List.filled(7, 0.0);
      whiteSmokeLast7Days = List.filled(7, 0.0);
      blueSmokeLast7Days = List.filled(7, 0.0);

      // Process each document
      for (var doc in snapshot.docs) {
        String smokeType = doc['smokeType'];
        Timestamp timestamp = doc['timestamp'];
        DateTime detectionDate = timestamp.toDate();

        // Count smoke types
        switch (smokeType.toLowerCase()) {
          case 'black smoke':
            blackSmokeCount++;
            break;
          case 'gray smoke':
            graySmokeCount++;
            break;
          case 'white smoke':
            whiteSmokeCount++;
            break;
          case 'blue smoke':
            blueSmokeCount++;
            break;
        }

        // If the detection is within the last 7 days, add it to the chart data
        if (detectionDate.isAfter(sevenDaysAgo)) {
          int dayIndex = now.difference(detectionDate).inDays;
          if (dayIndex >= 0 && dayIndex < 7) {
            switch (smokeType.toLowerCase()) {
              case 'black smoke':
                blackSmokeLast7Days[dayIndex]++;
                break;
              case 'gray smoke':
                graySmokeLast7Days[dayIndex]++;
                break;
              case 'white smoke':
                whiteSmokeLast7Days[dayIndex]++;
                break;
              case 'blue smoke':
                blueSmokeLast7Days[dayIndex]++;
                break;
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              print("Profile button pressed");
                            },
                            borderRadius: BorderRadius.circular(21),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFF535CE8),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: Color.fromARGB(255, 245, 244, 244),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Blog Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Protect what matters most with AI-powered Vehicle Smoke Detection System that’s faster and more reliable than traditional alarms. Our advanced technology uses real-time image analysis to detect smoke and potential fire hazards early, giving you critical time to react.",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Inter",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AboutAppPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF535CE8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Learn more",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Smoke Detection Stats Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: [
                      _buildSmokeDetectionCard(
                        "Total Detections",
                        totalDetections.toString(),
                        const Color(0xFF535CE8),
                        "assets/Icons/Total.svg",
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildResponsiveSmokeDetectionCard(
                            "Black Smoke",
                            blackSmokeCount.toString(),
                            Colors.black,
                            "assets/Icons/Smoke.svg",
                          ),
                          _buildResponsiveSmokeDetectionCard(
                            "Gray Smoke",
                            graySmokeCount.toString(),
                            const Color(0xFFD7DAD8),
                            "assets/Icons/Smoke.svg",
                          ),
                          _buildResponsiveSmokeDetectionCard(
                            "White Smoke",
                            whiteSmokeCount.toString(),
                            const Color(0xFFEEEFEE),
                            "assets/Icons/Smoke.svg",
                          ),
                          _buildResponsiveSmokeDetectionCard(
                            "Blue Smoke",
                            blueSmokeCount.toString(),
                            const Color(0xFF2acccf),
                            "assets/Icons/Smoke.svg",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Chart Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last 7 Days Detection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildLegend("Black", Colors.black),
                            const SizedBox(width: 12),
                            _buildLegend("White",
                                const Color.fromARGB(255, 255, 255, 255)),
                            const SizedBox(width: 12),
                            _buildLegend("Grey", const Color(0xFFD7DAD8)),
                            const SizedBox(width: 12),
                            _buildLegend("Blue", const Color(0xFF2acccf)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 180,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(
                                      color: Colors.black, width: 2),
                                  bottom: BorderSide(
                                      color: Colors.black, width: 2),
                                ),
                              ),
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: 8,
                              lineBarsData: [
                                _buildLineChartBarData(
                                    blackSmokeLast7Days, Colors.black),
                                _buildLineChartBarData(
                                    whiteSmokeLast7Days,
                                    const Color.fromARGB(
                                        255, 255, 255, 255)),
                                _buildLineChartBarData(
                                    graySmokeLast7Days,
                                    const Color(0xFFD7DAD8)),
                                _buildLineChartBarData(
                                    blueSmokeLast7Days,
                                    const Color(0xFF2acccf)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> values, Color color) {
    return LineChartBarData(
      spots: values
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      barWidth: 3,
    );
  }

  Widget _buildSmokeDetectionCard(
      String title, String count, Color color, String iconPath) {
    return Container(
      width: double.infinity,
      height: 90,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        count,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveSmokeDetectionCard(
      String title, String count, Color color, String iconPath) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 400
            ? (constraints.maxWidth - 10) / 2
            : constraints.maxWidth;
        return Container(
          width: cardWidth,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Archivo",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count,
                            style: const TextStyle(
                              fontSize: 22,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            iconPath,
                            width: 30,
                            height: 30,
                            colorFilter:
                            ColorFilter.mode(color, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}