import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';
  static const _nameKey = 'auth_name';

  final _storage = const FlutterSecureStorage();

  String? _token;
  String? _email;
  String? _password;
  String? _name;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  bool get isLoggedIn => _token != null;

  UserProvider() {
    _restoreUser();
  }

  Future<void> _restoreUser() async {
    final storedToken = await _storage.read(key: _tokenKey);
    final storedEmail = await _storage.read(key: _emailKey);
    final storedPassword = await _storage.read(key: _passwordKey);
    final storedName = await _storage.read(key: _nameKey);

    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      _email = storedEmail;
      _password = storedPassword;
      _name = storedName;
      notifyListeners();
    }
  }

  Future<void> login(
      String token, String email, String password, String name) async {
    _token = token;
    _email = email;
    _password = password;
    _name = name;

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
    await _storage.write(key: _nameKey, value: name);

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _password = null;
    _name = null;

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _nameKey);
    notifyListeners();
  }
}
