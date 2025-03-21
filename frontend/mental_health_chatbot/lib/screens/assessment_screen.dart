import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mental_health_chatbot/screens/screen_controller.dart';
// import 'package:your_app_path/screens/main_screen.dart'; // Update with the correct path

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  double _progressValue = 0.0;

  // Track focused field for animations
  String? _focusedField;

  // Form fields
  String? _gender;
  DateTime? _dob;
  String? _religion;
  String? _language;
  String? _salary;
  String? _maritalStatus;
  String? _healthIssues;
  String? _socialMediaHandles;
  String? _education;
  String? _nationality;
  String? _hobbies;
  String? _emergencyContact;
  String? _personalityType;

  // Page titles
  final List<String> _pageTitles = [
    'Basic Information',
    'Health & Status',
    'Personal Details',
    'Additional Information'
  ];

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    setState(() {
      _progressValue = (_currentPage + 1) / _pageTitles.length;
    });
  }

  void _nextPage() {
    if (_currentPage < _pageTitles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentPage++;
        _updateProgress();
      });
    } else {
      _submitForm();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentPage--;
        _updateProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F), // Dark purple background
      appBar: AppBar(
        title: const Text(
          'Tell Us About Yourself',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pageTitles[_currentPage],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                )
                    .animate(key: ValueKey(_currentPage))
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                // Custom animated progress bar
                Stack(
                  children: [
                    // Background track
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Progress fill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width:
                          MediaQuery.of(context).size.width * _progressValue -
                              48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFB9B0E8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    )
                        .animate(key: ValueKey(_progressValue))
                        .shimmer(delay: 300.ms, duration: 1.5.seconds),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_progressValue * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate(key: ValueKey(_progressValue))
                        .fadeIn()
                        .slideY(begin: 0.5, end: 0),
                    Text(
                      'Page ${_currentPage + 1} of ${_pageTitles.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    )
                        .animate(key: ValueKey(_currentPage))
                        .fadeIn()
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                  _updateProgress();
                });
              },
              children: [
                // Page 1: Basic Information
                _buildPage([
                  _buildDropdownField(
                    label: 'Gender',
                    value: _gender,
                    items: [
                      'Male',
                      'Female',
                      'Non-binary',
                      'Prefer not to say'
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                    icon: Icons.person,
                    fieldName: 'gender',
                  ),
                  _buildDateField(
                    label: 'Date of Birth',
                    selectedDate: _dob,
                    onDateSelected: (date) => setState(() => _dob = date),
                    fieldName: 'dob',
                  ),
                  _buildTextField(
                    label: 'Nationality',
                    onChanged: (value) => _nationality = value,
                    icon: Icons.flag,
                    fieldName: 'nationality',
                  ),
                ]),

                // Page 2: Health & Status
                _buildPage([
                  _buildDropdownField(
                    label: 'Marital Status',
                    value: _maritalStatus,
                    items: [
                      'Single',
                      'Married',
                      'Divorced',
                      'Widowed',
                      'Prefer not to say'
                    ],
                    onChanged: (value) =>
                        setState(() => _maritalStatus = value),
                    icon: Icons.people,
                    fieldName: 'maritalStatus',
                  ),
                  _buildTextField(
                    label: 'Health Issues (if any)',
                    onChanged: (value) => _healthIssues = value,
                    icon: Icons.health_and_safety,
                    multiline: true,
                    fieldName: 'healthIssues',
                  ),
                  _buildDropdownField(
                    label: 'Salary Range',
                    value: _salary,
                    items: [
                      '<₹30,000',
                      '₹30,000-₹60,000',
                      '₹60,000-₹1,00,000',
                      '>₹1,00,000',
                      'Prefer not to say'
                    ],
                    onChanged: (value) => setState(() => _salary = value),
                    icon: Icons.currency_rupee,
                    fieldName: 'salary',
                  ),
                ]),

                // Page 3: Personal Details
                _buildPage([
                  _buildTextField(
                    label: 'Religion (Optional)',
                    onChanged: (value) => _religion = value,
                    icon: Icons.church,
                    fieldName: 'religion',
                  ),
                  _buildTextField(
                    label: 'Preferred Language',
                    onChanged: (value) => _language = value,
                    icon: Icons.language,
                    fieldName: 'language',
                  ),
                  _buildTextField(
                    label: 'Education',
                    onChanged: (value) => _education = value,
                    icon: Icons.school,
                    fieldName: 'education',
                  ),
                ]),

                // Page 4: Additional Information
                _buildPage([
                  _buildTextField(
                    label: 'Hobbies & Interests',
                    onChanged: (value) => _hobbies = value,
                    icon: Icons.interests,
                    multiline: true,
                    fieldName: 'hobbies',
                  ),
                  _buildTextField(
                    label: 'Social Media Handles (Optional)',
                    onChanged: (value) => _socialMediaHandles = value,
                    icon: Icons.share,
                    fieldName: 'socialMedia',
                  ),
                  _buildTextField(
                    label: 'Emergency Contact',
                    onChanged: (value) => _emergencyContact = value,
                    icon: Icons.emergency,
                    fieldName: 'emergencyContact',
                  ),
                  _buildDropdownField(
                    label: 'Personality Type',
                    value: _personalityType,
                    items: ['Introvert', 'Extrovert', 'Ambivert', 'Not sure'],
                    onChanged: (value) =>
                        setState(() => _personalityType = value),
                    icon: Icons.psychology,
                    fieldName: 'personalityType',
                  ),
                ]),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2A2F4F).withOpacity(0.1),
                  const Color(0xFF2A2F4F),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                if (_currentPage > 0)
                  TextButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                      .animate(key: ValueKey("back-$_currentPage"))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.2, end: 0)
                else
                  const SizedBox(width: 100),

                // Next/Submit button
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF2A2F4F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.5),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage < _pageTitles.length - 1
                            ? 'Next'
                            : 'Submit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentPage < _pageTitles.length - 1)
                        const Icon(Icons.arrow_forward, size: 18)
                            .animate()
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0, delay: 200.ms),
                      if (_currentPage == _pageTitles.length - 1)
                        const Icon(Icons.check, size: 18)
                            .animate()
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0, delay: 200.ms),
                    ],
                  ),
                )
                    .animate(key: ValueKey("next-$_currentPage"))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.2, end: 0)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(delay: 2.seconds, duration: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(List<Widget> fields) {
    // Calculate staggered animations
    final List<Widget> animatedFields = [];
    for (int i = 0; i < fields.length; i++) {
      animatedFields.add(fields[i]
          .animate(key: ValueKey('page-$_currentPage-field-$i'))
          .fadeIn(duration: 500.ms, delay: (100 * i).ms)
          .slideY(
              begin: 0.3,
              end: 0,
              curve: Curves.easeOutQuad,
              delay: (100 * i).ms));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: animatedFields,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    IconData? icon,
    bool multiline = false,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _focusedField = hasFocus ? fieldName : null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _focusedField == fieldName
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            maxLines: multiline ? 3 : 1,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: _focusedField == fieldName
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: _focusedField == fieldName
                    ? FontWeight.w500
                    : FontWeight.normal,
                letterSpacing: 0.3,
              ),
              filled: true,
              fillColor: _focusedField == fieldName
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color: _focusedField == fieldName
                          ? Colors.white
                          : Colors.white70,
                    )
                      .animate(
                          key: ValueKey(
                              'icon-$fieldName-${_focusedField == fieldName}'))
                      .scaleXY(
                        begin: 1.0,
                        end: _focusedField == fieldName ? 1.1 : 1.0,
                        duration: 300.ms,
                      )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              hoverColor: Colors.white.withOpacity(0.07),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            cursorColor: Colors.white,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _focusedField = hasFocus ? fieldName : null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _focusedField == fieldName
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: _focusedField == fieldName
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: _focusedField == fieldName
                    ? FontWeight.w500
                    : FontWeight.normal,
                letterSpacing: 0.3,
              ),
              filled: true,
              fillColor: _focusedField == fieldName
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color: _focusedField == fieldName
                          ? Colors.white
                          : Colors.white70,
                    )
                      .animate(
                          key: ValueKey(
                              'dropdown-icon-$fieldName-${_focusedField == fieldName}'))
                      .scaleXY(
                        begin: 1.0,
                        end: _focusedField == fieldName ? 1.1 : 1.0,
                        duration: 300.ms,
                      )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            value: value,
            dropdownColor: const Color(0xFF3F4373),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: _focusedField == fieldName ? Colors.white : Colors.white70,
              size: 28,
            )
                .animate(
                    key: ValueKey(
                        'dropdown-arrow-$fieldName-${_focusedField == fieldName}'))
                .scaleXY(
                  begin: 1.0,
                  end: _focusedField == fieldName ? 1.2 : 1.0,
                  duration: 300.ms,
                ),
            borderRadius: BorderRadius.circular(12),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              onChanged(val);
              // Add a subtle animation when selection changes
              if (val != null) {
                Future.delayed(const Duration(milliseconds: 50), () {
                  // This triggers a small animation when value changes
                  setState(() {});
                });
              }
            },
            menuMaxHeight: 300,
            isExpanded: true,
          ),
        ),
      ),
    )
        .animate(
          // Add a subtle pulse when dropdown is opened
          target: _focusedField == fieldName ? 1 : 0,
        )
        .scaleXY(
          begin: 1.0,
          end: 1.02,
          duration: 200.ms,
        )
        .then()
        .scaleXY(
          begin: 1.02,
          end: 1.0,
          duration: 200.ms,
        );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _focusedField = hasFocus ? fieldName : null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _focusedField == fieldName
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              onTap: () async {
                // Set focus when tapped
                setState(() {
                  _focusedField = fieldName;
                });

                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.white,
                          onPrimary: Color(0xFF2A2F4F),
                          surface: Color(0xFF3A3F5F),
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: const Color(0xFF2A2F4F),
                        dialogTheme: DialogTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 24,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (date != null) {
                  onDateSelected(date);
                  // Simulate a button press animation
                  setState(() {});
                }

                // Reset focus after selection
                Future.delayed(const Duration(milliseconds: 200), () {
                  setState(() {
                    _focusedField = null;
                  });
                });
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: _focusedField == fieldName
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    fontSize: 15,
                    fontWeight: _focusedField == fieldName
                        ? FontWeight.w500
                        : FontWeight.normal,
                    letterSpacing: 0.3,
                  ),
                  filled: true,
                  fillColor: _focusedField == fieldName
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: _focusedField == fieldName || selectedDate != null
                        ? Colors.white
                        : Colors.white70,
                  )
                      .animate(
                          key: ValueKey(
                              'date-icon-$fieldName-${selectedDate != null}'))
                      .scaleXY(
                        begin: 1.0,
                        end: _focusedField == fieldName ? 1.1 : 1.0,
                        duration: 300.ms,
                      ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  suffixIcon: selectedDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.white60, size: 18),
                          onPressed: () {
                            setState(() {
                              onDateSelected(DateTime(0)); // Reset date
                            });
                          },
                        ).animate().fadeIn()
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null && selectedDate.year > 1900
                            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                            : 'Select date',
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Animated chevron
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white54,
                    )
                        .animate(
                          target: _focusedField == fieldName ? 1 : 0,
                        )
                        .scaleXY(
                          begin: 1.0,
                          end: 1.2,
                          duration: 200.ms,
                        )
                        .slideX(
                          begin: 0,
                          end: 0.2,
                          duration: 200.ms,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(
          key: ValueKey('date-field-$fieldName-${selectedDate != null}'),
          target: selectedDate != null ? 1 : 0,
        )
        .custom(
          duration: 400.ms,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: selectedDate != null
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05 * value),
                          blurRadius: 8 * value,
                          spreadRadius: 1 * value,
                        )
                      ]
                    : null,
              ),
              child: child,
            );
          },
        );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? true) {
      // Show success animation with enhanced effects
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF0F0F7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 80,
                  ).animate().scaleXY(
                        begin: 0.8,
                        end: 1.0,
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 16),
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2F4F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your information has been submitted successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2A2F4F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to MainScreen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2F4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
