import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailOTPService {
  // ⚠️ IMPORTANT: Move these to environment variables
  // before Play Store submission!
  static const String _senderEmail = 'unipathnasc@gmail.com';
  static const String _appPassword = 'lpes fhtu lmmg xjfy';
  // Replace YOUR_APP_PASSWORD_HERE with your 16-char app password!

  // ─── Generate 6-digit OTP ──────────────────────────────────
  static String _generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  // ─── Send OTP to email ─────────────────────────────────────
  static Future<void> sendOTP(String toEmail) async {
    final otp = _generateOTP();

    // Save OTP + expiry to local storage
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now()
        .add(const Duration(minutes: 10))
        .millisecondsSinceEpoch;
    await prefs.setString('email_otp', otp);
    await prefs.setString('email_otp_email', toEmail);
    await prefs.setInt('email_otp_expiry', expiry);

    // Setup Gmail SMTP
    final smtpServer = gmail(_senderEmail, _appPassword);

    // Create email message
    final message = Message()
      ..from = Address(_senderEmail, 'UniPath NASC')
      ..recipients.add(toEmail)
      ..subject = 'UniPath — Your OTP Code'
      ..html = '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px;">
  <div style="max-width: 500px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden;">
    
    <div style="background: #5B21B6; padding: 30px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 28px;">UniPath</h1>
      <p style="color: #EDE9FE; margin: 8px 0 0;">NASC Counselling & Wellness App</p>
    </div>
    
    <div style="padding: 30px; text-align: center;">
      <h2 style="color: #3B0764;">Your OTP Code</h2>
      <p style="color: #6B7280;">Use this code to login to UniPath</p>
      
      <div style="background: #EDE9FE; border-radius: 12px; padding: 20px; margin: 20px 0;">
        <h1 style="color: #5B21B6; font-size: 48px; letter-spacing: 8px; margin: 0;">$otp</h1>
      </div>
      
      <p style="color: #6B7280; font-size: 14px;">
        This OTP is valid for <strong>10 minutes</strong>
      </p>
      <p style="color: #6B7280; font-size: 14px;">
        Do not share this code with anyone.
      </p>
    </div>
    
    <div style="background: #F9FAFB; padding: 20px; text-align: center;">
      <p style="color: #9CA3AF; font-size: 12px; margin: 0;">
        UniPath — NASC | Your path to university and future success
      </p>
    </div>
    
  </div>
</body>
</html>
''';

    // Send email
    await send(message, smtpServer);
  }

  // ─── Verify OTP ────────────────────────────────────────────
  static Future<bool> verifyOTP(
      String email, String enteredOTP) async {
    final prefs = await SharedPreferences.getInstance();
    final savedOTP = prefs.getString('email_otp');
    final savedEmail =
        prefs.getString('email_otp_email');
    final expiry =
        prefs.getInt('email_otp_expiry') ?? 0;

    // Check expiry
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      return false; // OTP expired
    }

    // Check email and OTP match
    if (savedEmail != email || savedOTP != enteredOTP) {
      return false;
    }

    // Clear OTP after successful verification
    await prefs.remove('email_otp');
    await prefs.remove('email_otp_email');
    await prefs.remove('email_otp_expiry');

    return true;
  }

  // ─── Check if email is registered ─────────────────────────
  static Future<bool> isEmailRegistered(
      String email) async {
    // We check in AuthService
    return false;
  }
}