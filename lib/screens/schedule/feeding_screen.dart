// lib/screens/schedule/feeding_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/feeding_model.dart';
import '../../services/database_service.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  final DatabaseService _db = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showForm([FeedingSchedule? existing]) {
    final petNameCtrl = TextEditingController(text: existing?.petName ?? '');
    final foodTypeCtrl = TextEditingController(text: existing?.foodType ?? '');
    TimeOfDay selectedTime = existing != null
        ? _parseTime(existing.time)
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? 'Add Feeding Schedule' : 'Edit Schedule',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: petNameCtrl,
                decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: foodTypeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Food Type (e.g. Dry Food 1/4 cup)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
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
                  if (petNameCtrl.text.isEmpty || foodTypeCtrl.text.isEmpty) return;
                  final feeding = FeedingSchedule(
                    id: existing?.id ?? '',
                    ownerId: userId,
                    petName: petNameCtrl.text.trim(),
                    time: selectedTime.format(ctx),
                    foodType: foodTypeCtrl.text.trim(),
                  );
                  if (existing == null) {
                    await _db.addFeeding(feeding);
                  } else {
                    await _db.updateFeeding(feeding);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(existing == null ? 'Add Schedule' : 'Update',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
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
        title: const Text('Feeding Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: () => _showForm(),
          )
        ],
      ),
      body: StreamBuilder<List<FeedingSchedule>>(
        stream: _db.getUserFeedings(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🍽️', style: TextStyle(fontSize: 60)),
                SizedBox(height: 12),
                Text('No feeding schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Add a schedule to get started', style: TextStyle(color: Colors.grey)),
              ]),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text("TODAY'S MEALS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              ...items.map((f) => _buildCard(f)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Schedule', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(FeedingSchedule f) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.access_time, color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 8),
            Text(f.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Text(f.petName, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () => _showForm(f),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                onPressed: () => _db.deleteFeeding(f.id),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
          const Divider(height: 16),
          Row(children: [
            const Text('Food Type', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            Text(f.foodType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ]),
      ),
    );
  }
}
