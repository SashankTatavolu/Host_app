// import 'dart:io';

// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../../models/segment.dart'; // Adjust the import according to your file structure
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pdfrx/pdfrx.dart';
import '../file_download/USR_download_web.dart';
import 'concept_definition_tab.dart'; // Assuming this is where getJwtToken is defined

class DependencyRelationPage extends StatefulWidget {
  final int chapterId; // Receive chapterId as a parameter

  const DependencyRelationPage({super.key, required this.chapterId});

  @override
  _DependencyRelationPageState createState() => _DependencyRelationPageState();
}

class _DependencyRelationPageState extends State<DependencyRelationPage> {
  List<Segment> segments = [];
  SubSegment? selectedSubSegment;
  Map<String, dynamic>? segmentDetails;
  int columnCount = 0;

  double segmentPanelWidth = 250.0; // Initial width for the segment panel
  double minWidth = 150.0; // Minimum width for the segment panel
  double maxWidth = 400.0;

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

        print('Fetched concept definitions: $conceptDefinitions');
      } else {
        print('Failed to fetch segment details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching segment details: $e');
    }
  }

  Future<void> finalizeRelation(
      BuildContext context, SubSegment subSegment) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token is null.");
        return;
      }

      // Convert SubSegment data to the required format
      final List<dynamic> dependencyArray = segmentDetails!['relational'] ?? [];
      List<Map<String, dynamic>> dependencyData = [];
      for (var dependencyItem in dependencyArray) {
        dependencyData.add({
          'relational_id': dependencyItem['relational_id'],
          'segment_index': dependencyItem['segment_index'],
          'index': dependencyItem['index'],
          'head_relation': dependencyItem['head_relation'],
          'head_index': dependencyItem['head_index'],
          'relation': dependencyItem['relation'],
          'is_main': dependencyItem['is_main'],
          'concept_id': dependencyItem['concept_id'],
        });
      }

      print(dependencyData);

      final response = await http.put(
        Uri.parse(
            'https://canvas.iiit.ac.in/lc/api/relations/segment/${subSegment.segmentId}/relational'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dependencyData),
      );

      print(response);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Dependency relation has been finalized.'),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to finalize dependency relation: ${response.body}'),
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
      print('Error finalizing dependency relation: $e');
    }
  }

  Future<void> _generateText(SubSegment subSegment) async {
    final token = await getJwtToken();
    if (token == null) {
      // Handle token retrieval failure
      return;
    }

    final chapterId = widget.chapterId; // Replace with the actual chapter ID
    print(chapterId);
    final segmentId =
        subSegment.segmentId; // Replace with the actual segment ID

    // Generate text
    final response = await http.post(
      Uri.parse('https://canvas.iiit.ac.in/lc/api/generate/process_single'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'chapter_id': chapterId,
        'segment_ids': [segmentId],
      }),
    );

    if (response.statusCode == 200) {
      print(response);
      // Text generated successfully, now download it
      await _downloadGeneratedText(chapterId, segmentId);
    } else {
      // Handle error
      print('Failed to generate text: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error generating the file'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _downloadGeneratedText(int chapterId, int segmentId) async {
    final token = await getJwtToken();
    if (token == null) {
      // Handle token retrieval failure
      return;
    }

    final response = await http.get(
      Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/generate/generate/text?segment_id=$segmentId&chapter_id=$chapterId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Use the chapterId and segmentId in the filename
      final fileName =
          'Generated_text_chapter_${chapterId}_segment_$segmentId.txt';

      // Parse the JSON to extract the generated_text field
      final Map<String, dynamic> responseData = json.decode(response.body);
      final generatedText = responseData['generated_text'];

      if (generatedText == null) {
        print('Error: No generated text found in the response');
        return;
      }

      // Saving the generated text to a file
      if (kIsWeb) {
        // Use the extracted generatedText for the web
        downloadFileWeb(fileName, generatedText);
      } else {
        // For mobile or desktop
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Write the generated text to the file
        await file.writeAsString(generatedText);

        // Notify user about the file save location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text generated successfully! Saved at: $filePath'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Handle error
      print('Failed to download text: ${response.body}');
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
                    child: Text('Select a subsegment to configure dependency'))
                : buildDependencyRelationTable(selectedSubSegment!),
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
            child:
                PdfViewer.asset('assets/files/USR_dependency_relation_row.pdf'),
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

  Widget buildDependencyRelationTable(SubSegment subSegment) {
    if (segmentDetails == null) {
      return const Center(
          child: CircularProgressIndicator()); // Show loading indicator
    }

    final constructionArray = segmentDetails!['construction'] as List<dynamic>;
    ScrollController horizontalScrollController = ScrollController();

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _showPdf(context);
              },
              child: const Text('Show Guidelines'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _generateText(subSegment);
              },
              child: const Text('Generate Text'),
            ),
          ],
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
        // Horizontal scrollable DataTable
        Expanded(
          child: Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true, // Keeps the scrollbar visible
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: DataTable(
                columnSpacing: 8.0, // Reduce spacing between columns
                dataTextStyle:
                    const TextStyle(fontSize: 14), // Smaller text size
                headingTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold), // Smaller heading text size
                columns: _buildHeaderRow(subSegment, columnCount),
                rows: _buildDataRows(subSegment, columnCount) +
                    [
                      DataRow(
                        cells: [
                          const DataCell(Text('CxN Index')),
                          ...List.generate(columnCount, (columnIndex) {
                            final constructionItem =
                                constructionArray[columnIndex];
                            final cxnIndex = constructionItem['cxn_index'];
                            return DataCell(Text(cxnIndex.toString()));
                          }),
                        ],
                      ),
                      DataRow(
                        cells: [
                          const DataCell(Text('Component Type')),
                          ...List.generate(columnCount, (columnIndex) {
                            final constructionItem =
                                constructionArray[columnIndex];
                            final componentType =
                                constructionItem['component_type'];
                            return DataCell(Text(componentType));
                          }),
                        ],
                      ),
                      DataRow(
                        cells: List.generate(columnCount + 1,
                            (index) => const DataCell(Text(' '))),
                      ),
                      buildMainStatusRow(subSegment),
                      buildTargetIndexRow(subSegment),
                      buildRelationsRow(subSegment),
                    ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.done, color: Colors.white),
            label: const Text('Finalize Dependency Relation',
                style: TextStyle(color: Colors.white)),
            onPressed: () => finalizeRelation(context, subSegment),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              fixedSize: const Size(400, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
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
      "Speaker's View",
      // 'CxN index',
      // "Component type"
    ];

    print('subSegment.conceptDefinitions: ${subSegment.conceptDefinitions}');

    return List.generate(properties.length, (rowIndex) {
      return DataRow(cells: [
        DataCell(SizedBox(height: 50, child: Text(properties[rowIndex]))),
        ...List.generate(columnCount, (columnIndex) {
          var conceptDef = subSegment.conceptDefinitions.isNotEmpty
              ? subSegment.conceptDefinitions[columnIndex]
              : null;
          return DataCell(
            SizedBox(
              height: 50, // Fixed height for each cell
              child: conceptDef != null
                  ? Text(conceptDef.getProperty(properties[rowIndex]))
                  : const Text('N/A'), // Handle missing data
            ),
          );
        }),
      ]);
    });
  }

  DataRow buildTargetIndexRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('Head Index')),
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
        const DataCell(Text('Relation Type')),
        ...List.generate(columnCount, (index) {
          final dependencyItem = segmentDetails!['relational'][index];
          final relationType = dependencyItem['relation']; // Handle null case

          return DataCell(
            Row(
              children: [
                Text(relationType), // Display fetched component_type
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
    final constructionItem = segmentDetails!['relational'][currentIndex];
    final initialIndex = constructionItem['main_index'];

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
        const DropdownMenuItem<String>(
          value: '0', // Special value for "None"
          child: Text('0'),
        ),
        ...subSegment.conceptDefinitions.map((conceptDef) {
          return DropdownMenuItem<String>(
            value: conceptDef.index.toString(),
            child: Text(conceptDef.index.toString()),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          if (subSegment.dependencyRelations.length > currentIndex) {
            // If "None" is selected, set the value to "-"
            subSegment.dependencyRelations[currentIndex].targetIndex =
                value == '-' ? -1 : int.parse(value!);

            // Update the segmentDetails map accordingly
            final constructionItem =
                segmentDetails!['relational'][currentIndex];
            constructionItem['main_index'] =
                value == '-' ? '-' : int.parse(value!);
          }
        });
      },
    );
  }

  Widget buildRelationTypeDropdown(int currentIndex, SubSegment subSegment) {
    // if (segmentDetails == null ||
    //     !segmentDetails!.containsKey('conceptDefinitions')) {
    //   return const Center(
    //       child: CircularProgressIndicator()); // Show loading indicator
    // }

    List<String> relationTypes = [
      "k1",
      "k1s",
      "pk1",
      "mk1",
      "jk1",
      "k2",
      "k2p",
      "k2g",
      "k2s",
      "k3",
      "k4",
      "k4a",
      "k5",
      "k5prk",
      "k7t",
      "k7p",
      "k7",
      "k7a",
      "r6",
      "rsm",
      "rsma",
      "rhh",
      "mod",
      "rbks",
      "rvks",
      "dem",
      "ord",
      "card",
      "quant",
      "intf",
      "quantmore",
      "quantless",
      "rblsk",
      "rblpk",
      "rblak",
      "rpk",
      "rsk",
      "rh",
      "rt",
      "re",
      "rs",
      "rask1",
      "rask2",
      "rask3",
      "rask4",
      "rask5",
      "rask7",
      "rasneg",
      "ru",
      "rv",
      "rn",
      "rd",
      "rad",
      "neg",
      "freq",
      "rp",
      "krvn",
      "vkvn",
      "cxnpart",
      "dur",
      "extent",
      "vIpsA",
      "rcelab",
      "rcdelim",
      "rcsamAnakAla",
      "rcloc"
    ];
    return SizedBox(
      width: 120,
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
                  segmentDetails!['relational'][currentIndex];
              constructionItem['relation'] = newValue;
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

  DataRow buildMainStatusRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('is Main')),
        ...List.generate(columnCount, (index) {
          final relation = subSegment.dependencyRelations.length > index
              ? subSegment.dependencyRelations[index]
              : null;

          // Debugging: Print the current relation details
          print('Building row for index $index: $relation');

          final isMain = relation != null && relation.relation == 'main';

          return DataCell(
            Checkbox(
              value: isMain,
              onChanged: (newValue) {
                if (relation != null) {
                  setState(() {
                    // Update relations based on the new value
                    setMainRelation(subSegment, index, newValue!);
                  });
                }
              },
            ),
          );
        }),
      ],
    );
  }

  void setMainRelation(SubSegment subSegment, int mainIndex, bool isMain) {
    for (int i = 0; i < subSegment.dependencyRelations.length; i++) {
      final relation = subSegment.dependencyRelations[i];
      if (i == mainIndex) {
        // Set the selected relation as 'main'
        relation.relation = isMain ? 'main' : '';
        relation.targetIndex = isMain ? 0 : 0;
        relation.isMain = isMain;
      } else {
        // Clear other relations
        relation.relation = '';
        relation.targetIndex = 0;
        relation.isMain = false;
      }
      // Debugging output
      print(
          'Updated Index $i: relation=${relation.relation}, targetIndex=${relation.targetIndex}, isMain=${relation.isMain}');
    }
    setState(() {}); // Ensure UI is updated
  }
}
