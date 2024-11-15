// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';

class ChapterTextTab extends StatefulWidget {
  final int chapterId;

  const ChapterTextTab({super.key, required this.chapterId});

  @override
  _ChapterTextTabState createState() => _ChapterTextTabState();
}

class _ChapterTextTabState extends State<ChapterTextTab> {
  Future<String>? chapterContent;
  List<String> pages = [];
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    chapterContent = fetchChapterContent(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: chapterContent,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          String text = snapshot.data!;
          pages = splitTextIntoPages(text);
          return Container(
            color: Colors.grey.shade200,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      pages.isNotEmpty ? pages[currentPageIndex] : "Loading...",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                if (pages.isNotEmpty) _buildPaginationControls(),
              ],
            ),
          );
        } else {
          return const Center(child: Text("No data found."));
        }
      },
    );
  }

  List<String> splitTextIntoPages(String text) {
    // Split text logic remains the same
    int pageSize = 3000;
    List<String> splitPages = [];
    for (int i = 0; i < text.length; i += pageSize) {
      int end = (i + pageSize < text.length) ? i + pageSize : text.length;
      splitPages.add(text.substring(i, end));
    }
    return splitPages;
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: currentPageIndex > 0
              ? () => setState(() => currentPageIndex--)
              : null,
        ),
        Text('Page ${currentPageIndex + 1} of ${pages.length}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: currentPageIndex < pages.length - 1
              ? () => setState(() => currentPageIndex++)
              : null,
        ),
      ],
    );
  }

  Future<String> fetchChapterContent(int chapterId) async {
    print('Fetching chapter content for chapter ID: $chapterId');
    String baseUrl =
        'https://canvas.iiit.ac.in/lc/api/chapters/by_chapter/$chapterId/text';
    final String? jwtToken = await getJwtToken();

    if (jwtToken == null) {
      throw Exception('Failed to obtain JWT token.');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response and extract the "text" field
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String chapterText = jsonResponse['text'];

      return chapterText;
    } else {
      throw Exception('Failed to load chapter content: ${response.statusCode}');
    }
  }

  Future<String?> getJwtToken() async {
    try {
      final authService =
          AuthService(); // Adjust based on your AuthService implementation
      final token = await authService.getToken();

      if (token == null) {
        print("Failed to obtain JWT token.");
        return null;
      }
      print('JWT Token: $token');
      return token;
    } catch (e) {
      print('Error fetching JWT token: $e');
      return null;
    }
  }
}
