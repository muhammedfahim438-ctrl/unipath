import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ─── Cache profile locally ─────────────────────────────────
  static Future<void> _cacheProfile(
      Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(data));
  }

  // ─── Get cached profile ────────────────────────────────────
  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('profile');
    if (data != null) {
      try {
        final decoded =
            jsonDecode(data) as Map<String, dynamic>;
        // Clear old cache if department is old value
        const oldDepts = [
          'Computer Science', 'IOT', 'Biology',
          'Physics', 'Mathematics', 'Chemistry',
          'Commerce', 'Arts'
        ];
        if (oldDepts.contains(decoded['department'])) {
          await prefs.remove('profile');
          return null;
        }
        return decoded;
      } catch (e) {
        await prefs.remove('profile');
        return null;
      }
    }
    return null;
  }

  // ─── Clear cache ───────────────────────────────────────────
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile');
  }

  // ─── Check if mobile already registered ───────────────────
  static Future<bool> isMobileRegistered(String mobile) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('mobile', isEqualTo: '+91$mobile')
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─── Register student ──────────────────────────────────────
  static Future<void> registerStudent({
    required String mobile,
    required String name,
    required String email,
    required String gender,
    required String dob,
    required String department,
    required String year,
    required String major12th,
    required String yearOfPassing,
    required String parentContact,
  }) async {
    final exists = await isMobileRegistered(mobile);
    if (exists) {
      throw Exception(
          'This mobile number is already registered!');
    }

    final data = {
      'mobile': '+91$mobile',
      'name': name,
      'email': email,
      'gender': gender,
      'dob': dob,
      'department': department,
      'year': year,
      'major12th': major12th,
      'yearOfPassing': yearOfPassing,
      'parentContact': parentContact,
      'createdAt': DateTime.now().toIso8601String(),
      'isProfileComplete': true,
    };

    await _firestore
        .collection('students')
        .doc('+91$mobile')
        .set(data);

    await _cacheProfile(data);
  }

  // ─── Send OTP ──────────────────────────────────────────────
  static Future<void> sendOTP({
    required String mobile,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$mobile',
      verificationCompleted:
          (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ─── Verify OTP ────────────────────────────────────────────
  static Future<User?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final result =
        await _auth.signInWithCredential(credential);
    return result.user;
  }

  // ─── Get student profile ───────────────────────────────────
  static Future<Map<String, dynamic>?> getStudentProfile(
      String mobile) async {
    try {
      final doc = await _firestore
          .collection('students')
          .doc(mobile)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        await _cacheProfile(data);
        return data;
      }
      // Try searching by mobile field
      final query = await _firestore
          .collection('students')
          .where('mobile', isEqualTo: mobile)
          .get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        await _cacheProfile(data);
        return data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // ─── Update student profile ────────────────────────────────
  static Future<void> updateStudentProfile({
    required String mobile,
    required Map<String, dynamic> data,
  }) async {
    // Try direct document update
    try {
      final docRef =
          _firestore.collection('students').doc(mobile);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.update(data);
      } else {
        // Search by mobile field
        final query = await _firestore
            .collection('students')
            .where('mobile', isEqualTo: mobile)
            .get();
        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update(data);
        } else {
          throw Exception('Profile not found!');
        }
      }
    } catch (e) {
      rethrow;
    }

    // Update cache
    final cached = await getCachedProfile();
    if (cached != null) {
      cached.addAll(data);
      await _cacheProfile(cached);
    }
  }

  // ─── Check if profile exists ───────────────────────────────
  static Future<bool> profileExists(String mobile) async {
    try {
      final doc = await _firestore
          .collection('students')
          .doc(mobile)
          .get();
      if (doc.exists) return true;

      final query = await _firestore
          .collection('students')
          .where('mobile', isEqualTo: mobile)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────
  static Future<void> logout() async {
    await clearCache();
    await _auth.signOut();
  }

  // ─── Current user ──────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;

  // ─── Check if email is registered ───────────────────────────
  static Future<bool> isEmailRegistered(String email) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─── Generate and send OTP via email ────────────────────────
  static Future<void> sendEmailOTP(String email) async {
    try {
      final otp = (Random().nextInt(900000) + 100000).toString();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP temporarily
      await _firestore
          .collection('email_otps')
          .doc(email)
          .set({
        'otp': otp,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // In production, integrate with email service (SendGrid, Firebase, etc.)
      // OTP is stored in Firestore and should be sent via email service.
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // ─── Verify email OTP ───────────────────────────────────────
  static Future<bool> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final doc = await _firestore
          .collection('email_otps')
          .doc(email)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      // Check if OTP matches and is not expired
      if (storedOtp == otp && DateTime.now().isBefore(expiresAt)) {
        // Delete OTP after successful verification
        await _firestore
            .collection('email_otps')
            .doc(email)
            .delete();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ─── Check if profile exists by email ────────────────────────
  static Future<bool> profileExistsByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─── Get student profile by email ────────────────────────────
  static Future<Map<String, dynamic>?> getStudentProfileByEmail(
      String email) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        await _cacheProfile(data);
        return data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}