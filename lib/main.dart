import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tescon_app/core/app_repository.dart';
import 'package:tescon_app/core/auth_service.dart';
import 'package:tescon_app/core/biometric_auth_service.dart';
import 'package:tescon_app/core/push_notification_service.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';
import 'package:tescon_app/screens/forgot_password_screen.dart';
import 'package:tescon_app/screens/onboarding_screen.dart';
import 'package:tescon_app/screens/profile_completion_screen.dart';
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
        pageTransitionsTheme: PageTransitionsTheme(
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
        ForgotPasswordScreen.id: (context) => const ForgotPasswordScreen(),
        ProfileCompletionScreen.id: (context) =>
            const ProfileCompletionScreen(),
        DashboardScreen.id: (context) => const DashboardScreen(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  static const bool _portfolioDemo = bool.fromEnvironment(
    'PORTFOLIO_DEMO',
  );

  @override
  Widget build(BuildContext context) {
    if (_portfolioDemo) return const DashboardScreen();

    return FutureBuilder<_AuthDestination>(
      future: _canEnterApp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _QuietAuthCheck();
        }

        return switch (snapshot.data!) {
          _AuthDestination.dashboard => const DashboardScreen(),
          _AuthDestination.completeProfile => const ProfileCompletionScreen(),
          _AuthDestination.onboarding => const _SplashToOnboarding(),
        };
      },
    );
  }

  Future<_AuthDestination> _canEnterApp() async {
    final hasSession = await AuthService().hasSession();
    if (!hasSession) return _AuthDestination.onboarding;

    final biometricService = BiometricAuthService();
    if (await biometricService.isEnabled() &&
        !await biometricService.authenticate()) {
      return _AuthDestination.onboarding;
    }

    final user = await AppRepository().loadCurrentUser();
    if ((user?.institution ?? '').trim().isEmpty) {
      return _AuthDestination.completeProfile;
    }
    return _AuthDestination.dashboard;
  }
}

enum _AuthDestination { onboarding, completeProfile, dashboard }

class _QuietAuthCheck extends StatelessWidget {
  const _QuietAuthCheck();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

class _SplashToOnboarding extends StatefulWidget {
  const _SplashToOnboarding();

  @override
  State<_SplashToOnboarding> createState() => _SplashToOnboardingState();
}

class _SplashToOnboardingState extends State<_SplashToOnboarding> {
  bool showOnboarding = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => showOnboarding = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return showOnboarding ? const OnboardingScreen() : const _AppLaunchSplash();
  }
}

class _AppLaunchSplash extends StatelessWidget {
  const _AppLaunchSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34368C).withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 18),
            Text(
              'Tescon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF34368C),
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
