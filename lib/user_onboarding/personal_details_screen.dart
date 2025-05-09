import 'package:flutter/material.dart';
import 'id_verification_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // Default values for form inputs
  @override
  void initState() {
    super.initState();
    // Set default values
    _firstNameController.text = "Rajat";
    _lastNameController.text = "Pradhan";
    _emailController.text = "rajat.pradhan@gmail.com";
    _dayController.text = "06";
    _monthController.text = "05";
    _yearController.text = "2001";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF19173A), Color(0xFF363079)],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5F67EE).withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5F67EE).withOpacity(0.15),
                    ),
                  ),
                ),
                
                // Main content
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Personal Details',
                          style: TextStyle(
                            color: Color(0xFF19173A),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Please provide your personal information to complete your profile',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Form fields
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // First Name
                              buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hintText: 'Enter your first name',
                                helperText: 'Helper text for status and guidance',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              // Last Name
                              buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hintText: 'Enter your last name',
                                helperText: 'Helper text for status and guidance',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              // Email
                              buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hintText: 'Enter your email address',
                                helperText: 'Helper text for status and guidance',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  // Basic email validation
                                  if (!value.contains('@') || !value.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              
                              // Birthday section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Birthday',
                                    style: TextStyle(
                                      color: Color(0xFF19173A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Day, Month, Year fields
                                  Row(
                                    children: [
                                      // Day
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Day',
                                              style: TextStyle(
                                                color: Color(0xFF19173A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TextFormField(
                                                controller: _dayController,
                                                keyboardType: TextInputType.number,
                                                maxLength: 2,
                                                style: TextStyle(fontSize: 15),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  int? day = int.tryParse(value);
                                                  if (day == null || day < 1 || day > 31) {
                                                    return 'Invalid';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'DD',
                                                  counterText: '',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Helper text for status and guidance',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      
                                      // Month
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Month',
                                              style: TextStyle(
                                                color: Color(0xFF19173A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TextFormField(
                                                controller: _monthController,
                                                keyboardType: TextInputType.number,
                                                maxLength: 2,
                                                style: TextStyle(fontSize: 15),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  int? month = int.tryParse(value);
                                                  if (month == null || month < 1 || month > 12) {
                                                    return 'Invalid';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'MM',
                                                  counterText: '',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Helper text for status and guidance',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      
                                      // Year
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Year',
                                              style: TextStyle(
                                                color: Color(0xFF19173A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TextFormField(
                                                controller: _yearController,
                                                keyboardType: TextInputType.number,
                                                maxLength: 4,
                                                style: TextStyle(fontSize: 15),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  int? year = int.tryParse(value);
                                                  if (year == null || year < 1900 || year > DateTime.now().year) {
                                                    return 'Invalid';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'YYYY',
                                                  counterText: '',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Helper text for status and guidance',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 25),
                              
                              // Continue button
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF5F67EE).withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Navigate to ID Verification screen
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => IdVerificationScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF5F67EE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Back button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5F67EE).withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF5F67EE),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF19173A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            maxLines: maxLines,
            onTap: onTap,
            validator: validator,
            style: TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
              prefixIcon: Icon(icon, color: Color(0xFF5F67EE), size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 2),
            child: Text(
              helperText,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 9,
              ),
            ),
          ),
      ],
    );
  }
} 