part of '../dashboard_screen.dart';

class _DemoPageShell extends StatelessWidget {
  const _DemoPageShell({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          title,
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          children: [
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LatestNewsPage extends StatelessWidget {
  const _LatestNewsPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Latest News',
      subtitle: 'Official and campus TESCON stories.',
      children: [
        _RecommendationTile(
          imagePath: 'assets/images/coursel_image.png',
          authorImagePath: 'assets/images/suit.png',
          source: 'From National Secretariat',
          title: 'TESCON launches national campus mobilization drive',
          author: 'Chris Lloyd',
          date: 'Today',
        ),
        SizedBox(height: 14),
        _RecommendationTile(
          imagePath: 'assets/images/card.png',
          authorImagePath: 'assets/images/wayo.png',
          source: 'From Npp Head Office',
          title: 'National Delegates Conference 2025 is happening Tomorrow',
          author: 'Prince Yeboah',
          date: 'Jul 19, 2025.',
        ),
        SizedBox(height: 14),
        _RecommendationTile(
          imagePath: 'assets/images/give.png',
          authorImagePath: 'assets/images/white.png',
          source: 'From Tescon UCC',
          title: 'Ken Ohene Agyapong Speaks on Entrepreneurship',
          author: 'Baron',
          date: 'April 23, 2025.',
        ),
      ],
    );
  }
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  final notifications = <_InfoItem>[
    const _InfoItem(
      title: 'New announcement posted',
      subtitle: 'National Secretariat - unread',
      body: 'Membership update has been published for all chapter executives.',
      icon: Icons.campaign_outlined,
    ),
    const _InfoItem(
      title: 'Event reminder',
      subtitle: 'National Campus Tour - unread',
      body: 'The campus tour RSVP list is open for members.',
      icon: Icons.event_available_outlined,
    ),
    const _InfoItem(
      title: 'New opportunity',
      subtitle: 'Jobs & Opportunities - unread',
      body: 'A communications internship has been added.',
      icon: Icons.work_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Notifications',
      subtitle: notifications.isEmpty
          ? 'You are all caught up.'
          : 'Tap a notification to mark it as read.',
      children: [
        if (notifications.isEmpty)
          const _InfoCard(
            item: _InfoItem(
              title: 'No notifications',
              subtitle: 'Inbox clear',
              body: 'New alerts will appear here when they are available.',
              icon: Icons.notifications_none_rounded,
            ),
          )
        else
          ...notifications.map((item) {
            return InkWell(
              onTap: () => setState(() => notifications.remove(item)),
              borderRadius: BorderRadius.circular(16),
              child: _InfoCard(item: item),
            );
          }),
      ],
    );
  }
}

class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  String query = '';

  final items = const [
    _InfoItem(
      title: 'Origins of TESCON',
      subtitle: 'Student organization',
      body:
          'TESCON represents the tertiary student wing of the New Patriotic Party, preserving student leadership, organizing history, and chapter records.',
      icon: Icons.history_edu_outlined,
    ),
    _InfoItem(
      title: 'Campus Mobilization',
      subtitle: 'Student leadership',
      body:
          'Across tertiary institutions, TESCON chapters organize debates, outreach, policy education, and election support activities for students.',
      icon: Icons.groups_outlined,
    ),
    _InfoItem(
      title: 'Digital Chapter Records',
      subtitle: 'Digital archive',
      body:
          'Searchable records can include timelines, biographies, documents, photos, and verified milestones.',
      icon: Icons.folder_copy_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) => item.matches(query)).toList();

    return _SearchablePageShell(
      title: 'TESCON History',
      subtitle: 'Search institutional history, milestones, and archives.',
      hintText: 'Search history',
      onChanged: (value) => setState(() => query = value),
      children: filtered.map((item) => _InfoCard(item: item)).toList(),
    );
  }
}

class _MemberDirectoryPage extends StatefulWidget {
  const _MemberDirectoryPage();

  @override
  State<_MemberDirectoryPage> createState() => _MemberDirectoryPageState();
}

class _MemberDirectoryPageState extends State<_MemberDirectoryPage> {
  String query = '';

  final members = const [
    _Member(
      name: 'Chris Lloyd Nii Kwesi',
      role: 'Youth Organizer',
      institution: 'National TESCON',
      imagePath: 'assets/images/suit.png',
      bio:
          'Youth organizer focused on student mobilization, communication, and campus chapter development.',
    ),
    _Member(
      name: 'Ama Serwaa Mensah',
      role: 'Chapter President',
      institution: 'University of Ghana',
      imagePath: 'assets/images/white.png',
      bio:
          'Leads chapter programs, membership drives, and campus policy conversations for student members.',
    ),
    _Member(
      name: 'Kojo Ali',
      role: 'Communications Lead',
      institution: 'Central University',
      imagePath: 'assets/images/man.png',
      bio:
          'Coordinates chapter announcements, event media, and digital storytelling for the member directory.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = members.where((member) => member.matches(query)).toList();

    return _SearchablePageShell(
      title: 'Member Directory',
      subtitle: 'Search biographies of members, leaders, and chapter executives.',
      hintText: 'Search member or institution',
      onChanged: (value) => setState(() => query = value),
      children: filtered.map((member) => _MemberCard(member: member)).toList(),
    );
  }
}

class _JobsPage extends StatefulWidget {
  const _JobsPage();

  @override
  State<_JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<_JobsPage> {
  String query = '';
  String selectedFilter = 'All';

  final filters = const [
    'All',
    'Internship',
    'Full-time',
    'National Service',
    'Scholarship',
    'Volunteer',
  ];

  final jobs = const [
    _Job(
      title: 'Communications Intern',
      organization: 'Policy Youth Desk',
      location: 'Accra',
      type: 'Internship',
      deadline: 'June 12, 2026',
      description:
          'Support media monitoring, event reporting, and digital content preparation for youth programs.',
    ),
    _Job(
      title: 'National Service Assistant',
      organization: 'Civic Engagement Office',
      location: 'Kumasi',
      type: 'National Service',
      deadline: 'July 1, 2026',
      description:
          'Assist with research, member registration, program coordination, and stakeholder follow-ups.',
    ),
    _Job(
      title: 'Campus Ambassador',
      organization: 'TESCON Opportunities Desk',
      location: 'Remote / Campus',
      type: 'Volunteer',
      deadline: 'Open',
      description:
          'Represent the opportunities desk on campus and help members discover jobs, internships, and scholarships.',
    ),
    _Job(
      title: 'Leadership Scholarship',
      organization: 'Youth Development Fund',
      location: 'Ghana',
      type: 'Scholarship',
      deadline: 'August 30, 2026',
      description:
          'Scholarship opportunity for student leaders with strong community and campus involvement.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = jobs.where((job) {
      final filterMatch = selectedFilter == 'All' || job.type == selectedFilter;
      return filterMatch && job.matches(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          'Jobs & Opportunities',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          children: [
            Text(
              'Search internships, jobs, scholarships, national service, and youth development opportunities.',
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _DemoSearchField(
              hintText: 'Search jobs or organizations',
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: filter,
                      selected: selectedFilter == filter,
                      onTap: () => setState(() => selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ...filtered.map((job) => _JobCard(job: job)),
          ],
        ),
      ),
    );
  }
}

class _LiveChatPage extends StatefulWidget {
  const _LiveChatPage();

  @override
  State<_LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<_LiveChatPage> {
  final controller = TextEditingController();
  final messages = <_ChatMessage>[
    const _ChatMessage(
      sender: 'Chris Lloyd',
      text: 'Welcome to the TESCON national chat.',
      mine: false,
    ),
    const _ChatMessage(
      sender: 'Ama Serwaa',
      text: 'Central University chapter is ready for the event.',
      mine: false,
    ),
    const _ChatMessage(
      sender: 'You',
      text: 'Great. Please share updates here.',
      mine: true,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          'Live Chat',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: _LiquidScaffoldBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _LiquidGlass(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                opacity: 0.66,
                child: Text(
                  'Room: General TESCON Chat',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: messages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _LiquidGlass(
                        borderRadius: 22,
                        opacity: 0.72,
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: Icons.send_rounded,
                      onTap: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          messages.add(_ChatMessage(
                            sender: 'You',
                            text: text,
                            mine: true,
                          ));
                        });
                        controller.clear();
                      },
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

class _EventsPage extends StatelessWidget {
  const _EventsPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Events',
      subtitle: 'Upcoming programs and chapter activities.',
      children: const [
        _ActionInfoCard(
          item: _InfoItem(
            title: 'National Campus Tour',
            subtitle: 'June 20, 2026 - Accra',
            body:
                'Leadership engagement, policy conversations, and campus mobilization.',
            icon: Icons.event_available_outlined,
          ),
          actionLabel: 'RSVP',
        ),
        _ActionInfoCard(
          item: _InfoItem(
            title: 'Chapter Leadership Workshop',
            subtitle: 'July 5, 2026 - Kumasi',
            body:
                'Training for chapter executives on communication and organization.',
            icon: Icons.co_present_outlined,
          ),
          actionLabel: 'Register',
        ),
      ],
    );
  }
}

class _AnnouncementsPage extends StatelessWidget {
  const _AnnouncementsPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Announcements',
      subtitle: 'Official notices from national and campus leadership.',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: 'Membership Update',
            subtitle: 'National Secretariat',
            body:
                'All campus chapters are encouraged to update their member lists before the next engagement.',
            icon: Icons.campaign_outlined,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'Event Media Submission',
            subtitle: 'Communications Desk',
            body:
                'Chapter media teams can prepare event photos and reports for publication.',
            icon: Icons.photo_library_outlined,
          ),
        ),
      ],
    );
  }
}

class _ExecutivesPage extends StatelessWidget {
  const _ExecutivesPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Executives',
      subtitle: 'Leadership profiles and responsibilities.',
      children: [
        _MemberCard(
          member: _Member(
            name: 'Chris Lloyd Nii Kwesi',
            role: 'Youth Organizer',
            institution: 'National TESCON',
            imagePath: 'assets/images/suit.png',
            bio:
                'Coordinates youth communication, chapter mobilization, and student engagement programs.',
          ),
        ),
        _MemberCard(
          member: _Member(
            name: 'Ama Serwaa Mensah',
            role: 'Chapter President',
            institution: 'University of Ghana',
            imagePath: 'assets/images/white.png',
            bio:
                'Leads campus chapter planning, event execution, and membership growth.',
          ),
        ),
      ],
    );
  }
}

class _ChaptersPage extends StatelessWidget {
  const _ChaptersPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'Campus Chapters',
      subtitle: 'Institutional chapters and activity records.',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: 'University of Ghana',
            subtitle: 'Active chapter - 1,240 members',
            body:
                'Includes chapter executives, campus news, events, and member directory records.',
            icon: Icons.school_outlined,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'Central University',
            subtitle: 'Active chapter - 840 members',
            body:
                'Chapter dashboard can later show news, events, executives, and activity metrics.',
            icon: Icons.school_outlined,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'KNUST',
            subtitle: 'Active chapter - 1,520 members',
            body:
                'Searchable institution record for chapter activity and membership.',
            icon: Icons.school_outlined,
          ),
        ),
      ],
    );
  }
}

class _PollsPage extends StatefulWidget {
  const _PollsPage();

  @override
  State<_PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<_PollsPage> {
  String? selected;
  final votes = {
    'Jobs & internships': 58,
    'Leadership workshops': 27,
    'Campus events': 15,
  };

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Polls & Surveys',
      subtitle: 'Collect student feedback and chapter sentiment during campaigns.',
      children: [
        Text(
          'Which opportunity should TESCON prioritize this semester?',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        ...['Jobs & internships', 'Leadership workshops', 'Campus events']
            .map((option) {
          final isSelected = selected == option;
          return InkWell(
            onTap: () => setState(() => selected = option),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? const Color(0xFF34368C)
                        : const Color(0xFF9A9A9A),
                  ),
                  const SizedBox(width: 10),
                  Text(option),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        ...votes.entries.map((entry) {
          final boostedValue =
              selected == entry.key ? (entry.value + 5).clamp(0, 100) : entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text('$boostedValue%'),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: boostedValue / 100,
                  backgroundColor: const Color(0xFFE9E9EF),
                  color: const Color(0xFF34368C),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          );
        }),
        if (selected != null)
          _MiniPill(text: 'Your vote: $selected'),
      ],
    );
  }
}

class _ContactFormPage extends StatefulWidget {
  const _ContactFormPage({required this.title});

  final String title;

  @override
  State<_ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<_ContactFormPage> {
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: widget.title,
      subtitle: sent
          ? 'Your message has been submitted.'
          : 'Send a message to the relevant support desk.',
      children: [
        if (!sent) ...[
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your message',
              filled: true,
              fillColor: const Color(0xFFF6F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => setState(() => sent = true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF34368C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Send Message'),
          ),
        ] else
          const _InfoCard(
            item: _InfoItem(
              title: 'Message Sent',
              subtitle: 'Support desk notified',
              body:
                  'The support desk has received your message.',
              icon: Icons.mark_email_read_outlined,
            ),
          ),
      ],
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return const _DemoPageShell(
      title: 'About TESCON',
      subtitle: 'A concise institutional overview for the mobile app.',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: 'Inform, Organize, Mobilize',
            subtitle: 'Mobile app vision',
            body:
                'The app positions TESCON as a student communication, history, opportunity, and mobilization platform.',
            icon: Icons.info_outline_rounded,
          ),
        ),
        _InfoCard(
          item: _InfoItem(
            title: 'Mobile-first structure',
            subtitle: 'Ready for live data',
            body:
                'News, members, events, chat, jobs, and profile data are structured for live data integration.',
            icon: Icons.api_rounded,
          ),
        ),
      ],
    );
  }
}

class _ContactPage extends StatelessWidget {
  const _ContactPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Contact / Support',
      subtitle: 'Support routes for members and chapter executives.',
      children: [
        _ActionInfoCard(
          item: const _InfoItem(
            title: 'Support Desk',
            subtitle: 'support@tescon.app',
            body:
                'Members can contact support for account, chapter, and event questions.',
            icon: Icons.support_agent_rounded,
          ),
          actionLabel: 'Send Message',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const _ContactFormPage(title: 'Support Desk'),
            ),
          ),
        ),
        _ActionInfoCard(
          item: const _InfoItem(
            title: 'Chapter Help',
            subtitle: 'For campus executives',
            body:
                'Chapter leaders can request updates to events, executives, and institution records.',
            icon: Icons.groups_2_outlined,
          ),
          actionLabel: 'Request Help',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const _ContactFormPage(title: 'Chapter Help'),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool notifications = true;
  bool chatAlerts = true;
  bool jobAlerts = true;

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Settings',
      subtitle: 'Preferences for notifications, chat, and opportunities.',
      children: [
        SwitchListTile(
          value: notifications,
          activeThumbColor: const Color(0xFF34368C),
          title: const Text('News notifications'),
          onChanged: (value) => setState(() => notifications = value),
        ),
        SwitchListTile(
          value: chatAlerts,
          activeThumbColor: const Color(0xFF34368C),
          title: const Text('Live chat alerts'),
          onChanged: (value) => setState(() => chatAlerts = value),
        ),
        SwitchListTile(
          value: jobAlerts,
          activeThumbColor: const Color(0xFF34368C),
          title: const Text('Jobs & opportunities alerts'),
          onChanged: (value) => setState(() => jobAlerts = value),
        ),
      ],
    );
  }
}

class _SearchablePageShell extends StatelessWidget {
  const _SearchablePageShell({
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.onChanged,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String hintText;
  final ValueChanged<String> onChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          children: [
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _DemoSearchField(
              hintText: hintText,
              onChanged: onChanged,
            ),
            const SizedBox(height: 16),
            if (children.isEmpty)
              const _InfoCard(
                item: _InfoItem(
                  title: 'No results found',
                  subtitle: 'Try another keyword',
                  body:
                      'Try another keyword to search the available records.',
                  icon: Icons.search_off_rounded,
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _DemoSearchField extends StatelessWidget {
  const _DemoSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _LiquidGlass(
      borderRadius: 18,
      opacity: 0.72,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        subtitle.toLowerCase().contains(lower) ||
        body.toLowerCase().contains(lower);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return _LiquidGlass(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      opacity: 0.68,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: const Color(0xFF34368C), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7A7A7A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 11,
                    height: 1.35,
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

class _ActionInfoCard extends StatefulWidget {
  const _ActionInfoCard({
    required this.item,
    required this.actionLabel,
    this.onTap,
  });

  final _InfoItem item;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  State<_ActionInfoCard> createState() => _ActionInfoCardState();
}

class _ActionInfoCardState extends State<_ActionInfoCard> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(item: widget.item),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: completed
                ? null
                : widget.onTap ?? () => setState(() => completed = true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  completed ? const Color(0xFFBDBDBD) : const Color(0xFF34368C),
              foregroundColor: Colors.white,
            ),
            child: Text(completed ? 'Confirmed' : widget.actionLabel),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _Member {
  const _Member({
    required this.name,
    required this.role,
    required this.institution,
    required this.imagePath,
    required this.bio,
  });

  final String name;
  final String role;
  final String institution;
  final String imagePath;
  final String bio;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return name.toLowerCase().contains(lower) ||
        role.toLowerCase().contains(lower) ||
        institution.toLowerCase().contains(lower) ||
        bio.toLowerCase().contains(lower);
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDemoSheet(
        context,
        title: member.name,
        message: member.bio,
      ),
      borderRadius: BorderRadius.circular(16),
      child: _LiquidGlass(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        opacity: 0.68,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(member.imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.institution,
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}

class _Job {
  const _Job({
    required this.title,
    required this.organization,
    required this.location,
    required this.type,
    required this.deadline,
    required this.description,
  });

  final String title;
  final String organization;
  final String location;
  final String type;
  final String deadline;
  final String description;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        organization.toLowerCase().contains(lower) ||
        location.toLowerCase().contains(lower) ||
        type.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final _Job job;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _JobDetailPage(job: job)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: _LiquidGlass(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        opacity: 0.68,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const Icon(Icons.bookmark_border_rounded,
                    color: Color(0xFF34368C)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${job.organization} - ${job.location}',
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              job.description,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 11,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniPill(text: job.type),
                const SizedBox(width: 8),
                _MiniPill(text: 'Deadline: ${job.deadline}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobDetailPage extends StatefulWidget {
  const _JobDetailPage({required this.job});

  final _Job job;

  @override
  State<_JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<_JobDetailPage> {
  bool applied = false;
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: widget.job.title,
      subtitle: '${widget.job.organization} - ${widget.job.location}',
      children: [
        _InfoCard(
          item: _InfoItem(
            title: widget.job.type,
            subtitle: 'Deadline: ${widget.job.deadline}',
            body: widget.job.description,
            icon: Icons.work_outline_rounded,
          ),
        ),
        const _InfoCard(
          item: _InfoItem(
            title: 'Requirements',
            subtitle: 'Requirements',
            body:
                'Good communication skills, active student leadership interest, and availability for program activities.',
            icon: Icons.checklist_rounded,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => saved = !saved),
                icon: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                ),
                label: Text(saved ? 'Saved' : 'Save Job'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: applied ? null : () => setState(() => applied = true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34368C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(applied ? 'Applied' : 'Apply Now'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF34368C),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.mine,
  });

  final String sender;
  final String text;
  final bool mine;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: _LiquidGlass(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        opacity: message.mine ? 0.92 : 0.62,
        child: Column(
          crossAxisAlignment:
              message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: GoogleFonts.inter(
                color: message.mine
                    ? const Color(0xFF34368C)
                    : const Color(0xFF777777),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 12,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
