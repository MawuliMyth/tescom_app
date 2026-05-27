part of '../dashboard_screen.dart';

// Latest news route opened from the drawer and home see-all action.
// This file is intentionally separated so each screen has a clear home.

class _LatestNewsPage extends StatelessWidget {
  const _LatestNewsPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Latest News',
      subtitle: 'Official and campus TESCON stories.',
      children: [
        _RecommendationList(),
      ],
    );
  }
}

