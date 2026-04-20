// lib/screens/health/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/activity_model.dart';
import '../../services/database_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final DatabaseService _db = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showForm() {
    final petCtrl = TextEditingController();
    final activityCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

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
            const Text('Log New Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: petCtrl,
              decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: activityCtrl,
              decoration: const InputDecoration(
                  labelText: 'Activity (e.g. Laser Chasing, Walking)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Duration (minutes)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (activityCtrl.text.isEmpty) return;
                final a = Activity(
                  id: '',
                  ownerId: userId,
                  petName: petCtrl.text.trim(),
                  activityName: activityCtrl.text.trim(),
                  durationMinutes: int.tryParse(durationCtrl.text) ?? 0,
                  date: DateTime.now(),
                );
                await _db.addActivity(a);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Log Activity', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<double> _buildWeeklyData(List<Activity> activities) {
    final now = DateTime.now();
    final List<double> data = List.filled(7, 0);
    for (final a in activities) {
      final diff = now.weekday - a.date.weekday;
      if (diff >= 0 && diff < 7 && now.difference(a.date).inDays < 7) {
        final idx = a.date.weekday - 1; // Mon=0 ... Sun=6
        if (idx >= 0 && idx < 7) {
          data[idx] += a.durationMinutes.toDouble();
        }
      }
    }
    return data;
  }

  List<Activity> _getTodayActivities(List<Activity> all) {
    final today = DateTime.now();
    return all.where((a) =>
        a.date.year == today.year &&
        a.date.month == today.month &&
        a.date.day == today.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Pet Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Activity>>(
        stream: _db.getUserActivities(userId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data ?? [];
          final weeklyData = _buildWeeklyData(all);
          final todayActivities = _getTodayActivities(all);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Weekly Chart Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.show_chart, color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      const Text('Weekly Overview',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      const Text('This Week',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 20).clamp(20, double.infinity),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Text(days[val.toInt()],
                                      style: const TextStyle(fontSize: 10, color: Colors.grey));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: weeklyData.asMap().entries.map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value == 0 ? 2 : e.value,
                                color: const Color(0xFF2563EB),
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Text("TODAY'S LOGS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              if (todayActivities.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No activities logged today',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                )
              else
                ...todayActivities.map((a) => _buildActivityTile(a)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showForm,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static const _activityIcons = ['🎯', '🪶', '🌿', '🏃', '🎾', '🐟'];

  Widget _buildActivityTile(Activity a) {
    final icon = _activityIcons[a.activityName.length % _activityIcons.length];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(a.activityName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: a.petName.isNotEmpty ? Text(a.petName) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${a.durationMinutes} mins',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                onPressed: () => _db.deleteActivity(a.id),
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ],
        ),
      ),
    );
  }
}
