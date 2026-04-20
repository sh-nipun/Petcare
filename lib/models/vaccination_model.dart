// lib/models/vaccination_model.dart
class Vaccination {
  final String id;
  final String ownerId;
  final String petName;
  final String vaccineName;
  final DateTime dateTaken;
  final DateTime nextDue;
  final DateTime createdAt; // FIX: added for client-side sorting

  Vaccination({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.vaccineName,
    required this.dateTaken,
    required this.nextDue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => nextDue.isBefore(DateTime.now());

  factory Vaccination.fromMap(Map<String, dynamic> data, String documentId) {
    return Vaccination(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      petName: data['petName'] ?? '',
      vaccineName: data['vaccineName'] ?? '',
      dateTaken: (data['dateTaken'] as dynamic)?.toDate() ?? DateTime.now(),
      nextDue: (data['nextDue'] as dynamic)?.toDate() ?? DateTime.now(),
      // FIX: parse createdAt
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'petName': petName,
      'vaccineName': vaccineName,
      'dateTaken': dateTaken,
      'nextDue': nextDue,
      'createdAt': DateTime.now(),
    };
  }
}
