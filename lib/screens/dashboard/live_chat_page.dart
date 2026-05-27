part of '../dashboard_screen.dart';

// Live chat room list inspired by the supplied reference, using app colors.
class _LiveChatPage extends StatelessWidget {
  const _LiveChatPage();

  static const members = [
    _RoomMember(
      name: 'Chris',
      imagePath: 'assets/images/suit.png',
      online: true,
    ),
    _RoomMember(
      name: 'Ama',
      imagePath: 'assets/images/white.png',
      online: true,
    ),
    _RoomMember(
      name: 'Kojo',
      imagePath: 'assets/images/man.png',
      online: false,
    ),
    _RoomMember(
      name: 'Joseph',
      imagePath: 'assets/images/yellow.png',
      online: true,
    ),
    _RoomMember(
      name: 'Akua',
      imagePath: 'assets/images/ladies.png',
      online: false,
    ),
  ];

  static const conversations = [
    _RoomConversation(
      name: 'National Room',
      message: 'Welcome to the TESCON national chat.',
      time: '9:30 PM',
      imagePath: 'assets/images/logo.png',
      unread: true,
    ),
    _RoomConversation(
      name: 'Central University',
      message: 'Chapter is ready for the upcoming event.',
      time: '9:11 PM',
      imagePath: 'assets/images/cu.jpg',
      unread: false,
    ),
    _RoomConversation(
      name: 'Executives Room',
      message: 'Meeting notes have been shared.',
      time: 'Friday',
      imagePath: 'assets/images/suit.png',
      unread: false,
    ),
    _RoomConversation(
      name: 'Campus Events',
      message: 'Sent an attachment',
      time: '23 Mar',
      imagePath: 'assets/images/give.png',
      unread: false,
    ),
    _RoomConversation(
      name: 'Opportunities Desk',
      message: 'New internship update posted.',
      time: '12 Mar',
      imagePath: 'assets/images/card.png',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: _AppScaffoldBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
            children: [
              _WhatsAppHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 14),
              const _ChatSearchField(),
              const SizedBox(height: 12),
              ...conversations.map(
                (conversation) => _WhatsAppConversationTile(
                  conversation: conversation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Lightweight model for the horizontal active-member avatars.
class _RoomMember {
  const _RoomMember({
    required this.name,
    required this.imagePath,
    required this.online,
  });

  final String name;
  final String imagePath;
  final bool online;
}

// Lightweight model for the conversation cards.
class _RoomConversation {
  const _RoomConversation({
    required this.name,
    required this.message,
    required this.time,
    required this.imagePath,
    required this.unread,
  });

  final String name;
  final String message;
  final String time;
  final String imagePath;
  final bool unread;
}

// WhatsApp-style top header.
class _WhatsAppHeader extends StatelessWidget {
  const _WhatsAppHeader({required this.onBack});

  final VoidCallback onBack;

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
        _PlainIconButton(
          icon: Icons.more_vert_rounded,
          onTap: () => _showDemoSheet(
            context,
            title: 'Chat Actions',
            message: 'Chat settings and broadcast tools open here.',
          ),
        ),
      ],
    );
  }
}

// Search field used above the WhatsApp-style chat list.
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

// Horizontal avatar strip for online and recent participants.
class _OnlineMembersStrip extends StatelessWidget {
  const _OnlineMembersStrip({required this.members});

  final List<_RoomMember> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _OnlineMemberAvatar(member: members[index]);
        },
      ),
    );
  }
}

class _OnlineMemberAvatar extends StatelessWidget {
  const _OnlineMemberAvatar({required this.member});

  final _RoomMember member;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF34368C),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(member.imagePath),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: member.online
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFC7C7C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// WhatsApp-style conversation row with divider.
class _WhatsAppConversationTile extends StatelessWidget {
  const _WhatsAppConversationTile({required this.conversation});

  final _RoomConversation conversation;

  @override
  Widget build(BuildContext context) {
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(conversation.imagePath),
                ),
                if (conversation.unread)
                  Positioned(
                    right: 1,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE8E8EF)),
                  ),
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
                              conversation.name,
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
                            conversation.time,
                            style: GoogleFonts.inter(
                              color: conversation.unread
                                  ? const Color(0xFF34368C)
                                  : const Color(0xFF8A8A8A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                              conversation.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF666666),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          if (conversation.unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 21,
                              height: 21,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34368C),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '1',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ],
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

// Simple thread page opened from a room tile.
class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({required this.conversation});

  final _RoomConversation conversation;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final controller = TextEditingController();
  final messages = <_ChatMessage>[];

  @override
  void initState() {
    super.initState();
    messages.addAll([
      _ChatMessage(
        sender: widget.conversation.name,
        text: widget.conversation.message,
        mine: false,
      ),
      const _ChatMessage(
        sender: 'You',
        text: 'Thanks. Please keep the room updated.',
        mine: true,
      ),
    ]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          widget.conversation.name,
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
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: messages[index]);
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
                      icon: Icons.send_rounded,
                      onTap: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          messages.add(_ChatMessage(
                            sender: 'You',
                            text: text,
                            mine: true,
                          ));
                        });
                        controller.clear();
                      },
                    ),
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

class _ChatMessage {
  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.mine,
  });

  final String sender;
  final String text;
  final bool mine;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: _AppSurface(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        opacity: message.mine ? 0.92 : 0.62,
        child: Column(
          crossAxisAlignment:
              message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: GoogleFonts.inter(
                color: message.mine
                    ? const Color(0xFF34368C)
                    : const Color(0xFF777777),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
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
