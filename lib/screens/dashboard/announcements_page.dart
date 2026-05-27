part of '../dashboard_screen.dart';

// Announcements route for official notices.
// This file is intentionally separated so each screen has a clear home.

class _AnnouncementsPage extends StatelessWidget {
  const _AnnouncementsPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Announcements',
      subtitle: 'Official notices from national and campus leadership.',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: 'Membership Update',
            subtitle: 'National Secretariat',
            body:
                'All campus chapters are encouraged to update their member lists before the next engagement.',
            icon: Icons.campaign_outlined,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'Event Media Submission',
            subtitle: 'Communications Desk',
            body:
                'Chapter media teams can prepare event photos and reports for publication.',
            icon: Icons.photo_library_outlined,
          ),
        ),
      ],
    );
  }
}

