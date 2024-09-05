import 'package:flutter/material.dart';
import 'package:nithlostnfound/Pages/Setting/about_page.dart';
import 'package:nithlostnfound/Pages/Setting/reset_passwor.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepOrange, // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               // color: Colors.deepPurple, // Header text color
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Setting
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.deepPurple), // Icon color
              title: const Text('Reset Password'),
              onTap: () {
               
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                );
              },
              tileColor: Colors.deepPurple[50], // Tile background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            const SizedBox(height: 8),

            // Privacy & Security Setting
            ListTile(
              leading: const Icon(Icons.security, color: Colors.deepPurple),
              title: const Text('Privacy & Security'),
              onTap: () {
                // Implement privacy & security settings
              },
              tileColor: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),

            // Language Setting
            ListTile(
              leading: const Icon(Icons.language, color: Colors.deepPurple),
              title: const Text('Language'),
              onTap: () {
                // Implement language settings
              },
              tileColor: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            const SizedBox(height: 8),

            // Notifications Setting
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.deepPurple),
              title: const Text('About Developer'),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
              tileColor: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Your Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            // Add form fields for editing profile information here
          ],
        ),
      ),
    );
  }
}
