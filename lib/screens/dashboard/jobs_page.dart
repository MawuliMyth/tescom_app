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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: AppRepository().loadBootstrap(),
      builder: (context, snapshot) {
        final apiJobs = snapshot.data?.jobs.map(_jobFromApi).toList();
        final sourceJobs = apiJobs ?? const <_Job>[];
        final filtered = sourceJobs.where((job) {
          final filterMatch =
              selectedFilter == 'All' || job.type == selectedFilter;
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
          body: _AppScaffoldBackground(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
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
                            onTap: () =>
                                setState(() => selectedFilter = filter),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const _ListShimmer(itemCount: 4)
                  else if (snapshot.hasError)
                    const _InlineErrorState()
                  else if (filtered.isEmpty)
                    const _EmptyJobsState()
                  else
                    ...filtered.map((job) => _JobCard(job: job)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _Job _jobFromApi(AppJob job) {
    final words = job.company
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return _Job(
      id: job.id,
      title: job.title,
      organization: job.company,
      initials: words.isEmpty ? 'TS' : words,
      logoUrl: job.logoUrl,
      location: job.location,
      type: job.type,
      salary: 'See details',
      workMode: job.applyUrl == null ? 'TESCON' : 'Apply online',
      experience: 'Member',
      status: 'OPEN',
      deadline: job.deadline == null
          ? 'Open'
          : '${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}',
      description: job.description,
      applyUrl: job.applyUrl,
      requirements: const [
        'Review the full opportunity details',
        'Prepare the requested documents',
        'Apply before the deadline where applicable',
      ],
    );
  }
}

class _Job {
  const _Job({
    required this.id,
    required this.title,
    required this.organization,
    required this.initials,
    this.logoUrl,
    required this.location,
    required this.type,
    required this.salary,
    required this.workMode,
    required this.experience,
    required this.status,
    required this.deadline,
    required this.description,
    this.applyUrl,
    required this.requirements,
  });

  final String id;
  final String title;
  final String organization;
  final String initials;
  final String? logoUrl;
  final String location;
  final String type;
  final String salary;
  final String workMode;
  final String experience;
  final String status;
  final String deadline;
  final String description;
  final String? applyUrl;
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

class _JobHeaderButton extends StatelessWidget {
  const _JobHeaderButton({required this.icon, required this.onTap});

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

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final _Job job;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          _adaptivePageRoute(context, builder: (_) => _JobDetailPage(job: job)),
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
                _JobLogoBadge(initials: job.initials, logoUrl: job.logoUrl),
                const SizedBox(width: 10),
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

class _JobLogoBadge extends StatelessWidget {
  const _JobLogoBadge({required this.initials, this.logoUrl, this.radius = 22});

  final String initials;
  final String? logoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final source = logoUrl;
    if (source != null && source.trim().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFEFEFFC),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: ApiConfig.mediaUrl(source),
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, _) => _ShimmerBlock(
              width: radius * 2,
              height: radius * 2,
              borderRadius: radius,
            ),
            errorWidget: (_, _, _) => _JobInitialsMark(initials: initials),
          ),
        ),
      );
    }
    return _JobInitialsMark(initials: initials, radius: radius);
  }
}

class _JobInitialsMark extends StatelessWidget {
  const _JobInitialsMark({required this.initials, this.radius = 22});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF34368C),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: radius > 24 ? 15 : 13,
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
  bool applying = false;

  Future<void> apply() async {
    if (applying || applied) return;
    final result = await showModalBottomSheet<_JobApplicationDraft>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobApplicationSheet(job: widget.job),
    );
    if (result == null) return;

    setState(() => applying = true);
    try {
      await AppRepository().applyForJob(
        jobId: widget.job.id,
        fullName: result.fullName,
        email: result.email,
        phone: result.phone,
        institution: result.institution,
        coverNote: result.coverNote,
        credentialsUrl: result.credentialsUrl,
        supportingUrl: result.supportingUrl,
      );
      if (!mounted) return;
      setState(() => applied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => applying = false);
    }
  }

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
                onPressed: applied ? null : apply,
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
                  applying
                      ? 'SUBMITTING...'
                      : applied
                      ? 'APPLIED'
                      : 'APPLY NOW',
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
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
            icon: saved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _JobApplicationDraft {
  const _JobApplicationDraft({
    required this.fullName,
    required this.email,
    this.phone,
    this.institution,
    this.coverNote,
    this.credentialsUrl,
    this.supportingUrl,
  });

  final String fullName;
  final String email;
  final String? phone;
  final String? institution;
  final String? coverNote;
  final String? credentialsUrl;
  final String? supportingUrl;
}

class _JobApplicationSheet extends StatefulWidget {
  const _JobApplicationSheet({required this.job});

  final _Job job;

  @override
  State<_JobApplicationSheet> createState() => _JobApplicationSheetState();
}

class _JobApplicationSheetState extends State<_JobApplicationSheet> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final institutionController = TextEditingController();
  final coverController = TextEditingController();
  final credentialsController = TextEditingController();
  final supportingController = TextEditingController();
  late Future<AppUser?> userFuture;
  String? prefillError;

  @override
  void initState() {
    super.initState();
    userFuture = AppRepository().loadCurrentUser();
    userFuture
        .then((user) {
          if (!mounted || user == null) return;
          fullNameController.text = user.fullName;
          emailController.text = user.email;
          phoneController.text = user.phone ?? '';
          institutionController.text = user.institution ?? '';
        })
        .catchError((error) {
          if (!mounted) return null;
          setState(() {
            prefillError =
                'Could not prefill your profile. You can still apply manually.';
          });
          return null;
        });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    institutionController.dispose();
    coverController.dispose();
    credentialsController.dispose();
    supportingController.dispose();
    super.dispose();
  }

  void submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      _JobApplicationDraft(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        institution: institutionController.text.trim(),
        coverNote: coverController.text.trim(),
        credentialsUrl: credentialsController.text.trim(),
        supportingUrl: supportingController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E5F1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Apply for ${widget.job.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close application form',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.job.organization,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF777777),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    if (prefillError != null) ...[
                      const SizedBox(height: 12),
                      _ApplicationNotice(message: prefillError!),
                    ],
                    const SizedBox(height: 18),
                    _ApplicationField(
                      controller: fullNameController,
                      label: 'Full name',
                      validator: _requiredField,
                    ),
                    _ApplicationField(
                      controller: emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    _ApplicationField(
                      controller: phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    _ApplicationField(
                      controller: institutionController,
                      label: 'Institution',
                    ),
                    _ApplicationField(
                      controller: coverController,
                      label: 'Cover note',
                      maxLines: 4,
                    ),
                    _ApplicationField(
                      controller: credentialsController,
                      label: 'Credentials link',
                      keyboardType: TextInputType.url,
                      validator: _optionalUrlValidator,
                    ),
                    _ApplicationField(
                      controller: supportingController,
                      label: 'Supporting document link',
                      keyboardType: TextInputType.url,
                      validator: _optionalUrlValidator,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF34368C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Submit application'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationField extends StatelessWidget {
  const _ApplicationField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF7F8FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF34368C)),
          ),
        ),
      ),
    );
  }
}

class _ApplicationNotice extends StatelessWidget {
  const _ApplicationNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFA16207),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFA16207),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _requiredField(String? value) {
  return value == null || value.trim().length < 2 ? 'Enter this field' : null;
}

String? _emailValidator(String? value) {
  final text = value?.trim() ?? '';
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  return valid ? null : 'Enter a valid email address';
}

String? _optionalUrlValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  return uri != null && uri.hasScheme && uri.host.isNotEmpty
      ? null
      : 'Enter a valid link';
}

String _friendlyError(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  if (message.contains('Authentication') ||
      message.contains('expired') ||
      message.contains('401')) {
    return 'Please log in again before applying.';
  }
  if (message.contains('already exists')) {
    return 'You have already applied for this job.';
  }
  return message.isEmpty ? 'Something went wrong. Try again.' : message;
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
              _JobLogoBadge(
                initials: job.initials,
                logoUrl: job.logoUrl,
                radius: 26,
              ),
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
  const _JobDetailSection({required this.title, required this.body});

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
                  child: Icon(Icons.circle, color: Color(0xFF34368C), size: 9),
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
