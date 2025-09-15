import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ApiService {
  final String usersUrl =
      'https://raw.githubusercontent.com/Fikhri02/recipe-app-user-sample-data/main/users.json';
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse(usersUrl));

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return users.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.get(Uri.parse(usersUrl));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load users');
    }

    final List<dynamic> users = json.decode(resp.body);

    // Hash the input password
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    // Compare with pre-hashed passwords
    for (final u in users) {
      if (u['email'] == email && u['password'] == passwordHash) {
        return {
          'email': email,
          'token': 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
        };
      }
    }

    throw Exception('Invalid email or password');
  }
}
