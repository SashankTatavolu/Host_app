// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lc_frontend/views/USR_validation/concept_definition_tab.dart';
import '../../models/segment.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';

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
  double segmentPanelWidth = 250.0; // Initial width for the segment panel
  double minWidth = 150.0; // Minimum width for the segment panel
  double maxWidth = 400.0;

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
          'https://canvas.iiit.ac.in/lc/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
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
          SizedBox(
            width: segmentPanelWidth,
            child: buildSegmentList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  segmentPanelWidth =
                      (segmentPanelWidth + details.primaryDelta!)
                          .clamp(minWidth, maxWidth);
                });
              },
              child: Container(
                width: 10,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
            ),
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
          title: SelectableText(
            '${segment.mainSegment}: ${segment.text}',
            style: const TextStyle(color: Colors.black),
          ),
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
              title: SelectableText(
                subSegment.text, // Make the subsegment text selectable
                style: const TextStyle(color: Colors.black),
              ),
              subtitle: SelectableText(
                subSegment.subIndex, // Make the subsegment index selectable
                style: const TextStyle(color: Colors.grey),
              ),
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
          'https://canvas.iiit.ac.in/lc/api/lexicals/segment/$segmentId/is_concept_generated');
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
          'https://canvas.iiit.ac.in/lc/api/segment_details/segment_details/$segmentId');
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
          final cxnIndex =
              constructionItem['cxn_index'] ?? '-'; // Use a reasonable default
          final componentType =
              constructionItem['component_type'] ?? '-'; // Same here

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
            child: PdfViewer.asset('assets/files/Construction.pdf'),
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

  Future<void> _finalizeConstruction(SubSegment subSegment) async {
    if (selectedSubSegment == null || segmentDetails == null) return;

    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      // Extract construction details from the segmentDetails
      final List<dynamic> constructionArray =
          segmentDetails!['construction'] ?? [];
      final List<Map<String, dynamic>> constructionData = [];

      for (var constructionItem in constructionArray) {
        constructionData.add({
          "index": constructionItem['index'],
          "component_type": constructionItem['component_type'],
          "concept_id": constructionItem['concept_id'],
          "construction": constructionItem['cxn_index : component_type'],
          "construction_id": constructionItem['construction_id'],
          "cxn_index": constructionItem['cxn_index'],
          "segment_id": constructionItem['segment_id'],
          "segment_index": constructionItem['segment_index'],
        });
      }

      // Prepare the final payload directly as a list
      final payload = constructionData;

      print(payload);

      final url = Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/constructions/segment/${subSegment.segmentId}/construction');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Construction finalized successfully.');
      } else {
        print('Failed to finalize construction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error finalizing construction: $e');
    }
  }

  Widget buildConstructionTable(SubSegment subSegment) {
    TextEditingController constructionController =
        TextEditingController(text: selectedSubSegment?.construction);

    // Define a scroll controller for horizontal scrolling
    ScrollController horizontalScrollController = ScrollController();

    if (segmentDetails == null) {
      _fetchSegmentDetails(subSegment.segmentId);
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _showPdf(context),
            child: const Text('Show Guidelines'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
          child: Text(
            '${subSegment.subIndex} : ${subSegment.text}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Scrollable horizontal DataTable
        Expanded(
          child: Scrollbar(
            controller:
                horizontalScrollController, // Assign the scroll controller
            thumbVisibility: true, // Keeps the scrollbar visible
            interactive: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller:
                  horizontalScrollController, // Use the same controller here
              child: DataTable(
                columns: _buildHeaderRow(subSegment, columnCount),
                rows: [
                  ..._buildDataRows(subSegment, columnCount),
                  buildTargetIndexRow(subSegment),
                  buildRelationsRow(subSegment),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            _finalizeConstruction(subSegment);
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
    );
  }

  List<DataColumn> _buildHeaderRow(SubSegment subSegment, int columnCount) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('Index')),
      ...List.generate(columnCount, (index) {
        if (index < subSegment.conceptDefinitions.length) {
          var conceptDef = subSegment.conceptDefinitions[index];
          return DataColumn(
              label: Text(conceptDef.index.toString())); // Use index property
        } else {
          return const DataColumn(label: Text('N/A'));
        }
      }),
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
          return DataCell(
            buildIndexDropdown(index, subSegment),
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
    final constructionItem = segmentDetails!['construction'][currentIndex];
    final initialIndex = constructionItem['cxn_index'];

    // If the initial value is '-', set it to null to show the hint
    String? initialIndexValue =
        initialIndex != '-' ? initialIndex.toString() : null;

    return FormBuilderDropdown(
      name: 'index_$currentIndex',
      initialValue: initialIndexValue,
      items: [
        const DropdownMenuItem<String>(
          value: '-', // Special value for "None"
          child: Text('None'),
        ),
        ...List.generate(
          columnCount,
          (index) => DropdownMenuItem<String>(
            value: (index + 1).toString(),
            child: Text('${index + 1}'),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          if (subSegment.dependencyRelations.length > currentIndex) {
            // If "None" is selected, set the value to "-"
            subSegment.dependencyRelations[currentIndex].targetIndex =
                value == '-' ? -1 : int.parse(value!);

            // Update the segmentDetails map accordingly
            final constructionItem =
                segmentDetails!['construction'][currentIndex];
            constructionItem['cxn_index'] =
                value == '-' ? '-' : int.parse(value!);
          }
        });
      },
    );
  }

  Widget buildRelationTypeDropdown(int currentIndex, SubSegment subSegment) {
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
      width: 100,
      height: 35,
      child: DropdownButton<String?>(
        isDense: true,
        onChanged: (newValue) {
          setState(() {
            if (subSegment.dependencyRelations.length > currentIndex) {
              subSegment.dependencyRelations[currentIndex].relationType =
                  newValue ?? '';

              // Update the segmentDetails map
              final constructionItem =
                  segmentDetails!['construction'][currentIndex];
              constructionItem['component_type'] = newValue;
            }
          });
        },
        items: relationTypes.map((relationType) {
          return DropdownMenuItem<String?>(
            value: relationType,
            child: SizedBox(
              height: 30,
              child: Text(relationType, style: const TextStyle(fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
