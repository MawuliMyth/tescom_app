part of '../dashboard_screen.dart';

// Settings route with grouped preference/account sections.
class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool notifications = true;
  bool faceId = true;

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
              _SettingsHeader(onBack: () => Navigator.pop(context)),
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
                    onChanged: (value) => setState(() => notifications = value),
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
                  const _SettingsValueRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Password',
                  ),
                  _SettingsToggleRow(
                    icon: Icons.face_retouching_natural_outlined,
                    title: 'Login with Face ID',
                    value: faceId,
                    onChanged: (value) => setState(() => faceId = value),
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
                  const _SettingsValueRow(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear cache',
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
                    onTap: () => _showDemoSheet(
                      context,
                      title: 'Logout',
                      message: 'Logout confirmation can be connected here.',
                    ),
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
  const _SettingsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlainIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
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

// Profile block shown at the top of settings.
class _SettingsProfileHeader extends StatelessWidget {
  const _SettingsProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage('assets/images/suit.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chris Lloyd Nii Kwesi',
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
                'member@tescon.app',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _showDemoSheet(
                  context,
                  title: 'Edit profile',
                  message: 'Profile editing can be connected here.',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34368C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Edit profile',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// A titled group of settings rows.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

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
    final color = destructive ? const Color(0xFFE54848) : const Color(0xFF34368C);
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
        activeColor: const Color(0xFF34368C),
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
            color: destructive ? const Color(0xFFE54848) : const Color(0xFF999999),
            size: 20,
          ),
        ],
      ),
    );
  }
}
