part of '../dashboard_screen.dart';

// Notification route styled as a compact inbox using the app palette.
class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  final List<_NotificationItem> notifications = [
    const _NotificationItem(
      title: 'Membership due reminder',
      subtitle: 'You have 2 days before your next membership contribution.',
      time: '8m ago',
      icon: Icons.credit_card_rounded,
      highlighted: true,
    ),
    const _NotificationItem(
      title: 'Chapter report updated',
      subtitle: 'A new performance report is ready for your chapter.',
      time: '10m ago',
      icon: Icons.star_rounded,
    ),
    const _NotificationItem(
      title: 'New announcement',
      subtitle: 'A national update has been added for all members.',
      time: '2h ago',
      icon: Icons.article_rounded,
    ),
    const _NotificationItem(
      title: 'Event recording',
      subtitle: 'The latest leadership session recording is available.',
      time: '1d ago',
      icon: Icons.videocam_rounded,
      highlighted: true,
    ),
    const _NotificationItem(
      title: 'Payment received',
      subtitle: 'Your contribution was received successfully.',
      time: '6d ago',
      icon: Icons.credit_card_rounded,
    ),
    const _NotificationItem(
      title: 'Executive notice',
      subtitle: 'You have a new message from the leadership team.',
      time: '10d ago',
      icon: Icons.star_rounded,
    ),
    const _NotificationItem(
      title: 'Chapter task',
      subtitle: 'A new task has been assigned to your campus chapter.',
      time: '12h ago',
      icon: Icons.article_rounded,
    ),
    const _NotificationItem(
      title: 'Meeting replay',
      subtitle: 'A new meeting replay has been uploaded.',
      time: '14d ago',
      icon: Icons.videocam_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _NotificationHeader(
                hasNotifications: notifications.isNotEmpty,
                onBack: () => Navigator.pop(context),
                onClearAll: _clearAll,
                onMarkAllRead: _markAllRead,
              ),
              Expanded(
                child: notifications.isEmpty
                    ? const _NotificationEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 28),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _NotificationTile(
                            item: notifications[index],
                            onTap: () => _markRead(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markRead(int index) {
    setState(() {
      notifications[index] = notifications[index].copyWith(highlighted: false);
    });
  }

  void _markAllRead() {
    setState(() {
      for (var index = 0; index < notifications.length; index += 1) {
        notifications[index] = notifications[index].copyWith(highlighted: false);
      }
    });
  }

  void _clearAll() {
    setState(notifications.clear);
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool highlighted;

  _NotificationItem copyWith({bool? highlighted}) {
    return _NotificationItem(
      title: title,
      subtitle: subtitle,
      time: time,
      icon: icon,
      highlighted: highlighted ?? this.highlighted,
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({
    required this.hasNotifications,
    required this.onBack,
    required this.onClearAll,
    required this.onMarkAllRead,
  });

  final bool hasNotifications;
  final VoidCallback onBack;
  final VoidCallback onClearAll;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          _NotificationCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              'Notification',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          _NotificationMenuButton(
            hasNotifications: hasNotifications,
            onClearAll: onClearAll,
            onMarkAllRead: onMarkAllRead,
          ),
        ],
      ),
    );
  }
}

class _NotificationCircleButton extends StatelessWidget {
  const _NotificationCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFEFEFFC),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF34368C), size: 20),
      ),
    );
  }
}

class _NotificationMenuButton extends StatelessWidget {
  const _NotificationMenuButton({
    required this.hasNotifications,
    required this.onClearAll,
    required this.onMarkAllRead,
  });

  final bool hasNotifications;
  final VoidCallback onClearAll;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return _NotificationCircleButton(
      icon: Icons.more_vert_rounded,
      onTap: hasNotifications ? () => _showNotificationActions(context) : () {},
    );
  }

  void _showNotificationActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NotificationActionButton(
                  label: 'Clear All',
                  color: const Color(0xFFE54848),
                  onTap: () {
                    Navigator.pop(context);
                    onClearAll();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFEDEDF2)),
                _NotificationActionButton(
                  label: 'Mark all as read',
                  color: const Color(0xFF111827),
                  onTap: () {
                    Navigator.pop(context);
                    onMarkAllRead();
                  },
                ),
                const SizedBox(height: 8),
                Container(height: 7, color: const Color(0xFFF1F2F8)),
                _NotificationActionButton(
                  label: 'Cancel',
                  color: const Color(0xFF111827),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationActionButton extends StatelessWidget {
  const _NotificationActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        color: item.highlighted ? const Color(0xFFEFEFFC) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE3E4F3)),
              ),
              child: Icon(item.icon, color: const Color(0xFF34368C), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.time,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
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
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEFFC),
                    shape: BoxShape.circle,
                  ),
                ),
                const Positioned.fill(
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF34368C),
                    size: 76,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: 16,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE54848),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '0',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Text(
              'No Notification to show',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You currently have no notification. We will notify you when something new happens!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
