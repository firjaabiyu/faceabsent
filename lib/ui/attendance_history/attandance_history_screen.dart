import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection =
  FirebaseFirestore.instance.collection('absensija');

  // Summary counters
  int presentCount = 0;
  int lateCount = 0;
  int absentCount = 0;

  // Filter values
  String selectedFilter = 'All';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    try {
      // Get attendance counts
      QuerySnapshot presentSnapshot = await dataCollection
          .where('status', whereIn: ['masuk', 'attend'])
          .get();

      QuerySnapshot lateSnapshot = await dataCollection
          .where('status', whereIn: ['telat', 'late'])
          .get();

      QuerySnapshot absentSnapshot = await dataCollection
          .where('status', isEqualTo: 'absent')
          .get();

      setState(() {
        presentCount = presentSnapshot.docs.length;
        lateCount = lateSnapshot.docs.length;
        absentCount = absentSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading summary data: $e');
    }
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Local state for dialog
        String tempFilter = selectedFilter;
        DateTime? tempStartDate = startDate;
        DateTime? tempEndDate = endDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Attendance'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status filter
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Present',
                        'Late',
                        'Absent',
                        'Sick',
                        'Others'
                      ].map((status) {
                        return FilterChip(
                          label: Text(status),
                          selected: tempFilter == status,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempFilter = status;
                            });
                          },
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          selectedColor: const Color(0xFF4361EE).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF4361EE),
                          labelStyle: TextStyle(
                            color: tempFilter == status
                                ? const Color(0xFF4361EE)
                                : Colors.black87,
                            fontWeight: tempFilter == status
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    // Date range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Start date picker
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4361EE),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setDialogState(() {
                            tempStartDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tempStartDate != null
                                  ? DateFormat('MMM d, yyyy').format(tempStartDate!)
                                  : 'Start Date',
                              style: TextStyle(
                                color: tempStartDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // End date picker
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4361EE),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setDialogState(() {
                            tempEndDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tempEndDate != null
                                  ? DateFormat('MMM d, yyyy').format(tempEndDate!)
                                  : 'End Date',
                              style: TextStyle(
                                color: tempEndDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempFilter = 'All';
                      tempStartDate = null;
                      tempEndDate = null;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Update main state with filter values
                      selectedFilter = tempFilter;
                      startDate = tempStartDate;
                      endDate = tempEndDate;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show calendar view
  void _showCalendarView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Calendar header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance Calendar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar view placeholder - you would implement a full calendar here
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 70,
                        color: const Color(0xFF4361EE).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Calendar View Coming Soon',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This feature is under development',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
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

  // Show detailed attendance record
  void _showAttendanceDetails(DocumentSnapshot document) {
    // Parse date for formatting
    String dateTimeStr = document['dateTime'] ?? '';
    DateTime? dateTime;
    String formattedDate = '';
    String formattedTime = '';

    try {
      // Try to parse the date format
      if (dateTimeStr.contains('|')) {
        List<String> parts = dateTimeStr.split('|');
        if (parts.length == 2) {
          String datePart = parts[0].trim();
          String timePart = parts[1].trim();

          dateTime = DateFormat('yyyy-MM-dd').parse(datePart);
          formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
          formattedTime = timePart;
        } else {
          formattedDate = dateTimeStr;
        }
      } else if (dateTimeStr.contains('-')) {
        // Handle date range format for leave requests
        formattedDate = dateTimeStr;
      } else {
        formattedDate = dateTimeStr;
      }
    } catch (e) {
      formattedDate = dateTimeStr;
    }

    // Get status for styling
    String status = document['status'] ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF212529),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date & Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212529),
                                  ),
                                ),
                                if (formattedTime.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF212529),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Person info with avatar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAvatar(document['name'] ?? '-'),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212529),
                                ),
                              ),
                              if (document['position'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  document['position'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Location
                      _buildInfoSection(
                        title: 'Location',
                        icon: Icons.location_on_outlined,
                        content: document['address'] ?? 'No address provided',
                      ),

                      if (document['note'] != null && document['note'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Notes
                        _buildInfoSection(
                          title: 'Notes',
                          icon: Icons.note_alt_outlined,
                          content: document['note'],
                        ),
                      ],

                      // Add more details as needed
                      const SizedBox(height: 24),
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

  // Helper to build info sections in detail view
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF6C757D),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF212529),
            ),
          ),
        ),
      ],
    );
  }

  // Get filtered data stream based on selected filters
  Stream<QuerySnapshot> _getFilteredDataStream() {
    Query query = dataCollection.orderBy('dateTime', descending: true);

    // Apply status filter
    if (selectedFilter != 'All') {
      String statusFilter = selectedFilter.toLowerCase();

      // Handle different status formats
      if (statusFilter == 'present') {
        query = query.where('status', whereIn: ['masuk', 'attend']);
      } else if (statusFilter == 'late') {
        query = query.where('status', whereIn: ['telat', 'late']);
      } else {
        query = query.where('status', isEqualTo: statusFilter);
      }
    }

    // Date filtering is more complex in Firestore and would require additional code
    // based on your date format, which appears to be 'yyyy-MM-dd|HH:mm'

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4361EE),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _buildSummaryCard(
                  icon: Icons.check_circle_outline_rounded,
                  title: "Present",
                  count: presentCount.toString(),
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  icon: Icons.timelapse_rounded,
                  title: "Late",
                  count: lateCount.toString(),
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  icon: Icons.not_interested_rounded,
                  title: "Absent",
                  count: absentCount.toString(),
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // History List Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    // Show filter badge when filters are active
                    if (selectedFilter != 'All' || startDate != null || endDate != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_alt_outlined,
                              size: 14,
                              color: Color(0xFF4361EE),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filtered',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF4361EE),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _showCalendarView,
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: Color(0xFF4361EE),
                  ),
                  label: const Text(
                    'View Calendar',
                    style: TextStyle(
                      color: Color(0xFF4361EE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredDataStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4361EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData) {
                  var data = snapshot.data!.docs;

                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              size: 70,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No attendance records found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedFilter != 'All' || startDate != null || endDate != null
                                ? 'Try adjusting your filters'
                                : 'Your attendance history will appear here',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6C757D),
                            ),
                          ),

                          // Clear filters button
                          if (selectedFilter != 'All' || startDate != null || endDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedFilter = 'All';
                                    startDate = null;
                                    endDate = null;
                                  });
                                },
                                icon: const Icon(Icons.filter_alt_off),
                                label: const Text('Clear Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4361EE),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      // Parse date for formatting
                      String dateTimeStr = data[index]['dateTime'] ?? '';
                      DateTime? dateTime;
                      String formattedDate = '';
                      String formattedTime = '';

                      try {
                        // Try to parse the date format
                        if (dateTimeStr.contains('|')) {
                          List<String> parts = dateTimeStr.split('|');
                          if (parts.length == 2) {
                            String datePart = parts[0].trim();
                            String timePart = parts[1].trim();

                            dateTime = DateFormat('yyyy-MM-dd').parse(datePart);
                            formattedDate = DateFormat('MMM d, yyyy').format(dateTime);
                            formattedTime = timePart;
                          } else {
                            formattedDate = dateTimeStr;
                          }
                        } else if (dateTimeStr.contains('-')) {
                          // Handle date range format for leave requests
                          formattedDate = dateTimeStr;
                        } else {
                          formattedDate = dateTimeStr;
                        }
                      } catch (e) {
                        formattedDate = dateTimeStr;
                      }

                      // Get status for styling
                      String status = data[index]['status'] ?? 'Unknown';

                      return GestureDetector(
                        onTap: () {
                          _showAttendanceDetails(data[index]);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with date and status
                              Container(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
                                          color: const Color(0xFF4361EE).withOpacity(0.8),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212529),
                                          ),
                                        ),
                                        if (formattedTime.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4361EE).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              formattedTime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF4361EE).withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    _buildStatusBadge(status),
                                  ],
                                ),
                              ),

                              // User and attendance details
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    _buildAvatar(data[index]['name'] ?? '-'),

                                    const SizedBox(width: 16),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index]['name'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF212529),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Address
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 18,
                                                color: Color(0xFF6C757D),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  data[index]['address'] ?? 'No address provided',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6C757D),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          // Note if available
                                          if (data[index]['note'] != null && data[index]['note'].toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.note_outlined,
                                                    size: 18,
                                                    color: Color(0xFF6C757D),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      data[index]['note'],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xFF6C757D),
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'masuk':
      case 'attend':
        badgeColor = Colors.green;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case 'telat':
      case 'late':
        badgeColor = Colors.orange;
        iconData = Icons.timelapse_rounded;
        break;
      case 'absent':
        badgeColor = Colors.red;
        iconData = Icons.cancel_outlined;
        break;
      case 'sick':
        badgeColor = Colors.purple;
        iconData = Icons.medical_services_outlined;
        break;
      case 'others':
        badgeColor = Colors.blue;
        iconData = Icons.more_horiz_rounded;
        break;
      default:
        badgeColor = const Color(0xFF4361EE);
        iconData = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    // Generate a deterministic color based on the name
    int hashCode = name.isNotEmpty ? name.hashCode : 0;
    final List<Color> colorOptions = [
      const Color(0xFF4361EE), // Primary blue
      const Color(0xFF3A0CA3), // Dark purple
      const Color(0xFF7209B7), // Purple
      const Color(0xFFF72585), // Pink
      const Color(0xFF4CC9F0), // Light blue
      const Color(0xFF4F5D75), // Slate
      const Color(0xFF38b000), // Green
    ];

    Color avatarColor = colorOptions[hashCode.abs() % colorOptions.length];
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: avatarColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}