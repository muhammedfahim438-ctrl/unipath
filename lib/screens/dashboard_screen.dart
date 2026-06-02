import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'Dashboard Coming Soon!',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF5B21B6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}