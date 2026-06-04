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
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateChatDialog(),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_chatError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34368C),
        foregroundColor: Colors.white,
        title: Text(
          'Chats',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: createConversation,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AppConversation>>(
        future: conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(18),
              child: _ListShimmer(itemCount: 6),
            );
          }
          if (snapshot.hasError) return const _InlineErrorState();

          final conversations = snapshot.data ?? const [];
          if (conversations.isEmpty) {
            return RefreshIndicator.noSpinner(
              onRefresh: refresh,
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 420,
                  child: _ChatEmptyState(
                    title: 'No chats yet',
                    message: 'Create a chat to start a conversation.',
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator.noSpinner(
            onRefresh: refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _ConversationTile(conversation: conversations[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CreateChatDialog extends StatefulWidget {
  const _CreateChatDialog();

  @override
  State<_CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends State<_CreateChatDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New chat'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Chat title',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final AppConversation conversation;

  @override
  Widget build(BuildContext context) {
    final latest = conversation.latestMessage;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            _adaptivePageRoute(
              context,
              builder: (_) => _ChatThreadPage(conversation: conversation),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE8ECFF),
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _latestMessagePreview(latest),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 42,
                child: Text(
                  _chatTime(latest?.createdAt ?? conversation.updatedAt),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
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
  final scrollController = ScrollController();
  final imagePicker = ImagePicker();
  late Future<List<AppMessage>> messagesFuture;
  late Future<AppUser?> userFuture;
  bool sending = false;
  bool attaching = false;

  @override
  void initState() {
    super.initState();
    userFuture = AppRepository().loadCurrentUser();
    messagesFuture = AppRepository().loadConversationMessages(
      widget.conversation.id,
    );
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

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;

    controller.clear();
    setState(() => sending = true);
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
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> attachMedia({required bool video}) async {
    if (attaching || sending) return;
    try {
      final picked = video
          ? await imagePicker.pickVideo(source: ImageSource.gallery)
          : await imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 88,
            );
      if (picked == null) return;
      setState(() => attaching = true);
      final upload = await AppRepository().uploadChatMedia(
        filename: picked.name,
        bytes: await picked.readAsBytes(),
        contentType:
            picked.mimeType ?? _mediaTypeFromFilename(picked.name, video),
      );
      await AppRepository().sendConversationMessage(
        conversationId: widget.conversation.id,
        mediaUrl: upload.url,
        mediaType: upload.contentType,
      );
      await refreshMessages();
      scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_chatError(error))));
    } finally {
      if (mounted) setState(() => attaching = false);
    }
  }

  Future<void> inviteMember() async {
    try {
      final members = await AppRepository().loadMembers();
      if (!mounted) return;
      final invitedIds = widget.conversation.participants
          .map((participant) => participant.userId)
          .toSet();
      final available = members
          .where((member) => !invitedIds.contains(member.id))
          .toList(growable: false);
      final selected = await showModalBottomSheet<AppUser>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (_) => _InviteMemberSheet(members: available),
      );
      if (selected == null) return;
      await AppRepository().addConversationParticipant(
        conversationId: widget.conversation.id,
        userId: selected.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selected.fullName} was invited.')),
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
    return FutureBuilder<AppUser?>(
      future: userFuture,
      builder: (context, userSnapshot) {
        final currentUserId = userSnapshot.data?.id;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFF34368C),
            foregroundColor: Colors.white,
            title: Text(
              widget.conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Invite member',
                onPressed: inviteMember,
                icon: const Icon(Icons.person_add_alt_1_rounded),
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
                        padding: EdgeInsets.all(18),
                        child: _ListShimmer(itemCount: 6),
                      );
                    }
                    if (snapshot.hasError) return const _InlineErrorState();

                    final messages = snapshot.data ?? const [];
                    if (messages.isEmpty) {
                      return const _ChatEmptyState(
                        title: 'No messages yet',
                        message: 'Send the first message.',
                      );
                    }

                    scrollToBottom();
                    return RefreshIndicator.noSpinner(
                      onRefresh: refreshMessages,
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
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
              _MessageInput(
                controller: controller,
                sending: sending || attaching,
                onSend: sendMessage,
                onAttachImage: () => attachMedia(video: false),
                onAttachVideo: () => attachMedia(video: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final AppMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = (constraints.maxWidth * 0.74).clamp(150.0, 320.0);
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE8ECFF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.author?.fullName ?? 'Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34368C),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                Text(
                  _wrapChatText(_messageText(message)),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
                if (_hasMedia(message)) ...[
                  if (message.body.trim().isNotEmpty) const SizedBox(height: 8),
                  _MessageMedia(message: message),
                ],
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _chatTime(message.createdAt),
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onAttachImage,
    required this.onAttachVideo,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onAttachImage;
  final VoidCallback onAttachVideo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PopupMenuButton<String>(
              tooltip: 'Attach media',
              enabled: !sending,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF34368C),
              ),
              onSelected: (value) {
                if (value == 'image') onAttachImage();
                if (value == 'video') onAttachVideo();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'image', child: Text('Image')),
                PopupMenuItem(value: 'video', child: Text('Video')),
              ],
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: sending ? null : onSend,
              icon: Icon(
                sending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: const Color(0xFF34368C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageMedia extends StatelessWidget {
  const _MessageMedia({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    final url = message.mediaUrl;
    if (url == null || url.trim().isEmpty) return const SizedBox.shrink();
    if (_isImageMessage(message)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: ApiConfig.mediaUrl(url),
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, _) =>
              const SizedBox(height: 150, child: _ListShimmer(itemCount: 1)),
          errorWidget: (_, _, _) => const SizedBox(
            height: 120,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.play_circle_outline_rounded,
            color: Color(0xFF34368C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Video attachment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteMemberSheet extends StatelessWidget {
  const _InviteMemberSheet({required this.members});

  final List<AppUser> members;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Invite member',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              const _ChatEmptyState(
                title: 'No members available',
                message: 'Everyone visible to you is already in this chat.',
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8ECFF),
                        backgroundImage: _chatAvatarProvider(member),
                      ),
                      title: Text(
                        member.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        member.institution ?? member.organizationRole ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(context, member),
                    );
                  },
                ),
              ),
          ],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF34368C),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _messageText(AppMessage message) {
  if (message.body.trim().isNotEmpty) return message.body;
  if (_isImageMessage(message)) return 'Image';
  if (message.mediaUrl?.trim().isNotEmpty == true) return 'Video';
  return '';
}

String _latestMessagePreview(AppMessage? message) {
  if (message == null) return 'No messages yet';
  return _messageText(message);
}

String _wrapChatText(String value) {
  return value
      .split(' ')
      .map((word) {
        if (word.length <= 28) return word;
        final chunks = <String>[];
        for (var index = 0; index < word.length; index += 18) {
          final end = (index + 18).clamp(0, word.length);
          chunks.add(word.substring(index, end));
        }
        return chunks.join(' ');
      })
      .join(' ');
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

String _chatTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

bool _hasMedia(AppMessage message) =>
    message.mediaUrl != null && message.mediaUrl!.trim().isNotEmpty;

bool _isImageMessage(AppMessage message) =>
    _hasMedia(message) &&
    (message.mediaType?.startsWith('image/') == true ||
        RegExp(
          r'\.(jpe?g|png|webp|gif)$',
          caseSensitive: false,
        ).hasMatch(message.mediaUrl!));

ImageProvider _chatAvatarProvider(AppUser member) {
  final avatar = member.avatarUrl;
  if (avatar != null && avatar.trim().isNotEmpty) {
    return CachedNetworkImageProvider(ApiConfig.mediaUrl(avatar));
  }
  return const AssetImage('assets/images/logo.png');
}

String _mediaTypeFromFilename(String filename, bool video) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.mp4')) return 'video/mp4';
  if (lower.endsWith('.webm')) return 'video/webm';
  if (lower.endsWith('.mov')) return 'video/quicktime';
  return video ? 'video/mp4' : 'image/jpeg';
}
