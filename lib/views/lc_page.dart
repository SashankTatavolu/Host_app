import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';

class LcPage extends StatelessWidget {
  const LcPage({super.key});

  // Function to open the .doc file

  Future<void> _openDocFile() async {
    final Uri url = Uri.parse('https://example.com/your-document.doc');
    try {
      await launchUrl(url);
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Image.asset(
                'assets/images/logo.png',
                height: 50,
              ),
            ), // Main logo at the top left
            TextButton.icon(
              onPressed: () {
                // Navigate to the Login Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(
                Icons.person,
                color: Colors.black, // Changed icon color to white
              ),
              label: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black, // Changed text color to white
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Welcome to Language Communicator!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Your platform for seamless language communication.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width * 0.9, // Adjusted width
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        const SizedBox(height: 10),
                        const Text(
                          'We apply insights from Indian Grammatical Tradition to design Universal Semantic Representation (USR) for discourse. We can generate documents in multiple languages from these representations.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/images/About.png', // Your image asset
                            width: MediaQuery.of(context).size.width * 0.9,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'The above diagram represents a complex sentence structure. Here is what it illustrates: \n\n'
                          'Hindi: राम ने सुबह से शाम तक पढ़ाई की । क्युंकि कल परीक्षा है और इसमें वह सफलता चाहता है । \n\n'
                          'English: Ram studied from morning till evening because the exam is tomorrow and he wants success in it. \n\n'
                          'You can use our authoring interface to write content or upload the same. The authoring interface will guide you to convert your content into Universal Semantic Representation.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _openDocFile,
                            child: const Text('Open Document'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to About Us page
                        },
                        child: const Text('About Us'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Contact Us page
                        },
                        child: const Text('Contact Us'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/institution1.png',
                        height: 50,
                      ), // Institution 1 logo
                      const SizedBox(width: 20),
                      Image.asset(
                        'assets/images/institution2.png',
                        height: 50,
                      ), // Institution 2 logo
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
