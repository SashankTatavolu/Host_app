import 'package:flutter/material.dart';
import 'login_page.dart';

class LcPage extends StatelessWidget {
  const LcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/images/logo.png',
            height: 50,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.indigo,
            ),
            label: const Text(
              'Login',
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade300, Colors.indigo.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Welcome to Language Communicator!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your platform for seamless language communication.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.indigo.shade100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Language Communicator',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'We apply insights from Indian Grammatical Tradition to design Universal Semantic Representation (USR) for discourse. We can generate documents in multiple languages from these representations.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                'assets/images/About.png',
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width * 0.35,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Text(
                                'The above diagram represents a complex sentence structure. Here is what it illustrates:\n\n'
                                'Hindi: राम ने सुबह से शाम तक पढ़ाई की । क्युंकि कल परीक्षा है और इसमें वह सफलता चाहता है ।\n\n'
                                'English: Ram studied from morning till evening because the exam is tomorrow and he wants success in it.\n\n'
                                'You can use our authoring interface to write content or upload the same. The authoring interface will guide you to convert your content into Universal Semantic Representation.',
                                style: TextStyle(fontSize: 16, height: 1.5),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'About Us',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Contact Us',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/institution1.png',
                        height: 50,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'assets/images/institution2.png',
                        height: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
