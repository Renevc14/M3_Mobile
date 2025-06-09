// screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).register(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya existe')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
