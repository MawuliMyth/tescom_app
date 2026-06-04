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
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (!mounted || changed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
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
                  const _SettingsValueRow(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    value: 'English',
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
                    title: 'Logout',
                    destructive: true,
                    onTap: () async {
                      await AuthService().logout();
                      if (!context.mounted) return;
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('signin_screen', (_) => false);
                    },
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

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  bool saving = false;
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
      Navigator.pop(context, true);
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
    return AlertDialog(
      title: const Text('Change password'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(),
              ),
              validator: _validateNewPassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != newController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE54848),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : submit,
          child: Text(saving ? 'Saving...' : 'Save'),
        ),
      ],
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
class _SettingsProfileHeader extends StatelessWidget {
  const _SettingsProfileHeader();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: AppRepository().loadCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user?.avatarUrl == null
                  ? const AssetImage('assets/images/logo.png')
                  : _memberImageProvider(user!.avatarUrl!),
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
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
    this.value,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
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
          if (value != null)
            Text(
              value!,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          const SizedBox(width: 4),
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
