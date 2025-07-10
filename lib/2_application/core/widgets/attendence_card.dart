import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCard extends StatelessWidget {
  final Map<String, dynamic> attendance;

  const AttendanceCard({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Extract and parse data
    String rawCheckIn = attendance['checkInTime'] ?? "--";
    String rawCheckOut = attendance['checkOutTime'] ?? "--";
    String rawDate = attendance['date'] ?? "";

    // Format date display
    String formattedDate = "--";
    try {
      formattedDate = DateFormat('MMMM d, EEEE, yyyy')
          .format(DateTime.parse(rawDate));
    } catch (e) {
      // keep as "--" if parse fails
    }

    // Convert check-in to DateTime
    DateTime? checkInTime;
    try {
      checkInTime = DateFormat("HH:mm:ss").parse(rawCheckIn);
    } catch (e) {
      checkInTime = null;
    }

    // Determine late status
    final lateThreshold = DateFormat("HH:mm:ss").parse("09:15:00");
    String status = "--";
    if (checkInTime != null) {
      status = checkInTime.isAfter(lateThreshold) ? "Late" : "Present";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical:
      8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border(
          left: BorderSide(
            color: status == "Late" ? Colors.orange : Colors.green,
            width: 8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🗓 Date and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54, size: screenWidth * 0.065),
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: screenWidth * 0.043,

                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.015,
                    horizontal: screenWidth * 0.07,
                  ),
                  decoration: BoxDecoration(
                    color: status == "Late"
                        ? Colors.orangeAccent.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      color: status == "Late" ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),

            // 🕒 Check-in time
            Row(
              children: [
                Text("Check-in time:",
                    style: TextStyle(fontSize: screenWidth * 0.034)),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  rawCheckIn != "--"
                      ? DateFormat('hh:mm a')
                      .format(DateFormat("HH:mm:ss").parse(rawCheckIn))
                      : "--",
                  style: TextStyle(
                      fontSize: screenWidth * 0.034, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),

            // 🕔 Check-out time
            Row(
              children: [
                Text("Check-out time:",
                    style: TextStyle(fontSize: screenWidth * 0.034)),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  rawCheckOut != "--"
                      ? DateFormat('hh:mm a')
                      .format(DateFormat("HH:mm:ss").parse(rawCheckOut))
                      : "--",
                  style: TextStyle(
                      fontSize: screenWidth * 0.034, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
