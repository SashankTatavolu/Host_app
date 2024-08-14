import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../views/lc_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu), // Hamburger icon
            onPressed: () {
              Scaffold.of(context)
                  .openDrawer(); // Open drawer on hamburger icon press
            },
          ),
          const SizedBox(
              width: 8), // Add spacing between hamburger icon and logo
          Image.asset('assets/images/logo.png'), // Your logo asset
        ],
      ),
      leadingWidth: 200,
      toolbarHeight: 100,
      backgroundColor: Colors.blueGrey.shade100,
      actions: [
        PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  // Navigate to profile page
                  Navigator.popAndPushNamed(context, '/profile');
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  // Clear token and navigate to LcPage
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'access_token');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LcPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
