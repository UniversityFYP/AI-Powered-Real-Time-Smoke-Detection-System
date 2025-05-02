import 'package:flutter/material.dart';

class DiagnosisPage extends StatelessWidget {
  const DiagnosisPage({super.key});

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
                const SizedBox(height: 24),
                Vehicle_Smoke_TypeCard_Builder(
                  context,
                  'Black Smoke',
                  Icons.warning_amber_rounded,
                  Colors.orange,
                  'Indicates incomplete combustion, possibly due to:',
                  [
                    '• Clogged air filters',
                    '• Faulty fuel injectors',
                    '• Excessive fuel in combustion chamber',
                    '• Poor quality fuel'
                  ],
                ),
                const SizedBox(height: 16),
                Vehicle_Smoke_TypeCard_Builder(
                  context,
                  'White Smoke',
                  Icons.water_drop_rounded,
                  Colors.blue,
                  'Often caused by coolant/water entering combustion:',
                  [
                    '• Blown head gasket',
                    '• Cracked engine block',
                    '• Faulty cylinder head',
                    '• Cold weather condensation'
                  ],
                ),
                const SizedBox(height: 16),
                Vehicle_Smoke_TypeCard_Builder(
                  context,
                  'Blue Smoke',
                  Icons.oil_barrel,
                  Colors.indigo,
                  'Sign of oil burning in combustion chamber:',
                  [
                    '• Worn piston rings',
                    '• Faulty valve seals',
                    '• Turbocharger issues',
                    '• Overfilled engine oil'
                  ],
                ),
                const SizedBox(height: 16),
                Vehicle_Smoke_TypeCard_Builder(
                  context,
                  'Gray Smoke',
                  Icons.gradient_rounded,
                  Colors.grey,
                  'May suggest transmission fluid burning:',
                  [
                    '• Transmission fluid leakage',
                    '• Faulty PCV valve',
                    '• Turbocharger problems',
                    '• Incorrect fuel mixture'
                  ],
                ),
                const SizedBox(height: 24),
                DiagnosisGuidelinesCardBuilder(),
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
            "Diagnosis",
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
    );
  }

  Widget Vehicle_Smoke_TypeCard_Builder(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    List<String> causes,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Archivo",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Inter",
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: causes
                  .map((cause) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          cause,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget DiagnosisGuidelinesCardBuilder() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Diagnosis Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Archivo",
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            GuidLineItemBuilder('1. Regular Maintenance', Icons.build_circle),
            GuidLineItemBuilder(
                '2. Monitor Warning Lights', Icons.warning_amber),
            GuidLineItemBuilder(
                '3. Professional Diagnostics', Icons.engineering),
          ],
        ),
      ),
    );
  }

  Widget GuidLineItemBuilder(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
