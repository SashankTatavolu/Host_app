// import 'dart:io';

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/segment.dart'; // Adjust the import according to your file structure
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pdfrx/pdfrx.dart';
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
      List<Map<String, dynamic>> dependencyData = [];
      for (int i = 0; i < subSegment.columnCount; i++) {
        dependencyData.add({
          'segment_index': subSegment.segmentId,
          'index': i,
          'target_index': subSegment.dependencyRelations[i].targetIndex,
          'relation_type': subSegment.dependencyRelations[i].relationType,
          'is_main': subSegment.dependencyRelations[i].isMain,
        });
      }

      final response = await http.post(
        Uri.parse(
            'https://canvas.iiit.ac.in/lc/api/relations/segment/${subSegment.segmentId}/relational'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'dependencies': dependencyData}),
      );

      print(response);

      if (response.statusCode == 200) {
        // Show success dialog
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
        // Show error dialog
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

  // void finalizeRelation(BuildContext context, SubSegment subSegment) {
  //   setState(() {
  //     subSegment.isDependencyRelationDefined = true;
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Dependency relation finalized successfully!'),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }

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
          title: Text('${segment.mainSegment}: ${segment.text}'),
          children: segment.subSegments.map((SubSegment subSegment) {
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatar(
                    radius: 12, // Smaller radius for a compact appearance
                    backgroundColor: subSegment.isConceptDefinitionComplete
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('L',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white)), // Adjusted font size
                  ),
                  const SizedBox(
                      width: 2), // Provides spacing between the avatars
                  CircleAvatar(
                    radius: 12, // Consistent smaller radius for both avatars
                    backgroundColor: subSegment.isDependencyRelationDefined
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('R',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white)), // Adjusted font size
                  ),
                  const SizedBox(
                      width: 2), // Provides spacing between the avatars
                  CircleAvatar(
                    radius: 12, // Consistent smaller radius for both avatars
                    backgroundColor: subSegment.isConstructionDefined
                        ? Colors.green[200]
                        : Colors.grey[400],
                    child: const Text('C',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white)), // Adjusted font size
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
            child: PdfViewer.asset('assets/files/USR_dependency_relation.pdf'),
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
            columnSpacing: 8.0, // Reduce spacing between columns
            dataTextStyle: const TextStyle(fontSize: 14), // Smaller text size
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
                        final constructionItem = constructionArray[columnIndex];
                        final cxnIndex = constructionItem['cxn_index'];
                        return DataCell(Text(cxnIndex.toString()));
                      }),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text('Component Type')),
                      ...List.generate(columnCount, (columnIndex) {
                        final constructionItem = constructionArray[columnIndex];
                        final componentType =
                            constructionItem['component_type'];
                        return DataCell(Text(componentType));
                      }),
                    ],
                  ),
                  DataRow(
                    cells: List.generate(
                        columnCount + 1, (index) => const DataCell(Text(' '))),
                  ),
                  buildMainStatusRow(subSegment),
                  buildTargetIndexRow(subSegment),
                  buildRelationsRow(subSegment),
                ],
          ),
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
      'Semantic Category',
      'Morphological Semantics',
      "Speaker's View",
      // 'CxN index',
      // "Component type"
    ];

    print('subSegment.conceptDefinitions: ${subSegment.conceptDefinitions}');

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

  DataRow buildTargetIndexRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('Head Index')),
        ...List.generate(columnCount, (index) {
          final relation = subSegment.dependencyRelations.length > index
              ? subSegment.dependencyRelations[index]
              : null; // Handle null case

          return DataCell(
            Row(
              children: [
                Text(relation?.mainIndex.toString() ?? 'N/A'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80, // Set the width of the dropdown
                  child: DropdownButton<int>(
                    value: relation?.targetIndex ?? 0,
                    items: List.generate(
                      columnCount,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text((index + 1).toString(),
                            style: const TextStyle(
                                fontSize: 14)), // Adjust font size
                      ),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        if (relation != null) {
                          relation.targetIndex =
                              newValue ?? -1; // Update targetIndex
                          print('Selected value: $newValue');
                        }
                      });
                    },
                    iconSize: 16, // Adjust the icon size
                  ),
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
        const DataCell(Text('Relation Type')),
        ...List.generate(columnCount, (index) {
          final relation = subSegment.dependencyRelations.length > index
              ? subSegment.dependencyRelations[index]
              : null; // Handle null case

          return DataCell(
            Row(
              children: [
                Text(relation?.relation ??
                    'N/A'), // Display fetched relation type
                const SizedBox(
                    width: 8), // Add some spacing between text and dropdown
                SizedBox(
                  width: 80, // Adjust the width as needed
                  child: DropdownButton<String>(
                    value: null, // No initial value
                    isExpanded: true, // Ensure it fills the container width
                    items: relation?.getRelationTypes().map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        if (relation != null) {
                          relation.relation = newValue!;
                          // Trigger UI update here
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildIndexDropdown(int currentIndex, SubSegment subSegment) {
    int initialIndex = subSegment.dependencyRelations.length > currentIndex
        ? subSegment.dependencyRelations[currentIndex].targetIndex
        : 0; // Use default value (0) if out of bounds

    return FormBuilderDropdown(
      name: 'index_$currentIndex',
      initialValue: (initialIndex + 1).toString(), // Always set initial value
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
    // if (segmentDetails == null ||
    //     !segmentDetails!.containsKey('conceptDefinitions')) {
    //   return const Center(
    //       child: CircularProgressIndicator()); // Show loading indicator
    // }

    List<String> relationTypes = ['None', 'Subject', 'Object'];
    return FormBuilderDropdown(
      name: 'relation_type_$currentIndex',
      initialValue: subSegment.dependencyRelations.length > currentIndex
          ? subSegment.dependencyRelations[currentIndex].relationType
          : 'None',
      items: relationTypes
          .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          if (subSegment.dependencyRelations.length > currentIndex) {
            subSegment.dependencyRelations[currentIndex].relationType = value!;
          }
        });
      },
    );
  }

  DataRow buildMainStatusRow(SubSegment subSegment) {
    return DataRow(
      cells: [
        const DataCell(Text('is Main')),
        ...List.generate(columnCount, (index) {
          final relation = subSegment.dependencyRelations.length > index
              ? subSegment.dependencyRelations[index]
              : null; // Handle null case

          final isMain = relation != null &&
              relation.targetIndex == 0 &&
              relation.relation == 'main';

          return DataCell(
            Checkbox(
              value: isMain, // Set initial value based on fetched data
              onChanged: (newValue) => setState(() {
                if (relation != null) {
                  if (newValue!) {
                    // Set current index as main
                    relation.mainIndex = '0';
                    relation.relation = 'main';

                    // Clear other main relations (including the previous one)
                    for (int i = 0;
                        i < subSegment.dependencyRelations.length;
                        i++) {
                      if (i != index) {
                        // subSegment.dependencyRelations[i].mainIndex = '';
                        subSegment.dependencyRelations[i].relation = '';
                        subSegment.dependencyRelations[i].isMain = false;
                      }
                    }
                  } else {
                    // Clear head index and relation type if not main
                    relation.mainIndex = '';
                    relation.relation = '';
                  }
                  relation.isMain = newValue; // Update isMain after checks
                }
              }),
            ),
          );
        }),
      ],
    );
  }

  void setMainRelation(SubSegment subSegment, int mainIndex, bool isMain) {
    if (isMain) {
      for (int i = 0; i < subSegment.dependencyRelations.length; i++) {
        if (i == mainIndex) {
          // Set the selected relation as 'main'
          subSegment.dependencyRelations[i].relationType = 'main';
          subSegment.dependencyRelations[i].targetIndex = 0;
          subSegment.dependencyRelations[i].isMain =
              true; // Lock the 'main' so it can't be edited
        } else {
          // Reset other relations to default values
          subSegment.dependencyRelations[i].relationType =
              ''; // Assuming '1' is your default type
          subSegment.dependencyRelations[i].targetIndex = 1;
          subSegment.dependencyRelations[i].isMain = false; // Unlock others
        }
      }
    } else {
      subSegment.dependencyRelations[mainIndex].relationType = '';
      subSegment.dependencyRelations[mainIndex].targetIndex = 1;
      subSegment.dependencyRelations[mainIndex].isMain = false;
    }
    setState(() {}); // Update the state to refresh the UI
  }
}
