import 'package:flutter/material.dart';

class EnrolledMessageScreen extends StatelessWidget {
  final String message;
  final VoidCallback onGoToLogin;
  final VoidCallback onGoToSetup;

  const EnrolledMessageScreen({
    required this.message,
    required this.onGoToLogin,
    required this.onGoToSetup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onGoToLogin,
            child: const Text('Go to normal login'),
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
