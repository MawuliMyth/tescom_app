part of '../dashboard_screen.dart';

// Shared menu-page scaffolds, cards, and small reusable widgets.
// Individual screens now live in their own files beside this one.

class _DemoPageShell extends StatelessWidget {
  const _DemoPageShell({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
          title,
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
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SearchablePageShell extends StatelessWidget {
  const _SearchablePageShell({
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.onChanged,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String hintText;
  final ValueChanged<String> onChanged;
  final List<Widget> children;

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
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
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
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 12,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _DemoSearchField(hintText: hintText, onChanged: onChanged),
            const SizedBox(height: 16),
            if (children.isEmpty)
              const _InfoCard(
                item: _InfoItem(
                  title: 'No results found',
                  subtitle: 'Try another keyword',
                  body: 'Try another keyword to search the available records.',
                  icon: Icons.search_off_rounded,
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _DemoSearchField extends StatelessWidget {
  const _DemoSearchField({required this.hintText, required this.onChanged});

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

class _InfoItem {
  const _InfoItem({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String body;
  final IconData icon;

  bool matches(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        subtitle.toLowerCase().contains(lower) ||
        body.toLowerCase().contains(lower);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      opacity: 0.68,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: const Color(0xFF34368C), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7A7A7A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 11,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionInfoCard extends StatefulWidget {
  const _ActionInfoCard({
    required this.item,
    required this.actionLabel,
    this.onTap,
  });

  final _InfoItem item;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  State<_ActionInfoCard> createState() => _ActionInfoCardState();
}

class _ActionInfoCardState extends State<_ActionInfoCard> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(item: widget.item),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: completed
                ? null
                : widget.onTap ?? () => setState(() => completed = true),
            style: FilledButton.styleFrom(
              backgroundColor: completed
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFF34368C),
              foregroundColor: Colors.white,
            ),
            child: Text(completed ? 'Confirmed' : widget.actionLabel),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF34368C),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
