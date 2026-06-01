part of '../dashboard_screen.dart';

class _DemoDrawer extends StatelessWidget {
  const _DemoDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: _AppScaffoldBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                    _DrawerSection(
                      title: 'Updates',
                      children: [
                        _DrawerTile(
                          icon: Icons.article_outlined,
                          title: 'Latest News',
                          onTap: () =>
                              _openDrawerPage(context, const _LatestNewsPage()),
                        ),
                        _DrawerTile(
                          icon: Icons.event_outlined,
                          title: 'Events',
                          onTap: () =>
                              _openDrawerPage(context, const _EventsPage()),
                        ),
                        _DrawerTile(
                          icon: Icons.campaign_outlined,
                          title: 'Announcements',
                          onTap: () => _openDrawerPage(
                            context,
                            const _AnnouncementsPage(),
                          ),
                        ),
                      ],
                    ),
                    const _DrawerDivider(),
                    _DrawerSection(
                      title: 'Community',
                      children: [
                        _DrawerTile(
                          icon: Icons.history_edu_outlined,
                          title: 'TESCON History',
                          onTap: () =>
                              _openDrawerPage(context, const _HistoryPage()),
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
                          icon: Icons.groups_outlined,
                          title: 'Executives',
                          onTap: () =>
                              _openDrawerPage(context, const _ExecutivesPage()),
                        ),
                        _DrawerTile(
                          icon: Icons.school_outlined,
                          title: 'Campus Chapters',
                          onTap: () =>
                              _openDrawerPage(context, const _ChaptersPage()),
                        ),
                      ],
                    ),
                    const _DrawerDivider(),
                    _DrawerSection(
                      title: 'Tools',
                      children: [
                        _DrawerTile(
                          icon: Icons.work_outline_rounded,
                          title: 'Jobs & Opportunities',
                          onTap: () =>
                              _openDrawerPage(context, const _JobsPage()),
                        ),
                        _DrawerTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Live Chat',
                          onTap: () =>
                              _openDrawerPage(context, const _LiveChatPage()),
                        ),
                        _DrawerTile(
                          icon: Icons.poll_outlined,
                          title: 'Polls & Surveys',
                          onTap: () =>
                              _openDrawerPage(context, const _PollsPage()),
                        ),
                      ],
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
  final route = _adaptivePageRoute(context, builder: (_) => page);
  navigator.pop();
  Future<void>.delayed(const Duration(milliseconds: 180), () {
    navigator.push(route);
  });
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0x1F34368C),
      height: 18,
      indent: 10,
      endIndent: 10,
    );
  }
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
    return ListTile(
      minLeadingWidth: 24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(icon, color: const Color(0xFF34368C), size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      onTap: onTap,
    );
  }
}
