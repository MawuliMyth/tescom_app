import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tescon_app/core/app_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String id = 'forgot_password_screen';

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _codeSent = false;
  bool _passwordReset = false;
  String? _message;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();
    if (!(_emailFormKey.currentState?.validate() ?? false) || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _message = null;
    });

    try {
      final message = await AppRepository().requestPasswordReset(
        email: _emailController.text,
      );
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _message = message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (!(_resetFormKey.currentState?.validate() ?? false) || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppRepository().resetPassword(
        token: _codeController.text,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _passwordReset = true;
        _message = 'Your password has been reset successfully.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _passwordReset
        ? 'Password Reset!'
        : _codeSent
        ? 'Check your email'
        : 'Forgot your password?';
    final subtitle = _passwordReset
        ? _message ?? 'Your password has been reset successfully.'
        : _codeSent
        ? _message ?? 'Enter the reset code and your new password.'
        : 'Enter your email and we will send you a reset code.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _RoundBackButton(onTap: () => Navigator.pop(context)),
            ),
            const SizedBox(height: 56),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34368C).withValues(alpha: 0.08),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCC4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _passwordReset
                          ? Icons.check_rounded
                          : Icons.lock_outline_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_codeSent && !_passwordReset)
                    Form(
                      key: _emailFormKey,
                      child: _ResetInput(
                        controller: _emailController,
                        label: 'E-mail',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            _isSubmitting ? null : _requestCode(),
                        validator: _validateEmail,
                      ),
                    ),
                  if (_codeSent && !_passwordReset)
                    Form(
                      key: _resetFormKey,
                      child: Column(
                        children: [
                          _ResetInput(
                            controller: _codeController,
                            label: 'Reset code',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: _validateResetCode,
                          ),
                          const SizedBox(height: 14),
                          _ResetInput(
                            controller: _passwordController,
                            label: 'New password',
                            icon: Icons.key_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            validator: _validateNewPassword,
                          ),
                          const SizedBox(height: 14),
                          _ResetInput(
                            controller: _confirmPasswordController,
                            label: 'Confirm new password',
                            icon: Icons.key_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                _isSubmitting ? null : _resetPassword(),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE54848),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : _passwordReset
                          ? () => Navigator.pop(context)
                          : _codeSent
                          ? _resetPassword
                          : _requestCode,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF34368C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFECE4FF),
                        disabledForegroundColor: const Color(0xFF8D80B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _isSubmitting
                            ? 'Confirming...'
                            : _passwordReset
                            ? 'Continue'
                            : _codeSent
                            ? 'Reset Password'
                            : 'Confirm',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  if (_codeSent && !_passwordReset) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSubmitting ? null : _requestCode,
                      child: const Text('Resend code'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: const Text('Return to the login screen'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF34368C),
                      textStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF34368C)),
        ),
      ),
    );
  }
}

class _ResetInput extends StatefulWidget {
  const _ResetInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_ResetInput> createState() => _ResetInputState();
}

class _ResetInputState extends State<_ResetInput> {
  late bool obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(
        color: const Color(0xFF222222),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: const Color(0xFF7C7C7C), size: 20),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7C7C7C),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF34368C), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE54848)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE54848), width: 1.4),
        ),
      ),
    );
  }
}

final RegExp _emailPattern = RegExp(
  r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
  caseSensitive: false,
);

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? _validateResetCode(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Reset code is required';
  if (!RegExp(r'^\d{6}$').hasMatch(code)) return 'Enter the 6 digit code';
  return null;
}

String? _validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a new password';
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'\d').hasMatch(password)) {
    return 'Use letters and numbers';
  }
  return null;
}
