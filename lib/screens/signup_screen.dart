import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? selectedInstitution;

  final institutions = const [
    'University of Ghana',
    'KNUST',
    'University of Cape Coast',
    'UPSA',
    'GIMPA',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF4F8FF),
                Color(0xFFF7F6FF),
              ],
            ),
          ),
          child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.065),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.13),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create A New Account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SignUpInput(hintText: 'Full Name'),
                    const SizedBox(height: 16),
                    const _PhoneInput(),
                    const SizedBox(height: 16),
                    _InstitutionDropdown(
                      value: selectedInstitution,
                      institutions: institutions,
                      onChanged: (value) {
                        setState(() => selectedInstitution = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const _SignUpInput(
                      hintText: 'Enter Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const _SignUpInput(
                      hintText: 'Enter Password',
                      icon: Icons.key_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    const _SignUpInput(
                      hintText: 'Confirm New Password',
                      icon: Icons.key_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            DashboardScreen.id,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF34368C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}

class _SignUpInput extends StatelessWidget {
  const _SignUpInput({
    required this.hintText,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final String hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        color: const Color(0xFF222222),
        fontSize: 14,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF8F8F8F),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                color: const Color(0xFF7C7C7C),
                size: 20,
              ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.68),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.phone,
      style: GoogleFonts.poppins(
        color: const Color(0xFF222222),
        fontSize: 14,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: 'Enter Mobile Number',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF8F8F8F),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/gh.png',
                width: 20,
                height: 14,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 14),
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFD9D9D9),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.68),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _InstitutionDropdown extends StatelessWidget {
  const _InstitutionDropdown({
    required this.value,
    required this.institutions,
    required this.onChanged,
  });

  final String? value;
  final List<String> institutions;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: institutions.map((institution) {
        return DropdownMenuItem(
          value: institution,
          child: Text(institution),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF7C7C7C),
      ),
      style: GoogleFonts.poppins(
        color: const Color(0xFF222222),
        fontSize: 13,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: 'Choose Your Institution',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF8F8F8F),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.68),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
