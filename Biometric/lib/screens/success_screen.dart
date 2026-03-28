import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onGoToSetup;

  const SuccessScreen({
    required this.onGoToSetup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Login successful',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onGoToSetup,
            child: const Text('Go to biometric setup'),
          ),
        ],
      ),
    );
  }
}
