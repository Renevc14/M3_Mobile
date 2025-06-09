import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import 'appointment_form.dart';
import 'appointment_history.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final appointments =
        ref
            .watch(appointmentProvider)
            .where((a) => a.userId == user?.id)
            .toList();

    appointments.sort(
      (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
    );

    final nextAppointment = appointments.firstWhereOrNull(
      (a) => DateTime.parse(a.date).isAfter(DateTime.now()),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body:
          user == null
              ? const Center(child: Text('Usuario no disponible'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Carné
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade800, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          if (user.imagePath != null)
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: FileImage(File(user.imagePath!)),
                            ),
                          const SizedBox(height: 12),
                          const Icon(
                            Icons.credit_card,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ver Carné Digital',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TITULAR',
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user.username.toUpperCase(),
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Solicitar Cita Médica',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppointmentForm(),
                                ),
                              ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'Historial de Citas',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppointmentHistory(),
                                ),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Próxima cita
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tienes una cita programada:',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nextAppointment != null
                                ? '${DateTime.parse(nextAppointment.date).toLocal().toString().split(" ")[0]}'
                                : 'NINGUNA',
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              nextAppointment == null
                                  ? null
                                  : () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            title: const Row(
                                              children: [
                                                Icon(Icons.event),
                                                SizedBox(width: 8),
                                                Text('Detalle de la cita'),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      DateTime.parse(
                                                            nextAppointment
                                                                .date,
                                                          )
                                                          .toLocal()
                                                          .toString()
                                                          .split(" ")[0],
                                                      style:
                                                          GoogleFonts.openSans(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Dr. ${nextAppointment.doctor}',
                                                        style:
                                                            GoogleFonts.openSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.description,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        nextAppointment.reason,
                                                        style:
                                                            GoogleFonts.openSans(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                if (nextAppointment.imagePath !=
                                                    null)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.file(
                                                      File(
                                                        nextAppointment
                                                            .imagePath!,
                                                      ),
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                nextAppointment == null
                                    ? Colors.grey.shade300
                                    : Colors.blue,
                            foregroundColor:
                                nextAppointment == null
                                    ? Colors.black54
                                    : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ver detalle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
