import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tescon_app/core/auth_service.dart';
import 'package:tescon_app/core/biometric_auth_service.dart';
import 'package:tescon_app/core/push_notification_service.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';
import 'package:tescon_app/screens/onboarding_screen.dart';
import 'package:tescon_app/screens/sigin_screen.dart';
import 'package:tescon_app/screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.ensureFirebaseInitialized();
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
      home: const _AuthGate(),
      routes: {
        OnboardingScreen.id: (context) => const OnboardingScreen(),
        SiginScreen.id: (context) => const SiginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        DashboardScreen.id: (context) => const DashboardScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canEnterApp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: _AuthGateShimmer());
        }

        return snapshot.data!
            ? const DashboardScreen()
            : const OnboardingScreen();
      },
    );
  }

  Future<bool> _canEnterApp() async {
    final hasSession = await AuthService().hasSession();
    if (!hasSession) return false;

    final biometricService = BiometricAuthService();
    if (!await biometricService.isEnabled()) return true;
    return biometricService.authenticate();
  }
}

class _AuthGateShimmer extends StatelessWidget {
  const _AuthGateShimmer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8ECF4),
        highlightColor: const Color(0xFFF8FAFF),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 124,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
