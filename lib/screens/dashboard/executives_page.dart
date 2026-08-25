part of '../dashboard_screen.dart';

// Executives route with centered header, search, and leadership filters.
class _ExecutivesPage extends StatefulWidget {
  const _ExecutivesPage();

  @override
  State<_ExecutivesPage> createState() => _ExecutivesPageState();
}

class _ExecutivesPageState extends State<_ExecutivesPage> {
  late final Future<_DirectoryPeopleData> _executivesFuture;

  // Search text entered by the user.
  String query = '';

  // Active filter values for school and executive role.
  String selectedSchool = 'All';
  String selectedRole = 'All';
  bool _schoolInitialized = false;

  @override
  void initState() {
    super.initState();
    _executivesFuture = _loadPeople(AppRepository().loadExecutives());
  }

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
          'Executives',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.black,
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
              FutureBuilder<_DirectoryPeopleData>(
                future: _executivesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 34),
                      child: _ListShimmer(itemCount: 4),
                    );
                  }
                  if (snapshot.hasError) return const _InlineErrorState();

                  final executives = (snapshot.data?.users ?? const [])
                      .map(_Member.fromUser)
                      .toList();
                  final preferredSchool =
                      snapshot.data?.currentUser?.institution;
                  final schools = _schoolFilterValues(
                    executives,
                    preferredSchool: preferredSchool,
                  );
                  final activeSchool = _activeSchoolFor(
                    selectedSchool: selectedSchool,
                    preferredSchool: preferredSchool,
                    initialized: _schoolInitialized,
                  );
                  final filteredExecutives = _filterExecutives(
                    executives,
                    school: activeSchool,
                  );
                  final roles = [
                    'All',
                    ...{for (final member in executives) member.role},
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Leadership Team',
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
                        'Meet the leaders driving the organization forward.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF777777),
                          fontSize: 13,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
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
                      if (filteredExecutives.isEmpty)
                        const _EmptyMemberState()
                      else if (activeSchool == 'All')
                        ..._groupMembersBySchool(
                          filteredExecutives,
                        ).entries.map(
                          (entry) => _SchoolMemberSection(
                            school: entry.key,
                            members: entry.value,
                          ),
                        )
                      else
                        ...filteredExecutives.map(
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

  // Applies search, school, and role filters to the executive list.
  List<_Member> _filterExecutives(
    List<_Member> executives, {
    required String school,
  }) {
    return executives.where((member) {
      final schoolMatch = school == 'All' || member.institution == school;
      final roleMatch = selectedRole == 'All' || member.role == selectedRole;
      final queryMatch = query.trim().isEmpty || member.matches(query);
      return schoolMatch && roleMatch && queryMatch;
    }).toList();
  }
}
