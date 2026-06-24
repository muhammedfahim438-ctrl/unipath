import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailOTPService {
  static final _firestore = FirebaseFirestore.instance;

  static const String _brevoApiKey =
      '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';
  static const String _senderEmail = 'unipathnasc@gmail.com';
  static const String _senderName = 'UniPath NASC';

  static String _generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  static String _buildHtml(String otpCode) {
    return '''<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; margin: 0;">
  <div style="max-width: 500px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden;">
    <div style="background: linear-gradient(135deg, #3B0764, #5B21B6); padding: 32px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 32px; font-weight: 800;">UniPath</h1>
      <p style="color: #D8B4FE; margin: 6px 0 0; font-size: 13px;">Nehru Arts and Science College</p>
    </div>
    <div style="padding: 36px; text-align: center;">
      <h2 style="color: #3B0764; margin: 0 0 8px;">Verify Your Email</h2>
      <p style="color: #6B7280; font-size: 14px; margin: 0 0 28px;">Use the OTP below to login to UniPath</p>
      <div style="background: #EDE9FE; border-radius: 16px; padding: 24px; margin: 0 0 24px;">
        <p style="color: #6B7280; font-size: 12px; margin: 0 0 8px;">Your OTP Code</p>
        <h1 style="color: #5B21B6; font-size: 52px; letter-spacing: 12px; margin: 0; font-weight: 800;">''' + otpCode + '''</h1>
      </div>
      <p style="color: #6B7280; font-size: 13px; margin: 0 0 6px;">Valid for <strong>10 minutes</strong></p>
      <p style="color: #9CA3AF; font-size: 12px; margin: 0;">Do not share this code with anyone.</p>
    </div>
    <div style="background: #F9FAFB; padding: 20px; text-align: center; border-top: 1px solid #E5E7EB;">
      <p style="color: #9CA3AF; font-size: 11px; margin: 0;">UniPath - NASC Counselling and Wellness Platform</p>
      <p style="color: #5B21B6; font-size: 11px; margin: 4px 0 0;">unipath-nasc.web.app</p>
    </div>
  </div>
</body>
</html>''';
  }

  static Future<void> sendOTP(String toEmail) async {
    final otp = _generateOTP();
    final expiry = DateTime.now().add(const Duration(minutes: 10));

    await _firestore.collection('email_otps').doc(toEmail).set({
      'otp': otp,
      'expiresAt': expiry.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    final response = await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'Content-Type': 'application/json',
        'api-key': _brevoApiKey,
      },
      body: jsonEncode({
        'sender': {'name': _senderName, 'email': _senderEmail},
        'to': [{'email': toEmail}],
        'subject': 'UniPath - Your OTP Code',
        'htmlContent': _buildHtml(otp),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send OTP: ' + response.body);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_otp_email', toEmail);
  }

  static Future<bool> verifyOTP(String email, String enteredOTP) async {
    try {
      final doc = await _firestore.collection('email_otps').doc(email).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);
      if (storedOtp == enteredOTP && DateTime.now().isBefore(expiresAt)) {
        await _firestore.collection('email_otps').doc(email).delete();
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
