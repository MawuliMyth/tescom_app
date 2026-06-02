part of '../dashboard_screen.dart';

class _LiveChatPage extends StatefulWidget {
  const _LiveChatPage();

  @override
  State<_LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<_LiveChatPage> {
  late Future<List<AppConversation>> conversationsFuture;
  String query = '';

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
    final draft = await showModalBottomSheet<_ChatDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateChatSheet(),
    );
    if (draft == null || draft.title.trim().isEmpty) return;

    try {
      final conversation = await AppRepository().createConversation(
        title: draft.title.trim(),
        participantIds: draft.participantIds,
      );
      await refresh();
      if (!mounted) return;
      Navigator.push(
        context,
        _adaptivePageRoute(
          context,
          builder: (_) => _WhatsAppThreadPage(conversation: conversation),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_chatError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<AppConversation>>(
          future: conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(18, 72, 18, 26),
                child: _ListShimmer(itemCount: 6),
              );
            }
            if (snapshot.hasError) return const _InlineErrorState();

            final conversations = (snapshot.data ?? const []).where((
              conversation,
            ) {
              final text = query.trim().toLowerCase();
              if (text.isEmpty) return true;
              return conversation.title.toLowerCase().contains(text) ||
                  _latestMessagePreview(
                    conversation.latestMessage,
                  ).toLowerCase().contains(text);
            }).toList();

            return RefreshIndicator.noSpinner(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _WhatsAppListHeader(
                      query: query,
                      onBack: () => Navigator.pop(context),
                      onCreate: createConversation,
                      onQueryChanged: (value) => setState(() => query = value),
                    ),
                  ),
                  if (conversations.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ChatEmptyState(
                        title: 'No chats yet',
                        message: 'Create a chat and invite TESCON members.',
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        return _WhatsAppConversationTile(
                          conversation: conversations[index],
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WhatsAppListHeader extends StatelessWidget {
  const _WhatsAppListHeader({
    required this.query,
    required this.onBack,
    required this.onCreate,
    required this.onQueryChanged,
  });

  final String query;
  final VoidCallback onBack;
  final VoidCallback onCreate;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;
    return Container(
      color: const Color(0xFF34368C),
      padding: EdgeInsets.fromLTRB(compact ? 8 : 12, 8, compact ? 8 : 12, 14),
      child: Column(
        children: [
          Row(
            children: [
              _WhatsAppHeaderButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              Expanded(
                child: Text(
                  'Chats',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: compact ? 22 : 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                onPressed: onCreate,
                icon: const Icon(
                  Icons.add_comment_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: onQueryChanged,
            style: GoogleFonts.inter(color: Colors.black, letterSpacing: 0),
            decoration: InputDecoration(
              hintText: 'Search chats',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => onQueryChanged(''),
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppHeaderButton extends StatelessWidget {
  const _WhatsAppHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
    );
  }
}

class _ChatDraft {
  const _ChatDraft({required this.title, required this.participantIds});

  final String title;
  final List<String> participantIds;
}

class _CreateChatSheet extends StatefulWidget {
  const _CreateChatSheet();

  @override
  State<_CreateChatSheet> createState() => _CreateChatSheetState();
}

class _CreateChatSheetState extends State<_CreateChatSheet> {
  final controller = TextEditingController();
  late Future<List<AppUser>> membersFuture;
  final selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    membersFuture = AppRepository().loadMembers();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    Navigator.pop(
      context,
      _ChatDraft(
        title: controller.text,
        participantIds: selectedIds.toList(growable: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.86;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: height,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1E5F0),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'New chat',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Chat title',
                            prefixIcon: const Icon(Icons.group_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF4F7FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<AppUser>>(
                      future: membersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(18),
                            child: _ListShimmer(itemCount: 4),
                          );
                        }
                        final members = snapshot.data ?? const [];
                        if (members.isEmpty) {
                          return const _ChatEmptyState(
                            title: 'No members available',
                            message: 'Members will appear here when they join.',
                          );
                        }
                        return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final selected = selectedIds.contains(member.id);
                            return CheckboxListTile(
                              value: selected,
                              onChanged: (_) {
                                setState(() {
                                  selected
                                      ? selectedIds.remove(member.id)
                                      : selectedIds.add(member.id);
                                });
                              },
                              activeColor: const Color(0xFF34368C),
                              secondary: _ChatAvatar(user: member),
                              title: Text(
                                member.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                              subtitle: Text(
                                member.institution ?? member.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: FilledButton(
                      onPressed: submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF34368C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          selectedIds.isEmpty
                              ? 'Create chat'
                              : 'Create with ${selectedIds.length} member${selectedIds.length == 1 ? '' : 's'}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          builder: (_) => _WhatsAppThreadPage(conversation: conversation),
        ),
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            const _LogoAvatar(radius: 27),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE7EAEE))),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _chatTime(
                              latest?.createdAt ?? conversation.updatedAt,
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8A94A6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _latestMessagePreview(latest),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF657184),
                          fontSize: 13,
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

class _WhatsAppThreadPage extends StatefulWidget {
  const _WhatsAppThreadPage({required this.conversation});

  final AppConversation conversation;

  @override
  State<_WhatsAppThreadPage> createState() => _WhatsAppThreadPageState();
}

class _WhatsAppThreadPageState extends State<_WhatsAppThreadPage> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late Future<List<AppMessage>> messagesFuture;
  late Future<AppUser?> userFuture;
  bool sendingText = false;
  bool sendingMedia = false;

  @override
  void initState() {
    super.initState();
    messagesFuture = AppRepository().loadConversationMessages(
      widget.conversation.id,
    );
    userFuture = AppRepository().loadCurrentUser();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> refreshMessages() async {
    setState(() {
      messagesFuture = AppRepository().loadConversationMessages(
        widget.conversation.id,
      );
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  Future<void> sendText() async {
    final text = controller.text.trim();
    if (text.isEmpty || sendingText) return;
    controller.clear();
    setState(() => sendingText = true);
    try {
      await AppRepository().sendConversationMessage(
        conversationId: widget.conversation.id,
        body: text,
      );
      await refreshMessages();
      scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_chatError(error))));
    } finally {
      if (mounted) setState(() => sendingText = false);
    }
  }

  Future<void> sendMedia({
    required bool video,
    required ImageSource source,
  }) async {
    if (sendingMedia) return;
    final picker = ImagePicker();
    final picked = video
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source, imageQuality: 88);
    if (picked == null) return;

    setState(() => sendingMedia = true);
    try {
      final uploaded = await AppRepository().uploadChatMedia(
        filename: picked.name,
        bytes: await picked.readAsBytes(),
        contentType: picked.mimeType ?? (video ? 'video/mp4' : 'image/jpeg'),
      );
      await AppRepository().sendConversationMessage(
        conversationId: widget.conversation.id,
        body: '',
        mediaUrl: uploaded.url,
        mediaType: uploaded.contentType,
      );
      await refreshMessages();
      scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_chatError(error))));
    } finally {
      if (mounted) setState(() => sendingMedia = false);
    }
  }

  void showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachmentSheet(
        uploading: sendingMedia,
        onImage: () {
          Navigator.pop(context);
          sendMedia(video: false, source: ImageSource.gallery);
        },
        onCamera: () {
          Navigator.pop(context);
          sendMedia(video: false, source: ImageSource.camera);
        },
        onVideo: () {
          Navigator.pop(context);
          sendMedia(video: true, source: ImageSource.gallery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: userFuture,
      builder: (context, userSnapshot) {
        final currentUserId = userSnapshot.data?.id;
        return Scaffold(
          backgroundColor: const Color(0xFFF1F2FF),
          appBar: AppBar(
            backgroundColor: const Color(0xFF34368C),
            foregroundColor: Colors.white,
            titleSpacing: 0,
            title: Text(
              widget.conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            actions: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: refreshMessages,
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<AppMessage>>(
                  future: messagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
                        child: _ListShimmer(itemCount: 6),
                      );
                    }
                    if (snapshot.hasError) return const _InlineErrorState();
                    final messages = snapshot.data ?? const [];
                    if (messages.isEmpty) {
                      return const _ChatEmptyState(
                        title: 'No messages yet',
                        message: 'Send the first message to start the chat.',
                      );
                    }
                    scrollToBottom();
                    return RefreshIndicator.noSpinner(
                      onRefresh: refreshMessages,
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _MessageBubble(
                            message: message,
                            isMe:
                                currentUserId != null &&
                                message.authorId == currentUserId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _WhatsAppComposer(
                controller: controller,
                sendingText: sendingText,
                sendingMedia: sendingMedia,
                onAttach: showAttachmentSheet,
                onSend: sendText,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WhatsAppComposer extends StatelessWidget {
  const _WhatsAppComposer({
    required this.controller,
    required this.sendingText,
    required this.sendingMedia,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sendingText;
  final bool sendingMedia;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(compact ? 4 : 6, 6, compact ? 4 : 6, 8),
        child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Message',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF667781),
              letterSpacing: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            prefixIcon: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: sendingMedia ? null : onAttach,
              icon: Icon(
                sendingMedia
                    ? Icons.hourglass_top_rounded
                    : Icons.attach_file_rounded,
                color: const Color(0xFF667781),
              ),
            ),
            suffixIcon: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: sendingText ? null : onSend,
              icon: Icon(
                sendingText ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: const Color(0xFF34368C),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  const _AttachmentSheet({
    required this.uploading,
    required this.onImage,
    required this.onCamera,
    required this.onVideo,
  });

  final bool uploading;
  final VoidCallback onImage;
  final VoidCallback onCamera;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 12,
            children: [
              _AttachmentAction(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF35A7FF),
                onTap: uploading ? null : onImage,
              ),
              _AttachmentAction(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: const Color(0xFF32C770),
                onTap: uploading ? null : onCamera,
              ),
              _AttachmentAction(
                icon: Icons.videocam_rounded,
                label: 'Video',
                color: const Color(0xFFE84D8A),
                onTap: uploading ? null : onVideo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 27),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF657184),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final AppMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = message.mediaUrl?.trim();
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * 0.76;
          return Container(
            constraints: BoxConstraints(maxWidth: width.clamp(190.0, 330.0)),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE8ECFF) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 3),
                bottomRight: Radius.circular(isMe ? 3 : 14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      message.author?.fullName ?? 'Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                if (mediaUrl != null && mediaUrl.isNotEmpty)
                  _BubbleMedia(message: message),
                if (message.body.trim().isNotEmpty) ...[
                  if (mediaUrl != null && mediaUrl.isNotEmpty)
                    const SizedBox(height: 7),
                  Text(
                    message.body,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _chatTime(message.createdAt),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF667781),
                          fontSize: 10,
                          letterSpacing: 0,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 15,
                          color: Color(0xFF34368C),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BubbleMedia extends StatelessWidget {
  const _BubbleMedia({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    final isVideo = message.mediaType?.contains('video') == true;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.66;
        if (isVideo) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: ApiConfig.mediaUrl(message.mediaUrl ?? ''),
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                _ShimmerBlock(width: width, height: height, borderRadius: 10),
            errorWidget: (_, _, _) => Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              color: const Color(0xFFEFEFFC),
              child: Text(
                'Image unavailable',
                style: GoogleFonts.inter(
                  color: const Color(0xFF34368C),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return CircleAvatar(
        backgroundColor: const Color(0xFFEAF1F8),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: ApiConfig.mediaUrl(avatarUrl),
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => Text(_initials(user.fullName)),
          ),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: const Color(0xFF34368C),
      child: Text(
        _initials(user.fullName),
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8ECFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Color(0xFF34368C),
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF657184),
                fontSize: 13,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ],
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

String _latestMessagePreview(AppMessage? message) {
  if (message == null) return 'No messages yet';
  if (message.body.trim().isNotEmpty) return message.body;
  if (message.mediaUrl?.trim().isNotEmpty == true) {
    return message.mediaType?.contains('video') == true ? 'Video' : 'Photo';
  }
  return 'No messages yet';
}

String _chatTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
  return parts.isEmpty ? 'T' : parts;
}
