part of '../dashboard_screen.dart';

// Events list route, event detail route, and event-specific UI pieces.
// This file is intentionally separated so each screen has a clear home.

class _EventsPage extends StatelessWidget {
  const _EventsPage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: AppRepository().loadBootstrap(),
      builder: (context, snapshot) {
        final events = snapshot.data?.events.map(_eventFromApi).toList() ?? [];
        final currentEvents = events
            .where((event) => event.status == 'Going On')
            .toList();
        final upcomingEvents = events
            .where((event) => event.status != 'Going On')
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: _AppScaffoldBackground(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Events',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF111111),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const _ListShimmer(itemCount: 3)
                  else if (snapshot.hasError)
                    const _InlineErrorState()
                  else if (events.isEmpty)
                    const _InfoCard(
                      item: _InfoItem(
                        title: 'No events yet',
                        subtitle: 'Admin dashboard',
                        body: 'Published events will appear here.',
                        icon: Icons.event_busy_outlined,
                      ),
                    )
                  else ...[
                    const _EventSectionTitle('Current Events'),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 252,
                      child: currentEvents.isEmpty
                          ? const _EmptyEventGroup()
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: currentEvents.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                return _CurrentEventCard(
                                  event: currentEvents[index],
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 26),
                    const _EventSectionTitle('Upcoming Events'),
                    const SizedBox(height: 14),
                    if (upcomingEvents.isEmpty)
                      const _EmptyEventGroup()
                    else
                      ...upcomingEvents.map(
                        (event) => _UpcomingEventCard(event: event),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _EventItem _eventFromApi(AppEvent event) {
    final images = _contentImages(event.imageUrls, event.imageUrl);
    return _EventItem(
      imagePath: images.first,
      imagePaths: images,
      title: event.title,
      organizer: event.organizer,
      dateLabel: _timeLabel(event.startsAt),
      timeRangeLabel: _timeRangeLabel(event.startsAt, event.endsAt),
      fullDateLabel: _fullDateLabel(event.startsAt),
      fullDateRangeLabel: _fullDateRangeLabel(event.startsAt, event.endsAt),
      location: event.venue,
      status: event.startsAt.isAfter(DateTime.now()) ? 'Upcoming' : 'Going On',
      priceLabel: event.feeLabel,
      fee: event.feeLabel,
      venueNote: event.venueNote,
      chatUrl: event.chatUrl,
      day: event.startsAt.day.toString().padLeft(2, '0'),
      month: _monthLabel(event.startsAt.month),
      details: event.description,
    );
  }

  String _monthLabel(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  String _timeRangeLabel(DateTime startsAt, DateTime? endsAt) {
    if (endsAt == null) return _timeLabel(startsAt);
    return '${_timeLabel(startsAt)} to ${_timeLabel(endsAt)}';
  }

  String _timeLabel(DateTime value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _fullDateLabel(DateTime value) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[value.weekday - 1]}, ${months[value.month - 1]} ${value.day}';
  }

  String _fullDateRangeLabel(DateTime startsAt, DateTime? endsAt) {
    if (endsAt == null) return 'Starts ${_fullDateLabel(startsAt)}';
    final startsLabel = _fullDateLabel(startsAt);
    final endsLabel = _fullDateLabel(endsAt);
    return 'Starts $startsLabel\nEnds $endsLabel';
  }
}

class _EventItem {
  const _EventItem({
    required this.imagePath,
    this.imagePaths = const [],
    required this.title,
    required this.organizer,
    required this.dateLabel,
    required this.timeRangeLabel,
    required this.fullDateLabel,
    required this.fullDateRangeLabel,
    required this.location,
    required this.status,
    required this.priceLabel,
    required this.day,
    required this.month,
    required this.details,
    this.venueNote,
    this.chatUrl,
    this.fee = '',
  });

  final String imagePath;
  final List<String> imagePaths;
  final String title;
  final String organizer;
  final String dateLabel;
  final String timeRangeLabel;
  final String fullDateLabel;
  final String fullDateRangeLabel;
  final String location;
  final String status;
  final String priceLabel;
  final String day;
  final String month;
  final String details;
  final String? venueNote;
  final String? chatUrl;
  final String fee;

  bool get hasFee => fee.trim().isNotEmpty;
  bool get hasOrganizer => organizer.trim().isNotEmpty;
  bool get hasVenueNote => venueNote != null && venueNote!.trim().isNotEmpty;
}

class _EventSectionTitle extends StatelessWidget {
  const _EventSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: const Color(0xFF151515),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _EmptyEventGroup extends StatelessWidget {
  const _EmptyEventGroup();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No events in this section yet',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: const Color(0xFF777777),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CurrentEventCard extends StatelessWidget {
  const _CurrentEventCard({required this.event});

  final _EventItem event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 278,
      child: InkWell(
        onTap: () => _openEventDetails(context, event),
        borderRadius: BorderRadius.circular(16),
        child: _AppSurface(
          padding: const EdgeInsets.all(10),
          borderRadius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _EventImage(
                    imagePath: event.imagePath,
                    height: 98,
                    borderRadius: 14,
                  ),
                  if (event.hasFee)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _EventPill(
                        label: event.priceLabel,
                        backgroundColor: const Color(0xFFFFE66B),
                        foregroundColor: Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _EventPill(
                    label: event.status,
                    backgroundColor: const Color(0xFFEF3F73),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _EventMetaText(event.metaLine)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontSize: 15,
                  height: 1.16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              if (event.hasOrganizer) ...[
                const Spacer(),
                _EventOrganizerRow(organizer: event.organizer),
                const SizedBox(height: 6),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event});

  final _EventItem event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openEventDetails(context, event),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EventDateTile(month: event.month, day: event.day),
            const SizedBox(width: 14),
            Expanded(
              child: _AppSurface(
                padding: const EdgeInsets.all(8),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _EventImage(
                          imagePath: event.imagePath,
                          height: 118,
                          borderRadius: 14,
                        ),
                        if (event.hasFee)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _EventPill(
                              label: event.priceLabel,
                              backgroundColor: event.priceLabel == 'Paid'
                                  ? const Color(0xFFFF5D94)
                                  : const Color(0xFFFFE66B),
                              foregroundColor: Colors.black,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _EventPill(
                          label: event.status,
                          backgroundColor: const Color(0xFF4768FF),
                          foregroundColor: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _EventMetaText(event.metaLine)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 15,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    if (event.hasOrganizer) ...[
                      const SizedBox(height: 10),
                      _EventOrganizerRow(organizer: event.organizer),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _EventItemMeta on _EventItem {
  String get metaLine => '$dateLabel - $location';
}

void _openEventDetails(BuildContext context, _EventItem event) {
  Navigator.of(context).push(
    _adaptivePageRoute(
      context,
      builder: (_) => _EventDetailsPage(event: event),
    ),
  );
}

class _EventDetailsPage extends StatelessWidget {
  const _EventDetailsPage({required this.event});

  final _EventItem event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Events Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  event.chatUrl == null || event.chatUrl!.trim().isEmpty
                      ? const SizedBox(width: 36)
                      : _CircleIconButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () => _showDemoSheet(
                            context,
                            title: 'Event Chat',
                            message: event.chatUrl!,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 22),
              Stack(
                children: [
                  _EventGallery(
                    imagePaths: event.imagePaths.isEmpty
                        ? [event.imagePath]
                        : event.imagePaths,
                  ),
                  if (event.hasFee)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _EventPill(
                        label: event.priceLabel == 'Paid'
                            ? '\$ Paid'
                            : event.priceLabel,
                        backgroundColor: event.priceLabel == 'Paid'
                            ? const Color(0xFFFF5D94)
                            : const Color(0xFFFFE66B),
                        foregroundColor: Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _EventPill(
                    label: event.status,
                    backgroundColor: const Color(0xFF4768FF),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.hasFee
                          ? '${event.timeRangeLabel} - ${event.location} - ${event.priceLabel} Event'
                          : '${event.timeRangeLabel} - ${event.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontSize: 25,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              if (event.hasOrganizer) ...[
                const SizedBox(height: 14),
                _EventOrganizerRow(organizer: event.organizer, fontSize: 15),
              ],
              const SizedBox(height: 22),
              _EventInfoPanel(event: event),
              const SizedBox(height: 18),
              _AppSurface(
                padding: const EdgeInsets.all(16),
                borderRadius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Details',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF111111),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.details,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF555555),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventInfoPanel extends StatelessWidget {
  const _EventInfoPanel({required this.event});

  final _EventItem event;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        children: [
          if (event.hasFee) ...[
            _EventInfoRow(
              icon: Icons.wallet_rounded,
              title: 'Event Fee',
              subtitle: event.fee,
            ),
            const SizedBox(height: 16),
          ],
          _EventInfoRow(
            dateMonth: event.month,
            dateDay: event.day,
            title: event.fullDateRangeLabel,
            subtitle: event.timeRangeLabel,
          ),
          const SizedBox(height: 16),
          _EventInfoRow(
            icon: Icons.location_on_outlined,
            title: event.location,
            subtitle: event.hasVenueNote ? event.venueNote!.trim() : null,
          ),
        ],
      ),
    );
  }
}

class _EventInfoRow extends StatelessWidget {
  const _EventInfoRow({
    required this.title,
    this.subtitle,
    this.icon,
    this.dateMonth,
    this.dateDay,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? dateMonth;
  final String? dateDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          _EventIconBox(icon: icon!)
        else
          _EventDateTile(month: dateMonth!, day: dateDay!, compact: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventIconBox extends StatelessWidget {
  const _EventIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222222), width: 1.2),
      ),
      child: Icon(icon, color: const Color(0xFF111111), size: 25),
    );
  }
}

class _EventImage extends StatelessWidget {
  const _EventImage({
    required this.imagePath,
    required this.height,
    required this.borderRadius,
  });

  final String imagePath;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedPath = ApiConfig.mediaUrl(imagePath);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imagePath.startsWith('http') || imagePath.startsWith('/')
          ? CachedNetworkImage(
              imageUrl: resolvedPath,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  _ShimmerBlock(height: height, borderRadius: 0),
              errorWidget: (_, _, _) => _eventImageFallback(height),
            )
          : Image.asset(
              imagePath,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _eventImageFallback(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFE7EAF6),
      child: const Icon(Icons.event_busy_outlined),
    );
  }
}

class _EventGallery extends StatefulWidget {
  const _EventGallery({required this.imagePaths});

  final List<String> imagePaths;

  @override
  State<_EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends State<_EventGallery> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 205,
            child: PageView.builder(
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => setState(() => activeIndex = index),
              itemBuilder: (context, index) {
                return _EventImage(
                  imagePath: widget.imagePaths[index],
                  height: 205,
                  borderRadius: 0,
                );
              },
            ),
          ),
        ),
        if (widget.imagePaths.length > 1) ...[
          const SizedBox(height: 10),
          _GalleryDots(
            count: widget.imagePaths.length,
            activeIndex: activeIndex,
          ),
        ],
      ],
    );
  }
}

class _EventPill extends StatelessWidget {
  const _EventPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _EventMetaText extends StatelessWidget {
  const _EventMetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: const Color(0xFF111111),
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _EventOrganizerRow extends StatelessWidget {
  const _EventOrganizerRow({required this.organizer, this.fontSize = 12});

  final String organizer;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFEF5DFF), Color(0xFF705BFF)],
            ),
          ),
          child: const Icon(
            Icons.public_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            organizer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF666666),
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventDateTile extends StatelessWidget {
  const _EventDateTile({
    required this.month,
    required this.day,
    this.compact = false,
  });

  final String month;
  final String day;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 52.0 : 54.0;
    final height = compact ? 58.0 : 60.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF222222), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4B8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF111111),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
