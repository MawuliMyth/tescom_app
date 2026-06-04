part of '../dashboard_screen.dart';

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({super.key, required this.onDrawerChanged});

  final ValueChanged<bool> onDrawerChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: const _DemoDrawer(),
      onDrawerChanged: onDrawerChanged,
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
            children: [
              const _DashboardTopBar(),
              const SizedBox(height: 32),
              _SectionHeader(
                title: 'Tescon News',
                actionText: 'See all',
                onTap: () => Navigator.push(
                  context,
                  _adaptivePageRoute(
                    context,
                    builder: (_) => const _LatestNewsPage(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const _NewsCarousel(),
              _SectionHeader(
                title: 'Recommendation',
                actionText: 'See all',
                onTap: () => Navigator.push(
                  context,
                  _adaptivePageRoute(
                    context,
                    builder: (_) => const _RecommendationsPage(),
                  ),
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
            _adaptivePageRoute(
              context,
              builder: (_) => const _NotificationsPage(),
            ),
          ),
        ),
      ],
    );
  }
}
