import 'package:flutter/material.dart';
import 'package:smart_eommerce/user_onboarding/personal_details_screen.dart';

class OtpScreen extends StatefulWidget {
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // OTP digit controllers
  final TextEditingController _firstDigitController = TextEditingController();
  final TextEditingController _secondDigitController = TextEditingController();
  final TextEditingController _thirdDigitController = TextEditingController();
  final TextEditingController _fourthDigitController = TextEditingController();
  
  // Focus nodes for each digit field
  final FocusNode _firstDigitFocusNode = FocusNode();
  final FocusNode _secondDigitFocusNode = FocusNode();
  final FocusNode _thirdDigitFocusNode = FocusNode();
  final FocusNode _fourthDigitFocusNode = FocusNode();
  
  @override
  void dispose() {
    // Dispose controllers
    _firstDigitController.dispose();
    _secondDigitController.dispose();
    _thirdDigitController.dispose();
    _fourthDigitController.dispose();
    
    // Dispose focus nodes
    _firstDigitFocusNode.dispose();
    _secondDigitFocusNode.dispose();
    _thirdDigitFocusNode.dispose();
    _fourthDigitFocusNode.dispose();
    
    super.dispose();
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
                // Top Image that covers the upper part of the card
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Image.asset(
                        'assets/images/otp.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Decorative circles
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6366F1).withOpacity(0.2),
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
                      color: Color(0xFF6366F1).withOpacity(0.15),
                    ),
                  ),
                ),
                
                // Main content with scroll
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Space for the image at the top
                      SizedBox(height: 220),
                      
                      // Content with padding
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Column(
                          children: [
                            // OTP Verification Text
                            Text(
                              'OTP Verification',
                              style: TextStyle(
                                color: Color(0xFF19173A),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Instruction text
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1).withOpacity(0.08),
                                    Color(0xFF6366F1).withOpacity(0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Enter the OTP sent to\n',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '+91 7024393158',
                                      style: TextStyle(
                                        color: Color(0xFF19173A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // OTP input fields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // First digit
                                buildOTPDigitField(
                                  controller: _firstDigitController,
                                  focusNode: _firstDigitFocusNode,
                                  nextFocusNode: _secondDigitFocusNode,
                                ),
                                
                                // Second digit
                                buildOTPDigitField(
                                  controller: _secondDigitController,
                                  focusNode: _secondDigitFocusNode,
                                  nextFocusNode: _thirdDigitFocusNode,
                                  previousFocusNode: _firstDigitFocusNode,
                                ),
                                
                                // Third digit
                                buildOTPDigitField(
                                  controller: _thirdDigitController,
                                  focusNode: _thirdDigitFocusNode,
                                  nextFocusNode: _fourthDigitFocusNode,
                                  previousFocusNode: _secondDigitFocusNode,
                                ),
                                
                                // Fourth digit
                                buildOTPDigitField(
                                  controller: _fourthDigitController,
                                  focusNode: _fourthDigitFocusNode,
                                  previousFocusNode: _thirdDigitFocusNode,
                                  isLast: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // Resend OTP
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Didn\'t receive the OTP? ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Resend OTP',
                                    style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Verify button
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PersonalDetailsScreen()),
                                  );
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
                                  'Verify OTP',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildOTPDigitField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    FocusNode? previousFocusNode,
    bool isLast = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
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
            borderSide: BorderSide(color: Color(0xFF6366F1), width: 1.0),
          ),
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF19173A),
        ),
        onChanged: (value) {
          if (value.length == 1 && nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else if (value.isEmpty && previousFocusNode != null) {
            previousFocusNode.requestFocus();
          }
          
          if (isLast && value.length == 1) {
            // Hide keyboard when last digit is entered
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }
}