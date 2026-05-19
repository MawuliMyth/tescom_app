part of '../dashboard_screen.dart';

class _SavedScreen extends StatelessWidget {
  const _SavedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _LiquidScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 36, 18, 22),
            children: const [
              _SimplePageTitle(
                title: 'Saved News',
                subtitle: 'Stories bookmarked for later',
              ),
              SizedBox(height: 18),
              _RecommendationTile(
                imagePath: 'assets/images/man.png',
                authorImagePath: 'assets/images/pres.png',
                source: 'Saved from NPP Youth Organizer',
                title: 'Bawumiah is the man for the Job',
                author: 'Chris Lloyd',
                date: '6 Hours Ago',
              ),
              SizedBox(height: 14),
              _RecommendationTile(
                imagePath: 'assets/images/card.png',
                authorImagePath: 'assets/images/suit.png',
                source: 'Saved from Npp Head Office',
                title: 'National Delegates Conference 2025 is happening Tomorrow',
                author: 'Chris Lloyd',
                date: 'Jul 19, 2025.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _LiquidScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 36, 18, 22),
            children: [
              const _SimplePageTitle(
                title: 'Profile',
                subtitle: 'Member account',
              ),
              const SizedBox(height: 24),
              _LiquidGlass(
                padding: const EdgeInsets.all(14),
                borderRadius: 22,
                opacity: 0.68,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage('assets/images/suit.png'),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tescon Member',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Central University Chapter',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF777777),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _DrawerTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => _showDemoSheet(
                  context,
                  title: 'Edit Profile',
                  message: 'Profile editing is ready.',
                ),
              ),
              _DrawerTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notification Settings',
                onTap: () => _showDemoSheet(
                  context,
                  title: 'Notification Settings',
                  message: 'Notification preferences opened successfully.',
                ),
              ),
              _DrawerTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                onTap: () => _showDemoSheet(
                  context,
                  title: 'Help Center',
                  message: 'Help center content is ready.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimplePageTitle extends StatelessWidget {
  const _SimplePageTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: const Color(0xFF8A8A8A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
