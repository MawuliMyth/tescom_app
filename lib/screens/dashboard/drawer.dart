part of '../dashboard_screen.dart';

class _DemoDrawer extends StatelessWidget {
  const _DemoDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: _LiquidScaffoldBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LiquidGlass(
                margin: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                borderRadius: 22,
                opacity: 0.7,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TESCON',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _DrawerTile(
                      icon: Icons.article_outlined,
                      title: 'Latest News',
                      onTap: () => _openDrawerPage(
                        context,
                        const _LatestNewsPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.history_edu_outlined,
                      title: 'TESCON History',
                      onTap: () => _openDrawerPage(
                        context,
                        const _HistoryPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.badge_outlined,
                      title: 'Member Directory',
                      onTap: () => _openDrawerPage(
                        context,
                        const _MemberDirectoryPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.work_outline_rounded,
                      title: 'Jobs & Opportunities',
                      onTap: () => _openDrawerPage(
                        context,
                        const _JobsPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Live Chat',
                      onTap: () => _openDrawerPage(
                        context,
                        const _LiveChatPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.event_outlined,
                      title: 'Events',
                      onTap: () => _openDrawerPage(
                        context,
                        const _EventsPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.campaign_outlined,
                      title: 'Announcements',
                      onTap: () => _openDrawerPage(
                        context,
                        const _AnnouncementsPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.groups_outlined,
                      title: 'Executives',
                      onTap: () => _openDrawerPage(
                        context,
                        const _ExecutivesPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.school_outlined,
                      title: 'Campus Chapters',
                      onTap: () => _openDrawerPage(
                        context,
                        const _ChaptersPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.poll_outlined,
                      title: 'Polls & Surveys',
                      onTap: () => _openDrawerPage(
                        context,
                        const _PollsPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About TESCON',
                      onTap: () => _openDrawerPage(
                        context,
                        const _AboutPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Contact / Support',
                      onTap: () => _openDrawerPage(
                        context,
                        const _ContactPage(),
                      ),
                    ),
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => _openDrawerPage(
                        context,
                        const _SettingsPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openDrawerPage(BuildContext context, Widget page) {
  final navigator = Navigator.of(context);
  navigator.pop();
  Future<void>.delayed(const Duration(milliseconds: 180), () {
    navigator.push(MaterialPageRoute(builder: (_) => page));
  });
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _LiquidGlass(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 18,
      opacity: 0.56,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF34368C)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
