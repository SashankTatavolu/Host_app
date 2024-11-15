// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../../models/segment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  Map<String, dynamic>? segmentDetails;
  int columnCount = 0;
  SubSegment? dropdownSelectedSubSegment;
  bool _isConceptSelected = false;
  List<dynamic>? discourseArray;
  List<bool>? selectedDiscourseIndices;
  double segmentPanelWidth = 250.0; // Initial width for the segment panel
  double minWidth = 150.0; // Minimum width for the segment panel
  double maxWidth = 400.0;

  final List<String> relationTypes = [
    'samuccaya',
    'AvaSyakawApariNAma',
    'kAryakAraNa',
    'pariNAma',
    'vyABicAra',
    'viroXi',
    'anyawra',
    'samuccaya.alAvA',
    'samuccaya.samAveSI',
    'vyaBicAra',
    'samuccaya.BI',
    'viroXaxyotaka',
    'uXAharaNasvarUpa',
    'saMSepa mEM',
    'AvaSyakawApariNAma.nahIM',
    'uwwarkAla',
    'samuccaya.awirikwa',
    'arWAwa',
    'kAryaxyowaka'
  ];

  // Variable to hold the selected relation type
  String? selectedRelationType;

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
          'https://canvas.iiit.ac.in/lc/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // print('Response status: ${response.statusCode}');
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
          final cxnIndex = constructionItem['cxn_index'];
          final componentType = constructionItem['component_type'];
          print('cxn_index: $cxnIndex, component_type: $componentType');
          // ... Use cxnIndex and componentType here ...
        }

        setState(() {
          segmentDetails = jsonResponse;
          selectedSubSegment?.conceptDefinitions =
              conceptDefinitions; // Update conceptDefinitions
          selectedSubSegment?.dependencyRelations = dependencyRelations;
        });

        // print('Fetched concept definitions: $conceptDefinitions');
      } else {
        print('Failed to fetch segment details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segment details: $e');
    }
  }

  Future<void> _fetchConceptDetails(int segmentId) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      final url = Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/lexicals/segment/$segmentId');
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
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final conceptDefinitions = jsonResponse
            .map((json) => ConceptDefinition.fromJson(json))
            .toList();

        setState(() {
          // Update state with fetched concept definitions
          dropdownSelectedSubSegment?.conceptDefinitions = conceptDefinitions;
        });
      } else {
        print('Failed to fetch concept details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching concept details: $e');
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
        dropdownSelectedSubSegment = subSegment;
      });

      print('Selected SubSegment: $selectedSubSegment');
      // print('Dependency Relations: ${selectedSubSegment?.dependencyRelations}');
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
            child: PdfViewer.asset('assets/files/USR_Discourse.pdf'),
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

  Future<void> finalizeDiscourse(
      BuildContext context, SubSegment subSegment) async {
    try {
      final token = await getJwtToken(); // Fetch JWT token
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      // Convert SubSegment data to the required format for discourse finalization
      final List<dynamic> discourseArray = segmentDetails!['discourse'] ?? [];
      List<Map<String, dynamic>> discourseData = [];

      for (var discourseItem in discourseArray) {
        discourseData.add({
          'discourse_id': discourseItem['discourse_id'],
          'segment_index': discourseItem['segment_index'],
          'index': discourseItem['index'],
          'head_index': discourseItem['head_index'],
          'relation': discourseItem['relation'],
          'concept_id': discourseItem['concept_id'],
          'discourse':
              "${discourseItem['head_index']}:${discourseItem['relation']}", // Concatenate head_index and relation
        });
      }

      print(discourseData); // Debugging: Print the discourse data

      // Send PUT request to finalize the discourse
      final response = await http.put(
        Uri.parse(
            'https://canvas.iiit.ac.in/lc/api/discourse/segment/${subSegment.segmentId}/discourse'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(discourseData),
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Discourse has been finalized successfully.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchSegments(); // Refresh segments after finalizing
                },
              ),
            ],
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to finalize discourse: ${response.body}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error finalizing discourse: $e');
    }
  }

  Widget buildConceptTable(SubSegment? subSegment) {
    if (subSegment == null) {
      return const Center(child: Text('Select a concept to view details'));
    }
    final conceptDefinitions = subSegment.conceptDefinitions;
    final scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 8.0,
          dataTextStyle: const TextStyle(fontSize: 14),
          headingTextStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          columns: [
            const DataColumn(label: Text('Index')),
            ...conceptDefinitions.map((conceptDef) => DataColumn(
                  label: Text('${conceptDef.index}'),
                )),
          ],
          rows: [
            DataRow(cells: [
              const DataCell(Text('Concept')),
              ...conceptDefinitions
                  .map((conceptDef) => DataCell(Text(conceptDef.concept))),
            ]),
          ],
        ),
      ),
    );
  }
  // final _tableKey = GlobalKey();

  Widget buildDiscourseTable(SubSegment subSegment) {
    if (segmentDetails == null) {
      return const Center(
          child: CircularProgressIndicator()); // Show loading indicator
    }
    final discourseArray = segmentDetails!['discourse'] as List<dynamic>;
    // Populate selectedDiscourseIndices based on the presence of head_index
    final selectedDiscourseIndices = discourseArray.map((discourseItem) {
      return discourseItem['head_index'] != null &&
              discourseItem['head_index'].toString() != '-'
          ? true
          : false;
    }).toList();

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showPdf(context);
              },
              child: const Text('Show Guidelines'),
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
            DataTable(
              columnSpacing: 8.0,
              dataTextStyle: const TextStyle(fontSize: 14),
              headingTextStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              columns: _buildHeaderRow(subSegment, columnCount),
              rows: _buildDataRows(subSegment, columnCount) +
                  [
                    // Adding a row for checkboxes
                    DataRow(
                      cells: [
                        const DataCell(Text('')),
                        ...List.generate(columnCount, (columnIndex) {
                          String? relation =
                              discourseArray[columnIndex]['relation'];
                          return DataCell(Checkbox(
                            value: relation != 'coref' &&
                                selectedDiscourseIndices[columnIndex],
                            onChanged: (bool? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  selectedDiscourseIndices[columnIndex] =
                                      newValue;
                                }
                                // Find the previously checked checkbox
                                int prevCheckedIndex = -1;
                                for (int i = 0;
                                    i < selectedDiscourseIndices.length;
                                    i++) {
                                  if (selectedDiscourseIndices[i] &&
                                      i != columnIndex) {
                                    prevCheckedIndex = i;
                                    break;
                                  }
                                }
                                // Shift the head index and relation values of previously ticked checkbox to the newly checked ticked box
                                if (prevCheckedIndex != -1) {
                                  String? prevHeadIndex =
                                      discourseArray[prevCheckedIndex]
                                          ['head_index'];
                                  String? prevRelation =
                                      discourseArray[prevCheckedIndex]
                                          ['relation'];
                                  if (prevHeadIndex != null) {
                                    discourseArray[columnIndex]['head_index'] =
                                        prevHeadIndex;
                                  }
                                  if (prevRelation != null) {
                                    discourseArray[columnIndex]['relation'] =
                                        prevRelation;
                                  }
                                  // Clear the previously checked box's head index and relation values
                                  discourseArray[prevCheckedIndex]
                                      ['head_index'] = null;
                                  discourseArray[prevCheckedIndex]['relation'] =
                                      null;
                                }
                              });
                            },
                          ));
                        }),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Head Index')),
                        ...List.generate(columnCount, (columnIndex) {
                          String? relation =
                              discourseArray[columnIndex]['relation'];
                          return DataCell(TextField(
                            controller: TextEditingController(
                              text: relation == 'coref'
                                  ? '' // Keep the field empty if relation is 'coref'
                                  : discourseArray[columnIndex]['head_index']
                                          ?.toString() ??
                                      '',
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              // Always allow the field to be edited
                              discourseArray[columnIndex]['head_index'] = value;
                            },
                          ));
                        }),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Relation')),
                        ...List.generate(columnCount, (columnIndex) {
                          String? currentRelation =
                              discourseArray[columnIndex]['relation'];
                          // Ensure the current value is part of the relationTypes list
                          if (!relationTypes.contains(currentRelation)) {
                            currentRelation =
                                null; // Set to null if it doesn't match
                          }
                          return DataCell(
                            SizedBox(
                              width:
                                  150, // Set the desired width for the dropdown
                              child: DropdownButton<String>(
                                isExpanded:
                                    true, // Ensures the text is not clipped
                                value: currentRelation == 'coref'
                                    ? null
                                    : currentRelation,
                                hint: const Text(''),
                                items: relationTypes.map((String relation) {
                                  return DropdownMenuItem<String>(
                                    value: relation,
                                    child: Text(relation),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    discourseArray[columnIndex]['relation'] =
                                        newValue;
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<SubSegment>(
                  value: segments
                          .expand((segment) => segment.subSegments)
                          .contains(dropdownSelectedSubSegment)
                      ? dropdownSelectedSubSegment
                      : null, // Ensure value is either in the list or null
                  hint: const Text('Select Connecting Segment'),
                  items: segments
                      .expand((segment) => segment.subSegments)
                      .map((SubSegment subSegment) {
                    return DropdownMenuItem<SubSegment>(
                      value: subSegment,
                      child: Text(subSegment.subIndex),
                    );
                  }).toList(),
                  onChanged: (SubSegment? newValue) async {
                    setState(() {
                      dropdownSelectedSubSegment = newValue;
                      _isConceptSelected = newValue != null;
                    });
                    if (newValue != null) {
                      await _fetchConceptDetails(newValue.segmentId);
                    }
                  },
                )),
            if (_isConceptSelected)
              buildConceptTable(dropdownSelectedSubSegment),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: DropdownButton<String>(
            //     value: selectedRelationType,
            //     hint: const Text('Select Relation Type'),
            //     items: relationTypes.map((String relation) {
            //       return DropdownMenuItem<String>(
            //         value: relation,
            //         child: Text(relation),
            //       );
            //     }).toList(),
            //     onChanged: (String? newValue) {
            //       setState(() {
            //         selectedRelationType = newValue;
            //       });
            //     },
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.done, color: Colors.white),
                label: const Text('Finalize Discourse',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
                onPressed: () => finalizeDiscourse(context, subSegment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  fixedSize: const Size(400, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
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
      // 'Semantic Category',
      // 'Morphological Semantics',
      // "Speaker's View",
      // 'CxN index',
      // "Component type"
    ];

    // print('subSegment.conceptDefinitions: ${subSegment.conceptDefinitions}');

    return List.generate(properties.length, (rowIndex) {
      return DataRow(cells: [
        DataCell(Text(properties[rowIndex])),
        ...List.generate(columnCount, (columnIndex) {
          var conceptDef = subSegment.conceptDefinitions.isNotEmpty
              ? subSegment.conceptDefinitions[columnIndex]
              : null;
          return DataCell(
            conceptDef != null
                ? Text(conceptDef.getProperty(properties[rowIndex]))
                : const Text('N/A'), // Handle missing data
          );
        }),
      ]);
    });
  }
}
