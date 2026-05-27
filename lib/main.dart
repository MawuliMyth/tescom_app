import 'package:flutter/material.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';
import 'package:tescon_app/screens/onboarding_screen.dart';
import 'package:tescon_app/screens/sigin_screen.dart';
import 'package:tescon_app/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34368C),
          brightness: Brightness.light,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
        useMaterial3: true,
      ),
      initialRoute: OnboardingScreen.id,
      routes: {
        OnboardingScreen.id: (context) => const OnboardingScreen(),
        SiginScreen.id: (context) => const SiginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        DashboardScreen.id: (context) => const DashboardScreen(),
      },
    );
  }
}
