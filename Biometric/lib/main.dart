import 'package:flutter/material.dart';
import 'models/auth_models.dart';
import 'services/auth_storage_service.dart';
import 'services/secure_auth_service.dart';
import 'services/insecure_auth_service.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/enrollment_screen.dart';
import 'screens/enrolled_message_screen.dart';
import 'screens/login_screen.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BiometricLoginApp(),
    );
  }
}

class BiometricLoginApp extends StatefulWidget {
  const BiometricLoginApp({super.key});

  @override
  State<BiometricLoginApp> createState() => _BiometricLoginAppState();
}

class _BiometricLoginAppState extends State<BiometricLoginApp> {
  final _storageService = AuthStorageService();
  final _secureAuthService = SecureAuthService();
  final _insecureAuthService = InsecureAuthService();

  final _enrollUsernameController = TextEditingController();
  final _enrollPasswordController = TextEditingController();
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  BiometricMode? _selectedMode;
  AppView _view = AppView.modeSelection;
  String _message = '';
  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    _enrollUsernameController.dispose();
    _enrollPasswordController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initializeState() async {
    final modeRaw = await _storageService.readMode();
    if (!mounted) return;

    if (modeRaw == null) {
      setState(() {
        _view = AppView.modeSelection;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _selectedMode = modeRaw == BiometricMode.secure.name
          ? BiometricMode.secure
          : BiometricMode.bypassable;
      _view = AppView.login;
      _isLoading = false;
    });
  }

  void _selectMode(BiometricMode mode) {
    setState(() {
      _selectedMode = mode;
      _view = AppView.enrollment;
      _enrollUsernameController.clear();
      _enrollPasswordController.clear();
    });
  }

  Future<void> _enroll() async {
    final mode = _selectedMode;
    if (mode == null) return;

    final username = _enrollUsernameController.text.trim();
    final password = _enrollPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Please enter username and password.');
      return;
    }

    setState(() => _isBusy = true);

    try {
      if (mode == BiometricMode.bypassable) {
        await _insecureAuthService.enrollBypassable(
          username: username,
          password: password,
          saveToStorage: (key, value) async {
            if (key == 'username') {
              await _storageService.writeUsername(value);
            } else if (key == 'password') {
              await _storageService.writePassword(value);
            }
          },
          deleteFromStorage: (key) async {
            if (key == 'password_hash') {
              await _storageService.deletePasswordHash();
            }
          },
        );
        await _storageService.writeMode(mode.name);
        _message = 'From Bypassable biometric';
      } else {
        await _secureAuthService.enrollSecure(
          username: username,
          password: password,
          saveToStorage: (key, value) async {
            if (key == 'password_hash') {
              await _storageService.writePasswordHash(value);
            }
          },
        );
        await _storageService.writeMode(mode.name);
        await _storageService.writeUsername(username);
        _message = 'From Secure biometric';
      }

      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _selectedMode = mode;
        _view = AppView.enrolledMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Enrollment failed: ${e.toString()}');
    }
  }

  Future<void> _normalLogin() async {
    final mode = _selectedMode;
    final inputUsername = _loginUsernameController.text.trim();
    final inputPassword = _loginPasswordController.text;

    if (mode == null) {
      _showSnack('Please set up biometric mode first.');
      return;
    }

    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      _showSnack('Please enter username and password.');
      return;
    }

    final authenticated = await (mode == BiometricMode.bypassable
        ? _insecureAuthService.authenticateBiometric(
            'Authenticate to access saved credentials',
          )
        : _secureAuthService.authenticateBiometric(
            'Authenticate to access saved credentials',
          ));

    if (!authenticated) {
      _showSnack('Biometric authentication failed.');
      return;
    }

    final storedUsername = await _storageService.readUsername();
    var isValid = false;

    if (mode == BiometricMode.bypassable) {
      final storedPassword = await _storageService.readPassword();
      isValid = _insecureAuthService.validateBypassableCredentials(
        inputUsername: inputUsername,
        inputPassword: inputPassword,
        storedUsername: storedUsername ?? '',
        storedPassword: storedPassword ?? '',
      );
    } else {
      final storedHash = await _storageService.readPasswordHash();
      isValid = storedUsername == inputUsername &&
          await _secureAuthService.validateSecureCredentials(
            inputPassword: inputPassword,
            storedHash: storedHash ?? '',
          );
    }

    if (!mounted) return;

    if (!isValid) {
      _showSnack('Invalid credentials.');
      return;
    }

    setState(() => _view = AppView.success);
  }

  Future<void> _biometricLogin() async {
    final mode = _selectedMode;
    if (mode == null) {
      _showSnack('Please set up biometric mode first.');
      return;
    }

    setState(() => _isBusy = true);

    try {
      if (mode == BiometricMode.bypassable) {
        final authenticated = await _insecureAuthService.authenticateBiometric(
          'Authenticate to access saved credentials',
        );
        if (!authenticated) {
          if (!mounted) return;
          setState(() => _isBusy = false);
          _showSnack('Biometric authentication failed.');
          return;
        }

        final storedUsername = await _storageService.readUsername();
        final storedPassword = await _storageService.readPassword();

        final credentials = await _insecureAuthService.biometricLogin(
          storedUsername: storedUsername,
          storedPassword: storedPassword,
        );

        if (credentials == null) {
          if (!mounted) return;
          setState(() => _isBusy = false);
          _showSnack('Stored credentials not found. Please configure again.');
          return;
        }

        if (!mounted) return;
        setState(() {
          _loginUsernameController.text = credentials['username']!;
          _loginPasswordController.text = credentials['password']!;
          _isBusy = false;
          _view = AppView.success;
        });
        return;
      }

      final storedUsername = await _storageService.readUsername();
      final storedHash = await _storageService.readPasswordHash();

      final credentials = await _secureAuthService.biometricLogin(
        storedUsername: storedUsername ?? '',
        storedHash: storedHash ?? '',
      );

      if (credentials == null) {
        if (!mounted) return;
        setState(() => _isBusy = false);
        _showSnack('Secure credentials not found. Please configure again.');
        return;
      }

      if (!mounted) return;
      setState(() {
        _loginUsernameController.text = credentials['username']!;
        _loginPasswordController.text = credentials['password']!;
        _isBusy = false;
        _view = AppView.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Biometric login failed: ${e.toString()}');
    }
  }

  void _goToModeSelection() {
    setState(() {
      _view = AppView.modeSelection;
      _enrollUsernameController.clear();
      _enrollPasswordController.clear();
      _loginUsernameController.clear();
      _loginPasswordController.clear();
    });
  }

  void _goBack() {
    setState(() {
      switch (_view) {
        case AppView.modeSelection:
          break;
        case AppView.enrollment:
          _view = AppView.modeSelection;
          break;
        case AppView.enrolledMessage:
          _view = AppView.enrollment;
          break;
        case AppView.login:
          _view = AppView.modeSelection;
          break;
        case AppView.success:
          _view = AppView.login;
          break;
      }
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Login App'),
        leading: _view == AppView.modeSelection
            ? null
            : IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildView(),
      ),
    );
  }

  Widget _buildView() {
    switch (_view) {
      case AppView.modeSelection:
        return ModeSelectionScreen(
          onBypassableTap: () => _selectMode(BiometricMode.bypassable),
          onSecureTap: () => _selectMode(BiometricMode.secure),
        );

      case AppView.enrollment:
        return EnrollmentScreen(
          selectedMode: _selectedMode,
          usernameController: _enrollUsernameController,
          passwordController: _enrollPasswordController,
          isLoading: _isBusy,
          onEnroll: _enroll,
        );

      case AppView.enrolledMessage:
        return EnrolledMessageScreen(
          message: _message,
          onGoToLogin: () {
            _loginUsernameController.clear();
            _loginPasswordController.clear();
            setState(() => _view = AppView.login);
          },
          onGoToSetup: _goToModeSelection,
        );

      case AppView.login:
        return LoginScreen(
          usernameController: _loginUsernameController,
          passwordController: _loginPasswordController,
          isLoading: _isBusy,
          onNormalLogin: _normalLogin,
          onBiometricLogin: _biometricLogin,
          onGoToSetup: _goToModeSelection,
        );

      case AppView.success:
        return SuccessScreen(
          onGoToSetup: _goToModeSelection,
        );
    }
  }
}
