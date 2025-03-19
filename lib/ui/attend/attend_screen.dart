import 'dart:io';

import 'package:absensi/ui/attend/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;

  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> {
  String strDate = "";
  String strTime = "";
  String strDateTime = "";
  String strStatus = "Attend";
  String strAddress = "Fetching your location...";
  double dLat = 0.0;
  double dLong = 0.0;
  int dateHours = 0;
  int dateMinutes = 0;
  bool isLoading = true;
  XFile? image;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection =
  FirebaseFirestore.instance.collection('absensija');

  @override
  void initState() {
    super.initState();
    image = widget.image;
    setStatusAbsen();
    setDateTime();

    // Delay location permission check to avoid build-time errors
    Future.delayed(Duration.zero, () {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      bool success = await handleLocationPermition();
      if (success) {
        await getGeoLocationPosition();
      } else {
        setState(() {
          isLoading = false;
          strAddress = "Unable to access location. Please check permissions.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        strAddress = "Error initializing location: ${e.toString()}";
      });
    }
  }

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
          "Attendance Check-in",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.face,
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
                                'Time to Check In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strDateTime,
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Status: $strStatus',
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Photo Capture Section
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF4361EE),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Take a Selfie',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const Spacer(),
                        if (image != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                image = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraScreen(),
                          ),
                        ).then((result) {
                          if (result != null && result is XFile) {
                            setState(() {
                              image = result;
                            });
                          }
                        });
                      },
                      child: Container(
                        width: size.width,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: DottedBorder(
                            radius: const Radius.circular(12),
                            borderType: BorderType.RRect,
                            color: const Color(0xFF4361EE),
                            strokeWidth: 2,
                            dashPattern: const [6, 4],
                            child: Center(
                              child: image != null
                                  ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4361EE).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color(0xFF4361EE),
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to take a photo',
                                    style: TextStyle(
                                      color: Color(0xFF4361EE),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

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
                      textCapitalization: TextCapitalization.words,
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Section
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF4361EE),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const Spacer(),
                        if (!isLoading && strAddress != "Fetching your location...")
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                                strAddress = "Fetching your location...";
                              });
                              getGeoLocationPosition();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4361EE).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Color(0xFF4361EE),
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.pin_drop,
                            color: Color(0xFF4361EE),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isLoading
                                ? Row(
                              children: [
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  strAddress,
                                  style: const TextStyle(
                                    color: Color(0xFF6C757D),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              strAddress,
                              style: const TextStyle(
                                color: Color(0xFF212529),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (image == null || controllerName.text.isEmpty) {
                      showErrorSnackBar(context, image == null
                          ? 'Please take a selfie photo'
                          : 'Please enter your name');
                    } else {
                      submitAbsen(strAddress, controllerName.text.toString(), strStatus);
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
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Check In Now',
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

  Color _getStatusColor() {
    switch (strStatus) {
      case "Masuk":
        return Colors.green;
      case "Telat":
        return Colors.orange;
      case "Absent":
        return Colors.red;
      default:
        return Colors.white;
    }
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

  Future<bool> handleLocationPermition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Please enable location services on your device'),
                ],
              ),
              backgroundColor: const Color(0xFF4361EE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.location_off, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Location permission denied'),
                  ],
                ),
                backgroundColor: const Color(0xFF4361EE),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Location permissions are permanently denied, please enable in settings'),
                ],
              ),
              backgroundColor: const Color(0xFF4361EE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error checking location permissions: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return false;
    }
  }

  Future<void> getGeoLocationPosition() async {
    if (!mounted) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15));

      if (mounted) {
        setState(() {
          dLat = position.latitude;
          dLong = position.longitude;
        });
        await getAddressFromLongLat(position);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          strAddress = "Location unavailable. Please try again.";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error getting location: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> getAddressFromLongLat(Position position) async {
    if (!mounted) return;

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build address parts, filtering out empty or null values
        List<String?> addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((part) => part != null && part.isNotEmpty).toList();

        setState(() {
          isLoading = false;
          // Join with commas only the non-empty parts
          strAddress = addressParts.join(', ');

          // If the address is somehow empty after filtering
          if (strAddress.isEmpty) {
            strAddress = "Location found at: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          }
        });
      } else {
        setState(() {
          isLoading = false;
          strAddress = "Location found at: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          strAddress = "Found your location, but couldn't get the address details";
        });

        print("Error in getAddressFromLongLat: ${e.toString()}");
      }
    }
  }

  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('yyyy-MM-dd');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";
      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });

    setStatusAbsen();
  }

  void setStatusAbsen() {
    DateTime now = DateTime.now();
    dateHours = now.hour;
    dateMinutes = now.minute;

    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = "Masuk";
    } else if ((dateHours > 8 && dateHours < 18) ||
        (dateHours == 18 && dateMinutes <= 31)) {
      strStatus = "Telat";
    } else {
      strStatus = "Absent";
    }
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
                      "Submitting Attendance",
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

  Future<void> submitAbsen(String address, String name, String status) async {
    showLoaderDialog(context);
    dataCollection.add({
      'address': address,
      'name': name,
      'status': status,
      'dateTime': strDateTime,
    }).then((result) {
      Navigator.of(context).pop(); // Dismiss the loading dialog

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
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Attendance submitted successfully!',
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
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(
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
    }).catchError((error) {
      Navigator.of(context).pop(); // Dismiss the loading dialog

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
              Expanded(
                child: Text(
                  'Error: ${error.toString()}',
                  style: const TextStyle(
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
    });
  }
}