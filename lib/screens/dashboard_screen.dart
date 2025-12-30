import 'package:flutter/material.dart';
import 'form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Map<String, String>> services = const [
    {'name': 'Resident Certificate', 'icon': 'landscape'},
    {'name': 'Scheduled Caste Certificate', 'icon': 'people'},
    {'name': 'Income Certificate', 'icon': 'payments'},
    {'name': 'Legal Heir', 'icon': 'gavel'},
    {'name': 'Sebc Certificate', 'icon': 'people'},
    {'name': 'Scheduled Tribe Certificate', 'icon': 'sentiment_very_dissatisfied'},
    {'name': 'Guardianship Certificate', 'icon': 'favorite'},
    {'name': 'OBC Certificate', 'icon': 'badge'},
    {'name': 'Income Asset Certificate', 'icon': 'account_balance_wallet'},
  ];

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Instructions'),
        content: const Text(
          '1. Ensure all documents are scanned.\n'
          '2. Photo size must be < 200KB.\n'
          '3. Documents must be in JPG or PDF format.\n'
          '4. Verify details before final submission.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ResidentCertificateForm()));
            },
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services Portal')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () => _showInstructions(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    services[index]['name']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
