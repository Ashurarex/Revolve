import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'demo@citypulse.app');
  final _password = TextEditingController(text: 'password');
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await auth.signIn(_email.text, _password.text);
                      if (context.mounted)
                        Navigator.pushReplacementNamed(context, '/home');
                    },
              child: _busy
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Create an account'),
            ),
            const SizedBox(height: 12),
            Text('Admin mode: ${auth.isAdminOrModerator ? "ON" : "OFF"}'),
            Switch(
              value: auth.isAdminOrModerator,
              onChanged: (v) => auth.setAdmin(v),
            ),
          ],
        ),
      ),
    );
  }
}
