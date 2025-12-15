import 'package:flutter/material.dart';
import 'dart:convert';

class AcknowledgementScreen extends StatelessWidget {
  final String applicationId;
  final Map<String, dynamic> jsonData;

  const AcknowledgementScreen({
    super.key,
    required this.applicationId,
    required this.jsonData,
  });

  /// Creates a deep copy of the JSON data and removes large Base64 strings for safe display.
  Map<String, dynamic> _getSanitizedJson() {
    final copy = json.decode(json.encode(jsonData)); // Deep copy
    
    // Sanitize photo
    if (copy['personalDetails']?['photoBase64'] != null) {
      copy['personalDetails']['photoBase64'] = '[Image data removed for preview]';
    }

    // Sanitize document
    if (copy['supportingDocumentBase64'] != null) {
      copy['supportingDocumentBase64'] = '[Document data removed for preview]';
    }
    
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acknowledgement'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Application Submitted Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    const Text('Your Application ID', style: TextStyle(fontSize: 14)),
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
                'An acknowledgement will be sent to your registered mobile number and email.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('JSON Data for API'),
                      content: SingleChildScrollView(
                        child: SelectableText(
                          const JsonEncoder.withIndent('  ').convert(_getSanitizedJson()),
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('View JSON Data (Preview)'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
