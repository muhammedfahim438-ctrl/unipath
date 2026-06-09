import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/email_otp_service.dart';
import '../services/auth_service.dart';
import 'email_otp_screen.dart';
import 'register_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() =>
      _EmailLoginScreenState();
}

class _EmailLoginScreenState
    extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (!RegExp(
            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    // Check if email is registered
    final isRegistered =
        await AuthService.isEmailRegistered(email);
    if (!isRegistered) {
      setState(() => _isLoading = false);
      _showError(
          'Email not registered! Please register first.');
      return;
    }

    try {
      await EmailOTPService.sendOTP(email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmailOTPScreen(email: email),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to send OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school,
                    size: 50,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text('UniPath',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const Text('Care. Support. Grow.',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 50),

              // Email label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email Address',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark)),
              ),
              const SizedBox(height: 8),

              // Email input
              TextFormField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText:
                      'example@email.com',
                  hintStyle: const TextStyle(
                      color: AppColors.grey),
                  prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Send OTP',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              // Register link
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text('New here? ',
                      style: TextStyle(
                          color: AppColors.grey)),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen()),
                    ),
                    child: const Text('Register now',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight:
                                FontWeight.w600)),
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