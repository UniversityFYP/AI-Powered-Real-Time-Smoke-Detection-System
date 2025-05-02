import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? selectedSmokeType;
  DateTime? fromDate;
  DateTime? toDate;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
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
          toDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    if (mounted) {
      setState(() {
        selectedSmokeType = null;
        fromDate = null;
        toDate = null;
      });
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
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
                const SizedBox(height: 18),
                _buildFiltersContainer(),
                const SizedBox(height: 20),
                _buildHistoryList(),
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
            "History",
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

  Widget _buildFiltersContainer() {
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: _showTypeSelectionModal,
                  icon: const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Color(0xFF6E75EC),
                    size: 20,
                  ),
                  label: Text(
                    selectedSmokeType ?? "Select Type",
                    style: const TextStyle(
                      color: Color(0xFF6E75EC),
                      fontSize: 10,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E75EC),
                    side: const BorderSide(color: Color(0xFF6E75EC)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF6E75EC),
                    size: 16,
                  ),
                  label: Text(
                    fromDate != null
                        ? formatDate(fromDate!, [yyyy, '-', mm, '-', dd])
                        : "From",
                    style: const TextStyle(
                      color: Color(0xFF6E75EC),
                      fontSize: 10,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E75EC),
                    side: const BorderSide(color: Color(0xFF6E75EC)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context, false),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF6E75EC),
                    size: 16,
                  ),
                  label: Text(
                    toDate != null
                        ? formatDate(toDate!, [yyyy, '-', mm, '-', dd])
                        : "To",
                    style: const TextStyle(
                      color: Color(0xFF6E75EC),
                      fontSize: 10,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E75EC),
                    side: const BorderSide(color: Color(0xFF6E75EC)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 244, 244, 245),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6E75EC)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_outlined,
                    color: Color(0xFF6E75EC),
                    size: 20,
                  ),
                  onPressed: _clearFilters,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredDetections(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Violations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${docs.length} records",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildHistoryCard(data);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    final vehicleNo = data['numberPlate'] as String? ?? 'N/A';
    final date = data['creationDate'] as String? ?? 'N/A';
    final time = data['time'] as String? ?? 'N/A';
    final type = data['smokeType'] as String? ?? 'N/A';
    final location = data['location'] as String? ?? 'N/A';
    final imageUrl = data['imageUrl'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicleNo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (imageUrl != null) {
                      _showImagePreview(context, imageUrl);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(Icons.camera_alt, color: Colors.blue),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                        : const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(date),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(time),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                type,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredDetections() {
    Query query = firestore.collection('detections');

    // Apply smoke type filter if selected
    if (selectedSmokeType != null) {
      query = query.where('smokeType', isEqualTo: selectedSmokeType);
    }

    // Apply date range filters if selected
    if (fromDate != null || toDate != null) {
      if (fromDate != null) {
        query = query.where('creationDate',
            isGreaterThanOrEqualTo: formatDate(fromDate!, [yyyy, '-', mm, '-', dd]));
      }
      if (toDate != null) {
        query = query.where('creationDate',
            isLessThanOrEqualTo: formatDate(toDate!, [yyyy, '-', mm, '-', dd]));
      }
    }

    // Always apply timestamp ordering last
    query = query.orderBy('timestamp', descending: true);

    return query.snapshots();
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
              for (var type in ["Black Smoke", "White Smoke", "Gray Smoke", "Blue Smoke"])
                ListTile(
                  title: Text(type),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectedSmokeType = type;
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                title: const Text('Clear Filter'),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedSmokeType = null;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}