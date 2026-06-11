part of '../dashboard_screen.dart';

// Membership Directory screen with centered title, search, and filters.
class _MemberDirectoryPage extends StatefulWidget {
  const _MemberDirectoryPage();

  @override
  State<_MemberDirectoryPage> createState() => _MemberDirectoryPageState();
}

class _MemberDirectoryPageState extends State<_MemberDirectoryPage> {
  late final Future<_DirectoryPeopleData> _membersFuture;

  // Search text entered by the user.
  String query = '';

  // Active filter values. "All" means the filter is not restricting results.
  String selectedSchool = 'All';
  String selectedRole = 'All';
  bool _schoolInitialized = false;

  @override
  void initState() {
    super.initState();
    _membersFuture = _loadPeople(AppRepository().loadMembers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _MemberDirectoryTopBar(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 12),
              FutureBuilder<_DirectoryPeopleData>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 34),
                      child: _ListShimmer(itemCount: 4),
                    );
                  }
                  if (snapshot.hasError) return const _InlineErrorState();

                  final members = (snapshot.data?.users ?? const [])
                      .map(_Member.fromUser)
                      .toList();
                  final schools = [
                    'All',
                    ...{for (final member in members) member.institution},
                  ];
                  final preferredSchool = snapshot.data?.currentUser?.institution;
                  final activeSchool = _activeSchoolFor(
                    selectedSchool: selectedSchool,
                    preferredSchool: preferredSchool,
                    schools: schools,
                    initialized: _schoolInitialized,
                  );
                  final filteredMembers = _filterMembers(
                    members,
                    school: activeSchool,
                  );
                  final roles = [
                    'All',
                    ...{for (final member in members) member.role},
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MemberDirectoryIntro(count: filteredMembers.length),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _MemberSearchField(
                              hintText: 'Search by name',
                              onChanged: (value) =>
                                  setState(() => query = value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SmartMemberFilterButton(
                            selectedSchool: activeSchool,
                            selectedRole: selectedRole,
                            schools: schools,
                            roles: roles,
                            onApply: (school, role) {
                              setState(() {
                                _schoolInitialized = true;
                                selectedSchool = school;
                                selectedRole = role;
                              });
                            },
                          ),
                        ],
                      ),
                      if (activeSchool != 'All' || selectedRole != 'All') ...[
                        const SizedBox(height: 10),
                        _ActiveFilterSummary(
                          selectedSchool: activeSchool,
                          selectedRole: selectedRole,
                        ),
                      ],
                      const SizedBox(height: 18),
                      const _MemberListLabel(label: 'Members'),
                      const SizedBox(height: 10),
                      if (filteredMembers.isEmpty)
                        const _EmptyMemberState()
                      else if (activeSchool == 'All')
                        ..._groupMembersBySchool(filteredMembers).entries.map(
                          (entry) => _SchoolMemberSection(
                            school: entry.key,
                            members: entry.value,
                          ),
                        )
                      else
                        ...filteredMembers.map(
                          (member) => _MemberCard(member: member),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Applies search, school, and role filters to the member list.
  List<_Member> _filterMembers(List<_Member> members, {required String school}) {
    return members.where((member) {
      final schoolMatch = school == 'All' || member.institution == school;
      final roleMatch = selectedRole == 'All' || member.role == selectedRole;
      final queryMatch = query.trim().isEmpty || member.matches(query);
      return schoolMatch && roleMatch && queryMatch;
    }).toList();
  }
}

Future<_DirectoryPeopleData> _loadPeople(Future<List<AppUser>> usersFuture) async {
  final results = await Future.wait<Object?>([
    usersFuture,
    AppRepository().loadCurrentUser(),
  ]);
  return _DirectoryPeopleData(
    users: results[0] as List<AppUser>,
    currentUser: results[1] as AppUser?,
  );
}

class _DirectoryPeopleData {
  const _DirectoryPeopleData({required this.users, required this.currentUser});

  final List<AppUser> users;
  final AppUser? currentUser;
}

String _activeSchoolFor({
  required String selectedSchool,
  required String? preferredSchool,
  required List<String> schools,
  required bool initialized,
}) {
  if (initialized || selectedSchool != 'All') return selectedSchool;
  final school = preferredSchool?.trim();
  if (school == null || school.isEmpty) return selectedSchool;
  return schools.contains(school) ? school : selectedSchool;
}

Map<String, List<_Member>> _groupMembersBySchool(List<_Member> members) {
  final grouped = <String, List<_Member>>{};
  for (final member in members) {
    grouped.putIfAbsent(member.institution, () => []).add(member);
  }
  return Map.fromEntries(
    grouped.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
  );
}

// Header row with back button and centered page title.
class _MemberDirectoryTopBar extends StatelessWidget {
  const _MemberDirectoryTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlainIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        Expanded(
          child: Text(
            'Member Directory',
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
    );
  }
}

// Centered intro copy and result count pill.
class _MemberDirectoryIntro extends StatelessWidget {
  const _MemberDirectoryIntro({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Member Directory',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Biographies of members, leaders, and chapter executives.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF777777),
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        _MemberCountPill(count: count),
      ],
    );
  }
}

// Compact count badge shown below the centered header copy.
class _MemberCountPill extends StatelessWidget {
  const _MemberCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.groups_2_outlined,
            color: Color(0xFF34368C),
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: GoogleFonts.inter(
              color: const Color(0xFF151515),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// Search box shared by membership and executive screens.
class _MemberSearchField extends StatelessWidget {
  const _MemberSearchField({required this.hintText, required this.onChanged});

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
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

// Single advanced filter button that opens school and role filters in one sheet.
class _SmartMemberFilterButton extends StatelessWidget {
  const _SmartMemberFilterButton({
    required this.selectedSchool,
    required this.selectedRole,
    required this.schools,
    required this.roles,
    required this.onApply,
  });

  final String selectedSchool;
  final String selectedRole;
  final List<String> schools;
  final List<String> roles;
  final void Function(String school, String role) onApply;

  @override
  Widget build(BuildContext context) {
    final activeCount =
        (selectedSchool == 'All' ? 0 : 1) + (selectedRole == 'All' ? 0 : 1);

    return InkWell(
      onTap: () => _showMemberFilterSheet(
        context,
        selectedSchool: selectedSchool,
        selectedRole: selectedRole,
        schools: schools,
        roles: roles,
        onApply: onApply,
      ),
      borderRadius: BorderRadius.circular(18),
      child: _AppSurface(
        width: 54,
        height: 54,
        borderRadius: 18,
        opacity: 0.72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFF34368C),
                size: 22,
              ),
            ),
            if (activeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34368C),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$activeCount',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
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

// Shows active filter labels without taking over the page layout.
class _ActiveFilterSummary extends StatelessWidget {
  const _ActiveFilterSummary({
    required this.selectedSchool,
    required this.selectedRole,
  });

  final String selectedSchool;
  final String selectedRole;

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (selectedSchool != 'All') selectedSchool,
      if (selectedRole != 'All') selectedRole,
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: labels.map((label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFFC),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF34368C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Bottom sheet that lets users select school and role together.
void _showMemberFilterSheet(
  BuildContext context, {
  required String selectedSchool,
  required String selectedRole,
  required List<String> schools,
  required List<String> roles,
  required void Function(String school, String role) onApply,
}) {
  var sheetSchool = selectedSchool;
  var sheetRole = selectedRole;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Refine results',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            sheetSchool = 'All';
                            sheetRole = 'All';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MemberSheetFilterGroup(
                    label: 'School',
                    values: schools,
                    selectedValue: sheetSchool,
                    onSelected: (value) {
                      setSheetState(() => sheetSchool = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  _MemberSheetFilterGroup(
                    label: 'Role',
                    values: roles,
                    selectedValue: sheetRole,
                    onSelected: (value) {
                      setSheetState(() => sheetRole = value);
                    },
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        onApply(sheetSchool, sheetRole);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF34368C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Chip group inside the advanced filter sheet.
class _MemberSheetFilterGroup extends StatelessWidget {
  const _MemberSheetFilterGroup({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF777777),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            final isSelected = selectedValue == value;
            return ChoiceChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              selectedColor: const Color(0xFF34368C),
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : const Color(0xFF34368C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              side: const BorderSide(color: Color(0xFFE2E2FA)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Small section label above the member rows.
class _MemberListLabel extends StatelessWidget {
  const _MemberListLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _SchoolMemberSection extends StatelessWidget {
  const _SchoolMemberSection({required this.school, required this.members});

  final String school;
  final List<_Member> members;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDADCF8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  color: Color(0xFF34368C),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    school,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF23245F),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${members.length}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...members.map((member) => _MemberCard(member: member)),
        ],
      ),
    );
  }
}

// Empty state for filters that return no members.
class _EmptyMemberState extends StatelessWidget {
  const _EmptyMemberState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'No members found',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: const Color(0xFF777777),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
