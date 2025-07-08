import 'package:attendance_login/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'api_login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;

  Future<void> _handleSlideAction(BuildContext context) async {
    final now = DateTime.now();
    final formattedDate = DateFormat("yyyy-MM-dd").format(now);
    final formattedTime = DateFormat("HH:mm:ss").format(now);

    final token = await ApiClient.storage.read(key: 'accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not authenticated"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {
      "date": formattedDate,
    };

    if (_isCheckedIn) {
      // User is checking out
      checkOutTime = formattedTime;
      body["checkInTime"] = checkInTime;
      body["checkOutTime"] = checkOutTime;
    } else {
      // User is checking in
      checkInTime = formattedTime;
      body["checkInTime"] = checkInTime;
      body["checkOutTime"] = null;
    }

    // 👇 Add this for debugging
    print("📤 Sending Attendance Data:");
    print("  ➤ Final Body: $body");
    print("  ➤ Token: $token");

    try {
      final response = await ApiClient.dio.post(
        'Attendances/self',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isCheckedIn = !_isCheckedIn;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isCheckedIn ? "Checked in!" : "Checked out!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to submit");
      }
    } catch (e) {
      print("❌ Error submitting attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting attendance"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      backgroundColor: Color(0xFF0065BA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome!",
                style: TextStyle(fontSize: 24, color: Colors.white)),
            SizedBox(height: 20),

            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _isCheckedIn
                  ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.1416),
                child: SlideAction(
                  key: ValueKey("checkout"),
                  borderRadius: 30,
                  innerColor: Colors.redAccent,
                  outerColor: Colors.white,
                  elevation: 0,
                  sliderButtonIcon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.1416),
                    child: Icon(Icons.logout, color: Colors.white),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.1416),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 180),
                        Text(
                          'Check Out',
                          style: TextStyle(
                              color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  onSubmit: () async => await _handleSlideAction(context),
                ),
              )
                  : SlideAction(
                key: ValueKey("checkin"),
                borderRadius: 30,
                innerColor: Colors.green,
                outerColor: Colors.white,
                elevation: 0,
                sliderButtonIcon:
                Icon(Icons.login_rounded, color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 100),
                    Text(
                      'Check In',
                      style:
                      TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
                onSubmit: () async => await _handleSlideAction(context),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                await ApiClient.storage.delete(key: 'accessToken');
                await ApiClient.storage.delete(key: 'refreshToken');
                await ApiClient.storage.delete(key: 'keepLoggedIn');
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
