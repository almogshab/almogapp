import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'לוגו',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'צור חשבון',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'בכדי להתחבר לחשבונך מלא את השדות הבאים',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildTextField('כתובת מייל'),
            _buildTextField('סיסמה', isPassword: true),
            _buildTextField('אימות סיסמה', isPassword: true),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSocialButton('Google', Colors.white, 'assets/icons/google_logo.png'),
            _buildSocialButton('Facebook', Colors.blue, 'assets/facebook_logo.png'),
            _buildSocialButton('Mail', Colors.black, Icons.mail),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('רשום כבר? לחץ כאן!', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, Color color, dynamic icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == Colors.white ? Colors.black : Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {},
        icon: icon is String
            ? Image.asset(icon, width: 24, height: 24)
            : Icon(icon, size: 24),
        label: Text(text),
      ),
    );
  }
}
