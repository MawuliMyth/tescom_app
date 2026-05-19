import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tescon_app/screens/sigin_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String id = 'onboarding_screen';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF80B6DB),
              Color(0xFF24569A),
              Color(0xFF09286E),
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Column(
                children: [
                  SizedBox(height: height * 0.08),
                  SizedBox(
                    height: height * 0.44,
                    width: width,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: -0.2,
                          child: _OnboardingGlass(
                            width: width * 0.68,
                            height: height * 0.28,
                            borderRadius: 36,
                            child: const SizedBox.expand(),
                          ),
                        ),
                        Positioned(
                          left: width * 0.09,
                          top: height * 0.13,
                          child: Transform.rotate(
                            angle: -0.23,
                            child: _TiltedPhoto(
                              imagePath: 'assets/images/l.png',
                              width: width * 0.5,
                              height: height * 0.22,
                              fallbackColor: const Color(0xFF6D88AE),
                            ),
                          ),
                        ),
                        Positioned(
                          right: width * 0.05,
                          top: height * 0.04,
                          child: Transform.rotate(
                            angle: 0.08,
                            child: _TiltedPhoto(
                              imagePath: 'assets/images/r.png',
                              width: width * 0.54,
                              height: height * 0.24,
                              fallbackColor: const Color(0xFF9CB8D0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'TESCON',
                    style: GoogleFonts.lilitaOne(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to Tescon App',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 38),
                  SizedBox(
                    width: width * 0.54,
                    height: 48,
                    child: _OnboardingGlass(
                      borderRadius: 26,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, SiginScreen.id);
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Center(
                          child: Text(
                            'Get Started',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.09),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingGlass extends StatelessWidget {
  const _OnboardingGlass({
    required this.child,
    required this.borderRadius,
    this.width,
    this.height,
  });

  final Widget child;
  final double borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TiltedPhoto extends StatelessWidget {
  const _TiltedPhoto({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.fallbackColor,
  });

  final String imagePath;
  final double width;
  final double height;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: fallbackColor,
            child: Icon(
              Icons.image_outlined,
              color: Colors.white.withValues(alpha: 0.55),
              size: 34,
            ),
          );
        },
      ),
    );
  }
}
