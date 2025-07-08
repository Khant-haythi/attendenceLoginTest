
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../0_data/datasources/api_client.dart';
import '../core/widgets/clock_widget.dart';
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
            content: Text(_isCheckedIn ? "Check-in completed!" : "Check-out completed!"),
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
      appBar: AppBar(title: Center(child: Text("Welcome")), backgroundColor: Color(0xFF0065BA),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: 40.0,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
        ),

      actions: [IconButton(onPressed: (){}, icon: Icon(Icons.notifications,
        color: Colors.white,
        size: 40,))
      ],),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Header')),
            ListTile(title: Text('Item 1')),
          ],
        ),
      ),
      backgroundColor: Color(0xFF0065BA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top:60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              ClockWidget(),
              SizedBox(height: 20),

              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: _isCheckedIn
                    ? SizedBox(
                  width: 350,
                      child: SlideAction(
                                      key: ValueKey("checkout"),
                                      borderRadius: 50,
                                      innerColor: Colors.white,
                                      outerColor: Colors.white.withOpacity(0.15),
                                      elevation: 8,
                                      sliderButtonIcon: Icon(Icons.logout,
                                        color: Color(0xFF0065BA),size:30),
                                      onSubmit: () async => await _handleSlideAction(context),
                                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.exit_to_app_rounded, color: Color
                              (0xFF0065BA),size:35),
                            SizedBox(width: 50),
                            Text(
                              'Slide to check out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white60),
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                          ],
                        ),
                      ],
                                      ),
                                    ),
                    )
                    : SizedBox(
                  width: 350,
                      child: SlideAction(
                                      key: ValueKey("checkin"),
                                      borderRadius: 60,
                                      innerColor: Colors.white,
                                      outerColor: Colors.white.withOpacity(0.15),
                                      elevation: 8,
                                      sliderButtonIcon: Icon(Icons.alarm,
                                        color: Color(0xFF0065BA),size:30),
                                      onSubmit: () async => await _handleSlideAction(context),
                                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.alarm, color: Color(0xFF0065BA),
                            size: 35,),
                            SizedBox(width: 50),
                            Text(
                              'Slide to check in',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white60),
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                          ],
                        ),
                      ],
                                      ),
                                    ),
                    ),
              ),

              SizedBox(height: 40),

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
      ),
    );
  }

}
