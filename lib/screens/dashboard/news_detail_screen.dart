part of '../dashboard_screen.dart';

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
    _adaptivePageRoute(
      context,
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

  String get displaySource =>
      widget.source.replaceFirst(RegExp(r'^From\s+', caseSensitive: false), '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
          children: [
            Row(
              children: [
                _DetailCircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
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
              ],
            ),
            const SizedBox(height: 34),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                color: const Color(0xFF151515),
                fontSize: 22,
                height: 1.36,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundImage: AssetImage(widget.authorImagePath),
                ),
                // const SizedBox(width: 5),
                Text(
                  displaySource,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 9),
                const _DetailDot(),
                const SizedBox(width: 9),
                Text(
                  widget.date,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 9),
                const _DetailDot(),
                const SizedBox(width: 9),
                Text(
                  '8 Mins Read',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                widget.imagePath,
                width: double.infinity,
                height: 254,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Photo Courtesy By $displaySource',
                style: GoogleFonts.inter(
                  color: const Color(0xFF777777),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _detailBody(),
              style: GoogleFonts.inter(
                color: const Color(0xFF1D1D1D),
                fontSize: 15,
                height: 1.58,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailDot extends StatelessWidget {
  const _DetailDot();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.circle,
      size: 4,
      color: Color(0xFF9A9A9A),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          color: const Color(0xFF111111),
          size: 24,
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
