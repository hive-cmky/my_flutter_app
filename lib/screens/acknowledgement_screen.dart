import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AcknowledgementScreen extends StatelessWidget {
  final String applicationId;
  final Map<String, dynamic> jsonData;

  const AcknowledgementScreen({
    super.key,
    required this.applicationId,
    required this.jsonData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acknowledgement Slip'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),

              // Success Message
              const Text(
                'Application Submitted Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Application ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text('Your Application Reference Number', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    const SizedBox(height: 8),
                    Text(
                      applicationId,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'An acknowledgement has been sent to your registered mobile number and email. Please keep the reference number for future tracking.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Force navigation back to the Dashboard (Service List)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                  child: const Text('Go to Home', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
