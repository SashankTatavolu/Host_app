import 'package:flutter/material.dart';

import '../models/segment.dart';

class USRPage extends StatefulWidget {
  final List<Segment> segments;

  USRPage({Key? key, required this.segments}) : super(key: key);

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
                ? Center(child: Text('Select a subsegment to configure.'))
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
              trailing: selectedSubSegment == subSegment ? Icon(Icons.check) : null,
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
          title: Text("Specify number of columns"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter number of columns",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                int? columns = int.tryParse(controller.text);
                if (columns != null) {
                  setState(() {
                    subSegment.columnCount = columns;
                    subSegment.tableData = List.generate(7, (_) => List.filled(columns, ''));
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
          DataColumn(label: Text('Index')),
          ...List.generate(subSegment.columnCount ?? 0, (index) => DataColumn(label: Text('${index + 1}')))
        ],
        rows: List.generate(6, (index) => DataRow(
          cells: [
            DataCell(
                Text(["Row 1 [Concept]", "Row 2 [Sem Cat]", "Row 3 [Morph Sem]",
              "Row 4 [Discourse]", "Row 5 [Speakers View]",
              "Row 6 [Scope]"][index])),
            ...List.generate(subSegment.columnCount ?? 0, (colIndex) => DataCell(
              buildTextCell(subSegment, index, colIndex),
            )),
          ],
        )),
      ),
    );
  }

  Widget buildTextCell(SubSegment subSegment, int rowIndex, int colIndex) {
    return Container(
      width: 150,  // Adjust this width as needed
      child: TextField(controller: TextEditingController(),),
    );
  }

}
