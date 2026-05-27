part of '../dashboard_screen.dart';

// Jobs and opportunities route styled as a compact job-board experience.
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
      initials: 'PY',
      location: 'Accra',
      type: 'Internship',
      salary: 'GHS 800/month',
      workMode: 'Hybrid',
      experience: 'Entry',
      status: 'OPEN',
      deadline: 'June 12, 2026',
      description:
          'Support media monitoring, event reporting, and digital content preparation for youth programs.',
      requirements: [
        'Strong writing and communication skills',
        'Interest in public affairs and student leadership',
        'Basic social media and content planning ability',
        'Availability for program and event activities',
      ],
    ),
    _Job(
      title: 'National Service Assistant',
      organization: 'Civic Engagement Office',
      initials: 'CE',
      location: 'Kumasi',
      type: 'National Service',
      salary: 'Allowance',
      workMode: 'On-site',
      experience: 'Graduate',
      status: 'OPEN',
      deadline: 'July 1, 2026',
      description:
          'Assist with research, member registration, program coordination, and stakeholder follow-ups.',
      requirements: [
        'Eligible for national service placement',
        'Good organization and record-keeping skills',
        'Comfortable working with chapter executives',
        'Available for office and field coordination',
      ],
    ),
    _Job(
      title: 'Campus Ambassador',
      organization: 'TESCON Opportunities Desk',
      initials: 'TO',
      location: 'Remote / Campus',
      type: 'Volunteer',
      salary: 'Volunteer',
      workMode: 'Remote',
      experience: 'Student',
      status: 'FEATURED',
      deadline: 'Open',
      description:
          'Represent the opportunities desk on campus and help members discover jobs, internships, and scholarships.',
      requirements: [
        'Active TESCON member on campus',
        'Strong peer communication skills',
        'Interest in helping students find opportunities',
        'Ability to share weekly updates with members',
      ],
    ),
    _Job(
      title: 'Leadership Scholarship',
      organization: 'Youth Development Fund',
      initials: 'YD',
      location: 'Ghana',
      type: 'Scholarship',
      salary: 'Award',
      workMode: 'Nationwide',
      experience: 'Student',
      status: 'OPEN',
      deadline: 'August 30, 2026',
      description:
          'Scholarship opportunity for student leaders with strong community and campus involvement.',
      requirements: [
        'Evidence of student leadership',
        'Strong academic or community record',
        'Active involvement in campus programs',
        'Complete application before the deadline',
      ],
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
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Jobs & Opportunities',
          textAlign: TextAlign.center,
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
              textAlign: TextAlign.center,
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
            if (filtered.isEmpty)
              const _EmptyJobsState()
            else
              ...filtered.map((job) => _JobCard(job: job)),
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
    required this.initials,
    required this.location,
    required this.type,
    required this.salary,
    required this.workMode,
    required this.experience,
    required this.status,
    required this.deadline,
    required this.description,
    required this.requirements,
  });

  final String title;
  final String organization;
  final String initials;
  final String location;
  final String type;
  final String salary;
  final String workMode;
  final String experience;
  final String status;
  final String deadline;
  final String description;
  final List<String> requirements;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        organization.toLowerCase().contains(lower) ||
        location.toLowerCase().contains(lower) ||
        type.toLowerCase().contains(lower) ||
        workMode.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }
}

// Green welcome block at the top of the job board.
class _JobsWelcomeHeader extends StatelessWidget {
  const _JobsWelcomeHeader({
    required this.onBack,
    required this.onNotify,
  });

  final VoidCallback onBack;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34368C), Color(0xFF5A5CC6)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _JobHeaderButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/suit.png'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Find jobs, internships, service, and scholarships.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          _JobHeaderButton(icon: Icons.notifications_none_rounded, onTap: onNotify),
        ],
      ),
    );
  }
}

class _JobHeaderButton extends StatelessWidget {
  const _JobHeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _JobsSearchBar extends StatelessWidget {
  const _JobsSearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      borderRadius: 16,
      opacity: 0.9,
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search for a title, organization, or location',
          prefixIcon: Icon(Icons.search_rounded),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _TopCompaniesPanel extends StatelessWidget {
  const _TopCompaniesPanel({required this.jobs});

  final List<_Job> jobs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34368C), Color(0xFF5A5CC6)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Organizations',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: jobs.map((job) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _JobInitialsBadge(initials: job.initials),
                      const SizedBox(width: 8),
                      Text(
                        job.organization,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobsSectionHeader extends StatelessWidget {
  const _JobsSectionHeader({
    required this.title,
    required this.actionText,
  });

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF34368C),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        Text(
          actionText,
          style: GoogleFonts.inter(
            color: const Color(0xFF34368C),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
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
          _adaptivePageRoute(
            context,
            builder: (_) => _JobDetailPage(job: job),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: _AppSurface(
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
                const Icon(
                  Icons.bookmark_border_rounded,
                  color: Color(0xFF34368C),
                ),
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

class _JobInitialsBadge extends StatelessWidget {
  const _JobInitialsBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF34368C),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _JobStatusPill extends StatelessWidget {
  const _JobStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: status == 'FEATURED'
            ? const Color(0xFFEFEFFC)
            : const Color(0xFF34368C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: status == 'FEATURED' ? const Color(0xFF34368C) : Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _JobInfoPill extends StatelessWidget {
  const _JobInfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF34368C),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
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
    final job = widget.job;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _JobDetailHeader(
                  saved: saved,
                  onBack: () => Navigator.pop(context),
                  onSave: () => setState(() => saved = !saved),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _JobDetailSummary(job: job),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _JobDetailSection(
                                title: 'Job Description',
                                body: job.description,
                              ),
                              const SizedBox(height: 22),
                              _JobRequirements(requirements: job.requirements),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 24,
              child: FilledButton(
                onPressed: applied ? null : () => setState(() => applied = true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34368C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFBDBDEB),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  applied ? 'APPLIED' : 'APPLY NOW',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobDetailHeader extends StatelessWidget {
  const _JobDetailHeader({
    required this.saved,
    required this.onBack,
    required this.onSave,
  });

  final bool saved;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 74),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34368C), Color(0xFF5A5CC6)],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          _JobHeaderButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: Text(
                'Job Description',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          _JobHeaderButton(
            icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _JobDetailSummary extends StatelessWidget {
  const _JobDetailSummary({required this.job});

  final _Job job;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      borderRadius: 18,
      opacity: 0.96,
      child: Column(
        children: [
          Row(
            children: [
              _JobInitialsBadge(initials: job.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.organization,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.title,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF777777),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              _JobStatusPill(status: job.status),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _JobInfoPill(text: job.type),
              _JobInfoPill(text: job.salary),
              _JobInfoPill(text: job.workMode),
              _JobInfoPill(text: job.experience),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobDetailSection extends StatelessWidget {
  const _JobDetailSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF34368C),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: GoogleFonts.inter(
            color: const Color(0xFF777777),
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _JobRequirements extends StatelessWidget {
  const _JobRequirements({required this.requirements});

  final List<String> requirements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Requirements',
          style: GoogleFonts.inter(
            color: const Color(0xFF34368C),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        ...requirements.map(
          (requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFF34368C),
                    size: 9,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    requirement,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyJobsState extends StatelessWidget {
  const _EmptyJobsState();

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      opacity: 0.72,
      child: Text(
        'No opportunities found. Try another search keyword.',
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
