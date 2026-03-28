import 'package:flutter/material.dart';
import '../models/auth_models.dart';

class EnrollmentScreen extends StatelessWidget {
  final BiometricMode? selectedMode;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onEnroll;

  const EnrollmentScreen({
    required this.selectedMode,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.onEnroll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = selectedMode == BiometricMode.bypassable
        ? 'Bypassable Biometric Enrollment'
        : 'Secure Biometrics Enrollment';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : onEnroll,
          child: Text(isLoading ? 'Saving...' : 'Save credentials'),
        ),
      ],
    );
  }
}
