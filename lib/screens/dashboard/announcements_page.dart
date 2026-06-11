part of '../dashboard_screen.dart';

class _AnnouncementsPage extends StatefulWidget {
  const _AnnouncementsPage();

  @override
  State<_AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<_AnnouncementsPage> {
  late Future<AppBootstrap> announcementsFuture;
  StreamSubscription<void>? refreshSubscription;

  @override
  void initState() {
    super.initState();
    announcementsFuture = AppRepository().loadBootstrap();
    refreshSubscription = AppRefreshBus().stream.listen((_) {
      if (mounted) refresh();
    });
  }

  @override
  void dispose() {
    refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      announcementsFuture = AppRepository().loadBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 8),
            Text(
              'Announcements',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
      body: _AppScaffoldBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<AppBootstrap>(
            future: announcementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: _ListShimmer(itemCount: 4),
                );
              }
              if (snapshot.hasError) return const _InlineErrorState();

              final announcements = snapshot.data?.announcements ?? const [];

              return RefreshIndicator.noSpinner(
                onRefresh: refresh,
                child: announcements.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: const [_AnnouncementEmptyState()],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        itemCount: announcements.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final announcement = announcements[index];
                          return _AnnouncementTile(
                            item: announcement,
                            onTap: () => _openAnnouncement(
                              context,
                              announcement,
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openAnnouncement(
    BuildContext context,
    AppAnnouncement announcement,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _AnnouncementDetailSheet(item: announcement),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.item, required this.onTap});

  final AppAnnouncement item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priority = item.priority.toLowerCase();
    final urgent = priority == 'urgent' || priority == 'high';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _AppSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        opacity: 0.78,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: urgent
                    ? const Color(0xFFFFF1F1)
                    : const Color(0xFFEFEFFC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                urgent
                    ? Icons.priority_high_rounded
                    : Icons.campaign_outlined,
                color: urgent ? const Color(0xFFE5484D) : const Color(0xFF34368C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _AnnouncementPriorityPill(priority: item.priority),
                      const SizedBox(width: 8),
                      Text(
                        _friendlyDate(item.publishedAt ?? item.createdAt),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF999999),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementPriorityPill extends StatelessWidget {
  const _AnnouncementPriorityPill({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final urgent = priority.toLowerCase() == 'urgent' ||
        priority.toLowerCase() == 'high';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFF1F1) : const Color(0xFFEFEFFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.toUpperCase(),
        style: GoogleFonts.inter(
          color: urgent ? const Color(0xFFE5484D) : const Color(0xFF34368C),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AnnouncementDetailSheet extends StatelessWidget {
  const _AnnouncementDetailSheet({required this.item});

  final AppAnnouncement item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 58,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            _AnnouncementPriorityPill(priority: item.priority),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _friendlyDate(item.publishedAt ?? item.createdAt),
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item.body,
              style: GoogleFonts.inter(
                color: const Color(0xFF303447),
                fontSize: 14,
                height: 1.55,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34368C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementEmptyState extends StatelessWidget {
  const _AnnouncementEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.campaign_outlined,
              color: Color(0xFF34368C),
              size: 74,
            ),
            const SizedBox(height: 18),
            Text(
              'No announcements yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Published announcements will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
