import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'form_screen.dart';
import 'form_screen_income.dart';
import 'login_screen.dart';

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

  final List<String> completedServices = const [
    'Resident Certificate',
    'Income Certificate',
  ];

  void _handleServiceTap(BuildContext context, String serviceName) {
    if (completedServices.contains(serviceName)) {
      _showInstructions(context, serviceName);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Under Development'),
            content: Text(
              '$serviceName is currently under development.\n\n'
                  'please comeback later',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
              ),
            ],
          ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.clearToken();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }


  void _showInstructions(BuildContext context, String serviceName) {
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
              if (serviceName == 'Resident Certificate') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResidentCertificateForm(),
                  ),
                );
              } else if (serviceName == 'Income Certificate') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncomeCertificateForm(),
                  ),
                );
              }},

            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services Dashboard'),
        actions: [
          IconButton(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {

          final serviceName = services[index]['name']!;
          final isCompleted = completedServices.contains(serviceName);


          return Card(
            elevation: 4,
            color: isCompleted ? null : Colors.grey.shade300,
            child: InkWell(
              onTap: () => _handleServiceTap(context, serviceName),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          Icons.description,
                          size: 40,
                          color: isCompleted ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        serviceName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],

                  ),
                  if(!isCompleted)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ),
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
