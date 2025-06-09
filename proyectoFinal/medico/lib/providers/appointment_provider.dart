// providers/appointment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';
import '../services/database_service.dart';

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier();
});

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]);

  Future<void> loadAppointments(int userId) async {
    final appointments = await DatabaseService().getAppointmentsForUser(userId);
    state = appointments;
  }

  Future<void> addAppointment(Appointment appointment) async {
    await DatabaseService().createAppointment(appointment);
    await loadAppointments(appointment.userId);
  }

  void clear() {
    state = [];
  }
}
