// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lc_frontend/views/concept_definition_tab.dart';
import '../models/segment.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:http/http.dart' as http;

class ConstructionTab extends StatefulWidget {
  final String chapterId;

  const ConstructionTab({super.key, required this.chapterId});

  @override
  _ConstructionTabState createState() => _ConstructionTabState();
}

class _ConstructionTabState extends State<ConstructionTab> {
  SubSegment? selectedSubSegment;
  List<Segment> segments = [];
  Map<String, dynamic>? segmentDetails;
  int columnCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSegments();
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

      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        List<dynamic> jsonSegments = jsonDecode(jsonResponse);
        if (mounted) {
          setState(() {
            segments =
                jsonSegments.map((json) => Segment.fromJson(json)).toList();
          });
        }
      } else {
        print('Failed to fetch segments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segments: $e');
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
                    child:
                        Text('Select a subsegment to configure construction'))
                : buildConstructionTable(selectedSubSegment!),
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
                  buildStatusCircle(
                      'L', subSegment.isConceptDefinitionComplete),
                  buildStatusCircle(
                      'R', subSegment.isDependencyRelationDefined),
                  buildStatusCircle('C', subSegment.isConstructionDefined),
                  buildStatusCircle('D', subSegment.isDiscourseDefined),
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

  Widget buildStatusCircle(String label, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: isComplete ? Colors.green[200] : Colors.grey[400],
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
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
      await _fetchSegmentDetails(subSegment.segmentId);
      setState(() {
        selectedSubSegment = subSegment;
      });
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
        if (mounted) {
          setState(() {
            columnCount = jsonResponse['column_count'] ?? 0;
          });
        }
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

        final constructionArray = jsonResponse['construction'] as List<dynamic>;
        for (var constructionItem in constructionArray) {
          final cxnIndex = constructionItem['cxn_index'];
          final componentType = constructionItem['component_type'];
          print('cxn_index: $cxnIndex, component_type: $componentType');
          // ... Use cxnIndex and componentType here ...
        }

        if (mounted) {
          setState(() {
            segmentDetails = jsonResponse;
            selectedSubSegment?.conceptDefinitions =
                conceptDefinitions; // Update conceptDefinitions
            selectedSubSegment?.dependencyRelations = dependencyRelations;
          });
        }

        print('Fetched concept definitions: $conceptDefinitions');
      } else {
        print('Failed to fetch segment details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segment details: $e');
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

  Widget buildConstructionTable(SubSegment subSegment) {
    TextEditingController constructionController =
        TextEditingController(text: selectedSubSegment?.construction);

    if (segmentDetails == null) {
      _fetchSegmentDetails(subSegment.segmentId);
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showPdf(context),
              child: const Text('Show PDF'),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _buildHeaderRow(subSegment, columnCount),
              rows: [
                ..._buildDataRows(subSegment, columnCount),
                buildTargetIndexRow(subSegment),
                buildRelationsRow(subSegment),
              ],
            ),
          ),
          const SizedBox(height: 180),
          ElevatedButton(
            onPressed: () {
              setState(() {
                subSegment.construction = constructionController.text;
                subSegment.isConstructionDefined = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Construction finalized successfully!'),
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
              "Finalize Construction",
              style: TextStyle(color: Colors.white),
            ),
          ),
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
      'Semantic Category',
      'Morphological Semantics',
      "Speaker's View"
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

  DataRow buildTargetIndexRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('CxN Index')),
        ...List.generate(columnCount, (index) {
          final constructionItem = segmentDetails!['construction'][index];
          final cxnIndex = constructionItem['cxn_index'];

          return DataCell(
            Row(
              children: [
                Text(cxnIndex.toString()), // Display fetched cxn_index
                Expanded(
                  child: buildIndexDropdown(index, subSegment),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  DataRow buildRelationsRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('Component Type')),
        ...List.generate(columnCount, (index) {
          final constructionItem = segmentDetails!['construction'][index];
          final componentType = constructionItem['component_type'];

          return DataCell(
            Row(
              children: [
                Text(componentType), // Display fetched component_type
                Expanded(
                  child: buildRelationTypeDropdown(index, subSegment),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildIndexDropdown(int currentIndex, SubSegment subSegment) {
    return FormBuilderDropdown(
      name: 'index_$currentIndex',
      items: List.generate(
        columnCount,
        (index) => DropdownMenuItem<String>(
          value: (index + 1).toString(),
          child: Text('${index + 1}'),
        ),
      ),
      onChanged: (value) {
        setState(() {
          if (subSegment.dependencyRelations.length > currentIndex) {
            subSegment.dependencyRelations[currentIndex].targetIndex =
                int.parse(value!);
          }
        });
      },
    );
  }

  Widget buildRelationTypeDropdown(int currentIndex, SubSegment subSegment) {
    // Define the list of dropdown options
    final List<String> relationTypes = [
      'kriyAmUla',
      'verbalizer',
      'component1',
      'component2',
      'op1',
      'op2',
      'mod',
      'head',
      'AXAra',
      'AXeya',
    ];

    return SizedBox(
      width: 100, // Adjust width as needed
      height: 35, // Adjust height as needed
      child: DropdownButton<String?>(
        isDense: true,
        onChanged: (newValue) {
          setState(() {
            if (subSegment.dependencyRelations.length > currentIndex) {
              subSegment.dependencyRelations[currentIndex].relationType =
                  newValue ?? '';
              final constructionItem =
                  segmentDetails!['construction'][currentIndex];
              constructionItem['component_type'] =
                  newValue; // Update component_type
            }
          });
        },
        items: relationTypes.map((relationType) {
          return DropdownMenuItem<String?>(
            value: relationType,
            child: SizedBox(
              height: 30, // Adjust height as needed
              child: Text(relationType, style: const TextStyle(fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
