// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/feeding_model.dart';
import '../models/vaccination_model.dart';
import '../models/medication_model.dart';
import '../models/appointment_model.dart';
import '../models/activity_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PETS ---
  // FIX: Removed orderBy('createdAt') to avoid requiring a composite Firestore index.
  // Sorting is done client-side instead.
  Stream<List<Pet>> getUserPets(String userId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final pets = s.docs.map((d) => Pet.fromMap(d.data(), d.id)).toList();
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // client-side sort
      return pets;
    });
  }

  Future<void> addPet(Pet pet) async {
    await _db.collection('pets').add(pet.toMap());
  }

  Future<void> updatePet(Pet pet) async {
    Map<String, dynamic> data = pet.toMap();
    data.remove('createdAt');
    await _db.collection('pets').doc(pet.id).update(data);
  }

  Future<void> deletePet(String petId) async {
    await _db.collection('pets').doc(petId).delete();
  }

  // --- FEEDING ---
  // FIX: Removed orderBy('createdAt'), sort client-side
  Stream<List<FeedingSchedule>> getUserFeedings(String userId) {
    return _db
        .collection('feedings')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => FeedingSchedule.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // ascending
      return list;
    });
  }

  Future<void> addFeeding(FeedingSchedule feeding) async {
    await _db.collection('feedings').add(feeding.toMap());
  }

  Future<void> updateFeeding(FeedingSchedule feeding) async {
    Map<String, dynamic> data = feeding.toMap();
    data.remove('createdAt');
    await _db.collection('feedings').doc(feeding.id).update(data);
  }

  Future<void> deleteFeeding(String id) async {
    await _db.collection('feedings').doc(id).delete();
  }

  // --- VACCINATIONS ---
  // FIX: Removed orderBy('createdAt'), sort client-side
  Stream<List<Vaccination>> getUserVaccinations(String userId) {
    return _db
        .collection('vaccinations')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Vaccination.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addVaccination(Vaccination v) async {
    await _db.collection('vaccinations').add(v.toMap());
  }

  Future<void> updateVaccination(Vaccination v) async {
    Map<String, dynamic> data = v.toMap();
    data.remove('createdAt');
    await _db.collection('vaccinations').doc(v.id).update(data);
  }

  Future<void> deleteVaccination(String id) async {
    await _db.collection('vaccinations').doc(id).delete();
  }

  // --- MEDICATIONS ---
  // FIX: Removed orderBy('createdAt'), sort client-side
  Stream<List<Medication>> getUserMedications(String userId) {
    return _db
        .collection('medications')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Medication.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addMedication(Medication m) async {
    await _db.collection('medications').add(m.toMap());
  }

  Future<void> updateMedication(Medication m) async {
    Map<String, dynamic> data = m.toMap();
    data.remove('createdAt');
    await _db.collection('medications').doc(m.id).update(data);
  }

  Future<void> deleteMedication(String id) async {
    await _db.collection('medications').doc(id).delete();
  }

  Future<void> toggleMedicationTaken(String id, bool isTaken) async {
    await _db.collection('medications').doc(id).update({'isTaken': isTaken});
  }

  // --- VET APPOINTMENTS ---
  // FIX: Removed orderBy('appointmentDate') to avoid composite index requirement.
  // Sort client-side by appointmentDate ascending.
  Stream<List<VetAppointment>> getUserAppointments(String userId) {
    return _db
        .collection('appointments')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => VetAppointment.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      return list;
    });
  }

  Future<void> addAppointment(VetAppointment a) async {
    await _db.collection('appointments').add(a.toMap());
  }

  Future<void> updateAppointment(VetAppointment a) async {
    Map<String, dynamic> data = a.toMap();
    data.remove('createdAt');
    await _db.collection('appointments').doc(a.id).update(data);
  }

  Future<void> deleteAppointment(String id) async {
    await _db.collection('appointments').doc(id).delete();
  }

  // --- ACTIVITIES ---
  // FIX: Removed orderBy('date') to avoid composite index requirement.
  // Sort client-side by date descending.
  Stream<List<Activity>> getUserActivities(String userId) {
    return _db
        .collection('activities')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Activity.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> addActivity(Activity a) async {
    await _db.collection('activities').add(a.toMap());
  }

  Future<void> deleteActivity(String id) async {
    await _db.collection('activities').doc(id).delete();
  }
}
