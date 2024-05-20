import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Image.asset('assets/images/logo.png'),
      leadingWidth: 200,
      toolbarHeight: 100,
      backgroundColor: Colors.blueGrey.shade100,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}
