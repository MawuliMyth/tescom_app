part of '../dashboard_screen.dart';

// Campus Chapters screen with logo-led list tiles and chapter detail pages.
class _ChaptersPage extends StatelessWidget {
  const _ChaptersPage();

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
          'Campus Chapters',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
          children: [
            Text(
              'Explore chapter executives, members, news, and events by institution.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Object>>(
              future: Future.wait<Object>([
                AppRepository().loadBootstrap(),
                AppRepository().loadMembers(),
              ]),
              builder: (context, snapshot) {
                final bootstrap = snapshot.data == null
                    ? null
                    : snapshot.data![0] as AppBootstrap;
                final members = snapshot.data == null
                    ? const <AppUser>[]
                    : snapshot.data![1] as List<AppUser>;
                final apiChapters = bootstrap?.chapters
                    .map(
                      (chapter) =>
                          _chapterFromApi(chapter, members, bootstrap.events),
                    )
                    .toList(growable: false);
                final chapters = apiChapters ?? const [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ListShimmer(itemCount: 4);
                }
                if (snapshot.hasError) return const _InlineErrorState();

                if (chapters.isEmpty) {
                  return const _InfoCard(
                    item: _InfoItem(
                      title: 'No chapters yet',
                      subtitle: 'Admin dashboard',
                      body: 'Created chapters will appear here.',
                      icon: Icons.school_outlined,
                    ),
                  );
                }

                return Column(
                  children: chapters
                      .map((chapter) => _CampusChapterTile(chapter: chapter))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _CampusChapter _chapterFromApi(
    AppChapter chapter,
    List<AppUser> users,
    List<AppEvent> events,
  ) {
    final name = chapter.name.isEmpty ? chapter.campus : chapter.name;
    final chapterMembers = users
        .where((user) => user.chapterId == chapter.id)
        .map(_Member.fromUser)
        .toList(growable: false);
    final chapterExecutives = chapterMembers
        .where((member) => member.contribution != 'Membership')
        .toList(growable: false);
    final chapterEvents = events
        .where((event) => event.chapterId == chapter.id)
        .map(
          (event) => _ChapterEvent(
            title: event.title,
            date: _formatChapterEventDate(event.startsAt, event.endsAt),
            location: event.venue,
          ),
        )
        .toList(growable: false);
    return _CampusChapter(
      name: name,
      shortName: name,
      location: [
        chapter.campus,
        if (chapter.region != null && chapter.region!.isNotEmpty)
          chapter.region!,
      ].join(', '),
      logoPath: chapter.logoUrl ?? 'assets/images/logo.png',
      membersCount: chapterMembers.isEmpty
          ? chapter.membersCount
          : chapterMembers.length,
      executivesCount: chapterExecutives.isEmpty
          ? chapter.executivesCount
          : chapterExecutives.length,
      eventsCount: chapterEvents.isEmpty ? chapter.eventsCount : chapterEvents.length,
      newsCount: 0,
      description:
          chapter.description ??
          'No chapter description has been added yet.',
      executives: chapterExecutives,
      members: chapterMembers,
      news: const [],
      events: chapterEvents,
    );
  }

  String _formatChapterEventDate(DateTime startsAt, DateTime? endsAt) {
    final start = '${startsAt.day}/${startsAt.month}/${startsAt.year}';
    if (endsAt == null) return start;
    final end = '${endsAt.day}/${endsAt.month}/${endsAt.year}';
    return start == end ? '$start, ${_formatTime(startsAt)} - ${_formatTime(endsAt)}' : '$start - $end';
  }

  String _formatTime(DateTime value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

// Chapter data model for the list and detail screens.
class _CampusChapter {
  const _CampusChapter({
    required this.name,
    required this.shortName,
    required this.location,
    required this.logoPath,
    required this.membersCount,
    required this.executivesCount,
    required this.eventsCount,
    required this.newsCount,
    required this.description,
    required this.executives,
    required this.members,
    required this.news,
    required this.events,
  });

  final String name;
  final String shortName;
  final String location;
  final String logoPath;
  final int membersCount;
  final int executivesCount;
  final int eventsCount;
  final int newsCount;
  final String description;
  final List<_Member> executives;
  final List<_Member> members;
  final List<_ChapterUpdate> news;
  final List<_ChapterEvent> events;
}

// Small content model used for campus news cards.
class _ChapterUpdate {
  const _ChapterUpdate({
    required this.title,
    required this.source,
    required this.date,
  });

  final String title;
  final String source;
  final String date;
}

// Small content model used for campus event cards.
class _ChapterEvent {
  const _ChapterEvent({
    required this.title,
    required this.date,
    required this.location,
  });

  final String title;
  final String date;
  final String location;
}

// Logo-led chapter list tile.
class _CampusChapterTile extends StatelessWidget {
  const _CampusChapterTile({required this.chapter});

  final _CampusChapter chapter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        _adaptivePageRoute(
          context,
          builder: (_) => _CampusChapterDetailPage(chapter: chapter),
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: _AppSurface(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        borderRadius: 18,
        opacity: 0.74,
        child: Row(
          children: [
            _ChapterLogoBox(logoPath: chapter.logoPath, size: 58),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chapter.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${chapter.membersCount} members · ${chapter.eventsCount} events',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}

// Campus detail page inspired by the reference layout: visual top card, tabs,
// description, and grouped chapter records.
class _CampusChapterDetailPage extends StatelessWidget {
  const _CampusChapterDetailPage({required this.chapter});

  final _CampusChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              Row(
                children: [
                  _PlainIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      chapter.shortName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              _ChapterHeroCard(chapter: chapter),
              const SizedBox(height: 18),
              _ChapterTabStrip(chapter: chapter),
              const SizedBox(height: 18),
              _ChapterDescription(chapter: chapter),
              const SizedBox(height: 18),
              _ChapterSection(
                title: 'Executives',
                children: chapter.executives
                    .map((member) => _MemberCard(member: member))
                    .toList(),
              ),
              _ChapterSection(
                title: 'Members',
                children: chapter.members
                    .map((member) => _MemberCard(member: member))
                    .toList(),
              ),
              _ChapterSection(
                title: 'News',
                children: chapter.news
                    .map((item) => _ChapterNewsTile(item: item))
                    .toList(),
              ),
              _ChapterSection(
                title: 'Events',
                children: chapter.events
                    .map((event) => _ChapterEventTile(event: event))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Large top logo card for the selected campus chapter.
class _ChapterHeroCard extends StatelessWidget {
  const _ChapterHeroCard({required this.chapter});

  final _CampusChapter chapter;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      opacity: 0.84,
      child: Column(
        children: [
          _ChapterLogoBox(logoPath: chapter.logoPath, size: 118),
          const SizedBox(height: 16),
          Text(
            chapter.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 21,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF777777),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                chapter.location,
                style: GoogleFonts.inter(
                  color: const Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ChapterMetric(
                label: 'Members',
                value: '${chapter.membersCount}',
              ),
              _ChapterMetric(
                label: 'Executives',
                value: '${chapter.executivesCount}',
              ),
              _ChapterMetric(label: 'Events', value: '${chapter.eventsCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

// Rounded logo container reused by list tiles and detail hero.
class _ChapterLogoBox extends StatelessWidget {
  const _ChapterLogoBox({required this.logoPath, required this.size});

  final String logoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0xFFE8E8EF)),
      ),
      child: logoPath.startsWith('http') || logoPath.startsWith('/')
          ? CachedNetworkImage(
              imageUrl: ApiConfig.mediaUrl(logoPath),
              fit: BoxFit.contain,
              placeholder: (_, _) => const _ShimmerBlock(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 10,
              ),
              errorWidget: (_, _, _) => const Icon(Icons.school_outlined),
            )
          : Image.asset(logoPath, fit: BoxFit.contain),
    );
  }
}

// Small statistic item under the chapter hero.
class _ChapterMetric extends StatelessWidget {
  const _ChapterMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF34368C),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF777777),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// Non-interactive strip that mirrors the reference detail-page categories.
class _ChapterTabStrip extends StatelessWidget {
  const _ChapterTabStrip({required this.chapter});

  final _CampusChapter chapter;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'Executives ${chapter.executivesCount}',
      'Members ${chapter.membersCount}',
      'News ${chapter.newsCount}',
      'Events ${chapter.eventsCount}',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isFirst = tab == tabs.first;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isFirst ? const Color(0xFF34368C) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E8EF)),
            ),
            child: Text(
              tab,
              style: GoogleFonts.inter(
                color: isFirst ? Colors.white : const Color(0xFF34368C),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Chapter description block.
class _ChapterDescription extends StatelessWidget {
  const _ChapterDescription({required this.chapter});

  final _CampusChapter chapter;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      opacity: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter Description',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            chapter.description,
            style: GoogleFonts.inter(
              color: const Color(0xFF555555),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// Section wrapper for executives, members, news, and events.
class _ChapterSection extends StatelessWidget {
  const _ChapterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          if (children.isEmpty)
            _AppSurface(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              opacity: 0.68,
              child: Text(
                'No ${title.toLowerCase()} available yet.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

// Compact campus news tile.
class _ChapterNewsTile extends StatelessWidget {
  const _ChapterNewsTile({required this.item});

  final _ChapterUpdate item;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      opacity: 0.68,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEFEFFC),
            child: Icon(Icons.article_outlined, color: Color(0xFF34368C)),
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
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.source} - ${item.date}',
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
        ],
      ),
    );
  }
}

// Compact campus event tile.
class _ChapterEventTile extends StatelessWidget {
  const _ChapterEventTile({required this.event});

  final _ChapterEvent event;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      opacity: 0.68,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEFEFFC),
            child: Icon(Icons.event_outlined, color: Color(0xFF34368C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${event.date} · ${event.location}',
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
        ],
      ),
    );
  }
}
