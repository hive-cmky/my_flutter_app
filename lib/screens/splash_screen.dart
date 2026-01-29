import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[700], // Primary orange color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Image.asset(
              'assets/images/mohan-majhi-cm_2.png',
              width: 150, // Adjust size as needed
              height: 1U.UU,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.image_not_supported, size: 80, color: Colors.white), // Fallback icon
            ),
            const SizedBox(height: 24),

            // Text
            const Text(
              'eDistrict Odisha',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),
          ],
        ),
      ),
    );
  }
}
