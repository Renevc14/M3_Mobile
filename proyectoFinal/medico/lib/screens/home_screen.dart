// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'appointment_form.dart';
import 'appointment_history.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${user?.username ?? 'Usuario'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Reservar Cita'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentForm()),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Historial de Citas'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentHistory()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
