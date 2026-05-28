part of '../dashboard_screen.dart';

// Announcements route for official notices.
// This file is intentionally separated so each screen has a clear home.

class _AnnouncementsPage extends StatelessWidget {
  const _AnnouncementsPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Announcements',
      subtitle: 'Official notices from national and campus leadership.',
      children: [
        FutureBuilder<AppBootstrap>(
          future: AppRepository().loadBootstrap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final announcements = snapshot.data?.announcements ?? const [];
            if (announcements.isEmpty) return const _AnnouncementFallbackList();

            return Column(
              children: announcements.map((announcement) {
                return _InfoCard(
                  item: _InfoItem(
                    title: announcement.title,
                    subtitle: announcement.priority.toUpperCase(),
                    body: announcement.body,
                    icon: Icons.campaign_outlined,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AnnouncementFallbackList extends StatelessWidget {
  const _AnnouncementFallbackList();

  @override
  Widget build(BuildContext context) {
    return const Column(
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

