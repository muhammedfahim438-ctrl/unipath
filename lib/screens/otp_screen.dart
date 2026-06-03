import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text.trim()).join();

  void _showError(String message) {
    if (!mounted) return;
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5B21B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showError('Please enter all 6 digits of the OTP');
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(_otpCode)) {
      _showError('OTP must contain only numbers');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.verifyOTP(
        verificationId: widget.verificationId,
        otp: _otpCode,
      );

      if (user == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final mobile = '+91${widget.phoneNumber}';
      final profileExists =
          await AuthService.profileExists(mobile);

      if (!mounted) return;

      if (profileExists) {
        await AuthService.getStudentProfile(mobile);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const ProfileScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _showError('Invalid OTP! Please try again.');
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    await AuthService.sendOTP(
      mobile: widget.phoneNumber,
      onCodeSent: (verificationId) {
        _startResendTimer();
        _showSuccess('OTP resent successfully!');
      },
      onError: (error) {
        _showError('Failed to resend OTP: $error');
      },
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5B21B6),
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: _controllers[index].text.isNotEmpty
              ? const Color(0xFFEDE9FE)
              : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF5B21B6), width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        onTap: () {
          _controllers[index].selection =
              TextSelection.fromPosition(
            TextPosition(
                offset: _controllers[index].text.length),
          );
        },
      ),
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
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF5B21B6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.lock_outline,
                    size: 40, color: Color(0xFF5B21B6)),
              ),
              const SizedBox(height: 24),
              const Text('Verify OTP',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B0764))),
              const SizedBox(height: 10),
              Text(
                'Enter the 6-digit OTP sent to\n+91 ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(
                    6, (index) => _buildOTPBox(index)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter each digit in separate box',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Verify',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive OTP? ",
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _resendOTP : null,
                    child: Text(
                      _canResend
                          ? 'Resend OTP'
                          : 'Resend in ${_resendSeconds}s',
                      style: TextStyle(
                          color: _canResend
                              ? const Color(0xFF5B21B6)
                              : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Change Number',
                  style: TextStyle(
                      color: Color(0xFF5B21B6),
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}