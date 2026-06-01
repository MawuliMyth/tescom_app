part of '../dashboard_screen.dart';

// Contact route with support and chapter update actions.
// This file is intentionally separated so each screen has a clear home.

class _ContactPage extends StatelessWidget {
  const _ContactPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Contact / Support',
      subtitle: 'Support routes for members and chapter executives.',
      children: [
        _ActionInfoCard(
          item: const _InfoItem(
            title: 'Support Desk',
            subtitle: 'support@tescon.app',
            body:
                'Members can contact support for account, chapter, and event questions.',
            icon: Icons.support_agent_rounded,
          ),
          actionLabel: 'Send Message',
          onTap: () => Navigator.push(
            context,
            _adaptivePageRoute(
              context,
              builder: (_) => const _ContactFormPage(title: 'Support Desk'),
            ),
          ),
        ),
        _ActionInfoCard(
          item: const _InfoItem(
            title: 'Chapter Help',
            subtitle: 'For campus executives',
            body:
                'Chapter leaders can request updates to events, executives, and institution records.',
            icon: Icons.groups_2_outlined,
          ),
          actionLabel: 'Request Help',
          onTap: () => Navigator.push(
            context,
            _adaptivePageRoute(
              context,
              builder: (_) => const _ContactFormPage(title: 'Chapter Help'),
            ),
          ),
        ),
      ],
    );
  }
}
