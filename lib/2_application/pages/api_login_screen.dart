
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../0_data/datasources/api_client.dart';
import 'forgetpassword_screen.dart';
import 'home_screen.dart';


// Define the login function that returns a Future<bool>
Future<bool> login(String username, String password) async {
  try {
    print('Sending login request...');
    final response = await ApiClient.dio.post(
      'accounts/login',
      data: {
        'email': username,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;
    print('Login successful: $data');

    await ApiClient.storage.write(key: 'accessToken', value: data['accessToken']);
    await ApiClient.storage.write(key: 'refreshToken', value: data['refreshToken']);

    return true; // success: no error
  } on DioException catch (e) {
    print("❌ Login failed:");
    print("Status: ${e.response?.statusCode}");
    print("Data: ${e.response?.data}");
    return false;
  } catch (e) {
    print("Unexpected error: $e");
    return false;
  }
}


// Login Screen
class ApiLoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ApiLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _keepMeLoggedIn = false;
  bool _obscureText = true;
  double _keyboardPadding = 0.0;
  bool _showCustomKeyboard = false;

  void _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _error = null;
    });

    final success = await login(email, password);

    if (success) {
      if (_keepMeLoggedIn) {
        await ApiClient.storage.write(key: 'keepLoggedIn', value: 'true');
      } else {
        await ApiClient.storage.delete(key: 'keepLoggedIn');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      setState(() {
        _error = 'Invalid email or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showCustomKeyboard = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // allow scroll when keyboard shows
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/intbackground.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: keyboardHeight > 0 ? keyboardHeight + 50 : 0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.only(top: constraints.maxHeight * 0.15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/logo.png",
                              width: 245,
                              height: 118,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Email',
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                            SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Password',
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                            SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Enter your password",
                                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            CheckboxListTile(
                              title: Text(
                                "Keep me logged in",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: _keepMeLoggedIn,
                              onChanged: (value) {
                                setState(() {
                                  _keepMeLoggedIn = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              checkColor: Colors.grey,
                              activeColor: Colors.white,
                            ),
                            if (_error != null)
                              Text(
                                _error!,
                                style: TextStyle(color: Colors.red),
                              ),

                            // 👇 This will move button up slightly when keyboard appears
                            SizedBox(height: keyboardHeight > 0 ? 2 : 16),

                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: _submitLogin,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1068b2),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Forgot password action
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFFC7C7C7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }



}