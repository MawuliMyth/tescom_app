part of '../dashboard_screen.dart';

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  late Future<List<AppNotification>> notificationsFuture;
  StreamSubscription<void>? refreshSubscription;

  @override
  void initState() {
    super.initState();
    notificationsFuture = AppRepository().loadNotifications();
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
      notificationsFuture = AppRepository().loadNotifications();
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      body: _AppScaffoldBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<AppNotification>>(
            future: notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: _ListShimmer(itemCount: 5),
                );
              }
              if (snapshot.hasError) return const _InlineErrorState();

              final notifications = snapshot.data ?? const [];

              return RefreshIndicator.noSpinner(
                onRefresh: refresh,
                child: notifications.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: const [_NotificationEmptyState()],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _NotificationTile(
                            item: notifications[index],
                            onTap: () => _openNotification(
                              context,
                              notifications[index],
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

  Future<void> _openNotification(
    BuildContext context,
    AppNotification notification,
  ) async {
    if (notification.readAt == null) {
      try {
        await AppRepository().markNotificationRead(notification.id);
        if (mounted) refresh();
      } catch (_) {
        // Details should still open even if the read receipt fails offline.
      }
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _NotificationDetailSheet(item: notification),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = item.readAt == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _AppSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        opacity: unread ? 0.84 : 0.62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: unread
                    ? const Color(0xFFEFEFFC)
                    : const Color(0xFFF0F2F7),
                borderRadius: BorderRadius.circular(13),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
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
                  const SizedBox(height: 8),
                  Text(
                    _friendlyDate(item.createdAt),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
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

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({required this.item});

  final AppNotification item;

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
              _friendlyDate(item.createdAt),
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

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFF34368C),
              size: 74,
            ),
            const SizedBox(height: 18),
            Text(
              'No notifications yet',
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
              'Announcements from the admin dashboard will appear here.',
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
