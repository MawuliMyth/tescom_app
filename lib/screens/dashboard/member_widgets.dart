part of '../dashboard_screen.dart';

// Member model shared by the directory, details sheet, and existing executive cards.
class _Member {
  const _Member({
    required this.name,
    required this.role,
    required this.institution,
    required this.imagePath,
    required this.bio,
    this.joinDate = '1/09/2024',
    this.memberCount = '15',
    this.contribution = 'Campus Mobilization',
  });

  final String name;
  final String role;
  final String institution;
  final String imagePath;
  final String bio;
  final String joinDate;
  final String memberCount;
  final String contribution;

  // Case-insensitive search across the main fields users naturally look for.
  bool matches(String query) {
    final lower = query.toLowerCase();
    return name.toLowerCase().contains(lower) ||
        role.toLowerCase().contains(lower) ||
        institution.toLowerCase().contains(lower) ||
        bio.toLowerCase().contains(lower) ||
        memberCount.toLowerCase().contains(lower) ||
        contribution.toLowerCase().contains(lower);
  }
}

// Member row used by the new directory screen.
class _DirectoryMemberRow extends StatelessWidget {
  const _DirectoryMemberRow({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showMemberDetailSheet(context, member),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage(member.imagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF222222),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF222222),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// Card tile used by Membership Directory and Executives.
class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showMemberDetailSheet(context, member),
      borderRadius: BorderRadius.circular(16),
      child: _AppSurface(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        opacity: 0.68,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(member.imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.institution,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}

// Plain icon touch target used by the membership directory header.
class _PlainIconButton extends StatelessWidget {
  const _PlainIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}
