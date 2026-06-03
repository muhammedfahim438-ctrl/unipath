import 'package:flutter/material.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

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
      body: const Center(
        child: Text('Admin Login Coming Soon!',
            style: TextStyle(
                fontSize: 20,
                color: Color(0xFF5B21B6),
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}