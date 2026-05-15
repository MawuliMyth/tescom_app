import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = 'dashboard_screen';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PersistentTabController _controller = PersistentTabController();

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: const [
        _DashboardHome(),
        _DiscoverScreen(),
        _SavedScreen(),
        _ProfileScreen(),
      ],
      items: [
        _navItem(
          title: 'Home',
          icon: Icons.home_rounded,
          inactiveIcon: Icons.home_rounded,
        ),
        _navItem(
          title: 'Discover',
          icon: Icons.explore_rounded,
          inactiveIcon: Icons.explore_outlined,
        ),
        _navItem(
          title: 'Saved',
          icon: Icons.bookmark_rounded,
          inactiveIcon: Icons.bookmark_border_rounded,
        ),
        _navItem(
          title: 'Profile',
          icon: Icons.person_rounded,
          inactiveIcon: Icons.person_outline_rounded,
        ),
      ],
      backgroundColor: Colors.white,
      navBarHeight: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const NavBarDecoration(
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style7,
    );
  }

  PersistentBottomNavBarItem _navItem({
    required String title,
    required IconData icon,
    required IconData inactiveIcon,
  }) {
    return PersistentBottomNavBarItem(
      title: title,
      icon: Icon(icon),
      inactiveIcon: Icon(inactiveIcon),
      iconSize: 20,
      activeColorPrimary: const Color(0xFF34368C),
      activeColorSecondary: Colors.white,
      inactiveColorPrimary: const Color(0xFFB6B6B6),
      textStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const _DemoDrawer(),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
          children: [
            const _DashboardTopBar(),
            const SizedBox(height: 32),
            _SectionHeader(
              title: 'Tescon News',
              actionText: 'View all',
              onTap: () => _showDemoSheet(
                context,
                title: 'Tescon News',
                message: 'Opening the full Tescon News feed for demo.',
              ),
            ),
            const SizedBox(height: 12),
            const _NewsCarousel(),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Recommendation',
              actionText: 'View All',
              onTap: () => _showDemoSheet(
                context,
                title: 'Recommendations',
                message: 'Showing all recommended posts for demo.',
              ),
            ),
            const SizedBox(height: 10),
            const _RecommendationList(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const Spacer(),
        _CircleIconButton(
          icon: Icons.search_rounded,
          onTap: () => _showSearchSheet(context),
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _showDemoSheet(
            context,
            title: 'Notifications',
            message: 'You have 3 demo notifications from Tescon News.',
          ),
        ),
      ],
    );
  }
}

class _DemoDrawer extends StatelessWidget {
  const _DemoDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TESCON',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerTile(
              icon: Icons.article_outlined,
              title: 'Latest News',
              onTap: () => _closeDrawerAndShow(
                context,
                title: 'Latest News',
                message: 'Latest news feed is ready for this demo.',
              ),
            ),
            _DrawerTile(
              icon: Icons.event_outlined,
              title: 'Events',
              onTap: () => _closeDrawerAndShow(
                context,
                title: 'Events',
                message: 'Upcoming Tescon events will appear here.',
              ),
            ),
            _DrawerTile(
              icon: Icons.school_outlined,
              title: 'Institutions',
              onTap: () => _closeDrawerAndShow(
                context,
                title: 'Institutions',
                message: 'Institution chapters are available in the demo.',
              ),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => _closeDrawerAndShow(
                context,
                title: 'Settings',
                message: 'Settings panel opened successfully.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF34368C)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF7F7F7),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF121212),
          size: 20,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              actionText,
              style: GoogleFonts.inter(
                color: const Color(0xFF005BC5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCarousel extends StatelessWidget {
  const _NewsCarousel();

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: const [
        _CarouselImage(
          path: 'assets/images/coursel_image.png',
          authorImagePath: 'assets/images/suit.png',
          source: 'Tescon',
          title: 'Tescon Central University hosts leadership forum',
          author: 'Chris Lloyd',
          date: '6 Hours Ago',
        ),
        _CarouselImage(
          path: 'assets/images/yellow.png',
          authorImagePath: 'assets/images/man.png',
          source: 'Tescon',
          title: 'Central University Tescon Honors Samira Bawumiah',
          author: 'Joseph Mensah',
          date: 'Feb 23, 2025.',
        ),
        _CarouselImage(
          path: 'assets/images/pres.png',
          authorImagePath: 'assets/images/white.png',
          source: 'Tescon',
          title: 'NPP youth organizers rally students for outreach',
          author: 'Kojo Folson',
          date: 'Feb 23, 2025.',
        ),
      ],
      options: CarouselOptions(
        height: 140,
        viewportFraction: 0.92,
        enlargeCenterPage: true,
        enlargeFactor: 0.16,
        enableInfiniteScroll: true,
        autoPlay: false,
        padEnds: false,
      ),
    );
  }
}

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({
    required this.path,
    required this.authorImagePath,
    required this.source,
    required this.title,
    required this.author,
    required this.date,
  });

  final String path;
  final String authorImagePath;
  final String source;
  final String title;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openNewsDetail(
        context,
        imagePath: path,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          path,
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _RecommendationList extends StatelessWidget {
  const _RecommendationList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RecommendationTile(
          imagePath: 'assets/images/man.png',
          authorImagePath: 'assets/images/pres.png',
          source: 'From NPP Youth Organizer',
          title: 'Bawumiah is the man for the Job',
          author: 'Chris Lloyd',
          date: 'Feb 23, 2025.',
        ),
        SizedBox(height: 14),
        _RecommendationTile(
          imagePath: 'assets/images/pres.png',
          authorImagePath: 'assets/images/suit.png',
          source: 'From Tescon Central University',
          title: 'Central University Tescon Honors Samira Bawumiah ...',
          author: 'Issac Aheto',
          date: 'Feb 23, 2025.',
        ),
        SizedBox(height: 14),
        _RecommendationTile(
          imagePath: 'assets/images/yellow.png',
          authorImagePath: 'assets/images/man.png',
          source: 'From Tescon Central University',
          title: 'Central University Tescon Honors Samira Bawumiah ...',
          author: 'Joseph Mensah',
          date: 'Feb 23, 2025.',
        ),
        SizedBox(height: 14),
        _RecommendationTile(
          imagePath: 'assets/images/suit.png',
          authorImagePath: 'assets/images/white.png',
          source: 'From Tescon Central University',
          title: 'Central University Tescon Honors Samira Bawumiah ...',
          author: 'Kojo Folson',
          date: 'Feb 23, 2025.',
        ),
      ],
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
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
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              imagePath,
              width: 116,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7B7B7B),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.08,
                      fontWeight: FontWeight.w500,
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
                            fontSize: 9,
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
                          fontSize: 9,
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

class _DiscoverScreen extends StatelessWidget {
  const _DiscoverScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(9, 36, 9, 22),
          children: const [
            _DiscoverTitle(),
            SizedBox(height: 16),
            _DiscoverSearchBar(),
            SizedBox(height: 14),
            _DiscoverFilters(),
            SizedBox(height: 14),
            _DiscoverNewsList(),
          ],
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
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(22),
        ),
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
  const _DiscoverFilters();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'All', selected: true),
          SizedBox(width: 8),
          _FilterChip(label: 'Head Office'),
          SizedBox(width: 8),
          _FilterChip(label: 'UCC'),
          SizedBox(width: 8),
          _FilterChip(label: 'KNUST'),
          SizedBox(width: 8),
          _FilterChip(label: 'CU'),
          SizedBox(width: 8),
          _FilterChip(label: 'VVU'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSnack(context, '$label filter selected'),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF34368C) : const Color(0xFFF4F4F6),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : const Color(0xFF8E8E8E),
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
  const _DiscoverNewsList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DiscoverNewsTile(
          imagePath: 'assets/images/card.png',
          authorImagePath: 'assets/images/suit.png',
          source: 'From Npp Head Office',
          title: 'National Delegates Conference 2025 is happening Tomorrow',
          author: 'Chris Lloyd',
          date: 'Jul 19, 2025.',
        ),
        SizedBox(height: 15),
        _DiscoverNewsTile(
          imagePath: 'assets/images/give.png',
          authorImagePath: 'assets/images/white.png',
          source: 'From Tescon UCC',
          title: 'Ken Ohene Agyapong Speaks on Entrepreneurship',
          author: 'Baron',
          date: 'April 23, 2025.',
        ),
        SizedBox(height: 15),
        _DiscoverNewsTile(
          imagePath: 'assets/images/ladies.png',
          authorImagePath: 'assets/images/man.png',
          source: 'From Tescon Central University',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'James Kofi',
          date: 'July 10, 2025.',
        ),
        SizedBox(height: 15),
        _DiscoverNewsTile(
          imagePath: 'assets/images/suit.png',
          authorImagePath: 'assets/images/man.png',
          source: 'From Tescon Central University',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'kojo Ali',
          date: 'July 10, 2025.',
        ),
        SizedBox(height: 15),
        _DiscoverNewsTile(
          imagePath: 'assets/images/coursel_image.png',
          authorImagePath: 'assets/images/wayo.png',
          source: 'From Tescon VVU',
          title: 'Samira Bawumiah Calls for NPP loyal Ladies',
          author: 'Prince Yeboah',
          date: 'July 10, 2025.',
        ),
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

void _openNewsDetail(
  BuildContext context, {
  required String imagePath,
  required String authorImagePath,
  required String source,
  required String title,
  required String author,
  required String date,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _NewsDetailScreen(
        imagePath: imagePath,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
      ),
    ),
  );
}

class _NewsDetailScreen extends StatefulWidget {
  const _NewsDetailScreen({
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
  State<_NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<_NewsDetailScreen> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 410,
            backgroundColor: Colors.black,
            leading: _DetailCircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _DetailCircleButton(
                icon: isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                onTap: () {
                  setState(() => isSaved = !isSaved);
                  _showSnack(
                    context,
                    isSaved ? 'Saved for later' : 'Removed from saved',
                  );
                },
              ),
              const SizedBox(width: 8),
              _DetailCircleButton(
                icon: Icons.more_horiz_rounded,
                onTap: () => _showDemoSheet(
                  context,
                  title: 'More Actions',
                  message: 'Share, report, and copy link actions are ready.',
                ),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x00000000),
                          Color(0xD9000000),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34368C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.source,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.05,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Trending',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.circle,
                              size: 4,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.date,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: AssetImage(widget.authorImagePath),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.author,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _detailBody(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF555555),
                      fontSize: 11,
                      height: 1.32,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
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

class _DetailCircleButton extends StatelessWidget {
  const _DetailCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

String _detailBody() {
  return 'Dr. Mahamudu Bawumia is the RIGHT MAN for the job. I am saying this '
      'not just as your Deputy National Youth Organizer but as a young Ghanaian '
      'who believes in real leadership and real results. Bawumia is not about '
      'empty promises. He is about vision, innovation, and action.\n\n'
      'From the Ghana Card, digital address system, mobile money interoperability '
      'and paperless services, he has proven that he is ready to lead with ideas '
      'that solve real problems for everyday Ghanaians.\n\n'
      'TESCON, this is our time. Let us rise and rally behind Dr. Bawumia. Let us '
      'defend the progress we have made and push forward with a leader who truly '
      'understands and believes in the youth. I believe in him and I want you to '
      'believe too.\n\n'
      'Let us organize. Let us mobilize. Let us spread the message on every campus.';
}

void _showSearchSheet(BuildContext context) {
  final rootContext = context;
  showModalBottomSheet<void>(
    context: rootContext,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search News',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search Tescon news',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                Navigator.pop(sheetContext);
                _showSnack(rootContext, 'Searching for "$value"');
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showDemoSheet(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 13,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _closeDrawerAndShow(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final rootContext = Navigator.of(context).context;
  Navigator.pop(context);
  Future<void>.delayed(const Duration(milliseconds: 180), () {
    if (rootContext.mounted) {
      _showDemoSheet(rootContext, title: title, message: message);
    }
  });
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class _SavedScreen extends StatelessWidget {
  const _SavedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 36, 18, 22),
          children: const [
            _SimplePageTitle(
              title: 'Saved News',
              subtitle: 'Stories bookmarked for later',
            ),
            SizedBox(height: 18),
            _RecommendationTile(
              imagePath: 'assets/images/man.png',
              authorImagePath: 'assets/images/pres.png',
              source: 'Saved from NPP Youth Organizer',
              title: 'Bawumiah is the man for the Job',
              author: 'Chris Lloyd',
              date: '6 Hours Ago',
            ),
            SizedBox(height: 14),
            _RecommendationTile(
              imagePath: 'assets/images/card.png',
              authorImagePath: 'assets/images/suit.png',
              source: 'Saved from Npp Head Office',
              title: 'National Delegates Conference 2025 is happening Tomorrow',
              author: 'Chris Lloyd',
              date: 'Jul 19, 2025.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 36, 18, 22),
          children: [
            const _SimplePageTitle(
              title: 'Profile',
              subtitle: 'Demo member account',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage('assets/images/suit.png'),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tescon Member',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Central University Chapter',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF777777),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            _DrawerTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => _showDemoSheet(
                context,
                title: 'Edit Profile',
                message: 'Profile editing is available for the demo.',
              ),
            ),
            _DrawerTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notification Settings',
              onTap: () => _showDemoSheet(
                context,
                title: 'Notification Settings',
                message: 'Notification preferences opened successfully.',
              ),
            ),
            _DrawerTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              onTap: () => _showDemoSheet(
                context,
                title: 'Help Center',
                message: 'Help center content is ready for the presentation.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimplePageTitle extends StatelessWidget {
  const _SimplePageTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: const Color(0xFF8A8A8A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
