class AppBootstrap {
  const AppBootstrap({
    required this.news,
    required this.events,
    required this.announcements,
    required this.jobs,
    required this.chapters,
    required this.polls,
  });

  final List<AppNewsArticle> news;
  final List<AppEvent> events;
  final List<AppAnnouncement> announcements;
  final List<AppJob> jobs;
  final List<AppChapter> chapters;
  final List<AppPoll> polls;

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    return AppBootstrap(
      news: _list(json['news'], AppNewsArticle.fromJson),
      events: _list(json['events'], AppEvent.fromJson),
      announcements: _list(json['announcements'], AppAnnouncement.fromJson),
      jobs: _list(json['jobs'], AppJob.fromJson),
      chapters: _list(json['chapters'], AppChapter.fromJson),
      polls: _list(json['polls'], AppPoll.fromJson),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.institution,
    this.avatarUrl,
    this.bio,
    this.organizationRole,
    this.chapterId,
    this.status,
    this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? institution;
  final String? avatarUrl;
  final String? bio;
  final String? organizationRole;
  final String? chapterId;
  final String? status;
  final DateTime? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
      institution: json['institution'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      organizationRole: json['organizationRole'] as String?,
      chapterId: json['chapterId'] as String?,
      status: json['status'] as String?,
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppChapter {
  const AppChapter({
    required this.id,
    required this.name,
    required this.campus,
    this.region,
    this.description,
    this.logoUrl,
    this.membersCount = 0,
    this.executivesCount = 0,
    this.eventsCount = 0,
  });

  final String id;
  final String name;
  final String campus;
  final String? region;
  final String? description;
  final String? logoUrl;
  final int membersCount;
  final int executivesCount;
  final int eventsCount;

  factory AppChapter.fromJson(Map<String, dynamic> json) {
    return AppChapter(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      campus: json['campus'] as String? ?? '',
      region: json['region'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      membersCount: json['membersCount'] as int? ?? 0,
      executivesCount: json['executivesCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
    );
  }
}

class AppNewsArticle {
  const AppNewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    this.category,
    this.imageUrl,
    this.imageUrls = const [],
    this.publishedAt,
    this.createdAt,
  });

  final String title;
  final String id;
  final String summary;
  final String body;
  final String? category;
  final String? imageUrl;
  final List<String> imageUrls;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory AppNewsArticle.fromJson(Map<String, dynamic> json) {
    return AppNewsArticle(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: _stringList(json['imageUrls']),
      publishedAt: _date(json['publishedAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppEvent {
  const AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.startsAt,
    this.organizer = '',
    this.venueNote,
    this.endsAt,
    this.feeLabel = '',
    this.chatUrl,
    this.imageUrl,
    this.imageUrls = const [],
    this.chapterId,
  });

  final String title;
  final String id;
  final String description;
  final String organizer;
  final String venue;
  final String? venueNote;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String feeLabel;
  final String? chatUrl;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? chapterId;

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      venueNote: json['venueNote'] as String?,
      startsAt: _date(json['startsAt']) ?? DateTime.now(),
      endsAt: _date(json['endsAt']),
      feeLabel: json['feeLabel'] as String? ?? '',
      chatUrl: json['chatUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: _stringList(json['imageUrls']),
      chapterId: json['chapterId'] as String?,
    );
  }
}

class AppAnnouncement {
  const AppAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    this.publishedAt,
    this.createdAt,
  });

  final String title;
  final String id;
  final String body;
  final String priority;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory AppAnnouncement.fromJson(Map<String, dynamic> json) {
    return AppAnnouncement(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      publishedAt: _date(json['publishedAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppJob {
  const AppJob({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    this.logoUrl,
    this.applyUrl,
    this.deadline,
  });

  final String title;
  final String id;
  final String company;
  final String location;
  final String type;
  final String description;
  final String? logoUrl;
  final String? applyUrl;
  final DateTime? deadline;

  factory AppJob.fromJson(Map<String, dynamic> json) {
    return AppJob(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      applyUrl: json['applyUrl'] as String?,
      deadline: _date(json['deadline']),
    );
  }
}

class AppPoll {
  const AppPoll({
    required this.id,
    required this.question,
    required this.options,
    this.description,
    this.closesAt,
  });

  final String id;
  final String question;
  final String? description;
  final DateTime? closesAt;
  final List<AppPollOption> options;

  factory AppPoll.fromJson(Map<String, dynamic> json) {
    return AppPoll(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      description: json['description'] as String?,
      closesAt: _date(json['closesAt']),
      options: _list(json['options'], AppPollOption.fromJson),
    );
  }
}

class AppPollOption {
  const AppPollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
  });

  final String id;
  final String text;
  final int voteCount;

  factory AppPollOption.fromJson(Map<String, dynamic> json) {
    return AppPollOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      voteCount: json['_count'] is Map<String, dynamic>
          ? ((json['_count'] as Map<String, dynamic>)['votes'] as int? ?? 0)
          : 0,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      readAt: _date(json['readAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppConversation {
  const AppConversation({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.messages,
    this.updatedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final bool isGroup;
  final List<AppMessage> messages;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  AppMessage? get latestMessage => messages.isEmpty ? null : messages.last;

  factory AppConversation.fromJson(Map<String, dynamic> json) {
    return AppConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isGroup: json['isGroup'] as bool? ?? true,
      messages: _list(json['messages'], AppMessage.fromJson),
      updatedAt: _date(json['updatedAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppMessage {
  const AppMessage({
    required this.id,
    required this.body,
    required this.authorId,
    this.author,
    this.createdAt,
  });

  final String id;
  final String body;
  final String authorId;
  final AppUser? author;
  final DateTime? createdAt;

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      author: json['author'] is Map<String, dynamic>
          ? AppUser.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppSavedItem {
  const AppSavedItem({
    required this.id,
    required this.itemType,
    required this.itemId,
    this.createdAt,
  });

  final String id;
  final String itemType;
  final String itemId;
  final DateTime? createdAt;

  factory AppSavedItem.fromJson(Map<String, dynamic> json) {
    return AppSavedItem(
      id: json['id'] as String? ?? '',
      itemType: json['itemType'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      createdAt: _date(json['createdAt']),
    );
  }
}

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

DateTime? _date(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}
