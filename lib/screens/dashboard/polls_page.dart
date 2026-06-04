part of '../dashboard_screen.dart';

// Polls and surveys screen for responding to available activities.
class _PollsPage extends StatefulWidget {
  const _PollsPage();

  @override
  State<_PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<_PollsPage> {
  String selectedTab = 'Active';
  final Map<String, String> selectedOptions = {};
  final Set<String> votingPolls = {};
  late Future<AppBootstrap> bootstrapFuture;
  StreamSubscription<void>? refreshSubscription;

  @override
  void initState() {
    super.initState();
    bootstrapFuture = AppRepository().loadBootstrap();
    refreshSubscription = AppRefreshBus().stream.listen((_) {
      if (mounted) refreshPolls();
    });
  }

  @override
  void dispose() {
    refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshPolls() async {
    setState(() {
      bootstrapFuture = AppRepository().loadBootstrap();
    });
    await bootstrapFuture;
  }

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
              _PollsHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 14),
              _PollTabs(
                selectedTab: selectedTab,
                onSelected: (value) => setState(() => selectedTab = value),
              ),
              const SizedBox(height: 18),
              FutureBuilder<AppBootstrap>(
                future: bootstrapFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ListShimmer(itemCount: 2);
                  }
                  if (snapshot.hasError) return const _InlineErrorState();

                  final polls = _pollsForTab(
                    snapshot.data?.polls ?? const [],
                    selectedTab,
                  );
                  if (polls.isEmpty) return _emptyPollState(selectedTab);

                  return Column(
                    children: polls.map((poll) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PollActivityCard(
                          poll: poll,
                          selectedOption: selectedOptions[poll.id],
                          voting: votingPolls.contains(poll.id),
                          onSelected: (value) async {
                            if (votingPolls.contains(poll.id)) return;
                            final previousValue = selectedOptions[poll.id];
                            setState(() {
                              selectedOptions[poll.id] = value;
                              votingPolls.add(poll.id);
                            });
                            try {
                              await AppRepository().voteInPoll(
                                pollId: poll.id,
                                optionId: value,
                              );
                              await refreshPolls();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vote submitted.'),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;
                              setState(() {
                                if (previousValue == null) {
                                  selectedOptions.remove(poll.id);
                                } else {
                                  selectedOptions[poll.id] = previousValue;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_friendlyError(error))),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => votingPolls.remove(poll.id));
                              }
                            }
                          },
                          onShare: () {
                            Clipboard.setData(
                              ClipboardData(text: poll.question),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Poll question copied.'),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollOption {
  const _PollOption({
    required this.id,
    required this.label,
    required this.percent,
  });

  final String id;
  final String label;
  final int percent;
}

List<AppPoll> _pollsForTab(List<AppPoll> polls, String tab) {
  final now = DateTime.now();
  final active = polls.where((poll) {
    return poll.closesAt == null || poll.closesAt!.isAfter(now);
  }).toList();
  final completed = polls.where((poll) {
    return poll.closesAt != null && !poll.closesAt!.isAfter(now);
  }).toList();

  return switch (tab) {
    'Completed' || 'Results' => completed,
    _ => active,
  };
}

Widget _emptyPollState(String tab) {
  final completed = tab == 'Completed' || tab == 'Results';
  return _InfoCard(
    item: _InfoItem(
      title: completed ? 'No completed polls yet' : 'No active polls yet',
      subtitle: 'Admin dashboard',
      body: completed
          ? 'Closed poll results will appear here.'
          : 'Published polls that have not closed will appear here.',
      icon: Icons.poll_outlined,
    ),
  );
}

// Top bar for the polls area.
class _PollsHeader extends StatelessWidget {
  const _PollsHeader({required this.onBack});

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
          onTap: () => Navigator.push(
            context,
            _adaptivePageRoute(
              context,
              builder: (_) => const _NotificationsPage(),
            ),
          ),
        ),
      ],
    );
  }
}

// Category chips inspired by the poll reference UI.
class _PollTabs extends StatelessWidget {
  const _PollTabs({required this.selectedTab, required this.onSelected});

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
// ignore: unused_element
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
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE8ECF4),
              highlightColor: const Color(0xFFF8FAFF),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE8E8EF), width: 7),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '70%',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF34368C),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
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
    required this.poll,
    required this.selectedOption,
    required this.voting,
    required this.onSelected,
    required this.onShare,
  });

  final AppPoll poll;
  final String? selectedOption;
  final bool voting;
  final ValueChanged<String> onSelected;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final totalVotes = poll.options.fold<int>(
      0,
      (total, option) => total + option.voteCount,
    );

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
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TESCON',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      _friendlyDate(poll.closesAt),
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
            poll.question,
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
            poll.description ?? 'Vote to submit your response',
            style: GoogleFonts.inter(
              color: const Color(0xFF777777),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          ...poll.options.map((option) {
            final pollOption = _PollOption(
              id: option.id,
              label: option.text,
              percent: totalVotes == 0
                  ? 0
                  : ((option.voteCount / totalVotes) * 100).round(),
            );
            final isSelected = selectedOption == option.id;
            return _PollOptionBar(
              option: pollOption.label,
              percent: pollOption.percent,
              selected: isSelected,
              disabled: voting,
              onTap: () => onSelected(option.id),
            );
          }),
          const Divider(height: 26, color: Color(0xFFE8E8EF)),
          Row(
            children: [
              const Icon(
                Icons.how_to_vote_outlined,
                color: Color(0xFF34368C),
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                '$totalVotes votes',
                style: GoogleFonts.inter(fontSize: 11, letterSpacing: 0),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.checklist_rounded,
                color: Color(0xFF777777),
                size: 17,
              ),
              const SizedBox(width: 5),
              Text(
                '${poll.options.length} options',
                style: GoogleFonts.inter(fontSize: 11, letterSpacing: 0),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_rounded, size: 16),
                label: const Text('Share'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF34368C),
                  textStyle: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
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
    required this.disabled,
    required this.onTap,
  });

  final String option;
  final int percent;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
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
            child: RadioGroup<String>(
              groupValue: dailyApp,
              onChanged: (value) {
                if (value != null) setState(() => dailyApp = value);
              },
              child: Column(
                children: ['WhatsApp', 'Instagram', 'Facebook', 'X'].map((
                  item,
                ) {
                  return RadioListTile<String>(
                    value: item,
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
          ),
        ],
      ),
    );
  }
}

// Modern status card showing activities waiting for response.
// ignore: unused_element
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
  const _ActivityQueueStat({required this.value, required this.label});

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
  const _SurveyQuestion({required this.title, required this.child});

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
