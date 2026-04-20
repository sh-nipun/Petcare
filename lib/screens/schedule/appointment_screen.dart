// lib/screens/schedule/appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/database_service.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final DatabaseService _db = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showForm([VetAppointment? existing]) {
    final doctorCtrl = TextEditingController(text: existing?.doctorName ?? '');
    final clinicCtrl = TextEditingController(text: existing?.clinicName ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    DateTime selectedDate = existing?.appointmentDate ?? DateTime.now();
    TimeOfDay selectedTime = existing != null
        ? _parseTime(existing.appointmentTime)
        : TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing == null ? 'Book Appointment' : 'Edit Appointment',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: doctorCtrl,
                  decoration: const InputDecoration(labelText: 'Doctor Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clinicCtrl,
                  decoration: const InputDecoration(labelText: 'Clinic Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: ctx, initialDate: selectedDate,
                        firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (d != null) setModal(() => selectedDate = d);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text('Time: ${selectedTime.format(ctx)}'),
                  onPressed: () async {
                    final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                    if (t != null) setModal(() => selectedTime = t);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (doctorCtrl.text.isEmpty || clinicCtrl.text.isEmpty) return;
                    final appt = VetAppointment(
                      id: existing?.id ?? '',
                      ownerId: userId,
                      doctorName: doctorCtrl.text.trim(),
                      clinicName: clinicCtrl.text.trim(),
                      appointmentDate: selectedDate,
                      appointmentTime: selectedTime.format(ctx),
                      address: addressCtrl.text.trim(),
                    );
                    if (existing == null) {
                      await _db.addAppointment(appt);
                    } else {
                      await _db.updateAppointment(appt);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Book Appointment' : 'Update',
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    try {
      final parts = t.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (t.contains('PM') && hour != 12) hour += 12;
      if (t.contains('AM') && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Vet Appointments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<VetAppointment>>(
        stream: _db.getUserAppointments(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.location_on, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Find Nearby Vet',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 20),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Column(children: [
                    Text('🏥', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 12),
                    Text('No appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Book your first appointment', style: TextStyle(color: Colors.grey)),
                  ]),
                )
              else ...[
                const Text('UPCOMING VISITS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
                const SizedBox(height: 12),
                ...items.map((a) => _buildCard(a)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(VetAppointment a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.doctorName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(a.clinicName,
                    style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
              ]),
            ),
            IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () => _showForm(a),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                onPressed: () => _db.deleteAppointment(a.id),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(DateFormat('MMM dd, yyyy').format(a.appointmentDate),
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 16),
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(a.appointmentTime,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ]),
          if (a.address.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(a.address, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ],
        ]),
      ),
    );
  }
}
