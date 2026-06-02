part of '../dashboard_screen.dart';

class _LiveChatPage extends StatefulWidget {
  const _LiveChatPage();

  @override
  State<_LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<_LiveChatPage> {
  late Future<List<AppConversation>> conversationsFuture;

  @override
  void initState() {
    super.initState();
    conversationsFuture = AppRepository().loadConversations();
  }

  Future<void> refresh() async {
    setState(() {
      conversationsFuture = AppRepository().loadConversations();
    });
  }

  Future<void> createConversation() async {
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateChatSheet(),
    );
    if (title == null || title.trim().isEmpty) return;
    try {
      final conversation = await AppRepository().createConversation(
        title: title.trim(),
      );
      await refresh();
      if (!mounted) return;
      Navigator.push(
        context,
        _adaptivePageRoute(
          context,
          builder: (_) => _ChatThreadPage(conversation: conversation),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_chatError(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<AppConversation>>(
            future: conversationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(18, 72, 18, 26),
                  child: _ListShimmer(itemCount: 5),
                );
              }
              if (snapshot.hasError) return const _InlineErrorState();

              final conversations = snapshot.data ?? const [];
              return RefreshIndicator.noSpinner(
                onRefresh: refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
                  children: [
                    _WhatsAppHeader(
                      onBack: () => Navigator.pop(context),
                      onCreate: createConversation,
                    ),
                    const SizedBox(height: 14),
                    const _ChatSearchField(),
                    const SizedBox(height: 12),
                    if (conversations.isEmpty)
                      const _ChatEmptyState()
                    else
                      ...conversations.map(
                        (conversation) => _WhatsAppConversationTile(
                          conversation: conversation,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WhatsAppHeader extends StatelessWidget {
  const _WhatsAppHeader({required this.onBack, required this.onCreate});

  final VoidCallback onBack;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlainIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const SizedBox(width: 8),
        Text(
          'Chats',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        _PlainIconButton(icon: Icons.add_comment_rounded, onTap: onCreate),
      ],
    );
  }
}

class _CreateChatSheet extends StatefulWidget {
  const _CreateChatSheet();

  @override
  State<_CreateChatSheet> createState() => _CreateChatSheetState();
}

class _CreateChatSheetState extends State<_CreateChatSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start a chat',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Conversation title',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34368C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Create chat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatSearchField extends StatelessWidget {
  const _ChatSearchField();

  @override
  Widget build(BuildContext context) {
    return _AppSurface(
      borderRadius: 18,
      opacity: 0.72,
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search chats',
          prefixIcon: Icon(Icons.search_rounded),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _WhatsAppConversationTile extends StatelessWidget {
  const _WhatsAppConversationTile({required this.conversation});

  final AppConversation conversation;

  @override
  Widget build(BuildContext context) {
    final latest = conversation.latestMessage;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        _adaptivePageRoute(
          context,
          builder: (_) => _ChatThreadPage(conversation: conversation),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE8E8EF))),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          Text(
                            _friendlyDate(
                              latest?.createdAt ?? conversation.updatedAt,
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8A8A8A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _latestMessagePreview(latest),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF666666),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({required this.conversation});

  final AppConversation conversation;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final controller = TextEditingController();
  late Future<List<AppMessage>> messagesFuture;
  bool sendingMedia = false;

  @override
  void initState() {
    super.initState();
    messagesFuture = AppRepository().loadConversationMessages(
      widget.conversation.id,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    await AppRepository().sendConversationMessage(
      conversationId: widget.conversation.id,
      body: text,
    );
    setState(() {
      messagesFuture = AppRepository().loadConversationMessages(
        widget.conversation.id,
      );
    });
  }

  Future<void> sendMedia(ImageSource source, {required bool video}) async {
    if (sendingMedia) return;
    final picker = ImagePicker();
    final picked = video
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source, imageQuality: 88);
    if (picked == null) return;

    setState(() => sendingMedia = true);
    try {
      final bytes = await picked.readAsBytes();
      final mediaType = picked.mimeType ?? (video ? 'video/mp4' : 'image/jpeg');
      final uploaded = await AppRepository().uploadChatMedia(
        filename: picked.name,
        bytes: bytes,
        contentType: mediaType,
      );
      await AppRepository().sendConversationMessage(
        conversationId: widget.conversation.id,
        body: '',
        mediaUrl: uploaded.url,
        mediaType: uploaded.contentType,
      );
      setState(() {
        messagesFuture = AppRepository().loadConversationMessages(
          widget.conversation.id,
        );
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_chatError(error))),
      );
    } finally {
      if (mounted) setState(() => sendingMedia = false);
    }
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
          widget.conversation.title,
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
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<AppMessage>>(
                  future: messagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
                        child: _ListShimmer(itemCount: 5),
                      );
                    }
                    if (snapshot.hasError) return const _InlineErrorState();
                    final messages = snapshot.data ?? const [];
                    if (messages.isEmpty) return const _ChatEmptyState();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _ChatBubble(message: messages[index]);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _AppSurface(
                        borderRadius: 22,
                        opacity: 0.72,
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: sendingMedia
                          ? Icons.hourglass_top_rounded
                          : Icons.add_photo_alternate_rounded,
                      onTap: () => sendMedia(ImageSource.gallery, video: false),
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: Icons.videocam_rounded,
                      onTap: () => sendMedia(ImageSource.gallery, video: true),
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(icon: Icons.send_rounded, onTap: send),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _chatError(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  if (message.contains('Session expired') ||
      message.contains('Authentication') ||
      message.contains('401')) {
    return 'Please log in again to continue chatting.';
  }
  return message.isEmpty ? 'Something went wrong. Try again.' : message;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _AppSurface(
        constraints: const BoxConstraints(maxWidth: 270),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        opacity: 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.author?.fullName ?? 'Member',
              style: GoogleFonts.inter(
                color: const Color(0xFF34368C),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            if (message.mediaUrl != null &&
                message.mediaUrl!.trim().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.mediaUrl(message.mediaUrl!),
                  width: 230,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const _ShimmerBlock(
                    width: 230,
                    height: 150,
                    borderRadius: 12,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 230,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.mediaType?.contains('video') == true
                          ? 'Video unavailable'
                          : 'Image unavailable',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
              if (message.body.trim().isNotEmpty) const SizedBox(height: 8),
            ],
            if (message.body.trim().isNotEmpty)
              Text(
                message.body,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 12,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _latestMessagePreview(AppMessage? message) {
  if (message == null) return 'No messages yet';
  if (message.body.trim().isNotEmpty) return message.body;
  if (message.mediaUrl?.trim().isNotEmpty == true) {
    return message.mediaType?.contains('video') == true ? 'Video' : 'Image';
  }
  return 'No messages yet';
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'No chat data yet. Create a conversation in the admin dashboard.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF777777),
            fontSize: 13,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
