import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'http://your_flask_backend_ip:5000'; // Replace with your Flask backend IP

  Future<List<String>> generateQuotes(String emotion) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/generate-quotes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emotion': emotion}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> quotesJson = jsonDecode(response.body)['quotes'];
      return quotesJson.map((quote) => quote.toString()).toList();
    } else {
      throw Exception('Failed to generate quotes: ${response.statusCode}');
    }
  }
}
