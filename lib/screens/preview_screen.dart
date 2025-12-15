import 'package:flutter/material.dart';
import 'dart:convert';
import 'acknowledgement_screen.dart';

class FormPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  const FormPreviewScreen({super.key, required this.formData});

  /// Creates a deep copy of the JSON data and removes large Base64 strings for safe display.
  Map<String, dynamic> _getSanitizedJson(Map<String, dynamic> originalData) {
    final copy = json.decode(json.encode(originalData)); // Deep copy
    
    // Sanitize photo
    if (copy['photoBase64'] != null) {
      copy['photoBase64'] = '[Image data included]';
    }

    // Sanitize document
    if (copy['supportingDocumentBase64'] != null) {
      copy['supportingDocumentBase64'] = '[Document data included]';
    }
    
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Use the sanitized data for display
          _buildSection('PERSONAL DETAILS', _getSanitizedJson(formData['personalDetails'] ?? {})),
          const SizedBox(height: 16),

          _buildSection('PRESENT ADDRESS', formData['presentAddress'] ?? {}),
          const SizedBox(height: 16),

          _buildSection('PERMANENT ADDRESS', formData['permanentAddress'] ?? {}),
          const SizedBox(height: 16),

          _buildSection('GUARDIAN DETAILS', formData['guardianDetails'] ?? {}),
          const SizedBox(height: 16),

          const Text('PURPOSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formData['purpose'] ?? ''),
          const SizedBox(height: 16),

          const Text('SUPPORTING DOCUMENT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formData['supportingDocumentName'] != null
              ? 'Uploaded: ${formData['supportingDocumentName']}'
              : 'Not uploaded'),
          const SizedBox(height: 16),

          const Text('DECLARATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Place: ${formData['declaration']?['place'] ?? ''}'),
          Text('Date: ${formData['declaration']?['date'] ?? ''}'),
          Text('Agreed: ${formData['declaration']?['agreed'] == true ? 'Yes' : 'No'}'),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final appId = 'RC${DateTime.now().millisecondsSinceEpoch}';
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcknowledgementScreen(
                          applicationId: appId,
                          jsonData: formData, // The original, complete data is sent forward
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm & Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        ...data.entries.map((entry) {
          if (entry.value != null && entry.value.toString().isNotEmpty && entry.value != false) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('${entry.key}: ${entry.value}'),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
