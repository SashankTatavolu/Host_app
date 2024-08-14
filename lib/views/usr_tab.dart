// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../models/segment.dart';

class USRPage extends StatefulWidget {
  final List<Segment> segments;

  const USRPage({super.key, required this.segments});

  @override
  _USRPageState createState() => _USRPageState();
}

class _USRPageState extends State<USRPage> {
  SubSegment? selectedSubSegment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: buildSegmentList(),
          ),
          Expanded(
            flex: 2,
            child: selectedSubSegment == null
                ? const Center(child: Text('Select a subsegment to configure.'))
                : buildTableConfiguration(selectedSubSegment!),
          ),
        ],
      ),
    );
  }

  Widget buildSegmentList() {
    return ListView.builder(
      itemCount: widget.segments.length,
      itemBuilder: (context, index) {
        Segment segment = widget.segments[index];
        return ExpansionTile(
          title: Text('Segment ${segment.mainSegment}: ${segment.text}'),
          children: segment.subSegments.map((subSegment) {
            return ListTile(
              title: Text(subSegment.text),
              subtitle: Text('Sub-segment: ${subSegment.subIndex}'),
              onTap: () => _selectSubSegment(subSegment),
              selected: selectedSubSegment == subSegment,
              trailing: selectedSubSegment == subSegment
                  ? const Icon(Icons.check)
                  : null,
            );
          }).toList(),
        );
      },
    );
  }

  void _selectSubSegment(SubSegment subSegment) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text("Specify number of columns"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter number of columns",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                int? columns = int.tryParse(controller.text);
                if (columns != null) {
                  setState(() {
                    subSegment.columnCount = columns;
                    subSegment.tableData =
                        List.generate(7, (_) => List.filled(columns, ''));
                    selectedSubSegment = subSegment;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildTableConfiguration(SubSegment subSegment) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 48,
        columns: [
          const DataColumn(label: Text('Index')),
          ...List.generate(subSegment.columnCount,
              (index) => DataColumn(label: Text('${index + 1}')))
        ],
        rows: List.generate(
            6,
            (index) => DataRow(
                  cells: [
                    DataCell(Text([
                      "Row 1 [Concept]",
                      "Row 2 [Sem Cat]",
                      "Row 3 [Morph Sem]",
                      "Row 4 [Discourse]",
                      "Row 5 [Speakers View]",
                      "Row 6 [Scope]"
                    ][index])),
                    ...List.generate(
                        subSegment.columnCount,
                        (colIndex) => DataCell(
                              buildTextCell(subSegment, index, colIndex),
                            )),
                  ],
                )),
      ),
    );
  }

  Widget buildTextCell(SubSegment subSegment, int rowIndex, int colIndex) {
    return SizedBox(
      width: 150, // Adjust this width as needed
      child: TextField(
        controller: TextEditingController(),
      ),
    );
  }
}
