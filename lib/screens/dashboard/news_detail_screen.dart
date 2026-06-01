part of '../dashboard_screen.dart';

void _openNewsDetail(
  BuildContext context, {
  required String imagePath,
  List<String> imagePaths = const [],
  required String authorImagePath,
  required String source,
  required String title,
  required String author,
  required String date,
  String? body,
  String? itemId,
}) {
  Navigator.of(context).push(
    _adaptivePageRoute(
      context,
      builder: (_) => _NewsDetailScreen(
        imagePath: imagePath,
        imagePaths: imagePaths.isEmpty ? [imagePath] : imagePaths,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
        body: body,
        itemId: itemId,
      ),
    ),
  );
}

class _NewsDetailScreen extends StatefulWidget {
  const _NewsDetailScreen({
    required this.imagePath,
    required this.imagePaths,
    required this.authorImagePath,
    required this.source,
    required this.title,
    required this.author,
    required this.date,
    this.body,
    this.itemId,
  });

  final String imagePath;
  final List<String> imagePaths;
  final String authorImagePath;
  final String source;
  final String title;
  final String author;
  final String date;
  final String? body;
  final String? itemId;

  @override
  State<_NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<_NewsDetailScreen> {
  bool isSaved = false;
  int activeImage = 0;

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
                    if (widget.itemId == null || widget.itemId!.isEmpty) {
                      _showSnack(context, 'This story cannot be saved yet');
                      return;
                    }
                    setState(() => isSaved = !isSaved);
                    final repository = AppRepository();
                    if (isSaved) {
                      repository.saveItem(
                        itemType: 'NEWS',
                        itemId: widget.itemId!,
                      );
                    } else {
                      repository.removeSavedItem(
                        itemType: 'NEWS',
                        itemId: widget.itemId!,
                      );
                    }
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
            _NewsDetailMeta(
              authorImagePath: widget.authorImagePath,
              source: displaySource,
              date: widget.date,
            ),
            const SizedBox(height: 34),
            _NewsImageGallery(
              imagePaths: widget.imagePaths.isEmpty
                  ? [widget.imagePath]
                  : widget.imagePaths,
              activeIndex: activeImage,
              onChanged: (index) => setState(() => activeImage = index),
            ),
            if ((widget.imagePaths.isEmpty
                        ? [widget.imagePath]
                        : widget.imagePaths)
                    .length >
                1) ...[
              const SizedBox(height: 10),
              _GalleryDots(
                count:
                    (widget.imagePaths.isEmpty
                            ? [widget.imagePath]
                            : widget.imagePaths)
                        .length,
                activeIndex: activeImage,
              ),
            ],
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
              widget.body == null || widget.body!.trim().isEmpty
                  ? 'No story body has been added yet.'
                  : widget.body!,
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

class _NewsDetailMeta extends StatelessWidget {
  const _NewsDetailMeta({
    required this.authorImagePath,
    required this.source,
    required this.date,
  });

  final String authorImagePath;
  final String source;
  final String date;

  @override
  Widget build(BuildContext context) {
    final sourceStyle = GoogleFonts.inter(
      color: const Color(0xFF005BC5),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
    final metaStyle = GoogleFonts.inter(
      color: const Color(0xFF666666),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 9,
      runSpacing: 8,
      children: [
        CircleAvatar(radius: 13, backgroundImage: AssetImage(authorImagePath)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: sourceStyle,
          ),
        ),
        const _DetailDot(),
        Text(date, style: metaStyle),
      ],
    );
  }
}

class _NewsImageGallery extends StatelessWidget {
  const _NewsImageGallery({
    required this.imagePaths,
    required this.activeIndex,
    required this.onChanged,
  });

  final List<String> imagePaths;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 254,
        child: PageView.builder(
          itemCount: imagePaths.length,
          onPageChanged: onChanged,
          itemBuilder: (context, index) {
            return _DashboardContentImage(
              path: imagePaths[index],
              width: double.infinity,
              height: 254,
            );
          },
        ),
      ),
    );
  }
}

class _GalleryDots extends StatelessWidget {
  const _GalleryDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: active ? 18 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF34368C) : const Color(0xFFD4D8E5),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _DetailDot extends StatelessWidget {
  const _DetailDot();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.circle, size: 4, color: Color(0xFF9A9A9A));
  }
}

class _DetailCircleButton extends StatelessWidget {
  const _DetailCircleButton({required this.icon, required this.onTap});

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
        child: Icon(icon, color: const Color(0xFF111111), size: 24),
      ),
    );
  }
}
