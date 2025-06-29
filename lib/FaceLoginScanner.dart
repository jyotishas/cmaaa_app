import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'face_recognition_helper.dart';

class FaceLoginScanner extends StatefulWidget {
  final String mobile;
  final Function(bool success) onResult;
  final FaceRecognitionHelper faceHelper;

  const FaceLoginScanner({
    Key? key,
    required this.mobile,
    required this.onResult,
    required this.faceHelper,
  }) : super(key: key);

  @override
  State<FaceLoginScanner> createState() => _FaceLoginScannerState();
}

class _FaceLoginScannerState extends State<FaceLoginScanner> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  int _countdown = 3;
  Timer? _timer;
  String _statusMessage = "Align your face";
  bool _isProcessing = false;
  bool _faceDetected = false;


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );

    setState(() {});
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown == 0 && !_isProcessing) {
        timer.cancel();
        await _captureAndScan();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _captureAndScan() async {
    try {
      _isProcessing = true;
      setState(() => _statusMessage = "Scanning...");

      final XFile file = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() => _statusMessage = "Face detected. Hold still...");

        final bytes = await file.readAsBytes();
        final mirrored = await _mirrorImage(bytes);
        final embedding = await widget.faceHelper.getEmbedding(mirrored, faces.first);

        final result = await widget.faceHelper.matchFaceWithMobile(
            widget.mobile, embedding, 0.6);

        if (result['matched']) {
          setState(() => _statusMessage = "Face matched! Logging in...");
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 800));
          widget.onResult(true);
          if (mounted) Navigator.of(context).pop();
          return;
        } else {
          setState(() => _statusMessage = "Face not recognized");
        }
      } else {
        setState(() => _statusMessage = "No face found");
      }

      await Future.delayed(const Duration(seconds: 2));
      _showRetryBottomSheet();
    } catch (e) {
      print("Error during face scan: $e");
      if (mounted) _showRetryBottomSheet();
    }
  }

  Future<Uint8List> _mirrorImage(Uint8List bytes) async {
    final image = img.decodeImage(bytes)!;
    final flipped = img.flipHorizontal(image);
    return Uint8List.fromList(img.encodeJpg(flipped));
  }

  void _showRetryBottomSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.face_retouching_off, size: 40, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text("Face Not Recognized",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Make sure your face is clearly visible and try again.",
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onResult(false); // Cancel
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                      label: Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _countdown = 3;
                          _statusMessage = "Align your face";
                          _isProcessing = false;
                        });
                        _startCountdown();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text("Retry"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.1416),
            child: CameraPreview(_cameraController!),
          ),
          _buildOverlay(),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Face frame guide
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 30),
        // Countdown timer and status message
        Column(
          children: [
            if (_countdown > 0)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _countdown / 3,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation(Colors.green),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _statusMessage,
                key: ValueKey(_statusMessage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

