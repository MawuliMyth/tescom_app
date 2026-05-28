class AppBootstrap {
  const AppBootstrap({
    required this.news,
    required this.events,
    required this.announcements,
    required this.jobs,
  });

  final List<AppNewsArticle> news;
  final List<AppEvent> events;
  final List<AppAnnouncement> announcements;
  final List<AppJob> jobs;

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    return AppBootstrap(
      news: _list(json['news'], AppNewsArticle.fromJson),
      events: _list(json['events'], AppEvent.fromJson),
      announcements: _list(json['announcements'], AppAnnouncement.fromJson),
      jobs: _list(json['jobs'], AppJob.fromJson),
    );
  }
}

class AppNewsArticle {
  const AppNewsArticle({
    required this.title,
    required this.summary,
    required this.body,
    this.category,
    this.imageUrl,
    this.publishedAt,
    this.createdAt,
  });

  final String title;
  final String summary;
  final String body;
  final String? category;
  final String? imageUrl;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory AppNewsArticle.fromJson(Map<String, dynamic> json) {
    return AppNewsArticle(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: _date(json['publishedAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppEvent {
  const AppEvent({
    required this.title,
    required this.description,
    required this.venue,
    required this.startsAt,
    this.endsAt,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String venue;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? imageUrl;

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      startsAt: _date(json['startsAt']) ?? DateTime.now(),
      endsAt: _date(json['endsAt']),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class AppAnnouncement {
  const AppAnnouncement({
    required this.title,
    required this.body,
    required this.priority,
    this.publishedAt,
    this.createdAt,
  });

  final String title;
  final String body;
  final String priority;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  factory AppAnnouncement.fromJson(Map<String, dynamic> json) {
    return AppAnnouncement(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      publishedAt: _date(json['publishedAt']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AppJob {
  const AppJob({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    this.applyUrl,
    this.deadline,
  });

  final String title;
  final String company;
  final String location;
  final String type;
  final String description;
  final String? applyUrl;
  final DateTime? deadline;

  factory AppJob.fromJson(Map<String, dynamic> json) {
    return AppJob(
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      applyUrl: json['applyUrl'] as String?,
      deadline: _date(json['deadline']),
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
