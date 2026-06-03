import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();

    // Validate
    if (phone.isEmpty) {
      _showError('Please enter your mobile number');
      return;
    }
    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showError('Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    // Check if mobile is registered
    final isRegistered = await AuthService.isMobileRegistered(phone);
    if (!isRegistered) {
      setState(() => _isLoading = false);
      _showError('Mobile number not registered! Please register first.');
      return;
    }

    // Send OTP
    await AuthService.sendOTP(
      mobile: phone,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              verificationId: verificationId,
              phoneNumber: phone,
            ),
          ),
        );
      },
      onError: (error) {
        setState(() => _isLoading = false);
        _showError('Failed to send OTP: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B21B6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school,
                    size: 50, color: Color(0xFF5B21B6)),
              ),
              const SizedBox(height: 20),
              const Text('UniPath',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B21B6))),
              const Text('Care. Support. Grow.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 50),

              // Mobile number label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Mobile Number',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B0764))),
              ),
              const SizedBox(height: 8),

              // Phone input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '98765 43210',
                  hintStyle: const TextStyle(
                      color: Color(0xFFD1D5DB)),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: const Text('🇮🇳 +91',
                        style: TextStyle(fontSize: 14)),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                      minWidth: 0, minHeight: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF5B21B6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF5B21B6), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Send OTP',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New here? ',
                      style: TextStyle(color: Color(0xFF6B7280))),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen()),
                    ),
                    child: const Text('Register now',
                        style: TextStyle(
                            color: Color(0xFF5B21B6),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}