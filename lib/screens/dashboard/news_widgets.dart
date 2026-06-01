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
    return FutureBuilder<AppBootstrap>(
      future: AppRepository().loadBootstrap(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 228,
            child: _ShimmerBlock(height: 210, borderRadius: 18),
          );
        }
        if (snapshot.hasError) return const _InlineErrorState();

        final articles = snapshot.data?.news ?? const [];
        if (articles.isEmpty) {
          return const _InfoCard(
            item: _InfoItem(
              title: 'No featured news yet',
              subtitle: 'Admin dashboard',
              body: 'Published news will appear in this carousel.',
              icon: Icons.article_outlined,
            ),
          );
        }

        return CarouselSlider(
          items: articles.take(5).map((article) {
            final imagePaths = _contentImages(
              article.imageUrls,
              article.imageUrl,
            );
            return _CarouselImage(
              path: imagePaths.first,
              imagePaths: imagePaths,
              authorImagePath: 'assets/images/logo.png',
              source: article.category ?? 'TESCON',
              title: article.title,
              author: 'TESCON',
              date: _friendlyDate(article.publishedAt ?? article.createdAt),
              body: article.body,
              itemId: article.id,
            );
          }).toList(),
          options: CarouselOptions(
            height: 228,
            viewportFraction: 1,
            enlargeCenterPage: false,
            enableInfiniteScroll: articles.length > 1,
            autoPlay: articles.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            padEnds: false,
          ),
        );
      },
    );
  }
}

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({
    required this.path,
    required this.imagePaths,
    required this.authorImagePath,
    required this.source,
    required this.title,
    required this.author,
    required this.date,
    this.body,
    this.itemId,
  });

  final String path;
  final List<String> imagePaths;
  final String authorImagePath;
  final String source;
  final String title;
  final String author;
  final String date;
  final String? body;
  final String? itemId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openNewsDetail(
        context,
        imagePath: path,
        imagePaths: imagePaths,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
        body: body,
        itemId: itemId,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _DashboardContentImage(
                path: path,
                width: double.infinity,
                height: 132,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundImage: AssetImage(authorImagePath),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8A8A8A),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationList extends StatelessWidget {
  const _RecommendationList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: AppRepository().loadBootstrap(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ListShimmer(itemCount: 3);
        }
        if (snapshot.hasError) return const _InlineErrorState();

        final articles = snapshot.data?.news ?? const [];
        if (articles.isEmpty) {
          return const _InfoCard(
            item: _InfoItem(
              title: 'No recommendations yet',
              subtitle: 'Admin dashboard',
              body: 'Published news will appear here.',
              icon: Icons.article_outlined,
            ),
          );
        }

        return Column(children: articles.map(_ApiNewsTile.new).toList());
      },
    );
  }
}

class _ApiNewsTile extends StatelessWidget {
  const _ApiNewsTile(this.article);

  final AppNewsArticle article;

  @override
  Widget build(BuildContext context) {
    final imagePaths = _contentImages(article.imageUrls, article.imageUrl);
    return _RecommendationTile(
      imagePath: imagePaths.first,
      imagePaths: imagePaths,
      authorImagePath: 'assets/images/logo.png',
      source: article.category ?? 'TESCON',
      title: article.title,
      author: 'TESCON',
      date: _friendlyDate(article.publishedAt ?? article.createdAt),
      body: article.body,
      itemId: article.id,
    );
  }
}

class _RecommendationsPage extends StatelessWidget {
  const _RecommendationsPage();

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: 'Recommendations',
      subtitle: 'Recommended stories and updates for members.',
      children: [_RecommendationList()],
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.imagePath,
    this.imagePaths = const [],
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openNewsDetail(
        context,
        imagePath: imagePath,
        imagePaths: imagePaths,
        authorImagePath: authorImagePath,
        source: source,
        title: title,
        author: author,
        date: date,
        body: body,
        itemId: itemId,
      ),
      borderRadius: BorderRadius.circular(8),
      child: _AppSurface(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 2),
        borderRadius: 16,
        opacity: 0.62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _DashboardContentImage(
                path: imagePath,
                width: 116,
                height: 84,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 84,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NewsCategoryText(label: source),
                    const SizedBox(height: 6),
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

class _NewsCategoryText extends StatelessWidget {
  const _NewsCategoryText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: const Color(0xFF005BC5),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _DashboardContentImage extends StatelessWidget {
  const _DashboardContentImage({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final resolvedPath = ApiConfig.mediaUrl(path);
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: resolvedPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => _imagePlaceholder(width, height),
        errorWidget: (_, _, _) => _imageFallback(width, height),
      );
    }

    if (path.startsWith('/')) {
      return CachedNetworkImage(
        imageUrl: resolvedPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => _imagePlaceholder(width, height),
        errorWidget: (_, _, _) => _imageFallback(width, height),
      );
    }

    return Image.asset(path, width: width, height: height, fit: BoxFit.cover);
  }

  Widget _imageFallback(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE7EAF6),
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  Widget _imagePlaceholder(double width, double height) {
    return _ShimmerBlock(width: width, height: height, borderRadius: 0);
  }
}

String _friendlyDate(DateTime? value) {
  if (value == null) return 'Recently';
  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.inDays > 0) return '${difference.inDays}d ago';
  if (difference.inHours > 0) return '${difference.inHours}h ago';
  return 'Just now';
}

List<String> _contentImages(List<String> imageUrls, String? imageUrl) {
  final images = [
    ...imageUrls.where((item) => item.trim().isNotEmpty),
    if (imageUrl != null && imageUrl.trim().isNotEmpty) imageUrl,
  ];
  if (images.isEmpty) return const ['assets/images/logo.png'];
  return images.toSet().toList(growable: false);
}
