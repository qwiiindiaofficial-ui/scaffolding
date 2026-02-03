// lib/staff_management/features/selfie_attendance_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SelfieAttendancePage extends StatefulWidget {
  const SelfieAttendancePage({super.key});

  @override
  State<SelfieAttendancePage> createState() => _SelfieAttendancePageState();
}

class _SelfieAttendancePageState extends State<SelfieAttendancePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeCameraAndLocation();
  }

  Future<void> _initializeCameraAndLocation() async {
    // Check and request permissions
    await [Permission.camera, Permission.location].request();

    // Initialize Camera
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      setState(() => _isCameraInitialized = true);
    }

    // Get Location
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selfie Attendance")),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(child: CameraPreview(_controller!)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                          _currentPosition != null
                              ? 'Location: Lat ${_currentPosition!.latitude.toStringAsFixed(4)}, Lon ${_currentPosition!.longitude.toStringAsFixed(4)}'
                              : 'Fetching location...',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera),
                        label: const Text("Mark Attendance"),
                        onPressed: () async {
                          // Yahan aap picture capture karke, staff select karke
                          // use attendance service mein save kar sakte hain.
                          final image = await _controller!.takePicture();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Attendance Marked at ${image.path}")));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
