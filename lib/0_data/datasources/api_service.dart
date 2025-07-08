
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('https://reqres.in/api/login ');

    try {
      final response = await http.post(url, body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}