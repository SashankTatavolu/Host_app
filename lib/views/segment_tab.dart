
import 'package:flutter/material.dart';

import '../models/segment.dart';
import '../widgets/segment_editor.dart';

class SegmentTab extends StatefulWidget {
  const SegmentTab({Key? key}) : super(key: key);

  @override
  _SegmentTabState createState() => _SegmentTabState();
}

class _SegmentTabState extends State<SegmentTab> {
  List<Segment> segments = [
    Segment(mainSegment: 1, subSegments: [
      SubSegment(text: "Segment 1a", subIndex: "1a", indexType: 'Normal'),
      SubSegment(text: "Segment 1b", subIndex: "1b", indexType:  'Normal'),
    ], text: 'The text is for segment 1'),
    Segment(mainSegment: 2, subSegments: [
      SubSegment(text: "Segment 2a", subIndex: "2a", indexType:  'Normal'),
    ], text: 'The text is for segment 2'),
  ];

  static const int itemsPerPage = 3;  // Define how many segments to display per page
  int currentPage = 0;

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
              icon: Icon(Icons.arrow_back_ios),
              onPressed: currentPage > 0 ? previousPage : null,
              tooltip: 'Previous Page',
            ),
            Text('Page ${currentPage + 1} of $totalPages'),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: currentPage < totalPages - 1 ? nextPage : null,
              tooltip: 'Next Page',
            ),
          ],
        ),
      ],
    );
  }
}
