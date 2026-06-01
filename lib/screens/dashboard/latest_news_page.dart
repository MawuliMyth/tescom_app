part of '../dashboard_screen.dart';

// Latest news route opened from the drawer and home see-all action.
// This file is intentionally separated so each screen has a clear home.

class _LatestNewsPage extends StatelessWidget {
  const _LatestNewsPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Latest News',
      subtitle: 'Official and campus TESCON stories.',
      children: [
        FutureBuilder<AppBootstrap>(
          future: AppRepository().loadBootstrap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ListShimmer(itemCount: 3);
            }
            if (snapshot.hasError) return const _InlineErrorState();

            final articles = snapshot.data?.news ?? const [];
            if (articles.isEmpty) {
              return const _InfoCard(
                item: _InfoItem(
                  title: 'No news yet',
                  subtitle: 'Admin dashboard',
                  body: 'Published news stories will appear here.',
                  icon: Icons.article_outlined,
                ),
              );
            }

            return Column(children: articles.map(_ApiNewsTile.new).toList());
          },
        ),
      ],
    );
  }
}
