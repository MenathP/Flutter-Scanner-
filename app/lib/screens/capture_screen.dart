import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// permission_handler removed due to Android compile issues; camera init will
// fail gracefully if permissions are not granted.
import 'package:app/services/photo_service.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _captured;
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    // On Android, runtime camera permission is required. We'll attempt to
    // initialize the camera and surface any permission errors returned by the
    // camera plugin. If initialization fails due to missing permission, the
    // catch below will report it and the UI will show the error.

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = 'No cameras available';
          _initializing = false;
        });
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed initializing camera: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      setState(() {
        _captured = file;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _uploadAndProceed() async {
    if (_captured == null) return;
    setState(() {
      _initializing = true;
      _error = null;
    });
    try {
      await PhotoService.uploadPhoto(File(_captured!.path));
      // handle response if needed
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo uploaded')));
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Photo')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_initializing)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_initializing && _error != null)
              Expanded(child: Center(child: Text(_error!))),
            if (!_initializing &&
                _error == null &&
                _captured == null &&
                _controller != null)
              Expanded(child: CameraPreview(_controller!)),
            if (_captured != null)
              Expanded(
                child: Image.file(File(_captured!.path), fit: BoxFit.contain),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_captured == null)
                  ElevatedButton.icon(
                    onPressed: _initializing ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture'),
                  ),
                if (_captured != null) ...[
                  ElevatedButton(
                    onPressed: _uploadAndProceed,
                    child: const Text('Upload & Proceed'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _captured = null;
                      });
                    },
                    child: const Text('Retake'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
