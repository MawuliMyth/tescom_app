part of '../dashboard_screen.dart';

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  late Future<List<AppNotification>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = AppRepository().loadNotifications();
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
                          return _NotificationTile(item: notifications[index]);
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final unread = item.readAt == null;
    return _AppSurface(
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
              color: unread ? const Color(0xFFEFEFFC) : const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              unread
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_rounded,
              color: unread ? const Color(0xFF34368C) : const Color(0xFF777777),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.body,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    height: 1.35,
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
        ],
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
