enum IssueCategory { road, sanitation, lighting, water, electricity, other }

enum IssueStatus { unresolved, inProgress, resolved }

class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
}

class Issue {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  IssueStatus status;

  final double latitude;
  final double longitude;
  final String address;

  final String reporterId;
  final String reporterName;
  final String reporterEmail;

  final List<String> imageUrls;
  int upvotes;
  final List<Comment> comments;

  final DateTime createdAt;
  DateTime? resolvedAt;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = IssueStatus.unresolved,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.reporterId,
    required this.reporterName,
    required this.reporterEmail,
    this.imageUrls = const [],
    this.upvotes = 0,
    this.comments = const [],
    required this.createdAt,
    this.resolvedAt,
  });

  Issue copyWith({
    IssueStatus? status,
    int? upvotes,
    DateTime? resolvedAt,
  }) {
    return Issue(
      id: id,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      latitude: latitude,
      longitude: longitude,
      address: address,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterEmail: reporterEmail,
      imageUrls: imageUrls,
      upvotes: upvotes ?? this.upvotes,
      comments: comments,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
