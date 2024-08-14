// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:lc_frontend/views/concept_definition_tab.dart';
// import '../models/segment.dart';
// import 'package:http/http.dart' as http;

// class DiscourseTab extends StatefulWidget {
//   final String chapterId;

//   const DiscourseTab({super.key, required this.chapterId});

//   @override
//   _DiscourseTabState createState() => _DiscourseTabState();
// }

// class _DiscourseTabState extends State<DiscourseTab> {
//   SubSegment? selectedSubSegment;
//   List<Segment> segments = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSegments();
//   }

//   Future<void> _fetchSegments() async {
//     try {
//       final token = await getJwtToken();
//       if (token == null) {
//         print("JWT token is null.");
//         return;
//       }

//       final url = Uri.parse(
//           'http://localhost:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         String jsonResponse = response.body;
//         List<dynamic> jsonSegments = jsonDecode(jsonResponse);
//         setState(() {
//           segments =
//               jsonSegments.map((json) => Segment.fromJson(json)).toList();
//         });
//       } else {
//         print('Failed to fetch segments: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching segments: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: buildSegmentList(),
//           ),
//           Expanded(
//             flex: 3,
//             child: selectedSubSegment == null
//                 ? const Center(
//                     child: Text('Select a subsegment to configure Discourse'))
//                 : buildDiscourseTable(selectedSubSegment!),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSegmentList() {
//     return ListView.builder(
//       itemCount: segments.length,
//       itemBuilder: (context, index) {
//         Segment segment = segments[index];
//         return ExpansionTile(
//           title: Text('${segment.mainSegment}: ${segment.text}'),
//           children: segment.subSegments.map((SubSegment subSegment) {
//             return ListTile(
//               leading: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundColor: subSegment.isConceptDefinitionComplete
//                         ? Colors.green[200]
//                         : Colors.grey[400],
//                     child: const Text('L',
//                         style: TextStyle(fontSize: 12, color: Colors.white)),
//                   ),
//                   const SizedBox(width: 2),
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundColor: subSegment.isDependencyRelationDefined
//                         ? Colors.green[200]
//                         : Colors.grey[400],
//                     child: const Text('R',
//                         style: TextStyle(fontSize: 12, color: Colors.white)),
//                   ),
//                   const SizedBox(width: 2),
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundColor: subSegment.isDiscourseDefined
//                         ? Colors.green[200]
//                         : Colors.grey[400],
//                     child: const Text('C',
//                         style: TextStyle(fontSize: 12, color: Colors.white)),
//                   ),
//                   const SizedBox(width: 2),
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundColor: subSegment.isDiscourseDefined
//                         ? Colors.green[200]
//                         : Colors.grey[400],
//                     child: const Text('D',
//                         style: TextStyle(fontSize: 12, color: Colors.white)),
//                   ),
//                 ],
//               ),
//               title: Text(subSegment.text),
//               subtitle: Text(subSegment.subIndex),
//               onTap: () => selectSubSegment(subSegment),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   void selectSubSegment(SubSegment subSegment) {
//     if (!subSegment.isConceptDefinitionComplete) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Incomplete Data"),
//             content: const Text(
//                 "Concept definition is not complete. Please complete that before proceeding."),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       setState(() {
//         selectedSubSegment = subSegment;
//       });
//     }
//   }

//   Widget buildDiscourseTable(SubSegment subSegment) {
//     TextEditingController DiscourseController =
//         TextEditingController(text: selectedSubSegment?.discourse);

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           DataTable(
//             columns: _buildHeaderRow(subSegment),
//             rows: _buildDataRows(subSegment),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           Row(
//             children: [
//               const Flexible(
//                 flex: 1,
//                 child: Text("Discourse"),
//               ),
//               const SizedBox(width: 20),
//               Flexible(
//                 flex: 3,
//                 child: TextField(
//                   controller: DiscourseController,
//                   decoration: const InputDecoration(
//                     hintText: "Enter details",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: () {
//               print(DiscourseController.text);
//               setState(() {
//                 subSegment.discourse = DiscourseController.text;
//                 subSegment.isDiscourseDefined = true;
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Discourse finalized successfully!'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               fixedSize: const Size(400, 55),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               "Finalize Discourse",
//               style: TextStyle(color: Colors.white),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   List<DataColumn> _buildHeaderRow(SubSegment subSegment) {
//     List<DataColumn> columns = [
//       const DataColumn(label: Text('Property')),
//       ...List.generate(subSegment.columnCount,
//           (index) => DataColumn(label: Text('Index ${index + 1}'))),
//     ];

//     return columns;
//   }

//   List<DataRow> _buildDataRows(SubSegment subSegment) {
//     List<String> properties = [
//       'Concept',
//       'Semantic Category',
//       'Morphological Semantics',
//       "Speaker's View"
//     ];

//     return properties.map((property) {
//       List<DataCell> cells = [
//         DataCell(Text(property)),
//         ...List.generate(subSegment.columnCount, (columnIndex) {
//           var conceptDef = subSegment.conceptDefinitions[columnIndex];
//           return DataCell(Text(conceptDef.getProperty(property)));
//         }),
//       ];

//       return DataRow(cells: cells);
//     }).toList();
//   }
// }

import 'package:flutter/material.dart';
import '../models/segment.dart';

class DiscourseTab extends StatefulWidget {
  final List<Segment> segments;

  const DiscourseTab({super.key, required this.segments});

  @override
  _DiscourseTabState createState() => _DiscourseTabState();
}

class _DiscourseTabState extends State<DiscourseTab> {
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
            flex: 3,
            child: selectedSubSegment == null
                ? const Center(
                    child: Text('Select a subsegment to configure Discourse'))
                : buildDiscourseTable(selectedSubSegment!),
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
          title: Text('${segment.mainSegment}: ${segment.text}'),
          children: segment.subSegments.map((SubSegment subSegment) {
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: subSegment.isConceptDefinitionComplete
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('L',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 2),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: subSegment.isDependencyRelationDefined
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('R',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 2),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: subSegment.isDiscourseDefined
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('C',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  const SizedBox(width: 2),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: subSegment.isDiscourseDefined
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('D',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
              title: Text(subSegment.text),
              subtitle: Text('${subSegment.subIndex}'),
              onTap: () => selectSubSegment(subSegment),
            );
          }).toList(),
        );
      },
    );
  }

  void selectSubSegment(SubSegment subSegment) {
    if (!subSegment.isConceptDefinitionComplete) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Incomplete Data"),
            content: const Text(
                "Concept definition is not complete. Please complete that before proceeding."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        selectedSubSegment = subSegment;
      });
    }
  }

  Widget buildDiscourseTable(SubSegment subSegment) {
    TextEditingController DiscourseController =
        TextEditingController(text: selectedSubSegment?.discourse);

    return SingleChildScrollView(
      child: Column(
        children: [
          DataTable(
            columns: _buildHeaderRow(subSegment),
            rows: _buildDataRows(subSegment),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Text("Discourse"),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 3,
                child: TextField(
                  controller: DiscourseController,
                  decoration: InputDecoration(
                    hintText: "Enter details",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              print(DiscourseController.text);
              setState(() {
                subSegment.discourse = DiscourseController.text;
                subSegment.isDiscourseDefined = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Discourse finalized successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              fixedSize: const Size(400, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Finalize Discourse",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  List<DataColumn> _buildHeaderRow(SubSegment subSegment) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('Property')),
      ...List.generate(subSegment.columnCount,
          (index) => DataColumn(label: Text('Index ${index + 1}'))),
    ];

    return columns;
  }

  List<DataRow> _buildDataRows(SubSegment subSegment) {
    List<String> properties = [
      'Concept',
      'Semantic Category',
      'Morphological Semantics',
      "Speaker's View"
    ];

    return properties.map((property) {
      List<DataCell> cells = [
        DataCell(Text(property)),
        ...List.generate(subSegment.columnCount, (columnIndex) {
          var conceptDef = subSegment.conceptDefinitions[columnIndex];
          return DataCell(Text(conceptDef.getProperty(property)));
        }),
      ];

      return DataRow(cells: cells);
    }).toList();
  }
}
