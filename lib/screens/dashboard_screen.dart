import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tescon_app/core/api_config.dart';
import 'package:tescon_app/core/app_models.dart';
import 'package:tescon_app/core/app_repository.dart';
import 'package:tescon_app/core/auth_service.dart';

part 'dashboard/home_tab.dart';
part 'dashboard/drawer.dart';
part 'dashboard/shared_widgets.dart';
part 'dashboard/menu_pages.dart';
part 'dashboard/about_page.dart';
part 'dashboard/announcements_page.dart';
part 'dashboard/chapters_page.dart';
part 'dashboard/contact_form_page.dart';
part 'dashboard/contact_page.dart';
part 'dashboard/events_page.dart';
part 'dashboard/executives_page.dart';
part 'dashboard/history_page.dart';
part 'dashboard/jobs_page.dart';
part 'dashboard/latest_news_page.dart';
part 'dashboard/live_chat_page.dart';
part 'dashboard/member_directory_screen.dart';
part 'dashboard/member_detail_sheet.dart';
part 'dashboard/member_widgets.dart';
part 'dashboard/notifications_page.dart';
part 'dashboard/polls_page.dart';
part 'dashboard/settings_page.dart';
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
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PersistentTabView(
      context,
      controller: _controller,
      screens: [
        _DashboardHome(
          onDrawerChanged: (isOpen) {
            if (_isDrawerOpen == isOpen) return;
            setState(() => _isDrawerOpen = isOpen);
          },
        ),
        const _DiscoverScreen(),
        const _SavedScreen(),
        const _SettingsPage(showBackButton: false),
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
          title: 'Settings',
          icon: Icons.settings_rounded,
          inactiveIcon: Icons.settings_outlined,
        ),
      ],
      isVisible: !_isDrawerOpen,
      backgroundColor: colorScheme.surface,
      navBarHeight: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: NavBarDecoration(
        colorBehindNavBar: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      navBarStyle: NavBarStyle.style7,
    );
  }

  PersistentBottomNavBarItem _navItem({
    required String title,
    required IconData icon,
    required IconData inactiveIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PersistentBottomNavBarItem(
      title: title,
      icon: Icon(icon),
      inactiveIcon: Icon(inactiveIcon),
      iconSize: 20,
      activeColorPrimary: const Color(0xFF34368C),
      activeColorSecondary: colorScheme.onPrimary,
      inactiveColorPrimary: colorScheme.onSurfaceVariant,
      textStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

Route<T> _adaptivePageRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoPageRoute<T>(builder: builder);
  }

  return MaterialPageRoute<T>(builder: builder);
}
