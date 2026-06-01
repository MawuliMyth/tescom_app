part of '../dashboard_screen.dart';

// Executives route with centered header, search, and leadership filters.
class _ExecutivesPage extends StatefulWidget {
  const _ExecutivesPage();

  @override
  State<_ExecutivesPage> createState() => _ExecutivesPageState();
}

class _ExecutivesPageState extends State<_ExecutivesPage> {
  // Search text entered by the user.
  String query = '';

  // Active filter values for school and executive role.
  String selectedSchool = 'All';
  String selectedRole = 'All';

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
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          children: [
            FutureBuilder<List<AppUser>>(
              future: AppRepository().loadExecutives(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 34),
                    child: _ListShimmer(itemCount: 4),
                  );
                }
                if (snapshot.hasError) return const _InlineErrorState();

                final executives = (snapshot.data ?? const [])
                    .map(_Member.fromUser)
                    .toList();
                final filteredExecutives = _filterExecutives(executives);
                final schools = [
                  'All',
                  ...{for (final member in executives) member.institution},
                ];
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
                            onChanged: (value) => setState(() => query = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _SmartMemberFilterButton(
                          selectedSchool: selectedSchool,
                          selectedRole: selectedRole,
                          schools: schools,
                          roles: roles,
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
                    if (filteredExecutives.isEmpty)
                      const _EmptyMemberState()
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
    );
  }

  // Applies search, school, and role filters to the executive list.
  List<_Member> _filterExecutives(List<_Member> executives) {
    return executives.where((member) {
      final schoolMatch =
          selectedSchool == 'All' || member.institution == selectedSchool;
      final roleMatch = selectedRole == 'All' || member.role == selectedRole;
      final queryMatch = query.trim().isEmpty || member.matches(query);
      return schoolMatch && roleMatch && queryMatch;
    }).toList();
  }
}
