import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Analog Clock
            Center(
              child: Container(
                width: 300,
                height: 300,
                child:  Center(
                  child: AnalogClock(
                    dateTime: DateTime.now(),
                    isKeepTime: true,
                    dialColor: Colors.white,
                    dialBorderColor: Colors.black,
                    dialBorderWidthFactor: 0.02,
                    markingColor: Colors.grey,
                    markingRadiusFactor: 1.0,
                    markingWidthFactor: 1.0,
                    hourNumberColor: Colors.black,
                    hourNumbers: const ['', '', '3', '', '', '6', '', '', '9', '', '', '12'],
                    hourNumberSizeFactor: 1.0,
                    hourNumberRadiusFactor: 1.0,
                    hourHandColor: Colors.black,
                    hourHandWidthFactor: 1.0,
                    hourHandLengthFactor: 1.0,
                    minuteHandColor: Colors.black,
                    minuteHandWidthFactor: 1.0,
                    minuteHandLengthFactor: 1.0,
                    secondHandColor: Colors.black,
                    secondHandWidthFactor: 1.0,
                    secondHandLengthFactor: 1.0,
                    centerPointColor: Colors.black,
                    centerPointWidthFactor: 1.0,
                  ),
                )
              ),
            ),

            SizedBox(height: 40),

            // Welcome Message
            Text(
              "Welcome to Your Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}