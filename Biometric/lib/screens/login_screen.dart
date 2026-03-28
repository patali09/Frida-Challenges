import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onNormalLogin;
  final VoidCallback onBiometricLogin;
  final VoidCallback onGoToSetup;

  const LoginScreen({
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.onNormalLogin,
    required this.onBiometricLogin,
    required this.onGoToSetup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Normal Login',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          onPressed: isLoading ? null : onNormalLogin,
          child: const Text('Login'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isLoading ? null : onBiometricLogin,
          child: Text(isLoading ? 'Please wait...' : 'Login with biometric'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : onGoToSetup,
          child: const Text('Go to biometric setup'),
        ),
      ],
    );
  }
}
