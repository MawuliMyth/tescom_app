part of '../dashboard_screen.dart';

// Settings route with grouped preference/account sections.
class _SettingsPage extends StatefulWidget {
  const _SettingsPage({this.showBackButton = true});

  final bool showBackButton;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool notifications = true;
  bool biometricUnlock = false;
  bool loggingOut = false;
  final settingsService = AppSettingsService();
  final biometricService = BiometricAuthService();
  final pushNotificationService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await settingsService.notificationsEnabled();
    final biometricEnabled = await biometricService.isEnabled();
    if (!mounted) return;
    setState(() {
      notifications = enabled;
      biometricUnlock = biometricEnabled;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => notifications = value);
    if (value) {
      await pushNotificationService.enableNotifications();
    } else {
      await pushNotificationService.disableNotifications();
    }
  }

  Future<void> _setBiometricUnlock(bool value) async {
    if (value) {
      final available = await biometricService.isAvailable();
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric unlock is not available on this device'),
          ),
        );
        return;
      }
      final authenticated = await biometricService.authenticate(
        reason: 'Confirm your biometrics to enable app unlock',
      );
      if (!authenticated) return;
    }

    await biometricService.setEnabled(value);
    if (!mounted) return;
    setState(() => biometricUnlock = value);
  }

  Future<void> _clearImageCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image cache cleared')));
  }

  Future<void> _openChangePassword() async {
    await Navigator.push(
      context,
      _adaptivePageRoute(
        context,
        builder: (_) => const _ChangePasswordScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    if (loggingOut) return;
    setState(() => loggingOut = true);

    try {
      await AuthService().logout();
      await AppRepository().clearCachedSessionData();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('signin_screen', (_) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => loggingOut = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LogoutConfirmationSheet(),
    );
    if (shouldLogout == true) await _logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              _SettingsHeader(
                showBackButton: widget.showBackButton,
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 22),
              const _SettingsProfileHeader(),
              const SizedBox(height: 22),
              _SettingsSection(
                title: 'Preferences',
                children: [
                  _SettingsToggleRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications and sounds',
                    value: notifications,
                    onChanged: (value) => _setNotifications(value),
                  ),
                  _SettingsToggleRow(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric app unlock',
                    value: biometricUnlock,
                    onChanged: (value) => _setBiometricUnlock(value),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: 'Account',
                children: [
                  _SettingsValueRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Password',
                    onTap: _openChangePassword,
                  ),
                  _SettingsValueRow(
                    icon: Icons.support_agent_rounded,
                    title: 'Support',
                    onTap: () => Navigator.push(
                      context,
                      _adaptivePageRoute(
                        context,
                        builder: (_) => const _ContactPage(),
                      ),
                    ),
                  ),
                  _SettingsValueRow(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear cache',
                    onTap: _clearImageCache,
                  ),
                  _SettingsValueRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Terms and Privacy Policy',
                    onTap: () => Navigator.push(
                      context,
                      _adaptivePageRoute(
                        context,
                        builder: (_) => const _AboutPage(),
                      ),
                    ),
                  ),
                  _SettingsValueRow(
                    icon: Icons.logout_rounded,
                    title: loggingOut ? 'Logging out...' : 'Logout',
                    destructive: true,
                    onTap: loggingOut ? null : _confirmLogout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmationSheet extends StatelessWidget {
  const _LogoutConfirmationSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE9E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE54848),
                size: 25,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Log out of Tescon?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You will need to sign in again to access your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF34368C),
                      side: const BorderSide(color: Color(0xFFD7DAEA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE54848),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Top settings app bar with centered title.
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.showBackButton, required this.onBack});

  final bool showBackButton;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          _PlainIconButton(icon: Icons.arrow_back_rounded, onTap: onBack)
        else
          const SizedBox(width: 40),
        Expanded(
          child: Text(
            'Settings',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _ChangePasswordScreen extends StatefulWidget {
  const _ChangePasswordScreen();

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  bool saving = false;
  bool completed = false;
  String? error;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || saving) return;
    setState(() {
      saving = true;
      error = null;
    });

    try {
      await AppRepository().changePassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      setState(() {
        saving = false;
        completed = true;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = _friendlyError(exception);
        saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 46,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _PlainIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                    SizedBox(height: constraints.maxHeight * 0.08),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: completed
                          ? _PasswordSuccessCard(
                              key: const ValueKey('password-success'),
                              onContinue: () => Navigator.pop(context),
                            )
                          : _PasswordFormCard(
                              key: const ValueKey('password-form'),
                              formKey: formKey,
                              currentController: currentController,
                              newController: newController,
                              confirmController: confirmController,
                              saving: saving,
                              error: error,
                              onSubmit: submit,
                              onReturn: () => Navigator.pop(context),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordFormCard extends StatelessWidget {
  const _PasswordFormCard({
    super.key,
    required this.formKey,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.saving,
    required this.error,
    required this.onSubmit,
    required this.onReturn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool saving;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return _PasswordCard(
      icon: Icons.key_rounded,
      title: 'Set your new password',
      subtitle: 'Your new password should be different from your current one.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _PasswordInput(
              label: 'Current password',
              controller: currentController,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _PasswordInput(
              label: 'New password',
              controller: newController,
              textInputAction: TextInputAction.next,
              validator: _validateNewPassword,
            ),
            const SizedBox(height: 16),
            _PasswordInput(
              label: 'Confirm new password',
              controller: confirmController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => saving ? null : onSubmit(),
              validator: (value) {
                if (value != newController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 14),
              Text(
                error ?? '',
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
                onPressed: saving ? null : onSubmit,
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
                  saving ? 'Confirming...' : 'Confirm',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ReturnToSettingsButton(onTap: onReturn),
          ],
        ),
      ),
    );
  }
}

class _PasswordSuccessCard extends StatelessWidget {
  const _PasswordSuccessCard({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _PasswordCard(
      icon: Icons.check_rounded,
      title: 'Password Reset!',
      subtitle: 'Your password has been successfully updated.',
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF34368C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _ReturnToSettingsButton(onTap: onContinue),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFDCC4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 30),
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
          child,
        ],
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({
    required this.label,
    required this.controller,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
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
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF5D5D5D),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        suffixIcon: IconButton(
          tooltip: obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => obscure = !obscure),
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF7C7C7C),
            size: 20,
          ),
        ),
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
        errorStyle: GoogleFonts.inter(
          color: const Color(0xFFE54848),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ReturnToSettingsButton extends StatelessWidget {
  const _ReturnToSettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_rounded, size: 17),
      label: const Text('Return to settings'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF34368C),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
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

// Profile block shown at the top of settings.
class _SettingsProfileHeader extends StatefulWidget {
  const _SettingsProfileHeader();

  @override
  State<_SettingsProfileHeader> createState() => _SettingsProfileHeaderState();
}

class _SettingsProfileHeaderState extends State<_SettingsProfileHeader> {
  late Future<AppUser?> userFuture;
  bool uploading = false;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userFuture = AppRepository().loadCurrentUser();
  }

  Future<void> pickProfileImage() async {
    if (uploading) return;
    try {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (picked == null) return;

      setState(() => uploading = true);
      final upload = await AppRepository().uploadProfileImage(
        filename: picked.name,
        bytes: await picked.readAsBytes(),
        contentType: picked.mimeType ?? _imageContentType(picked.name),
      );
      await AppRepository().updateProfile(avatarUrl: upload.url);
      if (!mounted) return;
      setState(() {
        userFuture = AppRepository().loadCurrentUser();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Row(
          children: [
            InkWell(
              onTap: uploading ? null : pickProfileImage,
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFEFEFFC),
                    backgroundImage:
                        user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                        ? null
                        : _memberImageProvider(user.avatarUrl!),
                    child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                        ? Text(
                            _profileInitials(user?.fullName),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF34368C),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34368C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: uploading
                          ? const Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.white,
                              size: 14,
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'TESCON Member',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? 'No email available',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  if (user?.organizationRole != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      user!.organizationRole!,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    uploading ? 'Uploading photo...' : 'Tap photo to change',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String _profileInitials(String? fullName) {
  final parts = (fullName ?? 'TESCON Member')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'TM';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

String _imageContentType(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

// A titled group of settings rows.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        _AppSurface(
          padding: EdgeInsets.zero,
          borderRadius: 18,
          opacity: 0.74,
          child: Column(children: children),
        ),
      ],
    );
  }
}

// Base setting row with icon and optional trailing content.
class _SettingsBaseRow extends StatelessWidget {
  const _SettingsBaseRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = destructive
        ? const Color(0xFFE54848)
        : const Color(0xFF34368C);
    final iconBackground = destructive
        ? (isDark ? const Color(0xFF3A1F24) : const Color(0xFFFFE9E9))
        : (isDark ? const Color(0xFF292A46) : const Color(0xFFEFEFFC));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: destructive
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// Setting row with a switch.
class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsBaseRow(
      icon: icon,
      title: title,
      trailing: Switch.adaptive(
        value: value,
        activeThumbColor: const Color(0xFF34368C),
        onChanged: onChanged,
      ),
    );
  }
}

// Setting row with value text and chevron.
class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({
    required this.icon,
    required this.title,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsBaseRow(
      icon: icon,
      title: title,
      destructive: destructive,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chevron_right_rounded,
            color: destructive
                ? const Color(0xFFE54848)
                : const Color(0xFF999999),
            size: 20,
          ),
        ],
      ),
    );
  }
}
