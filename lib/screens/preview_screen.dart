import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'acknowledgement_screen.dart';

class FormPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, String> displayData;
  final String photoPath;
  final String? documentFileName;

  const FormPreviewScreen({
    super.key, 
    required this.formData, 
    required this.displayData,
    required this.photoPath,
    this.documentFileName,
  });

  @override
  State<FormPreviewScreen> createState() => _FormPreviewScreenState();
}

class _FormPreviewScreenState extends State<FormPreviewScreen> {
  bool _isLoading = false;

  Future<void> _finalSubmit() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(AppConstants.submitEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.formData),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final ack = jsonDecode(response.body);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AcknowledgementScreen(
              applicationId: ack['applicationId'] ?? 'N/A', 
              jsonData: ack
            )),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}\n${response.body}'))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission Error: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext contextIncome) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Application'), backgroundColor: Colors.blue[700]),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Please review all details before final submission.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Photo Preview
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(File(widget.photoPath), width: 120, height: 120, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    const Text('Applicant Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSection('Personal Details', [
                'Salutation', 'Name', 'Gender', 'Marital Status', 'Age', 'Aadhaar', 
                "Father's Name", "Mother's Name", "Husband's Name", 'Mobile', 'Email'
              ]),
              
              _buildSection('Present Address', [
                'Present District', 'Present Tehsil', 'Present Village', 'Present RI', 
                'Present Police Station', 'Present Post Office', 'Present PIN', 
                'Years Residing', 'Months Residing'
              ]),

              _buildSection('Permanent Address', [
                'Same as Present', 'Permanent State', 'Permanent District', 'Permanent Tehsil', 
                'Permanent Village', 'Permanent RI', 'Permanent Police Station', 
                'Permanent Post Office', 'Permanent PIN'
              ]),

              _buildSection('Guardian Details', [
                'Other Person Filling?', 'Guardian Name', 'Guardian Relation'
              ]),

              _buildSection('Purpose & Enclosures', [
                'Purpose', 'Document Type'
              ]),
              
              if (widget.documentFileName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Attached: ${widget.documentFileName}', 
                          style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontStyle: FontStyle.italic)
                        ),
                      ),
                    ],
                  ),
                ),

              _buildSection('Apply to Office', [
                'Apply to'
              ]),

              _buildSection('Declaration', [
                'Place'
              ]),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(contextIncome),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: const Text('Edit Details'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _finalSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                      child: const Text('Confirm & Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
    );
  }

  Widget _buildSection(String title, List<String> fields) {
    List<Widget> rows = [];
    for (var field in fields) {
      if (widget.displayData.containsKey(field) && widget.displayData[field]!.isNotEmpty) {
        rows.add(_buildInfoRow(field, widget.displayData[field]!));
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title.toUpperCase(), 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
        const Divider(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, 
            child: Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 13)
            )
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            flex: 3, 
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)
            )
          ),
        ],
      ),
    );
  }
}
