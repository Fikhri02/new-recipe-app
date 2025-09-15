import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_recipe_app/di/di.dart';
import 'package:new_recipe_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = di<ApiService>();
  bool _loading = false;
  bool _obscurePassword = true;
  List<Map<String, dynamic>> _sampleUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>();
      if (user.email != null) _email.text = user.email!;
      _loadSampleUsers();
    });
  }

  Future<void> _loadSampleUsers() async {
    try {
      final users = await _api.fetchUsers();
      setState(() {
        _sampleUsers = users.map((u) {
          return {
            'email': u['email'],
            'password': u['hash'],
            'plain_password': u['password'],
          };
        }).toList();
      });
    } catch (_) {
      setState(() => _sampleUsers = []);
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = context.read<UserProvider>();
      final email = _email.text.trim();
      final password = _password.text.trim();
      final name = email.split('@')[0];
      final hashedPassword = _api.hashPassword(password);

      final match = _sampleUsers.firstWhere(
          (u) => u['email'] == email && u['password'] == hashedPassword,
          orElse: () => {});

      if (match.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      final token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      await user.login(token, email, password, name);
      context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSampleUsers() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sample Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: _sampleUsers.isEmpty
              ? Center(
                  child: Text(
                    'No sample users available.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sampleUsers.length,
                  itemBuilder: (context, index) {
                    final u = _sampleUsers[index];
                    return ListTile(
                      title: Text(u['email'] ?? ''),
                      subtitle: Text(u['plain_password'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _continueAsGuest() async {
    final user = context.read<UserProvider>();
    final token = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await user.login(token, 'guest@example.com', '', 'Guest');
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email,
                                color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Email required';
                            if (!_isValidEmail(value.trim()))
                              return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock,
                                color: theme.colorScheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Password required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: _loading
                                ? CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary)
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                        color: theme.colorScheme.onPrimary),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Show sample users
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _showSampleUsers,
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: Text(
                              'Show Sample Users',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Continue as guest
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: Text(
                              'Continue as Guest',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
