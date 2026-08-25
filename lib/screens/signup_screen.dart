import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tescon_app/core/auth_service.dart';
import 'package:tescon_app/core/institutions.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';
import 'package:tescon_app/screens/sigin_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        institution: _institutionController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, DashboardScreen.id);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ColoredBox(
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.065),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Form(
                    key: _formKey,
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
                        _SignUpInput(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          textInputAction: TextInputAction.next,
                          validator: _validateFullName,
                        ),
                        const SizedBox(height: 16),
                        _PhoneInput(controller: _phoneController),
                        const SizedBox(height: 16),
                        _InstitutionAutocomplete(
                          controller: _institutionController,
                          institutions: ghanaInstitutions,
                          validator: _validateInstitution,
                        ),
                        const SizedBox(height: 16),
                        _SignUpInput(
                          controller: _emailController,
                          hintText: 'Enter Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        _SignUpInput(
                          controller: _passwordController,
                          hintText: 'Enter Password',
                          icon: Icons.key_outlined,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        _SignUpInput(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm New Password',
                          icon: Icons.key_outlined,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) => _validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) =>
                              _isSubmitting ? null : _signUp(),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _signUp,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF34368C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _isSubmitting ? 'Signing Up...' : 'Sign Up',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF7A7A7A),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                  return;
                                }
                                Navigator.pushReplacementNamed(
                                  context,
                                  SiginScreen.id,
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF34368C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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

final RegExp _emailPattern = RegExp(
  r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
  caseSensitive: false,
);
final RegExp _namePattern = RegExp(r"^[A-Za-z][A-Za-z' -]{1,}$");
final RegExp _ghanaPhonePattern = RegExp(
  r'^(?:0|233)(?:20|23|24|25|26|27|28|29|50|53|54|55|56|57|59)[0-9]{7}$',
);

String? _validateFullName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Full name is required';
  if (name.length < 2) return 'Enter your full name';
  if (!_namePattern.hasMatch(name)) {
    return 'Use letters, spaces, hyphens, or apostrophes only';
  }
  return null;
}

String? _validatePhone(String? value) {
  final phone = (value ?? '').replaceAll(RegExp(r'\s+'), '');
  if (phone.isEmpty) return 'Phone number is required';
  if (!_ghanaPhonePattern.hasMatch(phone)) {
    return 'Enter a valid Ghana phone number';
  }
  return null;
}

String? _validateInstitution(String? value) {
  final institution = value?.trim() ?? '';
  if (institution.isEmpty) return 'Enter your institution';
  if (institution.length < 3) return 'Enter a valid institution name';
  return null;
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? _validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required';
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'\d').hasMatch(password)) {
    return 'Use at least one letter and one number';
  }
  return null;
}

String? _validateConfirmPassword(String? value, String password) {
  final confirmPassword = value ?? '';
  if (confirmPassword.isEmpty) return 'Confirm your password';
  if (confirmPassword != password) return 'Passwords do not match';
  return null;
}

class _SignUpInput extends StatefulWidget {
  const _SignUpInput({
    required this.controller,
    required this.hintText,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_SignUpInput> createState() => _SignUpInputState();
}

class _SignUpInputState extends State<_SignUpInput> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.poppins(
        color: const Color(0xFF222222),
        fontSize: 14,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF8F8F8F),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: const Color(0xFF7C7C7C), size: 20),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7C7C7C),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: _validatePhone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
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
              Container(width: 1, height: 24, color: const Color(0xFFD9D9D9)),
            ],
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InstitutionAutocomplete extends StatefulWidget {
  const _InstitutionAutocomplete({
    required this.controller,
    required this.institutions,
    this.validator,
  });

  final TextEditingController controller;
  final List<String> institutions;
  final FormFieldValidator<String>? validator;

  @override
  State<_InstitutionAutocomplete> createState() =>
      _InstitutionAutocompleteState();
}

class _InstitutionAutocompleteState extends State<_InstitutionAutocomplete> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return widget.institutions.take(8);
        return widget.institutions
            .where((institution) => institution.toLowerCase().contains(query))
            .take(10);
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              validator: widget.validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: GoogleFonts.poppins(
                color: const Color(0xFF222222),
                fontSize: 13,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                hintText: 'Search or type your institution',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8F8F8F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7C7C7C),
                ),
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                errorStyle: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        final values = options.toList(growable: false);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.87,
              constraints: const BoxConstraints(maxHeight: 260),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: values.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFEFEFEF),
                ),
                itemBuilder: (context, index) {
                  final institution = values[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      institution,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF222222),
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                    onTap: () => onSelected(institution),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (value) => widget.controller.text = value,
    );
  }
}
