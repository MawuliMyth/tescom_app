part of '../dashboard_screen.dart';

// Polls and surveys screen for responding to available activities.
class _PollsPage extends StatefulWidget {
  const _PollsPage();

  @override
  State<_PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<_PollsPage> {
  String selectedTab = 'Polls';
  String? selectedOption;

  final pollOptions = const [
    _PollOption(label: 'Jobs & internships', percent: 47),
    _PollOption(label: 'Leadership workshops', percent: 34),
    _PollOption(label: 'Campus events', percent: 13),
    _PollOption(label: 'Community outreach', percent: 6),
  ];

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
              _PollsHeader(
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 14),
              _PollTabs(
                selectedTab: selectedTab,
                onSelected: (value) => setState(() => selectedTab = value),
              ),
              const SizedBox(height: 18),
              const _SurveyScoreCard(),
              const SizedBox(height: 18),
              const _ActivityQueue(),
              const SizedBox(height: 18),
              _PollActivityCard(
                options: pollOptions,
                selectedOption: selectedOption,
                onSelected: (value) => setState(() => selectedOption = value),
              ),
              const SizedBox(height: 18),
              const _QuickSurveyCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollOption {
  const _PollOption({
    required this.label,
    required this.percent,
  });

  final String label;
  final int percent;
}

// Top bar for the polls area.
class _PollsHeader extends StatelessWidget {
  const _PollsHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlainIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        Expanded(
          child: Text(
            'Polls & Surveys',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        _PlainIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _showDemoSheet(
            context,
            title: 'Activity Updates',
            message: 'New polls and surveys will appear here.',
          ),
        ),
      ],
    );
  }
}

// Category chips inspired by the poll reference UI.
class _PollTabs extends StatelessWidget {
  const _PollTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final String selectedTab;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Active', 'Surveys', 'Completed', 'Results'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab),
              selected: isSelected,
              onSelected: (_) => onSelected(tab),
              selectedColor: const Color(0xFF34368C),
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : const Color(0xFF34368C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              side: const BorderSide(color: Color(0xFFE2E2FA)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Compact survey status card with a circular score visual.
class _SurveyScoreCard extends StatelessWidget {
  const _SurveyScoreCard();

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      opacity: 0.86,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Survey',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF777777),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daily Score',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '6/10 tasks completed',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF34368C),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFE8E8EF),
                  color: const Color(0xFF34368C),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '70%',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

// Main poll card with progress bars and vote feedback.
class _PollActivityCard extends StatelessWidget {
  const _PollActivityCard({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final List<_PollOption> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      opacity: 0.88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                      'Chris Lloyd',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      '21 minutes ago',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF888888),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, color: Color(0xFF777777)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Which opportunity should TESCON prioritize this semester?',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '45 votes · Vote to see results',
            style: GoogleFonts.inter(
              color: const Color(0xFF777777),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          ...options.map(
            (option) {
              final isSelected = selectedOption == option.label;
              final value = isSelected
                  ? (option.percent + 5).clamp(0, 100)
                  : option.percent;
              return _PollOptionBar(
                option: option.label,
                percent: value,
                selected: isSelected,
                onTap: () => onSelected(option.label),
              );
            },
          ),
          const Divider(height: 26, color: Color(0xFFE8E8EF)),
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                '12',
                style: GoogleFonts.inter(fontSize: 11, letterSpacing: 0),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF777777),
                size: 17,
              ),
              const SizedBox(width: 5),
              Text(
                '12',
                style: GoogleFonts.inter(fontSize: 11, letterSpacing: 0),
              ),
              const Spacer(),
              Text(
                'Share',
                style: GoogleFonts.inter(
                  color: const Color(0xFF34368C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.ios_share_rounded,
                color: Color(0xFF34368C),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// A single selectable poll option with progress fill.
class _PollOptionBar extends StatelessWidget {
  const _PollOptionBar({
    required this.option,
    required this.percent,
    required this.selected,
    required this.onTap,
  });

  final String option;
  final int percent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Stack(
          children: [
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDF6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFDFF7E9)
                      : const Color(0xFFDCDCFF),
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: const Color(0xFF22C55E))
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: 34,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: selected
                          ? const Color(0xFF168A3A)
                          : const Color(0xFF777777),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        option,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
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

// Compact survey form inspired by the reference screen.
class _QuickSurveyCard extends StatefulWidget {
  const _QuickSurveyCard();

  @override
  State<_QuickSurveyCard> createState() => _QuickSurveyCardState();
}

class _QuickSurveyCardState extends State<_QuickSurveyCard> {
  bool wantsFeedback = true;
  String dailyApp = 'Instagram';

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      opacity: 0.86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick Survey',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Text(
                'See All',
                style: GoogleFonts.inter(
                  color: const Color(0xFF34368C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SurveyQuestion(
            title: 'Should TESCON show quick feedback animation?',
            child: Row(
              children: [
                Checkbox.adaptive(
                  value: wantsFeedback,
                  activeColor: const Color(0xFF34368C),
                  onChanged: (value) {
                    setState(() => wantsFeedback = value ?? false);
                  },
                ),
                const Text('Yes'),
                const SizedBox(width: 12),
                Checkbox.adaptive(
                  value: !wantsFeedback,
                  activeColor: const Color(0xFF34368C),
                  onChanged: (value) {
                    setState(() => wantsFeedback = !(value ?? false));
                  },
                ),
                const Text('No'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SurveyQuestion(
            title: 'Which platform do you use daily?',
            child: Column(
              children: ['WhatsApp', 'Instagram', 'Facebook', 'X'].map((item) {
                return RadioListTile<String>(
                  value: item,
                  groupValue: dailyApp,
                  onChanged: (value) => setState(() => dailyApp = value!),
                  activeColor: const Color(0xFF34368C),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item,
                    style: GoogleFonts.inter(fontSize: 12, letterSpacing: 0),
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

// Modern status card showing activities waiting for response.
class _ActivityQueue extends StatelessWidget {
  const _ActivityQueue();

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      opacity: 0.86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFFC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Color(0xFF34368C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Activity',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Respond to active polls and quick surveys.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF777777),
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _ActivityQueueStat(value: '3', label: 'Active'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActivityQueueStat(value: '1', label: 'Due Today'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActivityQueueStat(value: '70%', label: 'Completed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityQueueStat extends StatelessWidget {
  const _ActivityQueueStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8EF)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF34368C),
              fontSize: 16,
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
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyQuestion extends StatelessWidget {
  const _SurveyQuestion({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        child,
      ],
    );
  }
}
