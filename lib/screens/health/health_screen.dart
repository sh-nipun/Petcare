// lib/screens/health/health_screen.dart
import 'package:flutter/material.dart';
import 'vaccination_screen.dart';
import 'medication_screen.dart';
import 'activity_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Health', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HEALTH MANAGEMENT',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              icon: Icons.vaccines,
              color: const Color(0xFF22C55E),
              title: 'Vaccinations',
              subtitle: 'Records & due dates',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationScreen())),
            ),
            const SizedBox(height: 12),
            _buildNavCard(
              context,
              icon: Icons.medication,
              color: const Color(0xFFF59E0B),
              title: 'Medications',
              subtitle: 'Daily reminders & dosage',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationScreen())),
            ),
            const SizedBox(height: 12),
            _buildNavCard(
              context,
              icon: Icons.directions_run,
              color: const Color(0xFF8B5CF6),
              title: 'Activity Tracker',
              subtitle: 'Exercise & play logs',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}
