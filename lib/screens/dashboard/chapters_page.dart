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
            ..._campusChapters.map(
              (chapter) => _CampusChapterTile(chapter: chapter),
            ),
          ],
        ),
      ),
    );
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

// Demo chapter records using the university logos already in assets/images.
const _campusChapters = [
  _CampusChapter(
    name: 'University of Ghana',
    shortName: 'UG TESCON',
    location: 'Legon, Accra',
    logoPath: 'assets/images/268456827778626902.jpg',
    membersCount: 1320,
    executivesCount: 12,
    eventsCount: 8,
    newsCount: 17,
    description:
        'University of Ghana TESCON coordinates student outreach, leadership programs, campus news, and chapter activities across Legon.',
    executives: [
      _Member(
        name: 'Ama Serwaa Mensah',
        role: 'Chapter President',
        institution: 'University of Ghana',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio: 'Leads chapter programs, membership drives, and campus policy conversations.',
      ),
      _Member(
        name: 'Joseph Mensah',
        role: 'Organizer',
        institution: 'University of Ghana',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Executive',
        contribution: 'Member Mobilization',
        bio: 'Coordinates student outreach and volunteer teams.',
      ),
    ],
    members: [
      _Member(
        name: 'Nana Adjei',
        role: 'TESCON Member',
        institution: 'University of Ghana',
        imagePath: 'assets/images/man.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Supports campus engagement and member participation.',
      ),
      _Member(
        name: 'Esi Boateng',
        role: 'TESCON Member',
        institution: 'University of Ghana',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Assists with chapter programs and event coordination.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'UG TESCON opens new member registration drive',
        source: 'University of Ghana',
        date: 'Feb 23, 2025',
      ),
      _ChapterUpdate(
        title: 'Chapter executives meet students ahead of campus forum',
        source: 'University of Ghana',
        date: 'Mar 02, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Campus Leadership Forum',
        date: 'Mar 12, 2025',
        location: 'Legon',
      ),
      _ChapterEvent(
        title: 'Member Orientation',
        date: 'Apr 04, 2025',
        location: 'SRC Union',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Central University',
    shortName: 'CU TESCON',
    location: 'Miotso',
    logoPath: 'assets/images/cu.jpg',
    membersCount: 1240,
    executivesCount: 12,
    eventsCount: 8,
    newsCount: 18,
    description:
        'Central University chapter manages campus announcements, leadership activities, event reporting, and member records for active TESCON members.',
    executives: [
      _Member(
        name: 'Ama Serwaa Mensah',
        role: 'Chapter President',
        institution: 'Central University',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio:
            'Leads chapter programs, membership drives, and campus policy conversations.',
      ),
      _Member(
        name: 'Joseph Mensah',
        role: 'Organizer',
        institution: 'Central University',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Executive',
        contribution: 'Member Mobilization',
        bio: 'Coordinates student outreach and volunteer teams.',
      ),
    ],
    members: [
      _Member(
        name: 'Nana Adjei',
        role: 'TESCON Member',
        institution: 'Central University',
        imagePath: 'assets/images/man.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Supports campus engagement and member participation.',
      ),
      _Member(
        name: 'Esi Boateng',
        role: 'TESCON Member',
        institution: 'Central University',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Assists with chapter programs and event coordination.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'Central University TESCON opens new member registration drive',
        source: 'Central University',
        date: 'Feb 23, 2025',
      ),
      _ChapterUpdate(
        title: 'Chapter executives meet students ahead of campus forum',
        source: 'Central University',
        date: 'Mar 02, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Campus Leadership Forum',
        date: 'Mar 12, 2025',
        location: 'Miotso',
      ),
      _ChapterEvent(
        title: 'Member Orientation',
        date: 'Apr 04, 2025',
        location: 'Central University',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Ghana Communication Technology University',
    shortName: 'GCTU TESCON',
    location: 'Tesano, Accra',
    logoPath: 'assets/images/gctu.jpg',
    membersCount: 840,
    executivesCount: 10,
    eventsCount: 6,
    newsCount: 14,
    description:
        'GCTU TESCON connects students interested in technology, public service, communication, and campus leadership development.',
    executives: [
      _Member(
        name: 'Kojo Ali',
        role: 'Communications Lead',
        institution: 'GCTU',
        imagePath: 'assets/images/man.png',
        memberCount: 'Executive',
        contribution: 'Media & Publicity',
        bio:
            'Coordinates chapter announcements, event media, and digital storytelling.',
      ),
      _Member(
        name: 'Chris Lloyd Nii Kwesi',
        role: 'Youth Organizer',
        institution: 'GCTU',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Executive',
        contribution: 'Campus Mobilization',
        bio: 'Supports chapter mobilization and youth programs.',
      ),
    ],
    members: [
      _Member(
        name: 'Akua Mensah',
        role: 'TESCON Member',
        institution: 'GCTU',
        imagePath: 'assets/images/white.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Supports outreach, programs, and chapter activities.',
      ),
      _Member(
        name: 'Kofi Aheto',
        role: 'TESCON Member',
        institution: 'GCTU',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Member',
        contribution: 'Media Support',
        bio: 'Assists with event updates and media documentation.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'GCTU TESCON honors campus volunteers',
        source: 'GCTU',
        date: 'Feb 23, 2025',
      ),
      _ChapterUpdate(
        title: 'Executives announce upcoming outreach schedule',
        source: 'GCTU',
        date: 'Mar 08, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Executive Social',
        date: 'Mar 18, 2025',
        location: 'Tesano',
      ),
      _ChapterEvent(
        title: 'Campus Outreach Day',
        date: 'Apr 12, 2025',
        location: 'GCTU',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Ashesi University',
    shortName: 'Ashesi TESCON',
    location: 'Berekuso',
    logoPath: 'assets/images/ahesi.png',
    membersCount: 1520,
    executivesCount: 14,
    eventsCount: 9,
    newsCount: 22,
    description:
        'Ashesi TESCON brings students together for leadership training, policy discussion, member development, and chapter events.',
    executives: [
      _Member(
        name: 'Yaw Boakye',
        role: 'Chapter President',
        institution: 'Ashesi University',
        imagePath: 'assets/images/man.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio: 'Leads campus planning and chapter administration.',
      ),
      _Member(
        name: 'Abena Osei',
        role: 'Women Organizer',
        institution: 'Ashesi University',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Member Engagement',
        bio: 'Coordinates women-focused member engagement activities.',
      ),
    ],
    members: [
      _Member(
        name: 'Kwesi Appiah',
        role: 'TESCON Member',
        institution: 'Ashesi University',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Supports programs and campus engagement.',
      ),
      _Member(
        name: 'Afia Nyarko',
        role: 'TESCON Member',
        institution: 'Ashesi University',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Assists with member mobilization and outreach.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'Ashesi TESCON prepares for leadership workshop',
        source: 'Ashesi',
        date: 'Mar 15, 2025',
      ),
      _ChapterUpdate(
        title: 'Students join policy conversation on campus',
        source: 'Ashesi',
        date: 'Mar 21, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Leadership Workshop',
        date: 'Apr 02, 2025',
        location: 'Berekuso',
      ),
      _ChapterEvent(
        title: 'Freshers Engagement',
        date: 'Apr 20, 2025',
        location: 'Ashesi University',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Ghana Institute of Management and Public Administration',
    shortName: 'GIMPA TESCON',
    location: 'Achimota, Accra',
    logoPath: 'assets/images/gimpa.png',
    membersCount: 690,
    executivesCount: 9,
    eventsCount: 5,
    newsCount: 11,
    description:
        'GIMPA TESCON focuses on leadership, public administration, student civic engagement, and executive development programs.',
    executives: [
      _Member(
        name: 'Dennis Ofori',
        role: 'Chapter President',
        institution: 'GIMPA',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio: 'Leads chapter strategy and executive coordination.',
      ),
      _Member(
        name: 'Efua Sarpong',
        role: 'Secretary',
        institution: 'GIMPA',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Administration',
        bio: 'Keeps records and coordinates chapter communication.',
      ),
    ],
    members: [
      _Member(
        name: 'Kwame Adu',
        role: 'TESCON Member',
        institution: 'GIMPA',
        imagePath: 'assets/images/man.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Supports GIMPA chapter programs and outreach.',
      ),
      _Member(
        name: 'Akosua Tetteh',
        role: 'TESCON Member',
        institution: 'GIMPA',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Assists with chapter mobilization and events.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'GIMPA TESCON launches leadership discussion series',
        source: 'GIMPA',
        date: 'Mar 28, 2025',
      ),
      _ChapterUpdate(
        title: 'Executives prepare public policy engagement',
        source: 'GIMPA',
        date: 'Apr 05, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Public Leadership Talk',
        date: 'Apr 15, 2025',
        location: 'GIMPA',
      ),
      _ChapterEvent(
        title: 'Chapter Executive Meeting',
        date: 'Apr 29, 2025',
        location: 'Achimota',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Pentecost University',
    shortName: 'Pentecost TESCON',
    location: 'Sowutuom, Accra',
    logoPath: 'assets/images/pentecoast.png',
    membersCount: 720,
    executivesCount: 8,
    eventsCount: 4,
    newsCount: 9,
    description:
        'Pentecost University TESCON supports campus engagement, member organization, and student leadership activities.',
    executives: [
      _Member(
        name: 'Samuel Nartey',
        role: 'Chapter President',
        institution: 'Pentecost University',
        imagePath: 'assets/images/man.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio: 'Coordinates chapter direction and campus engagement.',
      ),
      _Member(
        name: 'Mavis Asante',
        role: 'Organizer',
        institution: 'Pentecost University',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Member Mobilization',
        bio: 'Leads member mobilization and volunteer planning.',
      ),
    ],
    members: [
      _Member(
        name: 'Joel Ansah',
        role: 'TESCON Member',
        institution: 'Pentecost University',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Supports chapter outreach and event planning.',
      ),
      _Member(
        name: 'Adwoa Frimpong',
        role: 'TESCON Member',
        institution: 'Pentecost University',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Assists with program coordination and member updates.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'Pentecost TESCON organizes campus engagement drive',
        source: 'Pentecost University',
        date: 'Apr 11, 2025',
      ),
      _ChapterUpdate(
        title: 'New volunteers join chapter outreach team',
        source: 'Pentecost University',
        date: 'Apr 20, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Campus Engagement Drive',
        date: 'May 03, 2025',
        location: 'Sowutuom',
      ),
      _ChapterEvent(
        title: 'Member Strategy Session',
        date: 'May 18, 2025',
        location: 'Pentecost University',
      ),
    ],
  ),
  _CampusChapter(
    name: 'Presbyterian University Ghana',
    shortName: 'Presby TESCON',
    location: 'Abetifi',
    logoPath: 'assets/images/preb.png',
    membersCount: 610,
    executivesCount: 7,
    eventsCount: 4,
    newsCount: 8,
    description:
        'Presbyterian University TESCON keeps student members connected through chapter programs, executive coordination, and campus updates.',
    executives: [
      _Member(
        name: 'Kwaku Boateng',
        role: 'Chapter President',
        institution: 'Presbyterian University Ghana',
        imagePath: 'assets/images/suit.png',
        memberCount: 'Executive',
        contribution: 'Chapter Leadership',
        bio: 'Leads chapter activity planning and member coordination.',
      ),
      _Member(
        name: 'Linda Osei',
        role: 'Communications Lead',
        institution: 'Presbyterian University Ghana',
        imagePath: 'assets/images/white.png',
        memberCount: 'Executive',
        contribution: 'Media & Publicity',
        bio: 'Coordinates announcements and chapter media updates.',
      ),
    ],
    members: [
      _Member(
        name: 'Prince Owusu',
        role: 'TESCON Member',
        institution: 'Presbyterian University Ghana',
        imagePath: 'assets/images/man.png',
        memberCount: 'Member',
        contribution: 'Volunteer Support',
        bio: 'Supports member outreach and chapter events.',
      ),
      _Member(
        name: 'Maame Gyamfi',
        role: 'TESCON Member',
        institution: 'Presbyterian University Ghana',
        imagePath: 'assets/images/yellow.png',
        memberCount: 'Member',
        contribution: 'Programs Support',
        bio: 'Assists chapter programs and member registration.',
      ),
    ],
    news: [
      _ChapterUpdate(
        title: 'Presby TESCON updates chapter activity calendar',
        source: 'Presbyterian University',
        date: 'May 06, 2025',
      ),
      _ChapterUpdate(
        title: 'Executives meet student volunteers ahead of forum',
        source: 'Presbyterian University',
        date: 'May 14, 2025',
      ),
    ],
    events: [
      _ChapterEvent(
        title: 'Student Leadership Forum',
        date: 'May 24, 2025',
        location: 'Abetifi',
      ),
      _ChapterEvent(
        title: 'Chapter Members Meeting',
        date: 'Jun 07, 2025',
        location: 'Presbyterian University',
      ),
    ],
  ),
];

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
              _ChapterMetric(label: 'Members', value: '${chapter.membersCount}'),
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
  const _ChapterLogoBox({
    required this.logoPath,
    required this.size,
  });

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
      child: Image.asset(logoPath, fit: BoxFit.contain),
    );
  }
}

// Small statistic item under the chapter hero.
class _ChapterMetric extends StatelessWidget {
  const _ChapterMetric({
    required this.label,
    required this.value,
  });

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
  const _ChapterSection({
    required this.title,
    required this.children,
  });

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
                  '${item.source} · ${item.date}',
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
