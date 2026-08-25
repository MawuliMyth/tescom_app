import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tescon_app/core/app_models.dart';
import 'package:tescon_app/core/app_repository.dart';
import 'package:tescon_app/core/institutions.dart';
import 'package:tescon_app/screens/dashboard_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  static const String id = 'profile_completion_screen';

  const ProfileCompletionScreen({super.key, this.user});

  final AppUser? user;

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _repository = AppRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    _schoolController = TextEditingController(
      text: widget.user?.institution ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _repository.updateProfile(
        fullName: _nameController.text.trim(),
        institution: _schoolController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        DashboardScreen.id,
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      SizedBox(height: constraints.maxHeight * 0.14),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111111),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your school so TESCON can show the right members, executives, and chapter content first.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF777777),
                          fontSize: 12,
                          height: 1.45,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _CompletionInput(
                        controller: _nameController,
                        hintText: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        validator: _validateName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _CompletionInstitutionAutocomplete(
                        controller: _schoolController,
                        institutions: ghanaInstitutions,
                        validator: _validateSchool,
                        onFieldSubmitted: (_) =>
                            _isSubmitting ? null : _completeProfile(),
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
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _completeProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF34368C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _isSubmitting ? 'Saving...' : 'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
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
    );
  }
}

String? _validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Full name is required';
  if (name.length < 2) return 'Enter your full name';
  return null;
}

String? _validateSchool(String? value) {
  final school = value?.trim() ?? '';
  if (school.isEmpty) return 'School is required';
  if (ghanaInstitutions.any(
    (institution) => institution.toLowerCase() == school.toLowerCase(),
  )) {
    return null;
  }
  if (school.length < 2) return 'Enter a valid school name';
  return null;
}

class _CompletionInput extends StatelessWidget {
  const _CompletionInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
        prefixIcon: Icon(icon, color: const Color(0xFF7C7C7C), size: 20),
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

class _CompletionInstitutionAutocomplete extends StatefulWidget {
  const _CompletionInstitutionAutocomplete({
    required this.controller,
    required this.institutions,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final List<String> institutions;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_CompletionInstitutionAutocomplete> createState() =>
      _CompletionInstitutionAutocompleteState();
}

class _CompletionInstitutionAutocompleteState
    extends State<_CompletionInstitutionAutocomplete> {
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
              textInputAction: TextInputAction.done,
              validator: widget.validator,
              onFieldSubmitted: widget.onFieldSubmitted,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: GoogleFonts.poppins(
                color: const Color(0xFF222222),
                fontSize: 14,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                hintText: 'Search or type your school',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8F8F8F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                prefixIcon: const Icon(
                  Icons.school_outlined,
                  color: Color(0xFF7C7C7C),
                  size: 20,
                ),
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7C7C7C),
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
                    leading: const Icon(
                      Icons.school_outlined,
                      color: Color(0xFF34368C),
                      size: 18,
                    ),
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
