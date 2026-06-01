part of '../dashboard_screen.dart';

// About route describing the TESCON app.
// This file is intentionally separated so each screen has a clear home.

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'About TESCON',
      subtitle: 'A concise institutional overview for the mobile app.',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: 'Inform, Organize, Mobilize',
            subtitle: 'Mobile app vision',
            body:
                'The app positions TESCON as a student communication, history, opportunity, and mobilization platform.',
            icon: Icons.info_outline_rounded,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'Mobile-first structure',
            subtitle: 'Ready for live data',
            body:
                'News, members, events, chat, jobs, and profile data are structured for live data integration.',
            icon: Icons.api_rounded,
          ),
        ),
      ],
    );
  }
}
