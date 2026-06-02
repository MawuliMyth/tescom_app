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
    return ListTile(
      tileColor: Colors.white,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8ECFF),
        backgroundImage: AssetImage('assets/images/logo.png'),
      ),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        _latestMessagePreview(latest),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
      trailing: Text(
        _chatTime(latest?.createdAt ?? conversation.updatedAt),
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 11,
          letterSpacing: 0,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          _adaptivePageRoute(
            context,
            builder: (_) => _ChatThreadPage(conversation: conversation),
          ),
        );
      },
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
  late Future<List<AppMessage>> messagesFuture;
  late Future<AppUser?> userFuture;
  bool sending = false;

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
                sending: sending,
                onSend: sendMessage,
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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
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
              _messageText(message),
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _chatTime(message.createdAt),
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
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        color: Colors.white,
        child: Row(
          children: [
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
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF34368C),
                foregroundColor: Colors.white,
              ),
              onPressed: sending ? null : onSend,
              icon: Icon(
                sending ? Icons.hourglass_top_rounded : Icons.send_rounded,
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
  if (message.mediaUrl?.trim().isNotEmpty == true) return 'Media message';
  return '';
}

String _latestMessagePreview(AppMessage? message) {
  if (message == null) return 'No messages yet';
  return _messageText(message);
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
