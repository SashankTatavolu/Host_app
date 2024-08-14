import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/segment.dart';
import '../services/auth_service.dart'; // Adjust based on your AuthService implementation

class ConceptTab extends StatefulWidget {
  final int chapterId;
  final List<Segment> segments;

  const ConceptTab(
      {super.key, required this.chapterId, required this.segments});

  @override
  _ConceptTabState createState() => _ConceptTabState();
}

class _ConceptTabState extends State<ConceptTab> {
  List<Segment> segments = [];
  SubSegment? selectedSubSegment;
  Segment? selectedSegment;
  double segmentPanelWidth = 250.0; // Initial width for the segment panel
  double minWidth = 150.0; // Minimum width for the segment panel
  double maxWidth = 400.0;
  bool isConceptDataAvailable = false;

  @override
  void initState() {
    super.initState();
    _fetchSegments();
  }

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations here
    super.dispose();
  }

  Future<void> _fetchSegments() async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      final url = Uri.parse(
          'http://10.2.8.12:5000/api/chapters/by_chapter/${widget.chapterId}/sentences_segments');
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

        for (var segment in segments) {
          for (var subSegment in segment.subSegments) {
            print(
                'SubSegment text: ${subSegment.text}, segmentId: ${subSegment.segmentId}');
          }
        }

        await _fetchConceptDetails(token);
      } else {
        print('Failed to fetch segments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segments: $e');
    }
  }

  Future<void> _fetchConceptDetails(String token) async {
    if (selectedSegment == null) {
      print('No segment selected.');
      return;
    }

    for (SubSegment subSegment in selectedSegment!.subSegments) {
      int? segmentId;
      try {
        segmentId = int.tryParse(subSegment.segmentId.toString());
        if (segmentId == null) {
          throw FormatException('Invalid segmentId: ${subSegment.segmentId}');
        }
      } catch (e) {
        print('Error converting segmentId: ${subSegment.segmentId} - $e');
        continue;
      }

      final conceptUrl =
          Uri.parse('http://10.2.8.12:5000/api/lexicals/segment/$segmentId');
      print('Fetching concepts from: $conceptUrl');

      try {
        final conceptResponse = await http.get(
          conceptUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (conceptResponse.statusCode == 200) {
          List<dynamic> conceptsJson = jsonDecode(conceptResponse.body);
          List<ConceptDefinition> conceptDefinitions = conceptsJson
              .map((json) => ConceptDefinition.fromJson(json))
              .toList();

          if (mounted) {
            setState(() {
              subSegment.conceptDefinitions = conceptDefinitions;
              subSegment.columnCount = conceptDefinitions.length;
            });
          }
        } else {
          print(
              'Failed to fetch concepts for segment $segmentId: ${conceptResponse.statusCode}');
        }
      } catch (e) {
        print('Error fetching concepts for segment $segmentId: $e');
        // Display error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Segment List Panel
          Container(
            width: segmentPanelWidth,
            child: buildSegmentList(),
          ),
          // Resizable Divider
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
          // Concept Editor
          Expanded(
            child: selectedSubSegment == null
                ? const Center(child: Text('Select a subsegment to configure.'))
                : ConceptEditor(
                    subSegment: selectedSubSegment!,
                    segment: selectedSegment!,
                  ),
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
                    backgroundColor: subSegment.isConstructionDefined
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
              subtitle: Text(subSegment.text),
              title: Text(subSegment.subIndex),
              onTap: () => _selectSubSegment(segment, subSegment),
            );
          }).toList(),
        );
      },
    );
  }

  // Future<void> _selectSubSegment(Segment segment, SubSegment subSegment) async {
  //   setState(() {
  //     selectedSegment = segment;
  //     selectedSubSegment = subSegment;
  //   });

  //   final token = await getJwtToken();
  //   if (token != null) {
  //     _fetchConceptDetails(token);
  //   }
  // }

  Future<void> _selectSubSegment(Segment segment, SubSegment subSegment) async {
    setState(() {
      selectedSegment = segment;
      selectedSubSegment = subSegment;
    });

    final token = await getJwtToken();
    if (token != null) {
      await _fetchConceptDetails(token);
    }
  }

  void _promptForColumnCount(SubSegment subSegment) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
                if (columns != null && columns > 0) {
                  setState(() {
                    subSegment.columnCount = columns;
                    // Initialize empty ConceptDefinitions for each column
                    for (int i = 0; i < columns; i++) {
                      subSegment.conceptDefinitions
                          .add(ConceptDefinition.create(index: i + 1));
                      subSegment.dependencyRelations
                          .add(DependencyRelation.create(index: i + 1));
                    }
                  });
                  Navigator.of(context).pop();
                  setState(() {
                    selectedSubSegment = subSegment;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}

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

class ConceptEditor extends StatefulWidget {
  final SubSegment subSegment;
  final Segment segment;

  const ConceptEditor(
      {super.key, required this.subSegment, required this.segment});

  @override
  _ConceptEditorState createState() => _ConceptEditorState();
}

class _ConceptEditorState extends State<ConceptEditor> {
  final List<String> semanticCategories = [
    'per/male',
    'per/female',
    'place',
    'org',
    'ne',
    'fw',
    'dow',
    'moy',
    'yoc',
    'era',
    'dom',
    'calendricunit',
    'clocktime',
    'season',
    'timex',
    'meas',
    'numex',
    'anim',
    'male',
    'female'
  ];

  final List<String> morphologicalSemantics = [
    'pl',
    'mawup',
    'kqw',
    'compermore',
    'comperless',
    'superl',
    'dvitva',
    'causative',
    'doublecausative'
  ];

  final List<String> speakersViews = [
    'respect',
    'informal',
    'proximal',
    'distal',
    'def',
    'hI_1',
    'hI_2',
    'BI_1'
  ];

  Map<int, List<String>> conceptOptions = {};
  Map<int, String> previousSelections = {};
  Map<int, String> originalConceptNames = {};
  bool isConceptDefinitionComplete = false;

  @override
  void initState() {
    super.initState();
    // Store the original concept names for each column
    for (int i = 0; i < widget.subSegment.columnCount; i++) {
      originalConceptNames[i] = widget.subSegment.conceptDefinitions[i].concept;
    }
  }

  Future<void> _fetchConceptOptions(int columnIndex, String conceptName) async {
    // Extract the part of conceptName up to the first underscore
    String originalConceptName = conceptName.split('_').first;

    final token = await getJwtToken();
    if (token == null) {
      print("JWT token is null.");
      return;
    }

    final url = Uri.parse(
        'http://10.2.8.12:5000/api/concepts/getconcepts/$originalConceptName');
    print('Fetching concept options from: $url');

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
      Map<String, dynamic> conceptsJson = jsonDecode(response.body);
      List<String> options = conceptsJson.entries
          .map((entry) => '${entry.key} (${entry.value})')
          .toList();

      setState(() {
        if (options.isEmpty) {
          // No concepts found
          conceptOptions[columnIndex] = ["No concepts found"];
        } else {
          conceptOptions[columnIndex] = options;
        }
      });
    } else {
      print('Failed to fetch concept options: ${response.statusCode}');
    }
  }

  void _showConceptOptionsPopup(int columnIndex, String conceptName) async {
    await _fetchConceptOptions(columnIndex, conceptName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Concept'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (conceptOptions[columnIndex]?.isEmpty ?? true)
                Text('No concepts found')
              else
                ...conceptOptions[columnIndex]!.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      setState(() {
                        previousSelections[columnIndex] = option;
                        widget.subSegment.conceptDefinitions[columnIndex]
                            .concept = option;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // void _undoSelection(int columnIndex) {
  //   if (previousSelections.containsKey(columnIndex)) {
  //     setState(() {
  //       conceptOptions[columnIndex] = [previousSelections[columnIndex]!];
  //     });
  //     // Clear previous selection
  //     previousSelections.remove(columnIndex);
  //   }
  // }

  // void _undoSelection(int columnIndex) {
  //   if (previousSelections.containsKey(columnIndex)) {
  //     setState(() {
  //       conceptOptions[columnIndex] = [previousSelections[columnIndex]!];
  //     });
  //     // Clear previous selection
  //     previousSelections.remove(columnIndex);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildConceptDataTable(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.done, color: Colors.white),
          label: const Text('Finalize Concept Definition',
              style: TextStyle(color: Colors.white)),
          onPressed: _finalizeConceptDefinition,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            fixedSize: const Size(400, 55),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  SingleChildScrollView buildConceptDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        columns: _buildHeaderRow(),
        rows: _buildDataRows(),
      ),
    );
  }

  List<DataColumn> _buildHeaderRow() {
    List<DataColumn> headers = [
      const DataColumn(label: Text('Index')), // Header for the row header
    ];

    headers.addAll(List.generate(
      widget.subSegment.columnCount,
      (index) => DataColumn(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100, // Set maximum width for header columns
              child: Text(
                '${index + 1}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<int>(
              onSelected: (value) {
                if (value == 1) {
                  addColumn(index);
                } else if (value == 2) {
                  removeColumn(index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                    value: 1, child: Text('Add Column After')),
                const PopupMenuItem<int>(
                    value: 2, child: Text('Remove This Column')),
              ],
            ),
          ],
        ),
      ),
    ));
    return headers;
  }

  List<DataRow> _buildDataRows() {
    List<String> properties = [
      'Concept',
      'Semantic Category',
      'Morphological Semantics',
      "Speaker's View"
    ];
    return List.generate(properties.length, (rowIndex) {
      return DataRow(cells: [
        DataCell(Text(properties[rowIndex])), // This is the row header
        ...List.generate(widget.subSegment.columnCount, (columnIndex) {
          final conceptDef = widget.subSegment.conceptDefinitions[columnIndex];
          switch (rowIndex) {
            case 0: // Concept
              return DataCell(
                GestureDetector(
                  onTap: () async {
                    _showConceptOptionsPopup(columnIndex, conceptDef.concept);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(conceptDef.concept),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            case 1: // Semantic Category dropdown
              return DataCell(_buildDropdown(
                conceptDef.semCat,
                semanticCategories,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            case 2: // Morphological Semantics dropdown
              return DataCell(_buildDropdown(
                conceptDef.morphSem,
                morphologicalSemantics,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            case 3: // Speaker's View dropdown
              return DataCell(_buildDropdown(
                conceptDef.speakerView,
                speakersViews,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            default:
              // return DataCell(SizedBox(
              //   width: 200,
              //   child: TextField(
              //     controller: TextEditingController.fromValue(TextEditingValue(
              //         text: conceptDef.getProperty(properties[rowIndex]),
              //         selection: TextSelection.collapsed(
              //             offset: conceptDef
              //                 .getProperty(properties[rowIndex])
              //                 .length))),
              //     onChanged: (value) => updateConceptProperty(
              //         columnIndex, properties[rowIndex], value),
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       contentPadding:
              //           EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              //     ),
              //   ),
              // ));

              return DataCell(
                SizedBox(
                  width: 120, // Adjust width as needed for each column
                  child: Text(
                    conceptDef.getProperty(properties[rowIndex]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
          }
        }),
      ]);
    });
  }

  Widget _buildDropdown(String currentValue, List<String> options,
      ValueChanged<String> onChanged) {
    return SizedBox(
      width: 150,
      child: DropdownButton<String>(
        isExpanded: true,
        value: options.contains(currentValue) ? currentValue : null,
        hint: const Text('Select'),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  void updateConceptProperty(int columnIndex, String property, String value) {
    ConceptDefinition conceptDef =
        widget.subSegment.conceptDefinitions[columnIndex];
    conceptDef.updateProperty(property, value);
    setState(() {});
  }

  void addColumn(int index) {
    setState(() {
      widget.subSegment.columnCount++;
      widget.subSegment.conceptDefinitions
          .insert(index + 1, ConceptDefinition.create(index: index + 2));
      for (int i = index + 2;
          i < widget.subSegment.conceptDefinitions.length;
          i++) {
        widget.subSegment.conceptDefinitions[i].index = i + 1;
      }
    });
  }

  void removeColumn(int index) {
    setState(() {
      if (widget.subSegment.columnCount > 1) {
        widget.subSegment.columnCount--;
        widget.subSegment.conceptDefinitions.removeAt(index);
        for (int i = index;
            i < widget.subSegment.conceptDefinitions.length;
            i++) {
          widget.subSegment.conceptDefinitions[i].index = i + 1;
        }
      }
    });
  }

  Future<void> _finalizeConceptDefinition() async {
    final token = await getJwtToken();
    if (token == null) {
      print("JWT token is null.");
      return;
    }

    final mainSegment = widget.segment.mainSegment;
    final subSegment = widget.subSegment;
    final segmentId = subSegment.segmentId;
    final url =
        Uri.parse('http://10.2.8.12:5000/api/lexicals/segment/$segmentId');
    final body = jsonEncode(widget.subSegment.conceptDefinitions.map((concept) {
      return {
        "segment_index": mainSegment, // Assuming you have this field
        "index": concept.index,
        "concept": concept.concept,
        "semantic_category": concept.semCat,
        "morphological_semantics": concept.morphSem,
        "speakers_view": concept.speakerView,
        "lexical_conceptual_id": concept.lexicalConceptualId
      };
    }).toList());

    print(body);
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Finalize response status: ${response.statusCode}');
      print('Finalize response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle successful response here

        print(
            'Before setting flag - isConceptDefinitionComplete for segment ${subSegment.segmentId}: ${subSegment.isConceptDefinitionComplete}');

        subSegment.isConceptDefinitionComplete = true;
        print('Concept definitions updated successfully.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lexico finalized successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Handle error response here
        print('Failed to update concept definitions: ${response.statusCode}');
      }

      print(
          'After setting flag - isConceptDefinitionComplete for segment ${subSegment.segmentId}: ${subSegment.isConceptDefinitionComplete}');
    } catch (e) {
      print('Error updating concept definitions: $e');
    }
  }
}
