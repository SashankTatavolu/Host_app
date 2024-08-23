// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/segment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';
import 'concept_definition_tab.dart';

class DiscourseTab extends StatefulWidget {
  final int chapterId;

  const DiscourseTab({super.key, required this.chapterId});

  @override
  _DiscourseTabState createState() => _DiscourseTabState();
}

class _DiscourseTabState extends State<DiscourseTab> {
  SubSegment? selectedSubSegment;
  List<Segment> segments = [];
  int columnCount = 0;
  Map<String, dynamic>? segmentDetails;

  @override
  void initState() {
    super.initState();
    _fetchSegments(); // Fetch segments when the widget is initialized
  }

  Future<void> _fetchSegments() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      final url = Uri.parse(
          'http://localhost:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        List<dynamic> jsonSegments = jsonDecode(jsonResponse);
        setState(() {
          segments =
              jsonSegments.map((json) => Segment.fromJson(json)).toList();
        });

        // for (var segment in segments) {
        //   for (var subSegment in segment.subSegments) {
        //     print(
        //         'SubSegment text: ${subSegment.text}, segmentId: ${subSegment.segmentId}');
        //   }
        // }

        // Optionally, fetch concept details if needed
        // await _fetchConceptDetails(token);
      } else {
        print('Failed to fetch segments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segments: $e');
    }
  }

  Future<bool> _isConceptDefinitionComplete(int segmentId) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return false;
      }

      final url = Uri.parse(
          'http://localhost:5000/api/lexicals/segment/$segmentId/is_concept_generated');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('isConceptDefinitionComplete response: $jsonResponse');
        columnCount = jsonResponse['column_count'] ?? 0;
        return jsonResponse['is_concept_generated'] ?? false;
      } else {
        print(
            'Failed to check concept definition status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking concept definition status: $e');
      return false;
    }
  }

  Future<void> _fetchSegmentDetails(int segmentId) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      final url = Uri.parse(
          'http://localhost:5000/api/segment_details/segment_details/$segmentId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> conceptJsonList =
            jsonResponse['lexico_conceptual'] ?? [];

        final List<dynamic> relationalJsonList =
            jsonResponse['relational'] ?? [];

        // Parse concept definitions
        final List<ConceptDefinition> conceptDefinitions = conceptJsonList
            .map((conceptJson) => ConceptDefinition.fromJson(conceptJson))
            .toList();

        List<DependencyRelation> dependencyRelations = relationalJsonList
            .map(
                (relationalJson) => DependencyRelation.fromJson(relationalJson))
            .toList();

        final List<dynamic> constructionArray = jsonResponse['discourse'] ?? [];
        for (var constructionItem in constructionArray) {
          final cxnIndex = constructionItem['head_index'];
          final componentType = constructionItem['relation'];
          print('cxn_index: $cxnIndex, component_type: $componentType');
          // ... Use cxnIndex and componentType here ...
        }

        setState(() {
          segmentDetails = jsonResponse;
          selectedSubSegment?.conceptDefinitions =
              conceptDefinitions; // Update conceptDefinitions
          selectedSubSegment?.dependencyRelations = dependencyRelations;
        });

        print('Fetched concept definitions: $conceptDefinitions');
      } else {
        print('Failed to fetch segment details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segment details: $e');
    }
  }

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
      itemCount: segments.length,
      itemBuilder: (context, index) {
        Segment segment = segments[index];
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
              subtitle: Text(subSegment.subIndex),
              onTap: () => selectSubSegment(subSegment),
            );
          }).toList(),
        );
      },
    );
  }

  void selectSubSegment(SubSegment subSegment) async {
    bool isComplete = await _isConceptDefinitionComplete(subSegment.segmentId);

    if (!isComplete) {
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
      await _fetchSegmentDetails(subSegment.segmentId); // Fetch segment details
      setState(() {
        selectedSubSegment = subSegment;
      });

      print('Selected SubSegment: $selectedSubSegment');
      print('Dependency Relations: ${selectedSubSegment?.dependencyRelations}');
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
            child: PdfViewer.asset('assets/files/USR_GUIDELINES.pdf'),
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

  Widget buildDiscourseTable(SubSegment subSegment) {
    if (segmentDetails == null) {
      _fetchSegmentDetails(subSegment.segmentId);
      return const Center(child: CircularProgressIndicator());
    }

    final constructionArray = segmentDetails!['discourse'] as List<dynamic>;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showPdf(context);
            },
            child: const Text('Show More Info'),
          ),
          DataTable(
            columns: _buildHeaderRow(subSegment, columnCount),
            rows: _buildDataRows(subSegment, columnCount) +
                [
                  DataRow(
                    cells: [
                      const DataCell(Text('Head Index')),
                      ...List.generate(columnCount, (columnIndex) {
                        final constructionItem = constructionArray[columnIndex];
                        final headIndex = constructionItem['head_index'];
                        return DataCell(Text(headIndex.toString()));
                      }),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text('Relation')),
                      ...List.generate(columnCount, (columnIndex) {
                        final constructionItem = constructionArray[columnIndex];
                        final relationType = constructionItem['relation'];
                        return DataCell(Text(relationType));
                      }),
                    ],
                  ),
                ],
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.done, color: Colors.white),
          //     label: const Text('Finalize Dependency Relation',
          //         style: TextStyle(color: Colors.white)),
          //     onPressed: () => finalizeRelation(context, subSegment),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.indigo,
          //       fixedSize: const Size(400, 55),
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<DataColumn> _buildHeaderRow(SubSegment subSegment, int columnCount) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('Property')),
      ...List.generate(columnCount,
          (index) => DataColumn(label: Text('Index ${index + 1}'))),
    ];

    return columns;
  }

  List<DataRow> _buildDataRows(SubSegment subSegment, int columnCount) {
    List<String> properties = [
      'Concept',
      // 'Semantic Category',
      // 'Morphological Semantics',
      // "Speaker's View"
    ];

    return properties.map((property) {
      List<DataCell> cells = [
        DataCell(Text(property)),
        ...List.generate(columnCount, (columnIndex) {
          if (columnIndex < subSegment.conceptDefinitions.length) {
            var conceptDef = subSegment.conceptDefinitions[columnIndex];
            return DataCell(Text(conceptDef.getProperty(property)));
          } else {
            // Handle cases where columnCount exceeds conceptDefinitions length
            return const DataCell(Text('N/A'));
          }
        }),
      ];

      return DataRow(cells: cells);
    }).toList();
  }
}
