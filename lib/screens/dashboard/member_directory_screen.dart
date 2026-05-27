part of '../dashboard_screen.dart';

// Membership Directory screen with centered title, search, and filters.
class _MemberDirectoryPage extends StatefulWidget {
  const _MemberDirectoryPage();

  @override
  State<_MemberDirectoryPage> createState() => _MemberDirectoryPageState();
}

class _MemberDirectoryPageState extends State<_MemberDirectoryPage> {
  // Search text entered by the user.
  String query = '';

  // Active filter values. "All" means the filter is not restricting results.
  String selectedSchool = 'All';
  String selectedRole = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _filterMembers(_members);

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
              _MemberDirectoryIntro(count: filteredMembers.length),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MemberSearchField(
                      hintText: 'Search by name',
                      onChanged: (value) => setState(() => query = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SmartMemberFilterButton(
                    selectedSchool: selectedSchool,
                    selectedRole: selectedRole,
                    schools: _schools,
                    roles: _roles,
                    onApply: (school, role) {
                      setState(() {
                        selectedSchool = school;
                        selectedRole = role;
                      });
                    },
                  ),
                ],
              ),
              if (selectedSchool != 'All' || selectedRole != 'All') ...[
                const SizedBox(height: 10),
                _ActiveFilterSummary(
                  selectedSchool: selectedSchool,
                  selectedRole: selectedRole,
                ),
              ],
              const SizedBox(height: 18),
              const _MemberListLabel(label: 'Members'),
              const SizedBox(height: 10),
              if (filteredMembers.isEmpty)
                const _EmptyMemberState()
              else
                ...filteredMembers.map(
                  (member) => _MemberCard(member: member),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Applies search, school, and role filters to the member list.
  List<_Member> _filterMembers(List<_Member> members) {
    return members.where((member) {
      final schoolMatch =
          selectedSchool == 'All' || member.institution == selectedSchool;
      final roleMatch = selectedRole == 'All' || member.role == selectedRole;
      final queryMatch = query.trim().isEmpty || member.matches(query);
      return schoolMatch && roleMatch && queryMatch;
    }).toList();
  }
}

// Static demo data for the directory until live member data is connected.
const _members = [
  _Member(
    name: 'Chris Lloyd Nii Kwesi',
    role: 'Youth Organizer',
    institution: 'National TESCON',
    imagePath: 'assets/images/suit.png',
    joinDate: 'Joined 2024',
    memberCount: 'Member',
    contribution: 'Campus Mobilization',
    bio:
        'Youth organizer focused on student mobilization, communication, and campus chapter development.',
  ),
  _Member(
    name: 'Ama Serwaa Mensah',
    role: 'Chapter President',
    institution: 'University of Ghana',
    imagePath: 'assets/images/white.png',
    joinDate: 'Joined 2024',
    memberCount: 'Executive',
    contribution: 'Chapter Leadership',
    bio:
        'Leads chapter programs, membership drives, and campus policy conversations for student members.',
  ),
  _Member(
    name: 'Kojo Ali',
    role: 'Communications Lead',
    institution: 'Central University',
    imagePath: 'assets/images/man.png',
    joinDate: 'Joined 2025',
    memberCount: 'Member',
    contribution: 'Media & Publicity',
    bio:
        'Coordinates chapter announcements, event media, and digital storytelling for the member directory.',
  ),
  _Member(
    name: 'Joseph Mensah',
    role: 'TESCON Member',
    institution: 'Central University',
    imagePath: 'assets/images/yellow.png',
    joinDate: 'Joined 2025',
    memberCount: 'Member',
    contribution: 'Volunteer Support',
    bio:
        'Supports campus outreach, volunteer coordination, and member engagement activities.',
  ),
];

// Filter options are derived from the same demo dataset used by the list.
final _schools = ['All', ...{for (final member in _members) member.institution}];
final _roles = ['All', ...{for (final member in _members) member.role}];

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
  const _MemberSearchField({
    required this.hintText,
    required this.onChanged,
  });

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
