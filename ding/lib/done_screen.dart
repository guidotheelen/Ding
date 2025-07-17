import 'package:flutter/material.dart';

class DoneScreen extends StatelessWidget {
  final VoidCallback onBack;
  const DoneScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 80,
        ),
        const SizedBox(height: 24),
        const Text(
          'Workout Complete!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onBack,
          child: const Text('Back'),
        ),
      ],
    );
  }
}
