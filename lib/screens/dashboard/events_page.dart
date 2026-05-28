part of '../dashboard_screen.dart';

// Events list route, event detail route, and event-specific UI pieces.
// This file is intentionally separated so each screen has a clear home.

class _EventsPage extends StatelessWidget {
  const _EventsPage();

  static const List<_EventItem> _currentEvents = [
    _EventItem(
      imagePath: 'assets/images/coursel_image.png',
      title: 'TESCON Campus Leadership Forum',
      organizer: 'TESCON Global Community Events',
      dateLabel: '10:00 PM',
      location: 'Accra',
      status: 'Going On',
      priceLabel: 'Free',
      day: '29',
      month: 'JAN',
      details:
          'Campus leaders, organizers, and members will gather for strategy conversations, networking, and student-focused mobilization.',
    ),
    _EventItem(
      imagePath: 'assets/images/give.png',
      title: 'Chapter Executive Social',
      organizer: 'TESCON Central University',
      dateLabel: '2:00 PM',
      location: 'Kumasi',
      status: 'Going On',
      priceLabel: 'Free',
      day: '06',
      month: 'FEB',
      details:
          'A relaxed member meet-up for chapter executives to share plans, build relationships, and coordinate upcoming campus activities.',
    ),
  ];

  static const List<_EventItem> _upcomingEvents = [
    _EventItem(
      imagePath: 'assets/images/ladies.png',
      title: 'Women in TESCON Networking Brunch',
      organizer: 'TESCON National Secretariat',
      dateLabel: '10:00 AM',
      location: 'West Legon',
      status: 'In 25 Min',
      priceLabel: 'Paid',
      day: '29',
      month: 'JAN',
      fee: 'GHS 150.00',
      details:
          'A focused gathering for women in TESCON to connect, share leadership experiences, and discuss stronger participation on campus.',
    ),
    _EventItem(
      imagePath: 'assets/images/give.png',
      title: 'Entrepreneurship and Social Networking',
      organizer: 'TESCON UCC',
      dateLabel: '4:30 PM',
      location: 'Cape Coast',
      status: 'In 2 Days',
      priceLabel: 'Free',
      day: '12',
      month: 'FEB',
      details:
          'A practical session for students interested in entrepreneurship, public service, and building useful professional relationships.',
    ),
    _EventItem(
      imagePath: 'assets/images/card.png',
      title: 'National Delegates Conference',
      organizer: 'TESCON National Secretariat',
      dateLabel: '9:00 AM',
      location: 'Accra',
      status: 'Upcoming',
      priceLabel: 'Free',
      day: '19',
      month: 'JUL',
      details:
          'Official conference updates, student delegation coordination, and media briefings for campus representatives.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: AppRepository().loadBootstrap(),
      builder: (context, snapshot) {
        final apiEvents = snapshot.data?.events.map(_eventFromApi).toList();
        final currentEvents = apiEvents == null || apiEvents.isEmpty
            ? _currentEvents
            : apiEvents.take(2).toList();
        final upcomingEvents = apiEvents == null || apiEvents.length <= 2
            ? _upcomingEvents
            : apiEvents.skip(2).toList();

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
                    const Center(child: CircularProgressIndicator()),
                  const _EventSectionTitle('Current Events'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 252,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentEvents.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return _CurrentEventCard(event: currentEvents[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _EventSectionTitle('Upcoming Events'),
                  const SizedBox(height: 14),
                  ...upcomingEvents.map(
                    (event) => _UpcomingEventCard(event: event),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _EventItem _eventFromApi(AppEvent event) {
    final minute = event.startsAt.minute.toString().padLeft(2, '0');
    return _EventItem(
      imagePath: event.imageUrl ?? 'assets/images/coursel_image.png',
      title: event.title,
      organizer: 'TESCON',
      dateLabel: '${event.startsAt.hour}:$minute',
      location: event.venue,
      status: event.startsAt.isAfter(DateTime.now()) ? 'Upcoming' : 'Going On',
      priceLabel: 'Free',
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
}

class _EventItem {
  const _EventItem({
    required this.imagePath,
    required this.title,
    required this.organizer,
    required this.dateLabel,
    required this.location,
    required this.status,
    required this.priceLabel,
    required this.day,
    required this.month,
    required this.details,
    this.fee = 'Free',
  });

  final String imagePath;
  final String title;
  final String organizer;
  final String dateLabel;
  final String location;
  final String status;
  final String priceLabel;
  final String day;
  final String month;
  final String details;
  final String fee;
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
              const Spacer(),
              _EventOrganizerRow(organizer: event.organizer),
              const SizedBox(height: 6),
              const _EventAvatarStack(),
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
                    const SizedBox(height: 10),
                    _EventOrganizerRow(organizer: event.organizer),
                    const SizedBox(height: 8),
                    const _EventAvatarStack(),
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
  String get metaLine => '$dateLabel · $location';
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
                  _CircleIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () => _showDemoSheet(
                      context,
                      title: 'Event Chat',
                      message: 'Event discussion opens here.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Stack(
                children: [
                  _EventImage(
                    imagePath: event.imagePath,
                    height: 205,
                    borderRadius: 18,
                  ),
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
                      '${event.dateLabel} · ${event.location} · ${event.priceLabel} Event',
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
              const SizedBox(height: 14),
              _EventOrganizerRow(organizer: event.organizer, fontSize: 15),
              const SizedBox(height: 10),
              const _EventAvatarStack(),
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
          _EventInfoRow(
            icon: Icons.wallet_rounded,
            title: 'Event Fee',
            subtitle: event.fee,
          ),
          const SizedBox(height: 16),
          _EventInfoRow(
            dateMonth: event.month,
            dateDay: event.day,
            title: 'Sunday, October 19',
            subtitle: '${event.dateLabel} to 9:00 PM GMT',
          ),
          const SizedBox(height: 16),
          _EventInfoRow(
            icon: Icons.location_on_outlined,
            title: event.location,
            subtitle: 'TESCON chapter event venue',
          ),
        ],
      ),
    );
  }
}

class _EventInfoRow extends StatelessWidget {
  const _EventInfoRow({
    required this.title,
    required this.subtitle,
    this.icon,
    this.dateMonth,
    this.dateDay,
  });

  final String title;
  final String subtitle;
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: const Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _eventImageFallback(height),
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
  const _EventOrganizerRow({
    required this.organizer,
    this.fontSize = 12,
  });

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

class _EventAvatarStack extends StatelessWidget {
  const _EventAvatarStack();

  @override
  Widget build(BuildContext context) {
    const avatars = [
      'assets/images/man.png',
      'assets/images/suit.png',
      'assets/images/white.png',
      'assets/images/yellow.png',
    ];

    return SizedBox(
      height: 26,
      width: 86,
      child: Stack(
        children: [
          for (var index = 0; index < avatars.length; index++)
            Positioned(
              left: index * 17,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 11,
                  backgroundImage: AssetImage(avatars[index]),
                ),
              ),
            ),
        ],
      ),
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

