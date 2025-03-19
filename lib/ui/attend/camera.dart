import 'dart:io';

import 'package:absensi/ui/attend/attend_screen.dart';
import 'package:absensi/utils/face_detection/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  FaceDetector? faceDetector;

  List<CameraDescription>? cameras;
  CameraController? controller;
  bool isBusy = false;
  bool isInitializing = true;
  bool isRearCamera = false;
  XFile? image;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize face detector
    faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
          enableTracking: true,
          enableLandmarks: true,
        )
    );

    // Initialize camera after the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before controller was initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      _initializeController(cameraController.description);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        setState(() {
          isInitializing = false;
          errorMessage = 'No cameras found on this device';
        });
        return;
      }

      // Find front camera
      CameraDescription? frontCamera;
      for (var camera in cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      // If no front camera found, use the first available camera
      final cameraToUse = frontCamera ?? cameras!.first;

      // Initialize the controller
      await _initializeController(cameraToUse);

    } catch (e) {
      setState(() {
        isInitializing = false;
        errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
      print("Camera initialization error: ${e.toString()}");
    }
  }

  Future<void> _initializeController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    try {
      // Create a new controller
      final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      // Store the controller
      controller = cameraController;

      // Initialize
      await cameraController.initialize();

      // Update the state
      if (mounted) {
        setState(() {
          isInitializing = false;
          isRearCamera = cameraDescription.lensDirection == CameraLensDirection.back;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isInitializing = false;
          errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
      }
      print("Camera controller initialization error: ${e.toString()}");
    }
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    setState(() {
      isInitializing = true;
    });

    final CameraDescription newCamera = isRearCamera
        ? cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first)
        : cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras!.last);

    await _initializeController(newCamera);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F25),
      body: SafeArea(
        child: Column(
          children: [
            // Camera Header
            _buildCameraHeader(),

            // Camera Preview Area
            Expanded(
              child: _buildCameraPreview(size),
            ),

            // Camera Controls
            _buildCameraControls(size),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1A1F25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Take a Selfie',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: _toggleCamera,
              child: const Icon(
                Icons.flip_camera_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(Size size) {
    if (isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF4361EE).withOpacity(0.8)
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Initializing camera...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = '';
                    isInitializing = true;
                  });
                  _initializeCamera();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (controller != null && controller!.value.isInitialized) {
      // Fixed camera preview layout
      return Container(
        width: size.width,
        height: size.width * controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Camera preview
            CameraPreview(controller!),

            // Overlay elements
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Face detection animation
                SizedBox(
                  width: size.width * 0.7,
                  child: Lottie.asset(
                    'assets/raw/face_id_ring.json',
                    fit: BoxFit.contain,
                  ),
                ),

                // Guide text
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Position your face in the circle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Camera unavailable',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Widget _buildCameraControls(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instructions
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'Make sure your face is clearly visible',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Position yourself in good lighting and look directly at the camera',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Camera button
          GestureDetector(
            onTap: () => _takePicture(),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4361EE),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4361EE).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized || isBusy) {
      return;
    }

    try {
      setState(() {
        isBusy = true;
      });

      // Check location permission first
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          isBusy = false;
        });
        return;
      }

      // Turn off flash for selfie
      await controller!.setFlashMode(FlashMode.off);

      // Take the picture
      final XFile? capturedImage = await controller!.takePicture();

      if (capturedImage == null) {
        setState(() {
          isBusy = false;
        });
        _showErrorSnackBar('Failed to capture image');
        return;
      }

      // Set image in state
      setState(() {
        image = capturedImage;
      });

      // Show processing dialog
      _showProcessingDialog();

      // Process the image
      if (Platform.isAndroid) {
        final inputImage = InputImage.fromFilePath(capturedImage.path);
        await _processFaceDetection(inputImage);
      } else {
        // For iOS, skip face detection
        if (mounted) {
          // Dismiss the loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          setState(() {
            isBusy = false;
          });

          // Navigate to attend screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendScreen(image: capturedImage),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isBusy = false;
      });

      // Hide loading dialog if shown
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      _showErrorSnackBar('Error taking picture: ${e.toString()}');
      print("Camera capture error: ${e.toString()}");
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Please enable location services on your device');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied. Please enable in settings.');
        return false;
      }

      return true;
    } catch (e) {
      _showErrorSnackBar('Error checking location permission');
      print("Location permission error: ${e.toString()}");
      return false;
    }
  }

  Future<void> _processFaceDetection(InputImage inputImage) async {
    if (faceDetector == null) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showErrorSnackBar('Face detector not initialized');
      }
      setState(() {
        isBusy = false;
      });
      return;
    }

    try {
      final List<Face> faces = await faceDetector!.processImage(inputImage);

      if (!mounted) return;

      // Dismiss loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        isBusy = false;
      });

      // Check if faces detected
      if (faces.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AttendScreen(image: image),
          ),
        );
      } else {
        _showErrorSnackBar('No face detected. Please try again in better lighting.');
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        setState(() {
          isBusy = false;
        });

        _showErrorSnackBar('Error detecting face: ${e.toString()}');
        print("Face detection error: ${e.toString()}");
      }
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      "Processing",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Checking face...",
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    faceDetector?.close();
    super.dispose();
  }
}