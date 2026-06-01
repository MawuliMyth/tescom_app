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
              return const _ListShimmer(itemCount: 2);
            }
            if (snapshot.hasError) return const _InlineErrorState();

            final announcements = snapshot.data?.announcements ?? const [];
            if (announcements.isEmpty) {
              return const _InfoCard(
                item: _InfoItem(
                  title: 'No announcements yet',
                  subtitle: 'Admin dashboard',
                  body: 'Published announcements will appear here.',
                  icon: Icons.campaign_outlined,
                ),
              );
            }

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
