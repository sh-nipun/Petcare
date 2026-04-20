// lib/models/appointment_model.dart
class VetAppointment {
  final String id;
  final String ownerId;
  final String doctorName;
  final String clinicName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String address;
  final DateTime createdAt; // FIX: added for completeness

  VetAppointment({
    required this.id,
    required this.ownerId,
    required this.doctorName,
    required this.clinicName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VetAppointment.fromMap(Map<String, dynamic> data, String documentId) {
    return VetAppointment(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      clinicName: data['clinicName'] ?? '',
      appointmentDate: (data['appointmentDate'] as dynamic)?.toDate() ?? DateTime.now(),
      appointmentTime: data['appointmentTime'] ?? '',
      address: data['address'] ?? '',
      // FIX: parse createdAt
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'doctorName': doctorName,
      'clinicName': clinicName,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'address': address,
      'createdAt': DateTime.now(),
    };
  }
}
