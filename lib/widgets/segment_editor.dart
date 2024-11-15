import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/segment.dart';
import '../services/auth_service.dart'; // Import your AuthService

class SegmentEditor extends StatefulWidget {
  final Segment segment;
  final Function(List<SubSegment>) onSubSegmentChanged;

  const SegmentEditor({
    super.key,
    required this.segment,
    required this.onSubSegmentChanged,
  });

  @override
  _SegmentEditorState createState() => _SegmentEditorState();
}

class _SegmentEditorState extends State<SegmentEditor> {
  bool isEditing = false;

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

  // API call to save edited segment
  Future<void> saveEditedSegment() async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) return;

    final url = Uri.parse(
        'https://canvas.iiit.ac.in/lc/api/segments/sentence/${widget.segment.mainSegment}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };

    // Create a list of subsegment JSON objects
    final List<Map<String, dynamic>> subSegmentList =
        widget.segment.subSegments.map((subSegment) {
      return {
        "segment_index": subSegment.subIndex,
        "segment_text": subSegment.text,
        "segment_type": "type", // Use actual segment type
        "index_type": "type", // Use actual index type
      };
    }).toList();

    final body = jsonEncode(subSegmentList);

    print(body);

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Segment saved successfully');
      } else {
        print('Failed to save segment: ${response.body}');
      }
    } catch (e) {
      print('Error saving segment: $e');
    }
  }

  // API call to delete a segment
  Future<void> deleteSegment(int segmentId) async {
    try {
      // Get JWT token
      String? jwtToken = await getJwtToken();
      if (jwtToken == null) {
        throw Exception('JWT token not found');
      }

      // Make DELETE request
      final url =
          Uri.parse('https://canvas.iiit.ac.in/lc/api/segments/$segmentId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Segment deleted successfully');
      } else {
        print('Failed to delete segment: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addSubSegment() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Sub-segment Type'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'Title'),
                    child: const Text('Title'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'Header'),
                    child: const Text('Header'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'Normal'),
                    child: const Text('Normal'),
                  ),
                ],
              ),
            ),
          );
        }).then((selectedType) {
      if (selectedType != null) {
        String newSubIndex = getNextSubSegmentIndex(selectedType);
        setState(() {
          SubSegment newSubSegment = SubSegment(
            text: "New $selectedType Sub-segment",
            subIndex: newSubIndex,
            indexType: selectedType,
            columnCount: 0,
            dependencyRelations: [],
          );
          if (selectedType == 'Title' || selectedType == 'Header') {
            widget.segment.subSegments.insert(0, newSubSegment);
          } else {
            widget.segment.subSegments.add(newSubSegment);
          }
          widget.onSubSegmentChanged(widget.segment.subSegments);
        });
      }
    });
  }

  String getNextSubSegmentIndex(String type) {
    if (type == 'Title' || type == 'Header') {
      return "${widget.segment.mainSegment}$type";
    } else {
      int lastIndex = 0;
      for (var subSegment in widget.segment.subSegments) {
        if (subSegment.indexType == 'Normal') {
          int charCode =
              subSegment.subIndex.codeUnitAt(subSegment.subIndex.length - 1);
          if (charCode > lastIndex) {
            lastIndex = charCode;
          }
        }
      }
      return "${widget.segment.mainSegment}${String.fromCharCode(lastIndex + 1)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title:
                Text('${widget.segment.mainSegment}. ${widget.segment.text}'),
            trailing: IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  await saveEditedSegment();
                }
                setState(() => isEditing = !isEditing);
              },
            ),
          ),
          if (isEditing) ...[
            for (int i = 0; i < widget.segment.subSegments.length; i++)
              ListTile(
                title: TextFormField(
                  initialValue: widget.segment.subSegments[i].text,
                  onFieldSubmitted: (val) {
                    widget.segment.subSegments[i].text = val;
                    widget.onSubSegmentChanged(widget.segment.subSegments);
                  },
                ),
                subtitle: Text(widget.segment.subSegments[i].subIndex),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final segmentId = widget.segment.subSegments[i]
                        .segmentId; // Assuming subIndex is the segmentId
                    await deleteSegment((segmentId));
                    setState(() {
                      widget.segment.subSegments.removeAt(i);
                      widget.onSubSegmentChanged(widget.segment.subSegments);
                    });
                  },
                ),
              ),
            ListTile(
              title: TextButton(
                onPressed: _addSubSegment,
                child: const Text("Add Sub-segment"),
              ),
            ),
          ] else ...[
            for (var subSegment in widget.segment.subSegments)
              ListTile(
                title: Text('${subSegment.subIndex} : ${subSegment.text}'),
              ),
          ],
        ],
      ),
    );
  }
}
