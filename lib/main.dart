// import 'package:flutter/material.dart';
// import 'views/lc_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LcPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
// import 'package:lc_frontend/views/home_page.dart';
import 'package:lc_frontend/views/USR_validation/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  final storage = const FlutterSecureStorage();

  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: storage.read(key: 'access_token'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
