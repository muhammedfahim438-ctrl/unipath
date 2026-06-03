import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
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
  // School of Commerce
  'B.Com Computer Applications',
  'B.Com Professional Accounting',
  'B.Com Information Technology',
  'B.Com Banking',
  'B.Com Business Analytics',
  'B.Com Accounting & Finance',
  'M.Com Finance and Control',
  // School of Computational Science
  'B.Sc Computer Science',
  'BCA',
  'B.Sc Information Technology',
  'B.Sc AI & ML',
  'B.Sc Computer Science with Data Science',
  'B.Sc Internet of Things',
  'BCA Business Analytics',
  'M.Sc Data Science',
  // School of Life Sciences
  'B.Sc Biotechnology',
  'B.Sc Microbiology',
  'B.Sc Food Science and Nutrition',
  'M.Sc Biotechnology',
  'M.Sc Microbiology',
  'M.Sc Food Science and Nutrition',
  // School of Management
  'BBA Computer Applications',
  'BBA International Business',
  'BBA Logistics',
  'BBA Aviation Management',
  // School of Creative Sciences
  'B.Sc CS & HM',
  'B.Sc Costume Design and Fashion',
  'B.Sc Visual Communication',
  // School of Investigative Science
  'B.Sc Digital and Cyber Forensic Science',
  'B.A Criminology',
  'B.Sc Forensic Science',
  'B.Sc Psychology',
  'M.A Criminology',
  'M.Sc Forensic Science',
  // School of Liberal Arts
  'B.A English Literature',
  'Master of Social Work',
];
  final List<String> _years = [
    '1st Year', '2nd Year', '3rd Year', '4th Year'
  ];
  final List<String> _majors = [
    'Science', 'Commerce', 'Arts', 'Vocational'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _parentContactController.dispose();
    _yearOfPassingController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Check duplicate mobile
      final exists = await AuthService.isMobileRegistered(
          _phoneController.text.trim());
      if (exists) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('This mobile number is already registered! Please login.');
        }
        return;
      }

      // Register student
      await AuthService.registerStudent(
        mobile: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        dob: _dobController.text.trim(),
        department: _selectedDepartment,
        year: _selectedYear,
        major12th: _selected12thMajor,
        yearOfPassing: _yearOfPassingController.text.trim(),
        parentContact: _parentContactController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Show success then go to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Color(0xFF5B21B6), size: 40),
                ),
                const SizedBox(height: 16),
                const Text('Registration Successful!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B0764))),
                const SizedBox(height: 8),
                const Text(
                  'Your account has been created.\nPlease login with your mobile number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B21B6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Go to Login',
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    String? fieldType,
    String? hint,
  }) {
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
          validator: (v) {
            if (v == null || v.isEmpty) return '$label is required';
            if (fieldType == 'email') {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(v)) {
                return 'Enter a valid email (must contain @)';
              }
            }
            if (fieldType == 'phone') {
              if (v.length != 10 ||
                  !RegExp(r'^[0-9]+$').hasMatch(v)) {
                return 'Enter valid 10-digit mobile number';
              }
            }
            if (fieldType == 'parentPhone') {
              if (v.length != 10 ||
                  !RegExp(r'^[0-9]+$').hasMatch(v)) {
                return 'Enter valid 10-digit parent number';
              }
            }
            if (fieldType == 'dob') {
              if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(v)) {
                return 'Enter date as DD/MM/YYYY';
              }
            }
            if (fieldType == 'year') {
              if (v.length != 4 ||
                  !RegExp(r'^[0-9]+$').hasMatch(v)) {
                return 'Enter valid 4-digit year';
              }
              final yr = int.tryParse(v);
              if (yr == null || yr < 1990 || yr > 2030) {
                return 'Enter a year between 1990 and 2030';
              }
            }
            if (fieldType == 'name') {
              if (v.length < 3) return 'Name must be at least 3 characters';
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) {
                return 'Name must contain only letters';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFFD1D5DB), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF5B21B6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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
  initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF5B21B6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mobile Number',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B0764))),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Mobile number is required';
            if (v.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(v)) {
              return 'Enter valid 10-digit mobile number';
            }
            return null;
          },
          decoration: InputDecoration(
            counterText: '',
            hintText: '98765 43210',
            hintStyle: const TextStyle(
                color: Color(0xFFD1D5DB), fontSize: 13),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
              child: const Text('🇮🇳 +91',
                  style: TextStyle(fontSize: 14)),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF5B21B6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.red, width: 2),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF5B21B6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account',
            style: TextStyle(
                color: Color(0xFF5B21B6),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fill in your details',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 24),

              _buildTextField('Full Name', _nameController,
                  fieldType: 'name', hint: 'Enter your full name'),

              _buildPhoneField(),

              _buildTextField('Email Address', _emailController,
                  type: TextInputType.emailAddress,
                  fieldType: 'email',
                  hint: 'example@email.com'),

              _buildDropdown('Gender', _selectedGender, _genders,
                  (v) => setState(() => _selectedGender = v!)),

              _buildTextField(
                  'Date of Birth', _dobController,
                  fieldType: 'dob', hint: 'DD/MM/YYYY'),

              _buildDropdown(
                  'Department',
                  _selectedDepartment,
                  _departments,
                  (v) => setState(() => _selectedDepartment = v!)),

              _buildDropdown('Year', _selectedYear, _years,
                  (v) => setState(() => _selectedYear = v!)),

              _buildDropdown(
                  '12th Standard Major',
                  _selected12thMajor,
                  _majors,
                  (v) => setState(() => _selected12thMajor = v!)),

              _buildTextField(
                  'Year of Passing', _yearOfPassingController,
                  type: TextInputType.number,
                  fieldType: 'year',
                  hint: 'e.g. 2024'),

              _buildTextField(
                  'Parent Contact Number',
                  _parentContactController,
                  type: TextInputType.phone,
                  fieldType: 'parentPhone',
                  hint: '98765 43210'),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('Register',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: Color(0xFF6B7280))),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    ),
                    child: const Text('Login',
                        style: TextStyle(
                            color: Color(0xFF5B21B6),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}