part of '../dashboard_screen.dart';

// Opens member details as a rounded modal bottom sheet.
void _showMemberDetailSheet(BuildContext context, _Member member) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MemberDetailSheet(member: member),
  );
}

// Bottom sheet content shown after tapping a member row.
class _MemberDetailSheet extends StatelessWidget {
  const _MemberDetailSheet({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.64,
      minChildSize: 0.48,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _CloseSheetButton(onTap: () => Navigator.pop(context)),
              ),
              const SizedBox(height: 26),
              _MemberProfileHeader(member: member),
              const SizedBox(height: 24),
              _MemberBioCard(member: member),
              const SizedBox(height: 24),
              _MemberDetailRows(member: member),
            ],
          ),
        );
      },
    );
  }
}

// Circular close button in the top-right corner of the detail sheet.
class _CloseSheetButton extends StatelessWidget {
  const _CloseSheetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBFC0C7)),
        ),
        child: const Icon(Icons.close_rounded, size: 22),
      ),
    );
  }
}

// Main identity block with avatar, name, role, and quick stats.
class _MemberProfileHeader extends StatelessWidget {
  const _MemberProfileHeader({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _memberImageProvider(member.imagePath),
        ),
        const SizedBox(height: 18),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF242424),
            fontSize: 27,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          member.role,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF777777),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            _MemberStat(
              icon: Icons.calendar_today_outlined,
              text: member.joinDate,
            ),
            _MemberStat(
              icon: Icons.groups_2_outlined,
              text: member.memberCount,
            ),
            _MemberStat(icon: Icons.flag_outlined, text: member.contribution),
          ],
        ),
      ],
    );
  }
}

// Highlight card for the member biography.
class _MemberBioCard extends StatelessWidget {
  const _MemberBioCard({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2FA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              member.bio,
              style: GoogleFonts.inter(
                color: const Color(0xFF222222),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          const Icon(Icons.badge_outlined, color: Color(0xFF34368C), size: 32),
        ],
      ),
    );
  }
}

// Vertical list of key/value details at the bottom of the sheet.
class _MemberDetailRows extends StatelessWidget {
  const _MemberDetailRows({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MemberDetailRow(label: 'Role', value: member.role),
        _MemberDetailRow(label: 'Institution', value: member.institution),
        _MemberDetailRow(label: 'Membership', value: member.memberCount),
        _MemberDetailRow(
          label: 'Focus area',
          value: member.contribution,
          valueColor: const Color(0xFF34368C),
        ),
      ],
    );
  }
}

// One key/value row in the member details sheet.
class _MemberDetailRow extends StatelessWidget {
  const _MemberDetailRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF151515),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact icon + text stat used under the member name.
class _MemberStat extends StatelessWidget {
  const _MemberStat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF243CA8), size: 17),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF111111),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
