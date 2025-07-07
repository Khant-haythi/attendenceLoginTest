import 'package:attendance_login/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forgetpassword_screen.dart';
import 'login_screen.dart';

// Define the login function that returns a Future<bool>
Future<String?> login(String username, String password) async {
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

    return null; // success: no error
  } on DioException catch (e) {
    print("❌ Login failed:");
    print("Status: ${e.response?.statusCode}");
    print("Data: ${e.response?.data}");

    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response?.data['message']; // show server error
    }

    return "Invalid email or password.";
  } catch (e) {
    print("Unexpected error: $e");
    return "An unexpected error occurred.";
  }
}

// Home Screen to navigate to after successful login
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to Login Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ApiLoginScreen()),
                );
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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

    final errorMessage = await login(email, password);

    if (errorMessage == null) {
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
        _error = errorMessage;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent overflow issues when keyboard appears
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1068b2),
                  Color(0xFF072C4C),
                ],
              ),
            ),
          ),

          // Bottom Image (Replace with your own image)
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     'assets/images/bottom.jpg', // Replace with your asset path
          //     fit: BoxFit.cover,
          //     height: 200,
          //   ),
          // ),
          Positioned(
            top:150,
            left:0,
            right:0,
            child: Image.asset(
              "assets/images/logo.png", // Replace with your logo
              width: 245,
              height: 118,
              fit: BoxFit.contain,
            ),
          ),
          // Login Form Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical:20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image at the Top


                SizedBox(height: 50), // Space between logo and form

                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.email,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.lock,color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(),
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

                  // ✅ Set checkbox colors here
                  checkColor: Colors.grey,       // Color of the check mark
                  activeColor: Colors.white,
                ),

                // Error Message
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),

                SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width:200,
                  child: ElevatedButton(
                    onPressed: _submitLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Adjust radius here
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1068b2),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Optional: adjust font size
                        color: Colors.blue, // Optional: text color
                      ),
                   ),
                  ),
                ),

                // Forgot Password Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFC7C7C7),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}