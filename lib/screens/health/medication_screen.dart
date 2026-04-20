// lib/screens/health/medication_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/medication_model.dart';
import '../../services/database_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final DatabaseService _db = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showForm([Medication? existing]) {
    final petCtrl = TextEditingController(text: existing?.petName ?? '');
    final nameCtrl = TextEditingController(text: existing?.medicationName ?? '');
    final dosageCtrl = TextEditingController(text: existing?.dosage ?? '');
    final timeCtrl = TextEditingController(text: existing?.scheduledTime ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(existing == null ? 'Add Medication' : 'Edit Medication',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: petCtrl,
              decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Medication Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageCtrl,
              decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 1 chewable, 5mg)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                  labelText: 'Scheduled Time (e.g. Morning, 08:00 PM)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final med = Medication(
                  id: existing?.id ?? '',
                  ownerId: userId,
                  petName: petCtrl.text.trim(),
                  medicationName: nameCtrl.text.trim(),
                  dosage: dosageCtrl.text.trim(),
                  scheduledTime: timeCtrl.text.trim(),
                  isTaken: existing?.isTaken ?? false,
                );
                if (existing == null) {
                  await _db.addMedication(med);
                } else {
                  await _db.updateMedication(med);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Add Medication' : 'Update',
                  style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Medications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _db.getUserMedications(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('💊', style: TextStyle(fontSize: 60)),
                SizedBox(height: 12),
                Text('No medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Add medication reminders', style: TextStyle(color: Colors.grey)),
              ]),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('DAILY REMINDERS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              ...items.map((m) => _buildCard(m)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Medication', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(Medication m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          GestureDetector(
            onTap: () => _db.toggleMedicationTaken(m.id, !m.isTaken),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: m.isTaken ? const Color(0xFF22C55E) : Colors.transparent,
                border: Border.all(
                    color: m.isTaken ? const Color(0xFF22C55E) : Colors.grey.shade400, width: 2),
              ),
              child: m.isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.medicationName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: m.isTaken ? TextDecoration.lineThrough : null)),
              Text(m.dosage, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Row(children: [
                const Text('Scheduled Time  ',
                    style: TextStyle(color: Color(0xFF2563EB), fontSize: 12)),
                Text(m.scheduledTime,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ]),
          ),
          IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
              onPressed: () => _showForm(m),
              padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
              onPressed: () => _db.deleteMedication(m.id),
              padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
      ),
    );
  }
}
