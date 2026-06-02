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
    final draft = await showModalBottomSheet<_CreateChatDraft>(
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
          builder: (_) => _TelegramThreadPage(conversation: conversation),
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
      backgroundColor: const Color(0xFFF4F7FB),
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

            final conversations = (snapshot.data ?? const [])
                .where((conversation) {
                  final text = query.toLowerCase();
                  return conversation.title.toLowerCase().contains(text) ||
                      _latestMessagePreview(
                        conversation.latestMessage,
                      ).toLowerCase().contains(text);
                })
                .toList();

            return RefreshIndicator.noSpinner(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _TelegramChatHeader(
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
                        message:
                            'Start a chat and invite members from the TESCON directory.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 22),
                      sliver: SliverList.separated(
                        itemCount: conversations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          return _TelegramConversationTile(
                            conversation: conversations[index],
                          );
                        },
                      ),
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

class _TelegramChatHeader extends StatelessWidget {
  const _TelegramChatHeader({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF34368C),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TelegramHeaderButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Telegram Chat',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _TelegramHeaderButton(
                icon: Icons.edit_square,
                onTap: onCreate,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: onQueryChanged,
            style: GoogleFonts.inter(color: Colors.white, letterSpacing: 0),
            decoration: InputDecoration(
              hintText: 'Search messages or chats',
              hintStyle: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 0,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => onQueryChanged(''),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelegramHeaderButton extends StatelessWidget {
  const _TelegramHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CreateChatDraft {
  const _CreateChatDraft({required this.title, required this.participantIds});

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
      _CreateChatDraft(
        title: controller.text,
        participantIds: selectedIds.toList(growable: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
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
                      const SizedBox(height: 18),
                      Text(
                        'New group chat',
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
                          hintText: 'Group or chat title',
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: _ListShimmer(itemCount: 4),
                        );
                      }
                      final members = snapshot.data ?? const [];
                      if (members.isEmpty) {
                        return const _ChatEmptyState(
                          title: 'No members available',
                          message:
                              'Members will appear here when they register.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            secondary: _TelegramAvatar(user: member),
                            title: Text(
                              member.fullName,
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                    child: Text(
                      selectedIds.isEmpty
                          ? 'Create chat'
                          : 'Create with ${selectedIds.length} member${selectedIds.length == 1 ? '' : 's'}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TelegramConversationTile extends StatelessWidget {
  const _TelegramConversationTile({required this.conversation});

  final AppConversation conversation;

  @override
  Widget build(BuildContext context) {
    final latest = conversation.latestMessage;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        _adaptivePageRoute(
          context,
          builder: (_) => _TelegramThreadPage(conversation: conversation),
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const _TelegramLogoAvatar(radius: 28),
            const SizedBox(width: 12),
            Expanded(
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
                      Text(
                        _chatTime(latest?.createdAt ?? conversation.updatedAt),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8A94A6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _latestMessagePreview(latest),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF657184),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (latest != null)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34368C),
                            shape: BoxShape.circle,
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
    );
  }
}

class _TelegramThreadPage extends StatefulWidget {
  const _TelegramThreadPage({required this.conversation});

  final AppConversation conversation;

  @override
  State<_TelegramThreadPage> createState() => _TelegramThreadPageState();
}

class _TelegramThreadPageState extends State<_TelegramThreadPage> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late Future<List<AppMessage>> messagesFuture;
  late Future<AppUser?> userFuture;
  AppMessage? replyTo;
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
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || sendingText) return;
    controller.clear();
    final body = replyTo == null
        ? text
        : '↪ ${replyTo!.author?.fullName ?? 'Member'}: ${_latestMessagePreview(replyTo)}\n$text';
    setState(() {
      sendingText = true;
      replyTo = null;
    });
    try {
      await AppRepository().sendConversationMessage(
        conversationId: widget.conversation.id,
        body: body,
      );
      await refreshMessages();
      scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_chatError(error))),
      );
    } finally {
      if (mounted) setState(() => sendingText = false);
    }
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
      await refreshMessages();
      scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_chatError(error))),
      );
    } finally {
      if (mounted) setState(() => sendingMedia = false);
    }
  }

  Future<void> showAttachmentSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TelegramAttachmentSheet(
        uploading: sendingMedia,
        onPhoto: () {
          Navigator.pop(context);
          sendMedia(ImageSource.gallery, video: false);
        },
        onCamera: () {
          Navigator.pop(context);
          sendMedia(ImageSource.camera, video: false);
        },
        onVideo: () {
          Navigator.pop(context);
          sendMedia(ImageSource.gallery, video: true);
        },
      ),
    );
  }

  void showMessageActions(AppMessage message) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TelegramMessageActions(
        onReply: () {
          Navigator.pop(context);
          setState(() => replyTo = message);
        },
        onCopy: () {
          Navigator.pop(context);
          Clipboard.setData(ClipboardData(text: message.body));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message copied')),
          );
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
          backgroundColor: const Color(0xFFEAF1F8),
          appBar: AppBar(
            backgroundColor: const Color(0xFF34368C),
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                const _TelegramLogoAvatar(radius: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      Text(
                        'online recently',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: refreshMessages,
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                onPressed: () {},
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
                        child: _ListShimmer(itemCount: 7),
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
                        padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                        itemCount: _messageListLength(messages),
                        itemBuilder: (context, index) {
                          final item = _messageListItem(messages, index);
                          if (item is DateTime) {
                            return _TelegramDateDivider(date: item);
                          }
                          final message = item as AppMessage;
                          return _TelegramBubble(
                            message: message,
                            isMe: currentUserId != null &&
                                message.authorId == currentUserId,
                            onLongPress: () => showMessageActions(message),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _TelegramComposer(
                controller: controller,
                replyTo: replyTo,
                sendingText: sendingText,
                sendingMedia: sendingMedia,
                onCancelReply: () => setState(() => replyTo = null),
                onAttach: showAttachmentSheet,
                onSend: send,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TelegramComposer extends StatelessWidget {
  const _TelegramComposer({
    required this.controller,
    required this.replyTo,
    required this.sendingText,
    required this.sendingMedia,
    required this.onCancelReply,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final AppMessage? replyTo;
  final bool sendingText;
  final bool sendingMedia;
  final VoidCallback onCancelReply;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(compact ? 6 : 8, 6, compact ? 6 : 8, 8),
        color: const Color(0xFFEAF1F8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTo != null)
              Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF34368C), width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reply to ${replyTo!.author?.fullName ?? 'Member'}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF34368C),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            _latestMessagePreview(replyTo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF657184),
                              fontSize: 12,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onCancelReply,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!compact)
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Color(0xFF778397),
                            ),
                          ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF8A94A6),
                                letterSpacing: 0,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: sendingMedia ? null : onAttach,
                          icon: Icon(
                            sendingMedia
                                ? Icons.hourglass_top_rounded
                                : Icons.attach_file_rounded,
                            color: const Color(0xFF778397),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
                InkWell(
                  onTap: sendingText ? null : onSend,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: compact ? 44 : 48,
                    height: compact ? 44 : 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34368C),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sendingText
                          ? Icons.hourglass_top_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TelegramAttachmentSheet extends StatelessWidget {
  const _TelegramAttachmentSheet({
    required this.uploading,
    required this.onPhoto,
    required this.onCamera,
    required this.onVideo,
  });

  final bool uploading;
  final VoidCallback onPhoto;
  final VoidCallback onCamera;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: _AttachmentAction(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF35A7FF),
                  onTap: uploading ? null : onPhoto,
                ),
              ),
              Expanded(
                child: _AttachmentAction(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF32C770),
                  onTap: uploading ? null : onCamera,
                ),
              ),
              Expanded(
                child: _AttachmentAction(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  color: const Color(0xFFE84D8A),
                  onTap: uploading ? null : onVideo,
                ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
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
    );
  }
}

class _TelegramMessageActions extends StatelessWidget {
  const _TelegramMessageActions({required this.onReply, required this.onCopy});

  final VoidCallback onReply;
  final VoidCallback onCopy;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply_rounded),
                title: const Text('Reply'),
                onTap: onReply,
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy text'),
                onTap: onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelegramBubble extends StatelessWidget {
  const _TelegramBubble({
    required this.message,
    required this.isMe,
    required this.onLongPress,
  });

  final AppMessage message;
  final bool isMe;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFDDF4FF) : Colors.white;
    final mediaUrl = message.mediaUrl?.trim();
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: EdgeInsets.only(
            left: isMe ? 52 : 0,
            right: isMe ? 0 : 52,
            bottom: 8,
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 5),
              bottomRight: Radius.circular(isMe ? 5 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    message.author?.fullName ?? 'Member',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34368C),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              if (mediaUrl != null && mediaUrl.isNotEmpty)
                _TelegramMediaPreview(message: message),
              if (message.body.trim().isNotEmpty) ...[
                if (mediaUrl != null && mediaUrl.isNotEmpty)
                  const SizedBox(height: 8),
                Text(
                  message.body,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _chatTime(message.createdAt),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7A8495),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      color: Color(0xFF2AABEE),
                      size: 15,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelegramMediaPreview extends StatelessWidget {
  const _TelegramMediaPreview({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = message.mediaUrl ?? '';
    final isVideo = message.mediaType?.contains('video') == true;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width * 0.68;
        final width = maxWidth < 240 ? maxWidth : 240.0;
        final imageHeight = width * 0.7;
        final videoHeight = width * 0.62;

        if (isVideo) {
          return Container(
            width: width,
            height: videoHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: ApiConfig.mediaUrl(mediaUrl),
            width: width,
            height: imageHeight,
            fit: BoxFit.cover,
            placeholder: (_, _) => _ShimmerBlock(
              width: width,
              height: imageHeight,
              borderRadius: 14,
            ),
            errorWidget: (_, _, _) => Container(
              width: width,
              height: width * 0.48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFFC),
                borderRadius: BorderRadius.circular(14),
              ),
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

class _TelegramDateDivider extends StatelessWidget {
  const _TelegramDateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFB8C7DA).withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _chatDateLabel(date),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _TelegramLogoAvatar extends StatelessWidget {
  const _TelegramLogoAvatar({required this.radius});

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

class _TelegramAvatar extends StatelessWidget {
  const _TelegramAvatar({required this.user});

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
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: Color(0xFF2AABEE),
                size: 34,
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

int _messageListLength(List<AppMessage> messages) {
  var length = 0;
  DateTime? lastDate;
  for (final message in messages) {
    final date = _dateOnly(message.createdAt ?? DateTime.now());
    if (lastDate == null || date != lastDate) {
      length++;
      lastDate = date;
    }
    length++;
  }
  return length;
}

Object _messageListItem(List<AppMessage> messages, int index) {
  var cursor = 0;
  DateTime? lastDate;
  for (final message in messages) {
    final date = _dateOnly(message.createdAt ?? DateTime.now());
    if (lastDate == null || date != lastDate) {
      if (cursor == index) return date;
      cursor++;
      lastDate = date;
    }
    if (cursor == index) return message;
    cursor++;
  }
  return messages.last;
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

String _chatTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _chatDateLabel(DateTime value) {
  final now = DateTime.now();
  final today = _dateOnly(now);
  final date = _dateOnly(value.toLocal());
  if (date == today) return 'Today';
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${date.day}/${date.month}/${date.year}';
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
