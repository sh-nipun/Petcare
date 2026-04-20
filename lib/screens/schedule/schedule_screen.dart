// lib/screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import 'feeding_screen.dart';
import 'appointment_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MANAGE SCHEDULES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              icon: Icons.restaurant,
              color: const Color(0xFFFF6B35),
              title: 'Feeding Schedule',
              subtitle: 'Daily meal times & food types',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedingScreen())),
            ),
            const SizedBox(height: 12),
            _buildNavCard(
              context,
              icon: Icons.local_hospital,
              color: const Color(0xFF2563EB),
              title: 'Vet Appointments',
              subtitle: 'Upcoming veterinary visits',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentScreen())),
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
