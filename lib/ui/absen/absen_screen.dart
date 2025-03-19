import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home.dart';

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({super.key});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  final CollectionReference dataCollection =
  FirebaseFirestore.instance.collection('absensija');
  final controllerName = TextEditingController();
  var categoriesList = <String>['Please Choose:', 'Sick', 'Others'];
  String dropValueCategories = 'Please Choose:';
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4361EE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Request Permission",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4361EE).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Request Permission',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please fill out all the required information',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      const Text(
                        'Your Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllerName,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212529),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF4361EE),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reason Field
                      const Text(
                        'Reason for Leave',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: dropValueCategories,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.medical_information_outlined,
                              color: Color(0xFF4361EE),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF212529),
                          ),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF4361EE),
                          ),
                          items: categoriesList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropValueCategories = newValue!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Date Range
                      const Text(
                        'Leave Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          // From Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: fromController,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now(),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: Color(0xFF4361EE),
                                              onPrimary: Colors.white,
                                            ),
                                            buttonTheme: const ButtonThemeData(
                                              textTheme: ButtonTextTheme.primary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        fromController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                                      });
                                    }
                                  },
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF212529),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'DD/MM/YYYY',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Color(0xFF4361EE),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // To Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Until',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: toController,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now(),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: Color(0xFF4361EE),
                                              onPrimary: Colors.white,
                                            ),
                                            buttonTheme: const ButtonThemeData(
                                              textTheme: ButtonTextTheme.primary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        toController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                                      });
                                    }
                                  },
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF212529),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'DD/MM/YYYY',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Color(0xFF4361EE),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (controllerName.text.isEmpty ||
                        dropValueCategories == 'Please Choose:' ||
                        fromController.text.isEmpty ||
                        toController.text.isEmpty) {
                      showErrorSnackBar(context, 'Please fill all required fields');
                    } else {
                      submitAbsen(
                        controllerName.text.toString(),
                        dropValueCategories,
                        fromController.text,
                        toController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submit Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4361EE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> submitAbsen(
      String name, String reason, String from, String until) async {
    showLoaderDialog(context);
    dataCollection.add({
      'address': '-',
      'name': name,
      'status': reason,
      'dateTime': '$from-$until',
    }).then((result) {
      setState(() {
        Navigator.of(context).pop();
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Request submitted successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              elevation: 4,
              duration: const Duration(seconds: 3),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Something went wrong. Please try again.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              elevation: 4,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  showLoaderDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                  strokeWidth: 3,
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Submitting Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please wait...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}