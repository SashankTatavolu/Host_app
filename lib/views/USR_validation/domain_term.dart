// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import '../../models/segment.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:pdfrx/pdfrx.dart';
// import 'concept_definition_tab.dart';

// class DomainTermTab extends StatefulWidget {
//   final int chapterId;

//   const DomainTermTab({super.key, required this.chapterId});

//   @override
//   _DomainTermTabState createState() => _DomainTermTabState();
// }

// class _DomainTermTabState extends State<DomainTermTab> {
//   SubSegment? selectedSubSegment;
//   List<Segment> segments = [];
//   double segmentPanelWidth = 250.0; // Initial width for the segment panel
//   double minWidth = 150.0; // Minimum width for the segment panel
//   double maxWidth = 400.0;
//   Map<String, dynamic>? segmentDetails;
//   int columnCount = 0;
//   SubSegment? dropdownSelectedSubSegment;
//   List<dynamic>? discourseArray;
//   List<bool>? selectedDiscourseIndices;

//   String? selectedDomainTerm;

//   Map<SubSegment, Map<int, String>> selectedDomainTermsPerSubSegment = {};

//   final List<String> domainOptions = [
//     '-',
//     'dm_geo_B',
//     'dm_geo_I',
//     'dm_geography physical_B',
//     'dm_geography physical_I',
//     'dm_recipe_B',
//     'dm_recipe_I'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSegments(); // Fetch segments when the widget is initialized
//   }

//   Future<void> _fetchSegments() async {
//     try {
//       final token = await getJwtToken();
//       if (token == null) {
//         print("JWT token is null.");
//         return;
//       }

//       final url = Uri.parse(
//           'https://canvas.iiit.ac.in/lc/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       // print('Response status: ${response.statusCode}');
//       // print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         String jsonResponse = response.body;
//         List<dynamic> jsonSegments = jsonDecode(jsonResponse);
//         setState(() {
//           segments =
//               jsonSegments.map((json) => Segment.fromJson(json)).toList();
//         });

//         // for (var segment in segments) {
//         //   for (var subSegment in segment.subSegments) {
//         //     print(
//         //         'SubSegment text: ${subSegment.text}, segmentId: ${subSegment.segmentId}');
//         //   }
//         // }

//         // Optionally, fetch concept details if needed
//         // await _fetchConceptDetails(token);
//       } else {
//         print('Failed to fetch segments: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching segments: $e');
//     }
//   }

//   Future<bool> _isConceptDefinitionComplete(int segmentId) async {
//     try {
//       final token = await getJwtToken();
//       if (token == null) {
//         print("JWT token is null.");
//         return false;
//       }

//       final url = Uri.parse(
//           'https://canvas.iiit.ac.in/lc/api/lexicals/segment/$segmentId/is_concept_generated');
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         print('isConceptDefinitionComplete response: $jsonResponse');
//         columnCount = jsonResponse['column_count'] ?? 0;
//         return jsonResponse['is_concept_generated'] ?? false;
//       } else {
//         print(
//             'Failed to check concept definition status: ${response.statusCode}');
//         return false;
//       }
//     } catch (e) {
//       print('Error checking concept definition status: $e');
//       return false;
//     }
//   }

//   Future<void> _fetchSegmentDetails(int segmentId) async {
//     try {
//       final token = await getJwtToken();
//       if (token == null) {
//         print("JWT token is null.");
//         return;
//       }

//       final url = Uri.parse(
//           'https://canvas.iiit.ac.in/lc/api/segment_details/segment_details/$segmentId');
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final List<dynamic> conceptJsonList =
//             jsonResponse['lexico_conceptual'] ?? [];

//         // Parse concept definitions
//         final List<ConceptDefinition> conceptDefinitions = conceptJsonList
//             .map((conceptJson) => ConceptDefinition.fromJson(conceptJson))
//             .toList();

//         final List<dynamic> domainTermArray = jsonResponse['domain_term'] ?? [];

//         setState(() {
//           segmentDetails = jsonResponse;
//           selectedSubSegment?.conceptDefinitions =
//               conceptDefinitions; // Update conceptDefinitions
//           selectedDomainTermsPerSubSegment[selectedSubSegment!] = {
//             for (var item in domainTermArray) item['index']: item['domain_term']
//           };
//         });

//         // print('Fetched concept definitions: $conceptDefinitions');
//       } else {
//         print('Failed to fetch segment details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching segment details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           SizedBox(
//             width: segmentPanelWidth,
//             child: buildSegmentList(),
//           ),
//           MouseRegion(
//             cursor: SystemMouseCursors.resizeLeftRight,
//             child: GestureDetector(
//               onHorizontalDragUpdate: (details) {
//                 setState(() {
//                   segmentPanelWidth =
//                       (segmentPanelWidth + details.primaryDelta!)
//                           .clamp(minWidth, maxWidth);
//                 });
//               },
//               child: Container(
//                 width: 10,
//                 color: Colors.grey[300],
//                 child: const Center(
//                   child: Icon(Icons.drag_handle, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: selectedSubSegment == null
//                 ? const Center(
//                     child: Text('Select a subsegment to configure Discourse'))
//                 : buildDomainTable(selectedSubSegment!),
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
//           title: SelectableText(
//             '${segment.mainSegment}: ${segment.text}',
//             style: const TextStyle(color: Colors.black),
//           ),
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
//               title: SelectableText(
//                 subSegment.text, // Make the subsegment text selectable
//                 style: const TextStyle(color: Colors.black),
//               ),
//               subtitle: SelectableText(
//                 subSegment.subIndex, // Make the subsegment index selectable
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               onTap: () => selectSubSegment(subSegment),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   void selectSubSegment(SubSegment subSegment) async {
//     bool isComplete = await _isConceptDefinitionComplete(subSegment.segmentId);

//     if (!isComplete) {
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
//       await _fetchSegmentDetails(subSegment.segmentId);
//       setState(() {
//         selectedSubSegment = subSegment;
//         dropdownSelectedSubSegment = subSegment;
//       });
//     }
//   }

//   void _showPdf(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("PDF Content"),
//           content: SizedBox(
//             width: 1000,
//             height: 600,
//             child: PdfViewer.asset('assets/files/USR_Co_ref.pdf'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> finalizeDomainTerm(
//       BuildContext context, SubSegment subSegment) async {
//     try {
//       final token = await getJwtToken(); // Fetch JWT token
//       if (token == null) {
//         print("JWT token is null.");
//         return;
//       }

//       // Convert SubSegment data to the required format for domain finalization
//       final List<dynamic> domainArray = segmentDetails?['domain_term'] ?? [];

//       final selectedDomainTerms =
//           selectedDomainTermsPerSubSegment[subSegment] ?? {};
//       List<Map<String, dynamic>> domainTermPayload = [];

//       for (int i = 0; i < domainArray.length; i++) {
//         final domainTerm = domainArray[i];

//         // Make sure the correct index is used when updating domain_term
//         domainTermPayload.add({
//           "domain_term_id":
//               domainTerm["domain_term_id"], // Existing domain_term_id
//           "segment_index":
//               domainTerm["segment_index"], // Existing segment_index
//           "concept_id": domainTerm["concept_id"], // Existing concept_id
//           "index": domainTerm["index"],
//           "domain_term": selectedDomainTerms[domainTerm["index"]] ??
//               '-', // Correctly mapped domain term
//         });
//       }

//       print(domainTermPayload); // Debugging: Print the domain term payload

//       // Send PUT request to finalize the domain terms
//       final response = await http.put(
//         Uri.parse(
//             'https://canvas.iiit.ac.in/lc/api/domain/segment/${subSegment.segmentId}/domain_term'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(domainTermPayload),
//       );

//       if (response.statusCode == 200) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Success'),
//             content: const Text('Domain term has been finalized successfully.'),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _fetchSegments(); // Refresh segments after finalizing
//                 },
//               ),
//             ],
//           ),
//         );
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text('Failed to finalize domain term: ${response.body}'),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error finalizing domain terms: $e");
//     }
//   }

//   Widget buildDomainTable(SubSegment subSegment) {
//     if (segmentDetails == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     ScrollController horizontalScrollController = ScrollController();

//     final selectedDomainTerms =
//         selectedDomainTermsPerSubSegment[subSegment] ?? {};
//     final domainArray = segmentDetails?['domain_term'] ?? [];
//     final columnCount = domainArray.length;

//     print('Selected domain terms: $selectedDomainTerms');
//     print('Domain array: $domainArray');
//     print('Column count: $columnCount');

//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             _showPdf(context);
//           },
//           child: const Text('Show Guidelines'),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
//           child: Text(
//             '${subSegment.subIndex} : ${subSegment.text}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16.0,
//             ),
//           ),
//         ),
//         // Wrap in a Scrollbar for better visual feedback
//         Expanded(
//           child: Scrollbar(
//             controller:
//                 horizontalScrollController, // Attach a scroll controller if needed
//             thumbVisibility: true, // To make scrollbar visible
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: horizontalScrollController,
//               child: DataTable(
//                 columnSpacing: 8.0,
//                 dataTextStyle: const TextStyle(fontSize: 14),
//                 headingTextStyle:
//                     const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 columns: _buildHeaderRow(subSegment, columnCount),
//                 rows: _buildDataRows(subSegment, columnCount) +
//                     [
//                       DataRow(
//                         cells: [
//                           const DataCell(Text('Domain Term')),
//                           ...List.generate(columnCount, (columnIndex) {
//                             return DataCell(
//                               SizedBox(
//                                 width: 150,
//                                 child: DropdownButton<String>(
//                                   isExpanded: true,
//                                   value: selectedDomainTerms[columnIndex + 1] ??
//                                       '-',
//                                   onChanged: (newValue) {
//                                     setState(() {
//                                       selectedDomainTerms[columnIndex + 1] =
//                                           newValue!;
//                                       selectedDomainTermsPerSubSegment[
//                                           subSegment] = selectedDomainTerms;
//                                     });
//                                   },
//                                   items: domainOptions.map((String domain) {
//                                     return DropdownMenuItem<String>(
//                                       value: domain,
//                                       child: Text(domain,
//                                           overflow: TextOverflow.ellipsis),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ],
//                       )
//                     ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.done, color: Colors.white),
//             label: const Text('Finalize Domain Terms',
//                 style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
//             onPressed: () => finalizeDomainTerm(context, subSegment),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               fixedSize: const Size(400, 55),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   List<DataColumn> _buildHeaderRow(SubSegment subSegment, int columnCount) {
//     List<DataColumn> columns = [
//       const DataColumn(label: Text('Index')),
//       ...List.generate(columnCount, (index) {
//         if (index < subSegment.conceptDefinitions.length) {
//           var conceptDef = subSegment.conceptDefinitions[index];
//           return DataColumn(
//               label: Text(conceptDef.index.toString())); // Use index property
//         } else {
//           return const DataColumn(label: Text('N/A'));
//         }
//       }),
//     ];

//     return columns;
//   }

//   List<DataRow> _buildDataRows(SubSegment subSegment, int columnCount) {
//     List<String> properties = [
//       'Concept',
//       // 'Semantic Category',
//       // 'Morphological Semantics',
//       // "Speaker's View",
//       // 'CxN index',
//       // "Component type"
//     ];

//     // print('subSegment.conceptDefinitions: ${subSegment.conceptDefinitions}');

//     return List.generate(properties.length, (rowIndex) {
//       return DataRow(cells: [
//         DataCell(Text(properties[rowIndex])),
//         ...List.generate(columnCount, (columnIndex) {
//           var conceptDef = subSegment.conceptDefinitions.isNotEmpty
//               ? subSegment.conceptDefinitions[columnIndex]
//               : null;
//           return DataCell(
//             conceptDef != null
//                 ? Text(conceptDef.getProperty(properties[rowIndex]))
//                 : const Text('N/A'), // Handle missing data
//           );
//         }),
//       ]);
//     });
//   }
// }
