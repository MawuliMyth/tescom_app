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
      backgroundColor: const Color(0xFFF8FAFF),
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
                  message: 'Share, report, and copy link.',
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
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: _LiquidScaffoldBackground(
                child: _LiquidGlass(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.fromLTRB(14, 30, 14, 30),
                  borderRadius: 26,
                  opacity: 0.78,
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
        child: _LiquidGlass(
          width: 34,
          height: 34,
          borderRadius: 17,
          opacity: 0.34,
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
