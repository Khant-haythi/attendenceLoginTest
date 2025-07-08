import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockWidget extends StatefulWidget {
  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('h:mm a').format(_now); // 9:05 AM
    String formattedDate = DateFormat('MMMM d, yyyy - EEEE').format(_now); // July 3, 2025 - Thursday

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),

          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 3),
        Text(
          formattedDate,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ],
    );
  }
}
