// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pets/pets_screen.dart';
import '../schedule/feeding_screen.dart';
import '../health/vaccination_screen.dart';
import '../health/medication_screen.dart';
import '../schedule/appointment_screen.dart';
import '../health/activity_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';
    final displayName = userName.isNotEmpty
        ? userName[0].toUpperCase() + userName.substring(1)
        : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.pets, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 8),
          const Text('PetCare',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, $displayName!',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("You have upcoming tasks today.",
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 28),
            const Text('QUICK ACCESS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildGridCard(context, icon: Icons.pets, title: 'My Pets', subtitle: 'Manage pet profiles', destination: const PetsScreen()),
                _buildGridCard(context, icon: Icons.restaurant, title: 'Feeding Schedule', subtitle: 'Daily meal times', destination: const FeedingScreen()),
                _buildGridCard(context, icon: Icons.vaccines, title: 'Vaccinations', subtitle: 'Records & Due Dates', destination: const VaccinationScreen()),
                _buildGridCard(context, icon: Icons.medication, title: 'Medications', subtitle: 'Daily reminders', destination: const MedicationScreen()),
                _buildGridCard(context, icon: Icons.local_hospital, title: 'Vet Appointments', subtitle: 'Upcoming visits', destination: const AppointmentScreen()),
                _buildGridCard(context, icon: Icons.directions_run, title: 'Activity Tracker', subtitle: 'Exercise & Play', destination: const ActivityScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required Widget destination}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2563EB), size: 26),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
