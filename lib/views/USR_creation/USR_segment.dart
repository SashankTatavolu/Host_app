import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lc_frontend/views/USR_validation/concept_definition_tab.dart';
import '/models/segment.dart';
import '/widgets/segment_editor.dart';

class USRSegmentTab extends StatefulWidget {
  final int chapterId;

  const USRSegmentTab({super.key, required this.chapterId});

  @override
  _USRSegmentTabState createState() => _USRSegmentTabState();
}

class _USRSegmentTabState extends State<USRSegmentTab> {
  static const int itemsPerPage = 3; // Number of segments to display per page
  int currentPage = 0;
  List<Segment> segments = [];
  bool isLoading = true; // Loading spinner state

  @override
  void initState() {
    super.initState();
    _checkAndFetchSegments(); // Check if segments exist, then fetch or generate them
  }

  Future<void> _checkAndFetchSegments() async {
    try {
      // Try fetching the segments first
      await _fetchSegments();

      // If no segments are present, generate them
      if (segments.isEmpty) {
        await _generateSegmentsForChapter();
        await _fetchSegments(); // Fetch again after generation
      }
    } catch (e) {
      print("Error checking and fetching segments: $e");
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _fetchSegments() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      final url = Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        List<dynamic> jsonSegments = jsonDecode(jsonResponse);
        if (mounted) {
          setState(() {
            segments =
                jsonSegments.map((json) => Segment.fromJson(json)).toList();
            isLoading = false; // Stop loading once segments are fetched
          });
        }
      } else {
        print('Failed to fetch segments: ${response.statusCode}');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    } catch (e) {
      print('Error fetching segments: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _generateSegmentsForChapter() async {
    try {
      // Fetch chapter content
      String chapterText = await fetchChapterContent(widget.chapterId);

      // Send a POST request to process the chapter text and generate segments
      await _processChapterText(widget.chapterId, chapterText);
      print('Segments generated successfully.');
    } catch (e) {
      print('Error generating segments: $e');
    }
  }

  // Method to fetch chapter content (required for generating segments)
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

  // Processing chapter text to generate segments via POST request
  Future<void> _processChapterText(int chapterId, String chapterText) async {
    final String? jwtToken = await getJwtToken();

    if (jwtToken == null) {
      throw Exception('Failed to obtain JWT token.');
    }

    String url =
        'https://canvas.iiit.ac.in/lc/api/segment_details/process_text';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'chapter_id': chapterId.toString(),
        'chapter_data': chapterText,
      }),
    );

    if (response.statusCode == 200) {
      print("Chapter processed successfully for segment generation.");
    } else {
      throw Exception('Failed to generate segments: ${response.statusCode}');
    }
  }

  // Pagination and display logic
  int get totalPages => (segments.length / itemsPerPage).ceil();

  List<Segment> getVisibleSegments() {
    int start = currentPage * itemsPerPage;
    int end = start + itemsPerPage;
    if (end > segments.length) {
      end = segments.length;
    }
    return segments.sublist(start, end);
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Segment> visibleSegments = getVisibleSegments();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: visibleSegments.length,
            itemBuilder: (context, index) {
              return SegmentEditor(
                segment: visibleSegments[index],
                onSubSegmentChanged: (subSegments) {
                  setState(() {
                    visibleSegments[index].subSegments = subSegments;
                  });
                },
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: currentPage > 0 ? previousPage : null,
              tooltip: 'Previous Page',
            ),
            Text('Page ${currentPage + 1} of $totalPages'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: currentPage < totalPages - 1 ? nextPage : null,
              tooltip: 'Next Page',
            ),
          ],
        ),
      ],
    );
  }
}
