class Appointment {
  final int? id;
  final int userId;
  final String date;
  final String reason;
  final String doctor;
  final String? imagePath;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.reason,
    required this.doctor,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'reason': reason,
      'doctor': doctor,
      'imagePath': imagePath,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      userId: map['userId'],
      date: map['date'],
      reason: map['reason'],
      doctor: map['doctor'],
      imagePath: map['imagePath'],
    );
  }
}
