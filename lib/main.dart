
import 'package:flutter/material.dart';

import '0_data/datasources/api_client.dart';
import '2_application/pages/api_login_screen.dart';
import '2_application/pages/home_screen.dart';

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
