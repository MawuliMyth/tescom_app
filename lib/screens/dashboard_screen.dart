import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

part 'dashboard/home_tab.dart';
part 'dashboard/drawer.dart';
part 'dashboard/shared_widgets.dart';
part 'dashboard/menu_pages.dart';
part 'dashboard/news_widgets.dart';
part 'dashboard/discover_tab.dart';
part 'dashboard/news_detail_screen.dart';
part 'dashboard/saved_profile_tabs.dart';

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
