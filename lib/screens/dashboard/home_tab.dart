part of '../dashboard_screen.dart';

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: const _DemoDrawer(),
      body: _LiquidScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
            children: [
              const _DashboardTopBar(),
              const SizedBox(height: 32),
              _SectionHeader(
                title: 'Tescon News',
                actionText: 'View all',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _LatestNewsPage()),
                ),
              ),
              const SizedBox(height: 12),
              const _NewsCarousel(),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Recommendation',
                actionText: 'View All',
                onTap: () => _showDemoSheet(
                  context,
                  title: 'Recommendations',
                  message: 'Showing all recommended posts.',
                ),
              ),
              const SizedBox(height: 10),
              const _RecommendationList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.search_rounded,
          onTap: () => _showSearchSheet(context),
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _NotificationsPage()),
          ),
        ),
      ],
    );
  }
}
