import 'package:attendance_login/services/api_client.dart';
import 'package:flutter/material.dart';
import 'api_login_screen.dart';
import 'login_screen.dart'; // make sure this file exists
import 'home_screen.dart' hide HomeScreen;  // optional, used after login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keepLoggedIn = await ApiClient.storage.read(key: 'keepLoggedIn');
  final token = await ApiClient.storage.read(key: 'accessToken');

  runApp(MyApp(
    isLoggedIn: keepLoggedIn == 'true' && token != null,
  ));
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set login screen as the initial screen
      home: isLoggedIn ? HomeScreen() : ApiLoginScreen(),
    );
  }
}
