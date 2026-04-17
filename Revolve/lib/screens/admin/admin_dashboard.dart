import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/auth_service.dart';
import '../../../services/issue_service.dart';
import '../../../models/issue_model.dart';
import 'package:intl/intl.dart';

/// Admin dashboard for managing issues and viewing analytics
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IssueService>(context, listen: false).fetchIssues();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Check if user has admin/moderator access
    if (!authService.isAdminOrModerator) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to access this page'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manage Issues'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ManageIssuesTab(),
          _AnalyticsTab(),
        ],
      ),
    );
  }
}

/// Tab for managing issues
class _ManageIssuesTab extends StatelessWidget {
  const _ManageIssuesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueService>(
      builder: (context, issueService, child) {
        if (issueService.isLoading && issueService.issues.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (issueService.issues.isEmpty) {
          return const Center(
            child: Text('No issues to manage'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: issueService.issues.length,
          itemBuilder: (context, index) {
            final issue = issueService.issues[index];
            return _AdminIssueCard(issue: issue);
          },
        );
      },
    );
  }
}

/// Card for managing individual issues
class _AdminIssueCard extends StatelessWidget {
  final Issue issue;

  const _AdminIssueCard({required this.issue});

  Color _getStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.inProgress:
        return Colors.orange;
      case IssueStatus.unresolved:
        return Colors.red;
    }
  }

  Future<void> _updateStatus(
      BuildContext context, IssueStatus newStatus) async {
    final issueService = Provider.of<IssueService>(context, listen: false);

    final error = await issueService.updateIssueStatus(issue.id, newStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Status updated successfully',
          ),
          backgroundColor: error != null ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    issue.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(issue.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Issue details
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  issue.category.name.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(issue.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reporter info
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Reported by ${issue.reporterName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Upvotes
            Row(
              children: [
                Icon(Icons.thumb_up_outlined,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${issue.upvotes} upvotes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              children: [
                if (issue.status != IssueStatus.inProgress)
                  ActionChip(
                    label: const Text('In Progress'),
                    onPressed: () =>
                        _updateStatus(context, IssueStatus.inProgress),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.orange),
                  ),
                if (issue.status != IssueStatus.resolved)
                  ActionChip(
                    label: const Text('Resolve'),
                    onPressed: () =>
                        _updateStatus(context, IssueStatus.resolved),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
                if (issue.status != IssueStatus.unresolved)
                  ActionChip(
                    label: const Text('Reopen'),
                    onPressed: () =>
                        _updateStatus(context, IssueStatus.unresolved),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab for analytics and statistics
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueService>(
      builder: (context, issueService, child) {
        final analytics = issueService.getAnalytics();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Issues',
                      value: analytics['total'].toString(),
                      color: const Color(0xFF2196F3),
                      icon: Icons.report,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Resolved',
                      value: analytics['resolved'].toString(),
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'In Progress',
                      value: analytics['inProgress'].toString(),
                      color: Colors.orange,
                      icon: Icons.hourglass_empty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Unresolved',
                      value: analytics['unresolved'].toString(),
                      color: Colors.red,
                      icon: Icons.error_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Average resolution time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Average Resolution Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${analytics['avgResolutionDays'].toStringAsFixed(1)} days',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category distribution chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Issues by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: _CategoryChart(
                          categoryCount:
                              analytics['categoryCount'] as Map<String, int>,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category distribution bar chart
class _CategoryChart extends StatelessWidget {
  final Map<String, int> categoryCount;

  const _CategoryChart({required this.categoryCount});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: categoryCount.values.isEmpty
            ? 10
            : categoryCount.values.reduce((a, b) => a > b ? a : b).toDouble() +
                5,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final categories = categoryCount.keys.toList();
                if (value.toInt() >= categories.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    categories[value.toInt()].toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: categoryCount.entries.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: const Color(0xFF2196F3),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
