// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final displayName = email.split('@')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person, size: 44, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 12),
                  Text(displayName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('PET OWNER',
                        style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 6),
                  Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            // Settings Tiles
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _tile(Icons.settings, 'Account Settings', () {}),
                const Divider(height: 1, indent: 56),
                _tile(Icons.notifications_outlined, 'Notifications', () {}),
                const Divider(height: 1, indent: 56),
                _tile(Icons.help_outline, 'Help & Support', () {}),
              ]),
            ),
            const SizedBox(height: 16),
            // Logout
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text('Log Out',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                onTap: () => FirebaseAuth.instance.signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
