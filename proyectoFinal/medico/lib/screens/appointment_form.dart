// screens/appointment_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


import '../models/appointment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  const AppointmentForm({super.key});

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name = p.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$name');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final user = ref.read(authProvider);
      if (user == null) return;

      final newAppointment = Appointment(
        userId: user.id!,
        date: _selectedDate!.toIso8601String(),
        reason: _reasonController.text.trim(),
        imagePath: _imageFile?.path,
      );

      await ref.read(appointmentProvider.notifier).addAppointment(newAppointment);

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Motivo / Síntoma'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto del Síntoma'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAppointment,
                child: const Text('Guardar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
