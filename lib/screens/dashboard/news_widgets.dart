part of '../dashboard_screen.dart';

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
        autoPlay: true,

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
      child: _LiquidGlass(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 2),
        borderRadius: 16,
        opacity: 0.62,
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
      ),
    );
  }
}
