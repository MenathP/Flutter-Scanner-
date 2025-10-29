import 'package:flutter/material.dart';
import 'package:app/screens/capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Photo'),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CaptureScreen())),
        ),
      ),
    );
  }
}
