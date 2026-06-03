import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'admin_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.school,
                    size: 56, color: Color(0xFF5B21B6)),
              ),
              const SizedBox(height: 16),
              // NASC badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B21B6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('NASC',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(height: 12),
              const Text('UniPath',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B21B6))),
              const SizedBox(height: 6),
              const Text(
                '"Your path to university and future success"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 60),
              // University illustration placeholder
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.account_balance,
                      size: 64, color: Color(0xFF5B21B6)),
                ),
              ),
              const SizedBox(height: 50),
              const Text('Choose your role',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B0764))),
              const SizedBox(height: 20),
              // Admin button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminLoginScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF5B21B6), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.admin_panel_settings,
                          color: Color(0xFF5B21B6)),
                      SizedBox(width: 10),
                      Text('Admin',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF5B21B6),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Student button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentEntryScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.school, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Student',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Student Entry Screen (Login or Register choice) ──────────
class StudentEntryScreen extends StatelessWidget {
  const StudentEntryScreen({super.key});

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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school,
                    size: 44, color: Color(0xFF5B21B6)),
              ),
              const SizedBox(height: 16),
              const Text('Welcome',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B0764))),
              const SizedBox(height: 8),
              const Text('Login or Register to continue',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 50),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Login',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 14),
              // Register button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF5B21B6), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Register',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5B21B6),
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}