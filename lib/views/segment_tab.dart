// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/segment.dart';
// import 'package:http/http.dart' as http;

// import '../services/auth_service.dart';
// import '../widgets/segment_editor.dart';

// class SegmentTab extends StatefulWidget {
//   final int chapterId;

//   const SegmentTab({Key? key, required this.chapterId}) : super(key: key);

//   @override
//   _SegmentTabState createState() => _SegmentTabState();
// }

// class _SegmentTabState extends State<SegmentTab> {
//   static const int itemsPerPage = 3;
//   int currentPage = 0;
//   List<Segment> segments = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchSegments();
//   }

//   Future<void> fetchSegments() async {
//     String? token = await getJwtToken();
//     if (token == null) return;

//     final response = await http.get(
//       Uri.parse(
//           'http://10.2.8.12:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       setState(() {
//         segments = data.map((segment) {
//           int mainSegment = int.parse(segment['sentence_id'].split('_').last);
//           return Segment(
//             mainSegment: mainSegment,
//             text: segment['text'],
//             subSegments: segment['segments'].map<SubSegment>((subSegment) {
//               return SubSegment(
//                 text: subSegment['segment_text'],
//                 subIndex: subSegment['segment_index'],
//                 indexType: subSegment['index_type'],
//               );
//             }).toList(),
//           );
//         }).toList();
//         isLoading = false;
//       });
//     } else {
//       // Handle error
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<String?> getJwtToken() async {
//     try {
//       // Assuming you have an AuthService that provides the JWT token
//       final authService = AuthService();
//       final token = await authService.getToken();
//       return token;
//     } catch (e) {
//       print('Error fetching JWT token: $e');
//       return null;
//     }
//   }

//   int get totalPages => (segments.length / itemsPerPage).ceil();

//   List<Segment> getVisibleSegments() {
//     int start = currentPage * itemsPerPage;
//     int end = start + itemsPerPage;
//     if (end > segments.length) {
//       end = segments.length;
//     }
//     return segments.sublist(start, end);
//   }

//   void nextPage() {
//     if (currentPage < totalPages - 1) {
//       setState(() {
//         currentPage++;
//       });
//     }
//   }

//   void previousPage() {
//     if (currentPage > 0) {
//       setState(() {
//         currentPage--;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     List<Segment> visibleSegments = getVisibleSegments();
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: visibleSegments.length,
//             itemBuilder: (context, index) {
//               return SegmentEditor(
//                 segment: visibleSegments[index],
//                 onSubSegmentChanged: (subSegments) {
//                   setState(() {
//                     visibleSegments[index].subSegments = subSegments;
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: currentPage > 0 ? previousPage : null,
//               tooltip: 'Previous Page',
//             ),
//             Text('Page ${currentPage + 1} of $totalPages'),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward_ios),
//               onPressed: currentPage < totalPages - 1 ? nextPage : null,
//               tooltip: 'Next Page',
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/segment.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../widgets/segment_editor.dart';

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
          'http://10.2.8.12:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments'),
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
