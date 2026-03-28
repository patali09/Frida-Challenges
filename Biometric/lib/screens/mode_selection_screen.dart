import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../widgets/mode_box.dart';

class ModeSelectionScreen extends StatelessWidget {
  final VoidCallback onBypassableTap;
  final VoidCallback onSecureTap;

  const ModeSelectionScreen({
    required this.onBypassableTap,
    required this.onSecureTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Choose biometric setup',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ModeBox(
          title: 'Bypassable Biometric',
          onTap: onBypassableTap,
        ),
        const SizedBox(height: 12),
        ModeBox(
          title: 'Secure Biometrics',
          onTap: onSecureTap,
        ),
      ],
    );
  }
}
