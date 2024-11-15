// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lc_frontend/views/USR_creation/USR_projects.dart';
import 'package:lc_frontend/views/USR_validation/home_page.dart';

class USRNavigationMenu extends StatefulWidget {
  const USRNavigationMenu({super.key});

  @override
  State<USRNavigationMenu> createState() => _USRNavigationMenuState();
}

class _USRNavigationMenuState extends State<USRNavigationMenu> {
  String _username = 'Loading...';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    String? username = await _storage.read(key: 'username');
    setState(() {
      _username = username ?? 'Unknown User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 10),
                Text(
                  _username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to Profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const USRProjectsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await _storage.deleteAll(); // Clear secure storage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
