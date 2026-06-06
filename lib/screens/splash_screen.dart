import 'package:flutter/material.dart';
import '../theme.dart';
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
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
        parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Auto navigate after 3 seconds
    _autoNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Auto navigate based on login status ──────────────────
  Future<void> _autoNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final user = AuthService.currentUser;

    if (user == null) {
      // Not logged in → Welcome screen
      _navigateTo(const WelcomeScreen());
      return;
    }

    // Check if admin (email login)
    if (user.email != null && user.phoneNumber == null) {
      // Admin user
      _navigateTo(const AdminDashboardScreen());
      return;
    }

    // Student user — check profile exists
    final mobile = user.phoneNumber ?? '';
    final profileExists =
        await AuthService.profileExists(mobile);

    if (!mounted) return;
    if (profileExists) {
      _navigateTo(const DashboardScreen());
    } else {
      _navigateTo(const WelcomeScreen());
    }
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: AnimatedBuilder(
            animation: _slideAnim,
            builder: (context, child) =>
                Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Logo ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── NASC Badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NASC',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── App Name ──
                  const Text(
                    'UniPath',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 40,
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
                      color: AppColors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── University illustration ──
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                          Icons.account_balance_rounded,
                          size: 80,
                          color: AppColors.primary),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Loading indicator ──
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}