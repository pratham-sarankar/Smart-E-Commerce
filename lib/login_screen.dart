import 'package:flutter/material.dart';
import 'package:smart_eommerce/otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
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
                
                // Main content with scroll
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 40, // Account for SafeArea margin
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Top section
                            Column(
                              children: [
                                // Decorated logo section
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF5F67EE).withOpacity(0.2),
                                            Color(0xFF5F67EE).withOpacity(0.05),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Hero(
                                      tag: 'logo',
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Image.network(
                                          'https://cdn.builder.io/api/v1/image/assets/TEMP/2b11c06bdf765b35249d2275cc985e97f0b5fa2a',
                                          width: 50,
                                          height: 55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Hero(
                                  tag: 'title',
                                  child: Text(
                                    'MASTI LOTTIE',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5F67EE),
                                      letterSpacing: 2.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.12),
                                          offset: Offset(1, 2),
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Middle section
                            Column(
                              children: [
                                // Welcome text with gradient container
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF5F67EE).withOpacity(0.08),
                                        Color(0xFF5F67EE).withOpacity(0.02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Welcome',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF19173A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'By signing in you are agreeing our',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Text(
                                          'Term and privacy policy',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF5F67EE),
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Email field
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
                                  child: TextField(
                                    style: const TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'Email Address',
                                      hintStyle: const TextStyle(fontSize: 15),
                                      prefixIcon: Container(
                                        margin: EdgeInsets.only(left: 12, right: 8),
                                        child: Icon(Icons.email_outlined, color: Color(0xFF5F67EE), size: 22),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                                const SizedBox(height: 16),
                                // Password field
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
                                  child: TextField(
                                    style: const TextStyle(fontSize: 15),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: const TextStyle(fontSize: 15),
                                      prefixIcon: Container(
                                        margin: EdgeInsets.only(left: 12, right: 8),
                                        child: Icon(Icons.lock_outline, color: Color(0xFF5F67EE), size: 22),
                                      ),
                                      suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 22),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                                const SizedBox(height: 16),
                                // Remember password and Forget password
                                Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF5F67EE),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF5F67EE).withOpacity(0.3),
                                            blurRadius: 5,
                                            spreadRadius: 0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember password',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        'Forget password',
                                        style: TextStyle(
                                          color: Color(0xFF5F67EE),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Bottom section
                            Column(
                              children: [
                                // Login and Register buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
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
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen()));
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
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              spreadRadius: 0,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            // Navigate to the onboarding flow
                                            Navigator.pushNamed(context, '/onboarding');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFF5F67EE), width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                          child: const Text(
                                            'Register',
                                            style: TextStyle(
                                              color: Color(0xFF5F67EE),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: const Text(
                                    'Login with touch ID',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF5F67EE).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF5F67EE).withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint,
                                      color: Color(0xFF5F67EE),
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
}
