import 'package:flutter/material.dart';
import 'package:smart_eommerce/auth/login_screen.dart';
import 'package:smart_eommerce/auth/splash_screen.dart';
import 'package:smart_eommerce/user_onboarding/personal_details_screen.dart';
import 'package:smart_eommerce/user_onboarding/id_verification_screen.dart';
import 'package:smart_eommerce/user_onboarding/account_success_screen.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/auth/register_screen.dart';
import 'package:smart_eommerce/auth/forgot_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF5F67EE),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF5F67EE),
          secondary: Color(0xFF19173A),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/onboarding': (context) => PersonalDetailsScreen(),
        '/id_verification': (context) => IdVerificationScreen(),
        '/account_success': (context) => AccountSuccessScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}