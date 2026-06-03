import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ─── Save profile to local cache ──────────────────────────
  static Future<void> _cacheProfile(
      Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(data));
  }

  // ─── Get profile from local cache ─────────────────────────
  static Future<Map<String, dynamic>?> getCachedProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('profile');
  if (data != null) {
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      // Clear old cache if department is old value
      final oldDepts = [
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

    // Save to Firestore
    await _firestore
        .collection('students')
        .doc('+91$mobile')
        .set(data);

    // Cache locally for fast access
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
      verificationCompleted: (PhoneAuthCredential credential) {},
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
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final result =
        await _auth.signInWithCredential(credential);
    return result.user;
  }

  // ─── Get student profile (cache first, then Firebase) ─────
  static Future<Map<String, dynamic>?> getStudentProfile(
      String mobile) async {
    // Try cache first — instant!
    final cached = await getCachedProfile();
    if (cached != null) {
      // Sync Firebase in background
      _syncProfileFromFirebase(mobile);
      return cached;
    }

    // No cache → fetch from Firebase
    return await _fetchFromFirebase(mobile);
  }

  // ─── Fetch from Firebase ───────────────────────────────────
  static Future<Map<String, dynamic>?> _fetchFromFirebase(
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
    } catch (e) {
      return null;
    }
    return null;
  }

  // ─── Sync Firebase in background ──────────────────────────
  static Future<void> _syncProfileFromFirebase(
      String mobile) async {
    try {
      final doc = await _firestore
          .collection('students')
          .doc(mobile)
          .get();
      if (doc.exists) {
        await _cacheProfile(doc.data()!);
      }
    } catch (e) {
      // Silent fail — cache still works
    }
  }

  // ─── Update student profile ────────────────────────────────
 static Future<void> updateStudentProfile({
  required String mobile,
  required Map<String, dynamic> data,
}) async {
  // Try exact mobile first
  try {
    final docRef = _firestore.collection('students').doc(mobile);
    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(data);
    } else {
      // Try finding by mobile field
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

    // Update cache
    final cached = await getCachedProfile();
    if (cached != null) {
      cached.addAll(data);
      await _cacheProfile(cached);
    }
  } catch (e) {
    rethrow;
  }
}

  // ─── Check if profile exists ───────────────────────────────
  static Future<bool> profileExists(String mobile) async {
    // Check cache first
    final cached = await getCachedProfile();
    if (cached != null) return true;

    // Check Firebase
    try {
      final doc = await _firestore
          .collection('students')
          .doc(mobile)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ─── Clear cache ───────────────────────────────────────────
static Future<void> clearCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('profile');
}

  // ─── Current user ──────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
}