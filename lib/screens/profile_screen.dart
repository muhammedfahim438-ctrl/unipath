import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
  String _mobileNumber = '';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _departments = [
    'Computer Science', 'IOT', 'Biology', 'Physics',
    'Mathematics', 'Chemistry', 'Commerce', 'Arts'
  ];
  final List<String> _years = [
    '1st Year', '2nd Year', '3rd Year', '4th Year'
  ];
  final List<String> _majors = [
    'Science', 'Commerce', 'Arts', 'Vocational'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _parentContactController.dispose();
    _yearOfPassingController.dispose();
    super.dispose();
  }

  // ─── Fill all fields ───────────────────────────────────────
  void _fillFields(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _dobController.text = data['dob'] ?? '';
    _parentContactController.text = data['parentContact'] ?? '';
    _yearOfPassingController.text = data['yearOfPassing'] ?? '';

    final genders = ['Male', 'Female', 'Other'];
    final departments = [
      'Computer Science', 'IOT', 'Biology', 'Physics',
      'Mathematics', 'Chemistry', 'Commerce', 'Arts'
    ];
    final years = [
      '1st Year', '2nd Year', '3rd Year', '4th Year'
    ];
    final majors = [
      'Science', 'Commerce', 'Arts', 'Vocational'
    ];

    _selectedGender = genders.contains(data['gender'])
        ? data['gender']
        : 'Male';
    _selectedDepartment =
        departments.contains(data['department'])
            ? data['department']
            : 'Computer Science';
    _selectedYear = years.contains(data['year'])
        ? data['year']
        : '1st Year';
    _selected12thMajor =
        majors.contains(data['major12th'])
            ? data['major12th']
            : 'Science';
  }

  // ─── Load profile ──────────────────────────────────────────
  Future<void> _loadProfile() async {
  try {
    final user = AuthService.currentUser;
    if (user == null) return;

    // Get exact phone number from Firebase Auth
    final mobile = user.phoneNumber ?? '';
    setState(() => _mobileNumber = mobile);

    print('DEBUG mobile: $mobile'); // check this

    // Load from cache FIRST
    final cached = await AuthService.getCachedProfile();
    if (cached != null && mounted) {
      _fillFields(cached);
      setState(() => _isLoading = false);
      return;
    }

    // No cache — fetch from Firebase
    final data = await AuthService.getStudentProfile(mobile);
    if (data != null && mounted) {
      _fillFields(data);
    }
    if (mounted) setState(() => _isLoading = false);
  } catch (e) {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // ─── Save updated profile ──────────────────────────────────
Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isSaving = true);

  try {
    // Get current user phone number
    final user = AuthService.currentUser;
    final mobile = user?.phoneNumber ?? _mobileNumber;

    await AuthService.updateStudentProfile(
      mobile: mobile,
      data: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'dob': _dobController.text.trim(),
        'department': _selectedDepartment,
        'year': _selectedYear,
        'major12th': _selected12thMajor,
        'yearOfPassing': _yearOfPassingController.text.trim(),
        'parentContact': _parentContactController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: const Color(0xFF5B21B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  // ─── Go to dashboard ───────────────────────────────────────
  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  // ─── Read only field (mobile) ──────────────────────────────
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B0764))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280))),
              ),
              const Icon(Icons.lock_outline,
                  size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── Text field ────────────────────────────────────────────
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    String? fieldType,
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
          enabled: _isEditing,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return '$label is required';
            }
            if (fieldType == 'email') {
              if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(v)) {
                return 'Enter a valid email address';
              }
            }
            if (fieldType == 'phone') {
              if (v.length != 10 ||
                  !RegExp(r'^[0-9]+$').hasMatch(v)) {
                return 'Enter valid 10-digit number';
              }
            }
            if (fieldType == 'dob') {
              if (!RegExp(r'^\d{2}/\d{2}/\d{4}$')
                  .hasMatch(v)) {
                return 'Enter date as DD/MM/YYYY';
              }
            }
            if (fieldType == 'year') {
              if (v.length != 4 ||
                  !RegExp(r'^[0-9]+$').hasMatch(v)) {
                return 'Enter valid 4-digit year';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            fillColor: _isEditing
                ? Colors.white
                : const Color(0xFFF9FAFB),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFD1D5DB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF5B21B6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Colors.red, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── Dropdown field ────────────────────────────────────────
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
        IgnorePointer(
          ignoring: !_isEditing,
          child: DropdownButtonFormField<String>(
  initialValue: value,
            items: items
                .map((e) => DropdownMenuItem(
                    value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              fillColor: _isEditing
                  ? Colors.white
                  : const Color(0xFFF9FAFB),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF5B21B6), width: 2),
              ),
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
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF5B21B6)))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Avatar ──
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius:
                                BorderRadius.circular(45),
                          ),
                          child: const Icon(Icons.person,
                              size: 50,
                              color: Color(0xFF5B21B6)),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF5B21B6),
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16,
                                  color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Student',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B0764)),
                    ),
                    Text(
                      _selectedDepartment,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 24),

                    // ── Mobile READ ONLY ──
                    _buildReadOnlyField(
                        'Mobile Number', _mobileNumber),

                    // ── All other fields ──
                    _buildTextField(
                        'Full Name', _nameController,
                        fieldType: 'name'),
                    _buildTextField(
                        'Email Address', _emailController,
                        type: TextInputType.emailAddress,
                        fieldType: 'email'),
                    _buildDropdown(
                        'Gender',
                        _selectedGender,
                        _genders,
                        (v) => setState(
                            () => _selectedGender = v!)),
                    _buildTextField(
                        'Date of Birth', _dobController,
                        fieldType: 'dob'),
                    _buildDropdown(
                        'Department',
                        _selectedDepartment,
                        _departments,
                        (v) => setState(
                            () => _selectedDepartment = v!)),
                    _buildDropdown(
                        'Year',
                        _selectedYear,
                        _years,
                        (v) => setState(
                            () => _selectedYear = v!)),
                    _buildDropdown(
                        '12th Standard Major',
                        _selected12thMajor,
                        _majors,
                        (v) => setState(
                            () => _selected12thMajor = v!)),
                    _buildTextField(
                        'Year of Passing',
                        _yearOfPassingController,
                        type: TextInputType.number,
                        fieldType: 'year'),
                    _buildTextField(
                        'Parent Contact Number',
                        _parentContactController,
                        type: TextInputType.phone,
                        fieldType: 'phone'),

                    const SizedBox(height: 20),

                    // ── Go to Dashboard (view mode) ──
                    if (!_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _goToDashboard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF5B21B6),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        12)),
                          ),
                          child: const Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w600)),
                        ),
                      ),

                    // ── Save/Cancel (edit mode) ──
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(
                                  () => _isEditing = false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color:
                                        Color(0xFF5B21B6)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            12)),
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      color:
                                          Color(0xFF5B21B6),
                                      fontWeight:
                                          FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF5B21B6),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            12)),
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Save',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w600)),
                            ),
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