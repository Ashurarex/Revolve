import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/issue_model.dart';

class IssueService extends ChangeNotifier {
  final _uuid = const Uuid();
  final List<Issue> _issues = [];
  bool _isLoading = false;

  List<Issue> get issues => List.unmodifiable(_issues);
  bool get isLoading => _isLoading;

  void bootstrap() {
    // Seed with a few mock issues so Map/Admin/Home show data
    if (_issues.isNotEmpty) return;
    _issues.addAll([
      Issue(
        id: _uuid.v4(),
        title: 'Pothole near Community Park',
        description: 'Large pothole causing traffic and two-wheeler skids.',
        category: IssueCategory.road,
        status: IssueStatus.unresolved,
        latitude: 15.2993 + _rand(), // around Goa for your default
        longitude: 74.1240 + _rand(),
        address: 'Community Park Rd, Panaji',
        reporterId: 'demo',
        reporterName: 'Demo User',
        reporterEmail: 'demo@citypulse.app',
        imageUrls: const [
          'https://images.unsplash.com/photo-1564760582623-1e9b79c8392b?auto=format&fit=crop&w=800&q=60'
        ],
        upvotes: 12,
        comments: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Issue(
        id: _uuid.v4(),
        title: 'Streetlight not working',
        description: 'Dark stretch near Block C. Needs bulb replacement.',
        category: IssueCategory.lighting,
        status: IssueStatus.inProgress,
        latitude: 15.2993 + _rand(),
        longitude: 74.1240 + _rand(),
        address: 'Block C, Ribandar',
        reporterId: 'demo',
        reporterName: 'Meera',
        reporterEmail: 'meera@citypulse.app',
        imageUrls: const [
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=60'
        ],
        upvotes: 7,
        comments: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Issue(
        id: _uuid.v4(),
        title: 'Overflowing garbage bin',
        description: 'Requires urgent pick-up; foul smell nearby.',
        category: IssueCategory.sanitation,
        status: IssueStatus.resolved,
        latitude: 15.2993 + _rand(),
        longitude: 74.1240 + _rand(),
        address: 'Market Lane, Panaji',
        reporterId: 'demo',
        reporterName: 'Arun',
        reporterEmail: 'arun@citypulse.app',
        imageUrls: const [
          'https://images.unsplash.com/photo-1520975922284-5f1a6f9f6f5e?auto=format&fit=crop&w=800&q=60'
        ],
        upvotes: 20,
        comments: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  double _rand() => (Random().nextDouble() - 0.5) * 0.02;

  Future<void> fetchIssues() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createIssue({
    required String title,
    required String description,
    required IssueCategory category,
    required double latitude,
    required double longitude,
    required String address,
    required String reporterId,
    required String reporterName,
    required String reporterEmail,
    required List<dynamic> images, // File list in your screen; we mock upload
  }) async {
    // In mock mode, just attach the first placeholder URL
    final newIssue = Issue(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      status: IssueStatus.unresolved,
      latitude: latitude,
      longitude: longitude,
      address: address,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterEmail: reporterEmail,
      imageUrls: const [
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=60'
      ],
      upvotes: 0,
      comments: const [],
      createdAt: DateTime.now(),
    );
    _issues.insert(0, newIssue);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // no error
  }

  Future<String?> updateIssueStatus(String issueId, IssueStatus status) async {
    final idx = _issues.indexWhere((e) => e.id == issueId);
    if (idx == -1) return 'Issue not found';
    _issues[idx] = _issues[idx].copyWith(
      status: status,
      resolvedAt: status == IssueStatus.resolved ? DateTime.now() : null,
    );
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 150));
    return null;
  }

  Map<String, dynamic> getAnalytics() {
    final total = _issues.length;
    final resolved =
        _issues.where((i) => i.status == IssueStatus.resolved).length;
    final inProgress =
        _issues.where((i) => i.status == IssueStatus.inProgress).length;
    final unresolved =
        _issues.where((i) => i.status == IssueStatus.unresolved).length;

    // Average resolution days
    final resolvedItems = _issues.where((i) => i.resolvedAt != null).toList();
    final avgResolutionDays = resolvedItems.isEmpty
        ? 0.0
        : resolvedItems
                .map(
                    (i) => i.resolvedAt!.difference(i.createdAt).inHours / 24.0)
                .reduce((a, b) => a + b) /
            resolvedItems.length;

    // Category counts
    final Map<String, int> categoryCount = {};
    for (final i in _issues) {
      final key = i.category.name;
      categoryCount[key] = (categoryCount[key] ?? 0) + 1;
    }

    return {
      'total': total,
      'resolved': resolved,
      'inProgress': inProgress,
      'unresolved': unresolved,
      'avgResolutionDays': avgResolutionDays,
      'categoryCount': categoryCount,
    };
  }
}
