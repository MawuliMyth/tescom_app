part of '../dashboard_screen.dart';

class _SavedScreen extends StatelessWidget {
  const _SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 36, 18, 22),
            children: [
              const _SimplePageTitle(
                title: 'Saved News',
                subtitle: 'Stories bookmarked for later',
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Object>>(
                future: Future.wait([
                  AppRepository().loadSavedItems(),
                  AppRepository().loadBootstrap(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ListShimmer(itemCount: 3);
                  }
                  if (snapshot.hasError) return const _InlineErrorState();

                  final savedItems =
                      snapshot.data?[0] as List<AppSavedItem>? ?? const [];
                  final bootstrap = snapshot.data?[1] as AppBootstrap?;
                  final savedNewsIds = savedItems
                      .where((item) => item.itemType == 'NEWS')
                      .map((item) => item.itemId)
                      .toSet();
                  final savedNews = (bootstrap?.news ?? const [])
                      .where((article) => savedNewsIds.contains(article.id))
                      .toList();

                  if (savedNews.isEmpty) {
                    return const _InfoCard(
                      item: _InfoItem(
                        title: 'No saved news yet',
                        subtitle: 'Bookmarks',
                        body: 'Saved news from the app will appear here.',
                        icon: Icons.bookmark_border_rounded,
                      ),
                    );
                  }

                  return Column(
                    children: savedNews.map(_ApiNewsTile.new).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimplePageTitle extends StatelessWidget {
  const _SimplePageTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: const Color(0xFF8A8A8A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
