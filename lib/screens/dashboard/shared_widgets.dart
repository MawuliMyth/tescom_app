part of '../dashboard_screen.dart';

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _AppSurface(
        width: 36,
        height: 36,
        borderRadius: 18,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }
}

class _AppSurface extends StatelessWidget {
  const _AppSurface({
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.opacity = 1,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Color.lerp(
      colorScheme.surfaceContainerLow,
      colorScheme.surface,
      opacity.clamp(0, 1).toDouble(),
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF2F2F3A) : const Color(0xFFEDEDF2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AppScaffoldBackground extends StatelessWidget {
  const _AppScaffoldBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: child,
    );
  }
}

void _showSearchSheet(BuildContext context) {
  Navigator.push(
    context,
    _adaptivePageRoute(context, builder: (_) => const _GlobalSearchPage()),
  );
}

// modal for notifcation
// void _showDemoSheet(
//   BuildContext context, {
//   required String title,
//   required String message,
// }) {
//   showModalBottomSheet<void>(
//     context: context,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               message,
//               style: GoogleFonts.inter(
//                 color: const Color(0xFF666666),
//                 fontSize: 13,
//                 height: 1.35,
//                 letterSpacing: 0,
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
void _showDemoSheet(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.height,
    this.width,
    this.borderRadius = 16,
    this.margin = EdgeInsets.zero,
  });

  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF4),
      highlightColor: const Color(0xFFF8FAFF),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer({this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const _ShimmerBlock(
          height: 92,
          borderRadius: 18,
          margin: EdgeInsets.only(bottom: 12),
        ),
      ),
    );
  }
}

class _InlineErrorState extends StatelessWidget {
  const _InlineErrorState();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      item: _InfoItem(
        title: 'Something went wrong',
        subtitle: 'Connection error',
        body: 'We could not load this data. Please try again.',
        icon: Icons.error_outline_rounded,
      ),
    );
  }
}

class _GlobalSearchPage extends StatefulWidget {
  const _GlobalSearchPage();

  @override
  State<_GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<_GlobalSearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          'Search',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: _AppScaffoldBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _AppSurface(
                borderRadius: 18,
                opacity: 0.72,
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search news, history, members, jobs',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Object>>(
                future: Future.wait([
                  AppRepository().loadBootstrap(),
                  AppRepository().loadMembers(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ListShimmer(itemCount: 4);
                  }
                  if (snapshot.hasError) return const _InlineErrorState();

                  final bootstrap = snapshot.data?[0] as AppBootstrap?;
                  final members =
                      snapshot.data?[1] as List<AppUser>? ?? const [];
                  final results = [
                    for (final item in bootstrap?.news ?? const [])
                      _SearchResult(
                        title: item.title,
                        label: 'News',
                        icon: Icons.article_outlined,
                      ),
                    for (final item in bootstrap?.events ?? const [])
                      _SearchResult(
                        title: item.title,
                        label: 'Event',
                        icon: Icons.event_outlined,
                      ),
                    for (final item in bootstrap?.jobs ?? const [])
                      _SearchResult(
                        title: item.title,
                        label: 'Job opportunity',
                        icon: Icons.work_outline_rounded,
                      ),
                    for (final item in members)
                      _SearchResult(
                        title: item.fullName,
                        label: item.organizationRole ?? 'Member biography',
                        icon: Icons.badge_outlined,
                      ),
                  ];
                  final filtered = query.trim().isEmpty
                      ? results
                      : results
                            .where((result) => result.matches(query))
                            .toList();

                  if (filtered.isEmpty) {
                    return const _InfoCard(
                      item: _InfoItem(
                        title: 'No results found',
                        subtitle: 'Live search',
                        body:
                            'Published news, events, jobs, and members will appear here.',
                        icon: Icons.search_off_rounded,
                      ),
                    );
                  }

                  return Column(
                    children: filtered
                        .map((result) => _SearchResultTile(result: result))
                        .toList(),
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

class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.label,
    required this.icon,
  });

  final String title;
  final String label;
  final IconData icon;

  bool matches(String value) {
    final lower = value.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        label.toLowerCase().contains(lower);
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});

  final _SearchResult result;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 18,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEFEFFC),
          child: Icon(result.icon, color: const Color(0xFF34368C), size: 20),
        ),
        title: Text(
          result.title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        subtitle: Text(result.label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _showDemoSheet(
          context,
          title: result.title,
          message: 'Opened ${result.label.toLowerCase()} result.',
        ),
      ),
    );
  }
}
