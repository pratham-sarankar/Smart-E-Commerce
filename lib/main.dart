import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_eommerce/auth/login_screen.dart';
import 'package:smart_eommerce/auth/splash_screen.dart';
import 'package:smart_eommerce/user_onboarding/personal_details_screen.dart';
import 'package:smart_eommerce/user_onboarding/id_verification_screen.dart';
import 'package:smart_eommerce/user_onboarding/account_success_screen.dart';
import 'package:smart_eommerce/screens/main_screen.dart';
import 'package:smart_eommerce/auth/register_screen.dart';
import 'package:smart_eommerce/auth/forgot_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
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
        primaryColor: Color(0xFF0B1D3A),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0B1D3A),
          secondary: Color(0xFFFFD700),
          background: Color(0xFF0B1D3A),
          surface: Color(0xFF0B1D3A),
        ),
        scaffoldBackgroundColor: Color(0xFF0B1D3A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B1D3A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFFFD700)),
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFD700),
            foregroundColor: Color(0xFF0B1D3A),
          ),
        ),
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