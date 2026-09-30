import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sembunyikanPassword = true;
  String? _errorLogin; // satu pesan umum, tidak membedakan email/password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Jalankan semua validator; berhenti jika ada yang gagal.
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email == dummyEmail && password == dummyPassword) {
      // pushReplacementNamed: Login dihapus dari stack, jadi tombol back
      // di Home tidak kembali ke Login.
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Sengaja satu pesan yang sama: tidak memberi tahu mana yang salah.
      setState(() => _errorLogin = 'Email atau password salah');
    }
  }

  void _hapusError() {
    if (_errorLogin != null) setState(() => _errorLogin = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SpendWise',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.email,
                    onChanged: (_) => _hapusError(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _sembunyikanPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_sembunyikanPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                          () => _sembunyikanPassword = !_sembunyikanPassword,
                        ),
                      ),
                    ),
                    validator: Validators.password,
                    onChanged: (_) => _hapusError(),
                  ),
                  if (_errorLogin != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorLogin!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _login,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Masuk'),
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
