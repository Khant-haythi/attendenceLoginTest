import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../0_data/datasources/api_client.dart';
import '../core/widgets/attendence_card.dart';
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
  String? status; // "Present" or "Late"

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAttendanceHistory(); // initial fetch
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      fetchAttendanceHistory(); // fetch again every 20s
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // clean up timer
    super.dispose();
  }


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

      final checkInDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final lateThreshold = DateTime(now.year, now.month, now.day, 9, 15);
      status = checkInDateTime.isAfter(lateThreshold) ? "Late" : "Present";

      body["checkInTime"] = checkInTime;
      body["checkOutTime"] = null;
    }

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

  List<Map<String, dynamic>> _attendanceList = [];

  Future<void> fetchAttendanceHistory() async {
    final token = await ApiClient.storage.read(key: 'accessToken');
    if (token == null) return;

    try {
      final response = await ApiClient.dio.get(
        'Attendances/self',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> attendanceData =
        List<Map<String, dynamic>>.from(response.data);

        attendanceData.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1900);
          DateTime dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA); // DESCENDING
        });

        setState(() {
          _attendanceList = attendanceData;
        });
      }
    } catch (e) {
      print("❌ Error fetching attendance: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Welcome")),
        backgroundColor: Color(0xFF0065BA),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 40.0),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: Colors.white, size: 40),
          )
        ],
      ),
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
          padding: const EdgeInsets.only(top: 60.0),
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
                    sliderButtonIcon: Icon(Icons.logout, color: Color(0xFF0065BA), size: 30),
                    onSubmit: () async => await _handleSlideAction(context),
                    child: _buildSlideText('Slide to check out', Icons.exit_to_app_rounded),
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
                    sliderButtonIcon: Icon(Icons.alarm, color: Color(0xFF0065BA), size: 30),
                    onSubmit: () async => await _handleSlideAction(context),
                    child: _buildSlideText('Slide to check in', Icons.alarm),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Background color
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Attendance History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _attendanceList.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: _attendanceList.length,
                          itemBuilder: (context, index) {
                            return AttendanceCard(attendance: _attendanceList[index]);
                          },
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildSlideText(String label, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF0065BA), size: 35),
            SizedBox(width: 50),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }
}
