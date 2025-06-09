// screens/appointment_history.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment_model.dart';

class AppointmentHistory extends ConsumerWidget {
  const AppointmentHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final appointments = ref.watch(appointmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Citas')),
      body: user == null
          ? const Center(child: Text('No hay usuario activo'))
          : FutureBuilder(
              future: ref.read(appointmentProvider.notifier).loadAppointments(user.id!),
              builder: (context, snapshot) {
                if (appointments.isEmpty) {
                  return const Center(child: Text('No hay citas registradas'));
                }
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(appt.reason),
                        subtitle: Text('Fecha: ${appt.date.split("T")[0]}'),
                        leading: appt.imagePath != null
                            ? Image.file(File(appt.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.event_note),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
