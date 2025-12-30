import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import '../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _authKeyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://serviceonline.gov.in/configure/foreignHostAuth'),
        headers: {
          'client_id': '822123',
          'auth_key': _authKeyController.text.trim(),
          'uid': _uidController.text.trim(),
          'usecret': '312fb5609823b09a83660c84e9ede856afdc7b95871e98c1230b3ecce67a917d',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save session details including the reference_no from the CURL response
        SessionManager.startSession(
          data['token'] ?? '', 
          _uidController.text.trim(),
          data['reference_no'] ?? ''
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Failed: Invalid credentials')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text('ServicePlus Portal', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _uidController,
                    decoration: const InputDecoration(labelText: 'User Name', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => v!.isEmpty ? 'Enter User Name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _authKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) => v!.isEmpty ? 'Enter Password' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
