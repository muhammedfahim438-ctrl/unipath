import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _yearOfPassingController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedDepartment = 'Computer Science';
  String _selectedYear = '1st Year';
  String _selected12thMajor = 'Science';
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _departments = [
    'Computer Science', 'IOT', 'Biology', 'Physics',
    'Mathematics', 'Chemistry', 'Commerce', 'Arts'
  ];
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> _majors = ['Science', 'Commerce', 'Arts', 'Vocational'];

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user?.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': user?.phoneNumber ?? '',
        'gender': _selectedGender,
        'dob': _dobController.text.trim(),
        'department': _selectedDepartment,
        'year': _selectedYear,
        'major12th': _selected12thMajor,
        'yearOfPassing': _yearOfPassingController.text.trim(),
        'parentContact': _parentContactController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B0764))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          validator: required
              ? (v) => v == null || v.isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5B21B6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5B21B6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B0764))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5B21B6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5B21B6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B21B6),
        title: const Text('Personal Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.person,
                    size: 44, color: Color(0xFF5B21B6)),
              ),
              const SizedBox(height: 20),
              _buildTextField('Full Name', _nameController),
              _buildTextField('Email Address', _emailController,
                  type: TextInputType.emailAddress),
              _buildDropdown('Gender', _selectedGender, _genders,
                  (v) => setState(() => _selectedGender = v!)),
              _buildTextField('Date of Birth (DD/MM/YYYY)', _dobController),
              _buildDropdown('Department', _selectedDepartment, _departments,
                  (v) => setState(() => _selectedDepartment = v!)),
              _buildDropdown('Year', _selectedYear, _years,
                  (v) => setState(() => _selectedYear = v!)),
              _buildDropdown('12th Standard Major', _selected12thMajor, _majors,
                  (v) => setState(() => _selected12thMajor = v!)),
              _buildTextField('Year of Passing', _yearOfPassingController,
                  type: TextInputType.number),
              _buildTextField('Parent Contact Number', _parentContactController,
                  type: TextInputType.phone),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save & Continue',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}