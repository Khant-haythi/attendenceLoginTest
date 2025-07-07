import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _message;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = "Please enter your email.";
      });
      return;
    }

    try {
      // ⚠️ DUMMY SIMULATION (because dummyjson has no reset endpoint)
      final url = Uri.parse('https://dummyjson.com/users');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;

        // Check if email exists
        final foundUser = users.firstWhere(
              (user) => user['email'].toString().toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );

        if (foundUser != null) {
          setState(() {
            _message = "Reset link sent to $email (simulated).";
          });
        } else {
          setState(() {
            _message = "Email not found. Please try again.";
          });
        }
      } else {
        setState(() {
          _message = "Error fetching users.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Something went wrong: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your email to simulate password reset"),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendResetLink,
              child: Text("Send Reset Link"),
            ),
            if (_message != null) ...[
              SizedBox(height: 16),
              Text(
                _message!,
                style: TextStyle(color: Colors.blue),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
