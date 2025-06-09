import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';

class AppointmentHistory extends ConsumerWidget {
  const AppointmentHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final appointments = ref.watch(appointmentProvider)
        .where((a) => a.userId == user?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Citas')),
      body: appointments.isEmpty
          ? const Center(child: Text('No hay citas registradas.'))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('${appt.date.split("T").first} con Dr. ${appt.doctor}'),
                  subtitle: Text(appt.reason),
                  trailing: appt.imagePath != null
                      ? Image.file(File(appt.imagePath!), width: 50, fit: BoxFit.cover)
                      : null,
                );
              },
            ),
    );
  }
}
