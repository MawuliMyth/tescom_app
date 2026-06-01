part of '../dashboard_screen.dart';

// TESCON history route with searchable timeline cards.
// This file is intentionally separated so each screen has a clear home.

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
