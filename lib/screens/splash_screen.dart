import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnim = CurvedAnimation(
        parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _autoNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _autoNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // ── Step 1: Firebase Auth (works on mobile) ──
    final user = AuthService.currentUser;
    if (user != null) {
      // Admin: signed in with email (no phone number)
      if (user.email != null && user.phoneNumber == null) {
        _navigateTo(const AdminDashboardScreen());
        return;
      }
      // Student: signed in with phone number
      final mobile = user.phoneNumber ?? '';
      if (mobile.isNotEmpty) {
        final exists = await AuthService.profileExists(mobile);
        if (!mounted) return;
        if (exists) {
          _navigateTo(const DashboardScreen());
          return;
        }
      }
    }

    // ── Step 2: SharedPreferences (web + mobile restart) ──
    final prefs = await SharedPreferences.getInstance();

    // Check admin session
    final adminEmail = prefs.getString('admin_email');
    if (adminEmail != null && adminEmail.isNotEmpty) {
      if (!mounted) return;
      _navigateTo(const AdminDashboardScreen());
      return;
    }

    // ── Check student email session (email OTP login) ──
    final savedEmail = prefs.getString('loggedInEmail');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      final exists =
          await AuthService.profileExistsByEmail(savedEmail);
      if (!mounted) return;
      if (exists) {
        // Restore profile cache
        await AuthService.getStudentProfileByEmail(savedEmail);
        if (!mounted) return;
        _navigateTo(const DashboardScreen());
        return;
      } else {
        // Profile not found — clear stale session
        await prefs.remove('loggedInEmail');
      }
    }

    // ── Check student mobile session (phone OTP login, backward compat) ──
    final savedMobile = prefs.getString('loggedInMobile');
    if (savedMobile != null && savedMobile.isNotEmpty) {
      final exists = await AuthService.profileExists(savedMobile);
      if (!mounted) return;
      if (exists) {
        _navigateTo(const DashboardScreen());
        return;
      } else {
        // Profile not found — clear stale session
        await prefs.remove('loggedInMobile');
      }
    }

    // ── Step 3: Not logged in ──
    if (!mounted) return;
    _navigateTo(const WelcomeScreen());
  }

  void _navigateTo(Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0764),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── NASC Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'NASC',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── App Name ──
                const Text(
                  'UniPath',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Tagline ──
                const Text(
                  '"Your path to university and future success"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8B4FE),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 60),

                // ── Loading ──
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}