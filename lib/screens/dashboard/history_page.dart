part of '../dashboard_screen.dart';

// Live TESCON history route with searchable timeline cards.

class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  final _repository = AppRepository();
  late Future<List<AppHistoryEntry>> _future;
  String query = '';

  @override
  void initState() {
    super.initState();
    _future = _repository.loadHistory();
  }

  Future<void> _refresh() async {
    final future = _repository.loadHistory();
    setState(() => _future = future);
    await future;
  }

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
          'TESCON History',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: _AppScaffoldBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            color: const Color(0xFF34368C),
            onRefresh: _refresh,
            child: FutureBuilder<List<AppHistoryEntry>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _HistoryShimmerList();
                }

                if (snapshot.hasError) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    children: const [
                      _InfoCard(
                        item: _InfoItem(
                          title: 'History unavailable',
                          subtitle: 'Could not load records',
                          body:
                              'Please check your connection and pull down to try again.',
                          icon: Icons.error_outline_rounded,
                        ),
                      ),
                    ],
                  );
                }

                final items = snapshot.data ?? const <AppHistoryEntry>[];
                final filtered = items
                    .where((item) => _historyMatches(item, query))
                    .toList(growable: false);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                  children: [
                    Text(
                      'Search institutional history, milestones, and archives.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF777777),
                        fontSize: 12,
                        height: 1.35,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DemoSearchField(
                      hintText: 'Search history',
                      onChanged: (value) => setState(() => query = value),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      _InfoCard(
                        item: _InfoItem(
                          title: items.isEmpty
                              ? 'No history available'
                              : 'No results found',
                          subtitle: items.isEmpty
                              ? 'No live records yet'
                              : 'Try another keyword',
                          body: items.isEmpty
                              ? 'History records added from the admin dashboard will appear here.'
                              : 'Try another keyword to search the available records.',
                          icon: items.isEmpty
                              ? Icons.history_edu_outlined
                              : Icons.search_off_rounded,
                        ),
                      )
                    else
                      ...filtered.map(_HistoryCard.new),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

bool _historyMatches(AppHistoryEntry item, String query) {
  final lower = query.trim().toLowerCase();
  if (lower.isEmpty) return true;
  return item.title.toLowerCase().contains(lower) ||
      item.body.toLowerCase().contains(lower) ||
      (item.summary ?? '').toLowerCase().contains(lower) ||
      (item.category ?? '').toLowerCase().contains(lower);
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard(this.item);

  final AppHistoryEntry item;

  @override
  Widget build(BuildContext context) {
    final mediaSource = item.mediaUrl ?? item.imageUrl;
    final mediaUrl = mediaSource == null
        ? null
        : ApiConfig.mediaUrl(mediaSource);
    final isVideo =
        (item.mediaType ?? '').startsWith('video') ||
        (mediaUrl != null &&
            RegExp(
              r'\.(mp4|webm|mov)(\?|$)',
              caseSensitive: false,
            ).hasMatch(mediaUrl));
    return _AppSurface(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      opacity: 0.68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mediaUrl != null)
            _HistoryMediaPreview(url: mediaUrl, isVideo: isVideo),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history_edu_outlined,
                      color: Color(0xFF34368C),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category ?? 'History',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF34368C),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      _historyDate(item.occurredAt ?? item.createdAt),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8A94A6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                if ((item.summary ?? '').isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.summary!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7A7A7A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 11,
                    height: 1.45,
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

class _HistoryMediaPreview extends StatelessWidget {
  const _HistoryMediaPreview({required this.url, required this.isVideo});

  final String url;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: isVideo
          ? _HistoryVideoPlayer(url: url)
          : CachedNetworkImage(
              imageUrl: url,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => const _HistoryImageShimmer(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
    );
  }
}

class _HistoryVideoPlayer extends StatefulWidget {
  const _HistoryVideoPlayer({required this.url});

  final String url;

  @override
  State<_HistoryVideoPlayer> createState() => _HistoryVideoPlayerState();
}

class _HistoryVideoPlayerState extends State<_HistoryVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        height: 150,
        color: const Color(0xFFE9ECF7),
        alignment: Alignment.center,
        child: Text(
          'Video unavailable',
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      );
    }

    if (!_ready) {
      return const SizedBox(height: 150, child: _HistoryImageShimmer());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF34368C).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
        ],
      ),
    );
  }
}

String _historyDate(DateTime? date) {
  if (date == null) return 'Recent';
  return '${date.day}/${date.month}/${date.year}';
}

class _HistoryShimmerList extends StatelessWidget {
  const _HistoryShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFFE8ECF4),
        highlightColor: Colors.white,
        child: Container(
          height: 126,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _HistoryImageShimmer extends StatelessWidget {
  const _HistoryImageShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF4),
      highlightColor: Colors.white,
      child: Container(color: Colors.white),
    );
  }
}
