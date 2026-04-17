import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/issue_service.dart';
import '../../../widgets/issue_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CityPulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.pushNamed(context, '/map'),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/admin'),
          ),
        ],
      ),
      body: Consumer<IssueService>(
        builder: (context, data, _) {
          if (data.isLoading && data.issues.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.issues.isEmpty) {
            return const Center(
                child: Text('No issues yet. Report the first one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.issues.length,
            itemBuilder: (context, i) => IssueCard(
              issue: data.issues[i],
              onTap: () {}, // hook up to a detail page later
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/report'),
        icon: const Icon(Icons.add),
        label: const Text('Report'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
    );
  }
}
