// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/segment.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
// import '../widgets/segment_editor.dart';
import 'package:pdfrx/pdfrx.dart';

class SegmentTab extends StatefulWidget {
  final int chapterId;

  const SegmentTab({super.key, required this.chapterId});

  @override
  _SegmentTabState createState() => _SegmentTabState();
}

class _SegmentTabState extends State<SegmentTab> {
  static const int itemsPerPage = 3;
  int currentPage = 0;
  List<Segment> segments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSegments();
  }

  Future<void> fetchSegments() async {
    String? token = await getJwtToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          'http://localhost:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            segments = data.map<Segment>((segment) {
              String sentenceId = segment['sentence_id'];
              String mainSegment = _extractMainSegment(sentenceId);
              return Segment(
                mainSegment: mainSegment,
                text: segment['text'],
                subSegments:
                    (segment['segments'] as List).map<SubSegment>((subSegment) {
                  return SubSegment(
                    text:
                        subSegment['segment_text'] ?? '', // Handle null values
                    subIndex: subSegment['segment_index'] ?? 0,
                    indexType: subSegment['index_type'] ?? '',
                    segmentId: int.parse(subSegment['segment_id'].toString()),
                    columnCount: ['lexico_conceptual'].length,
                    dependencyRelations: [], // Convert correctly
                  );
                }).toList(),
              );
            }).toList();
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error parsing JSON data: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _extractMainSegment(String sentenceId) {
    final regex = RegExp(r'0+([0-9]+[a-zA-Z]*)');
    final match = regex.firstMatch(sentenceId);
    if (match != null) {
      return match.group(1) ?? sentenceId;
    }
    return sentenceId;
  }

  Future<String?> getJwtToken() async {
    try {
      // Assuming you have an AuthService that provides the JWT token
      final authService = AuthService();
      final token = await authService.getToken();
      return token;
    } catch (e) {
      print('Error fetching JWT token: $e');
      return null;
    }
  }

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

  void _showPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("PDF Content"),
          content: SizedBox(
            width: 1000,
            height: 600,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 1000,
                height: 600,
                child: PdfViewer.asset(
                    'assets/files/USR_Sentence_Segmentation.pdf'),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Segment> visibleSegments = getVisibleSegments();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _showPdf(context),
            child: const Text('Show PDF'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visibleSegments.length,
            itemBuilder: (context, index) {
              final segment = visibleSegments[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${segment.mainSegment}.${segment.text}'),
                      const SizedBox(height: 25),
                      ...segment.subSegments.map((subSegment) {
                        return Text(
                            '${subSegment.subIndex} ${subSegment.text}');
                      }),
                    ],
                  ),
                ),
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
