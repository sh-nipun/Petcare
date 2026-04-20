// lib/screens/health/vaccination_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/vaccination_model.dart';
import '../../services/database_service.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final DatabaseService _db = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showForm([Vaccination? existing]) {
    final petNameCtrl = TextEditingController(text: existing?.petName ?? '');
    final vaccineCtrl = TextEditingController(text: existing?.vaccineName ?? '');
    DateTime dateTaken = existing?.dateTaken ?? DateTime.now();
    DateTime nextDue = existing?.nextDue ?? DateTime.now().add(const Duration(days: 365));

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
                Text(existing == null ? 'Add Vaccination Record' : 'Edit Record',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: petNameCtrl,
                  decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vaccineCtrl,
                  decoration: const InputDecoration(labelText: 'Vaccine Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Date Taken: ${DateFormat('yyyy-MM-dd').format(dateTaken)}'),
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: ctx, initialDate: dateTaken,
                        firstDate: DateTime(2000), lastDate: DateTime(2030));
                    if (d != null) setModal(() => dateTaken = d);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Next Due: ${DateFormat('yyyy-MM-dd').format(nextDue)}'),
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: ctx, initialDate: nextDue,
                        firstDate: DateTime(2000), lastDate: DateTime(2035));
                    if (d != null) setModal(() => nextDue = d);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (petNameCtrl.text.isEmpty || vaccineCtrl.text.isEmpty) return;
                    final v = Vaccination(
                      id: existing?.id ?? '',
                      ownerId: userId,
                      petName: petNameCtrl.text.trim(),
                      vaccineName: vaccineCtrl.text.trim(),
                      dateTaken: dateTaken,
                      nextDue: nextDue,
                    );
                    if (existing == null) {
                      await _db.addVaccination(v);
                    } else {
                      await _db.updateVaccination(v);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Add Record' : 'Update',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Vaccinations', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Vaccination>>(
        stream: _db.getUserVaccinations(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('💉', style: TextStyle(fontSize: 60)),
                SizedBox(height: 12),
                Text('No vaccination records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Add your first record', style: TextStyle(color: Colors.grey)),
              ]),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((v) => _buildCard(v)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(Vaccination v) {
    final overdue = v.isOverdue;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.vaccines,
                color: overdue ? const Color(0xFFEF4444) : const Color(0xFF22C55E), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.vaccineName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  overdue ? 'Overdue' : 'Valid',
                  style: TextStyle(
                      color: overdue ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
            IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () => _showForm(v),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                onPressed: () => _db.deleteVaccination(v.id),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
          const Divider(height: 16),
          _row('Pet', v.petName),
          const SizedBox(height: 4),
          _row('Date Taken', DateFormat('yyyy-MM-dd').format(v.dateTaken)),
          const SizedBox(height: 4),
          _row('Next Due', DateFormat('yyyy-MM-dd').format(v.nextDue),
              valueColor: overdue ? const Color(0xFFEF4444) : null),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13, color: valueColor ?? Colors.black87)),
    ]);
  }
}
