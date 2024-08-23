// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../models/segment.dart';

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
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'Header'),
                    child: const Text('Header'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
              // segmentId: int.parse('segmentId'),
              columnCount: 0,
              dependencyRelations: []);
          if (selectedType == 'Title' || selectedType == 'Header') {
            widget.segment.subSegments
                .insert(0, newSubSegment); // Insert at top for Title and Header
          } else {
            widget.segment.subSegments
                .add(newSubSegment); // Append at bottom for Normal
          }
          widget.onSubSegmentChanged(widget.segment.subSegments);
        });
      }
    });
  }

  String getNextSubSegmentIndex(String type) {
    // Generate next index based on type and existing entries
    if (type == 'Title' || type == 'Header') {
      return "${widget.segment.mainSegment}$type";
    } else {
      // Calculate next alphabet character for sub-segment
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
              onPressed: () => setState(() => isEditing = !isEditing),
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
                  onPressed: () {
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
                title: Text(
                    '${subSegment.subIndex} : ${subSegment.text} (${subSegment.indexType})'),
              ),
          ],
        ],
      ),
    );
  }
}
