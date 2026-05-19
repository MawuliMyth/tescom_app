part of '../dashboard_screen.dart';

class _DiscoverScreen extends StatefulWidget {
  const _DiscoverScreen();

  @override
  State<_DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<_DiscoverScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _LiquidScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(9, 36, 9, 22),
            children: [
              const _DiscoverTitle(),
              const SizedBox(height: 16),
              const _DiscoverSearchBar(),
              const SizedBox(height: 14),
              _DiscoverFilters(
                selectedFilter: selectedFilter,
                onSelected: (value) => setState(() => selectedFilter = value),
              ),
              const SizedBox(height: 14),
              _DiscoverNewsList(filter: selectedFilter),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverTitle extends StatelessWidget {
  const _DiscoverTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Trending News',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'News from all around NPP',
          style: GoogleFonts.inter(
            color: const Color(0xFF9B9B9B),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _DiscoverSearchBar extends StatelessWidget {
  const _DiscoverSearchBar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSearchSheet(context),
      borderRadius: BorderRadius.circular(22),
      child: _LiquidGlass(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        borderRadius: 22,
        opacity: 0.72,
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF9A9A9A),
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9A9A9A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
            const Icon(
              Icons.tune_rounded,
              color: Color(0xFF9A9A9A),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverFilters extends StatelessWidget {
  const _DiscoverFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Head Office', 'UCC', 'KNUST', 'CU', 'VVU'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: filter,
              selected: selectedFilter == filter,
              onTap: () => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _showSnack(context, '$label filter selected'),
      borderRadius: BorderRadius.circular(17),
      child: _LiquidGlass(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        borderRadius: 17,
        opacity: selected ? 0.9 : 0.58,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? const Color(0xFF34368C) : const Color(0xFF8E8E8E),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _DiscoverNewsList extends StatelessWidget {
  const _DiscoverNewsList({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    const items = [
      _DiscoverNewsTile(
          imagePath: 'assets/images/card.png',
          authorImagePath: 'assets/images/suit.png',
          source: 'From Npp Head Office',
          title: 'National Delegates Conference 2025 is happening Tomorrow',
          author: 'Chris Lloyd',
          date: 'Jul 19, 2025.',
        ),
      _DiscoverNewsTile(
          imagePath: 'assets/images/give.png',
          authorImagePath: 'assets/images/white.png',
          source: 'From Tescon UCC',
          title: 'Ken Ohene Agyapong Speaks on Entrepreneurship',
          author: 'Baron',
          date: 'April 23, 2025.',
        ),
      _DiscoverNewsTile(
          imagePath: 'assets/images/ladies.png',
          authorImagePath: 'assets/images/man.png',
          source: 'From Tescon Central University',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'James Kofi',
          date: 'July 10, 2025.',
        ),
      _DiscoverNewsTile(
          imagePath: 'assets/images/suit.png',
          authorImagePath: 'assets/images/man.png',
          source: 'From Tescon Central University',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'kojo Ali',
          date: 'July 10, 2025.',
        ),
      _DiscoverNewsTile(
          imagePath: 'assets/images/coursel_image.png',
          authorImagePath: 'assets/images/wayo.png',
          source: 'From Tescon VVU',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'Prince Yeboah',
          date: 'July 10, 2025.',
        ),
    ];

    final visible = filter == 'All'
        ? items
        : items.where((item) => item.source.toLowerCase().contains(filter.toLowerCase())).toList();

    if (visible.isEmpty) {
      return const _InfoCard(
        item: _InfoItem(
          title: 'No stories in this filter',
          subtitle: 'Try another category',
          body: 'Filtered stories will appear here when available.',
          icon: Icons.filter_alt_off_rounded,
        ),
      );
    }

    return Column(
      children: [
        for (final item in visible) ...[
          item,
          if (item != visible.last) const SizedBox(height: 15),
        ],
      ],
    );
  }
}

class _DiscoverNewsTile extends StatelessWidget {
  const _DiscoverNewsTile({
    required this.imagePath,
    required this.authorImagePath,
    required this.source,
    required this.title,
    required this.author,
    required this.date,
  });

  final String imagePath;
  final String authorImagePath;
  final String source;
  final String title;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openNewsDetail(
        context,
        imagePath: imagePath,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              imagePath,
              width: 118,
              height: 86,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 86,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7B7B7B),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundImage: AssetImage(authorImagePath),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF969696),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF969696),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
