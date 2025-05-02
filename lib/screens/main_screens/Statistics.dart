import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String? selectedSmokeType;
  DateTime? fromDate;
  DateTime? toDate;
  String selectedTimePeriod = 'Last 7 Days';
  late FirebaseFirestore firestore;
  List<Map<String, dynamic>> detectionData = [];

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    _fetchDetectionData();
  }

  Future<void> _fetchDetectionData() async {
    try {
      Query query = firestore.collection('detections')
          .orderBy('timestamp', descending: true);

      if (selectedSmokeType != null) {
        query = query.where('smokeType', isEqualTo: selectedSmokeType);
      }

      if (fromDate != null) {
        query = query.where('creationDate',
            isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(fromDate!));
      }

      if (toDate != null) {
        query = query.where('creationDate',
            isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(toDate!));
      }

      final snapshot = await query.get();
      setState(() {
        detectionData = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  List<PieChartSectionData> get doughnutData {
    final counts = {
      'Black Smoke': 0,
      'White Smoke': 0,
      'Gray Smoke': 0,
      'Blue Smoke': 0,
    };

    for (var detection in detectionData) {
      final type = detection['smokeType'] as String? ?? 'Unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }

    final total = detectionData.length;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.black,
        value: (counts['Black Smoke']! / total * 100),
        title: '${(counts['Black Smoke']! / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: (counts['Gray Smoke']! / total * 100),
        title: '${(counts['Gray Smoke']! / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.white,
        value: (counts['White Smoke']! / total * 100),
        title: '${(counts['White Smoke']! / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.blueAccent,
        value: (counts['Blue Smoke']! / total * 100),
        title: '${(counts['Blue Smoke']! / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Map<String, List<FlSpot>> get timePeriodData {
    final now = DateTime.now();
    final periodData = <FlSpot>[];

    if (detectionData.isEmpty) {
      return {
        'Last 7 Days': List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
        'Last 30 Days': List.generate(4, (i) => FlSpot(i.toDouble(), 0)),
        'Last 3 Months': List.generate(3, (i) => FlSpot(i.toDouble(), 0)),
        'Last 6 Months': List.generate(6, (i) => FlSpot(i.toDouble(), 0)),
      };
    }

    if (selectedTimePeriod == 'Last 7 Days') {
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final count = detectionData.where((detection) {
          try {
            final detectionDate = DateFormat('yyyy-MM-dd').parse(detection['creationDate'] as String);
            return detectionDate.year == date.year &&
                detectionDate.month == date.month &&
                detectionDate.day == date.day;
          } catch (e) {
            return false;
          }
        }).length;
        periodData.add(FlSpot(i.toDouble(), count.toDouble()));
      }
    } else if (selectedTimePeriod == 'Last 30 Days') {
      for (int i = 0; i < 4; i++) {
        final startDate = now.subtract(Duration(days: (i + 1) * 7));
        final endDate = now.subtract(Duration(days: i * 7));
        final count = detectionData.where((detection) {
          try {
            final detectionDate = DateFormat('yyyy-MM-dd').parse(detection['creationDate'] as String);
            return detectionDate.isAfter(startDate) &&
                detectionDate.isBefore(endDate);
          } catch (e) {
            return false;
          }
        }).length;
        periodData.add(FlSpot(i.toDouble(), count.toDouble()));
      }
    } else if (selectedTimePeriod == 'Last 3 Months') {
      for (int i = 0; i < 3; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 1);
        final count = detectionData.where((detection) {
          try {
            final detectionDate = DateFormat('yyyy-MM-dd').parse(detection['creationDate'] as String);
            return detectionDate.isAfter(monthStart) &&
                detectionDate.isBefore(monthEnd);
          } catch (e) {
            return false;
          }
        }).length;
        periodData.add(FlSpot(i.toDouble(), count.toDouble()));
      }
    } else { // Last 6 Months
      for (int i = 0; i < 6; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 1);
        final count = detectionData.where((detection) {
          try {
            final detectionDate = DateFormat('yyyy-MM-dd').parse(detection['creationDate'] as String);
            return detectionDate.isAfter(monthStart) &&
                detectionDate.isBefore(monthEnd);
          } catch (e) {
            return false;
          }
        }).length;
        periodData.add(FlSpot(i.toDouble(), count.toDouble()));
      }
    }

    return {selectedTimePeriod: periodData};
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
        _fetchDetectionData();
      });
    }
  }

  void _clearFilters() {
    if (mounted) {
      setState(() {
        selectedSmokeType = null;
        fromDate = null;
        toDate = null;
        _fetchDetectionData();
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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildChartsContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text(
            "Statistics",
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
                onTap: () => print("Save button pressed"),
                borderRadius: BorderRadius.circular(21),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 244, 244, 245),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.save_alt_outlined,
                    color: Color(0xFF535CE8),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => print("Profile button pressed"),
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
    );
  }



  Widget _buildChartsContainer() {
    return Container(
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
        children: [
          _buildDoughnutChart(),
          const SizedBox(height: 16),
          _buildTimeSeriesChart(),
        ],
      ),
    );
  }

  Widget _buildDoughnutChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Smoke Type Distribution",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.black, "Black"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.grey, "Grey"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.white, "White"),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.blueAccent, "Blue"),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: detectionData.isEmpty
                ? const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : PieChart(
              PieChartData(
                sections: doughnutData,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Detections Over Time",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: selectedTimePeriod,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTimePeriod = newValue!;
                  });
                },
                items: <String>[
                  'Last 7 Days',
                  'Last 30 Days',
                  'Last 3 Months',
                  'Last 6 Months'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                underline: Container(
                  height: 2,
                  color: const Color(0xFF6E75EC),
                ),
                style: const TextStyle(
                  color: Color(0xFF6E75EC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: selectedTimePeriod == 'Last 7 Days'
                    ? 6
                    : selectedTimePeriod == 'Last 30 Days'
                    ? 29
                    : selectedTimePeriod == 'Last 3 Months'
                    ? 90
                    : 180,
                minY: 0,
                maxY: detectionData.isEmpty
                    ? 10
                    : timePeriodData[selectedTimePeriod]!
                    .map((spot) => spot.y)
                    .reduce((a, b) => a > b ? a : b)
                    .ceilToDouble() +
                    2,
                lineBarsData: [
                  LineChartBarData(
                    spots: timePeriodData[selectedTimePeriod]!,
                    isCurved: true,
                    color: const Color(0xFF6E75EC),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF6E75EC).withOpacity(0.3),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = getXAxisLabels();
                        final interval = selectedTimePeriod == 'Last 7 Days'
                            ? 1
                            : selectedTimePeriod == 'Last 30 Days'
                            ? 7
                            : selectedTimePeriod == 'Last 3 Months'
                            ? 30
                            : 60;

                        if (value.toInt() % interval == 0) {
                          final index = (value.toInt() / interval)
                              .clamp(0, labels.length - 1)
                              .toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 20,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var type in [
                "Black Smoke",
                "White Smoke",
                "Gray Smoke",
                "Blue Smoke"
              ])
                ListTile(
                  title: Text(type),
                  onTap: () {
                    setState(() {
                      selectedSmokeType = type;
                      _fetchDetectionData();
                    });
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                title: const Text('Clear Filter'),
                onTap: () {
                  setState(() {
                    selectedSmokeType = null;
                    _fetchDetectionData();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == Colors.amber ? Border.all(color: Colors.grey) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  List<String> getXAxisLabels() {
    switch (selectedTimePeriod) {
      case 'Last 7 Days':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Last 30 Days':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'Last 3 Months':
        return ['Month 1', 'Month 2', 'Month 3'];
      case 'Last 6 Months':
        return ['Jan', 'Mar', 'May', 'Jul'];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }
}