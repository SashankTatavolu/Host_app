// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lc_frontend/views/file_download/USR_download_mobile.dart';
import 'package:lc_frontend/views/file_download/USR_download_web.dart';
import '../../models/segment.dart';
import '../../services/auth_service.dart'; // Adjust based on your AuthService implementation
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

    bool hasData = false; // Track if any data is found

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

      final conceptUrl = Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/segment_details/segment_details/$segmentId');
      print('Fetching concepts from: $conceptUrl');

      try {
        final response = await http.get(
          conceptUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final List<dynamic> conceptJsonList =
              jsonResponse['lexico_conceptual'] ?? [];
          final List<ConceptDefinition> conceptDefinitions = conceptJsonList
              .map((conceptJson) => ConceptDefinition.fromJson(conceptJson))
              .toList();

          if (conceptDefinitions.isNotEmpty) {
            hasData = true; // Set true if any data is found
          }

          if (mounted) {
            setState(() {
              subSegment.conceptDefinitions = conceptDefinitions;
              subSegment.columnCount = conceptDefinitions.length;
            });
          }

          print(conceptDefinitions);
        } else {
          print(
              'Failed to fetch concepts for segment $segmentId: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching concepts for segment $segmentId: $e');
      }
    }

    // If no data found, show Snackbar
    if (!hasData && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No USR found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Segment List Panel
          SizedBox(
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
    '-',
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
    '-',
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
    '-',
    'respect',
    'informal',
    'proximal',
    'distal',
    'def',
    'hI_1',
    'hI_2',
    'BI_1'
  ];

  final List<String> componentTypes = [
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

  List<String> relationTypes = [
    '-',
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

  List<String> discourserel = [
    '-',
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
    'kAryaxyowaka',
  ];

  // final List<String> domainTerms = [
  //   '-',
  //   'geography',
  //   'geography physical',
  //   'recipe'
  // ];

  final List<String> constructionOptions = [
    '[3-waw]',
    '[4-waw]',
    '[5-waw]',
    '[6-waw]',
    '[7-waw]',
    '[naF-waw]',
    '[2-waw]',
    '[karmaXAraya]',
    '[xvigu]',
    '[2-bahubrIhi]',
    '[3-bahubrIhi]',
    '[4-bahubrIhi]',
    '[5-bahubrIhi]',
    '[6-bahubrIhi]',
    '[7-bahubrIhi]',
    '[xvanxva]',
    '[avyayIBAva]',
    '[upapaxa]',
    '[maXyamapaxalopI]',
    '[conj_1]',
    '[conj_2]',
    '[conj_3]',
    '[disjunct_1]',
    '[disjunct_2]',
    '[disjunct_3]',
    '[span_1]',
    '[span_2]',
    '[meas_1]',
    '[meas_2]',
    '[cp_1]',
    '[cp_2]',
    '[cp_3]',
    '[compound_1]',
    '[compound_2]',
    '[compound_3',
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
        'https://canvas.iiit.ac.in/lc/api/concepts/getconcepts/$originalConceptName');
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

  Future<void> _downloadUsr() async {
    final token = await getJwtToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not retrieve JWT token')),
      );
      return;
    }

    final url =
        'https://canvas.iiit.ac.in/lc/api/segment_details/segment_details/${widget.subSegment.segmentId}/download';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        const fileName = 'downloaded_usr.txt';

        if (kIsWeb) {
          // Convert response.bodyBytes to String using UTF-8 encoding
          final fileContent = utf8.decode(response.bodyBytes);
          downloadFileWeb(fileName, fileContent);
        } else {
          await downloadFileIO(fileName, response.bodyBytes);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading file')),
      );
    }
  }

  void _showConceptOptionsPopup(int columnIndex, String conceptName) async {
    await _fetchConceptOptions(columnIndex, conceptName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Concept'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (conceptOptions[columnIndex]?.isEmpty ?? true)
                const Text('No concepts found')
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

  void _showPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Show Guidelines"),
          content: SizedBox(
            width: 1000,
            height: 600,
            child: PdfViewer.asset('assets/files/Lexico-Conceptual.pdf'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _downloadUsr, // Download button for USR
              child: const Text("Download USR"),
            ),
            ElevatedButton(
              onPressed: () {
                _showPdf(context); // Call the showPdf function when pressed
              },
              child: const Text("View PDF Guidelines"),
            ),
            ElevatedButton(
              onPressed: () => _promptForColumnCount(widget.subSegment),
              child: const Text("Change Concepts"),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
          child: Text(
            '${widget.subSegment.subIndex} : ${widget.subSegment.text}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
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

  void _clearConceptOptions() {
    setState(() {
      conceptOptions = {};
    });
  }

  void _promptForColumnCount(SubSegment subSegment) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Specify Number of Columns"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display subSegment text and subIndex
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '${subSegment.subIndex} : ${subSegment.text}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              // Text field for number of columns
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter number of columns",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                int? columns = int.tryParse(controller.text);
                if (columns != null && columns > 0) {
                  setState(() {
                    subSegment.columnCount = columns;

                    subSegment.conceptDefinitions.clear();
                    _clearConceptOptions();

                    // Initialize empty ConceptDefinitions for each column
                    subSegment.conceptDefinitions.clear();
                    for (int i = 0; i < columns; i++) {
                      subSegment.conceptDefinitions
                          .add(ConceptDefinition.create(index: i + 1));
                    }

                    // (Optional) Initialize empty DependencyRelations
                    subSegment.dependencyRelations.clear();
                    for (int i = 0; i < columns; i++) {
                      subSegment.dependencyRelations
                          .add(DependencyRelation.create(index: i + 1));
                    }
                  });

                  Navigator.of(context).pop();
                  _showDataEntryPopup(
                      subSegment); // Show data entry popup after column count is set
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDataEntryPopup(SubSegment subSegment) {
    List<Map<String, TextEditingController>> controllers = List.generate(
      subSegment.columnCount,
      (index) => {
        'index': TextEditingController(),
        'concept': TextEditingController(),
        'semanticCategory': TextEditingController(),
        'morphologicalSemantics': TextEditingController(),
        'speakersView': TextEditingController(),
        'CxN head': TextEditingController(),
        'Component Type': TextEditingController(),
        'Head Index': TextEditingController(),
        'Is Main': TextEditingController(),
        'Dep Rel': TextEditingController(),
        'Discourse Head Index': TextEditingController(),
        'Discourse Rel': TextEditingController(),
        'CO-ref': TextEditingController(),
      },
    );

    ScrollController verticalScrollController = ScrollController();
    ScrollController horizontalScrollController = ScrollController();

    void showDiscourseRelPopup(int columnIndex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Discourse Rel'),
            content: SingleChildScrollView(
              child: Column(
                children: discourserel.map((String value) {
                  return ListTile(
                    title: Text(value),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        controllers[columnIndex]['Discourse Rel']?.text = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Data for Each Column'),
          content: SizedBox(
            width: 1000.0, // Adjust the width as needed
            height: 700.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '${subSegment.subIndex} : ${subSegment.text}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: verticalScrollController,
                    child: SingleChildScrollView(
                      controller: verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: horizontalScrollController,
                        child: SingleChildScrollView(
                          controller: horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 60.0, // Adjust height as needed
                            // Updated DataColumn code with three-dot icon and popup menu
                            columns: [
                              const DataColumn(
                                label: Text('Index',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              for (int i = 0; i < subSegment.columnCount; i++)
                                DataColumn(
                                  label: Text('Column ${i + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],

                            rows: [
                              DataRow(
                                cells: [
                                  const DataCell(Text('Index:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]['index'],
                                          decoration: InputDecoration(
                                            labelText: 'index ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Concept:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: Stack(
                                          children: [
                                            TextField(
                                              controller: controllers[i]
                                                  ['concept'],
                                              decoration: InputDecoration(
                                                labelText: 'Concept ${i + 1}',
                                              ),
                                              onChanged: (value) {
                                                // Trigger fetching of concept options based on the current input
                                                _fetchConceptOptions(i, value);
                                              },
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: PopupMenuButton<String>(
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                onSelected: (String value) {
                                                  setState(() {
                                                    controllers[i]['concept']!
                                                        .text = value;
                                                  });
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return conceptOptions[i]?.map(
                                                          (String option) {
                                                        return PopupMenuItem<
                                                            String>(
                                                          value: option,
                                                          child: Text(option),
                                                        );
                                                      }).toList() ??
                                                      [];
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Semantic Category:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText:
                                                'Semantic Category ${i + 1}',
                                          ),
                                          items: semanticCategories
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            controllers[i]['semanticCategory']!
                                                .text = value!;
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Morpho Semantics:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText:
                                                'Morpho Semantics ${i + 1}',
                                          ),
                                          items: morphologicalSemantics
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            controllers[i]
                                                    ['morphologicalSemantics']!
                                                .text = value!;
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Speakers View:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Speakers View ${i + 1}',
                                          ),
                                          items:
                                              speakersViews.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            controllers[i]['speakersView']!
                                                .text = value!;
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('CxN head')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]
                                              ['CxN head'],
                                          decoration: InputDecoration(
                                            labelText: 'CxN head ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Component Type:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText:
                                                'Component Type ${i + 1}',
                                          ),
                                          items: componentTypes
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            controllers[i]['Component Type']!
                                                .text = value!;
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Head Index:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]
                                              ['Head Index'],
                                          decoration: InputDecoration(
                                            labelText: 'Head Index ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Is Main:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]['Is Main'],
                                          decoration: InputDecoration(
                                            labelText: 'Is Main ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Dep Rel:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]['Dep Rel'],
                                          decoration: InputDecoration(
                                            labelText: 'Dep Rel ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Discourse Head Index:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]
                                              ['Discourse Head Index'],
                                          decoration: InputDecoration(
                                            labelText:
                                                'Discourse Head Index ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Discourse Rel:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]
                                              ['Discourse Rel'],
                                          decoration: InputDecoration(
                                            labelText: 'Discourse Rel ${i + 1}',
                                          ),
                                          onTap: () => showDiscourseRelPopup(i),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('CO-ref:')),
                                  for (int i = 0;
                                      i < subSegment.columnCount;
                                      i++)
                                    DataCell(
                                      SizedBox(
                                        width: 180.0,
                                        child: TextField(
                                          controller: controllers[i]['CO-ref'],
                                          decoration: InputDecoration(
                                            labelText: 'CO-ref ${i + 1}',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                // Dispose controllers here if necessary
                verticalScrollController.dispose();
                horizontalScrollController.dispose();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                _submitData(subSegment, controllers);
                // Dispose controllers here if necessary
                verticalScrollController.dispose();
                horizontalScrollController.dispose();
                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _submitData(SubSegment subSegment,
      List<Map<String, TextEditingController>> controllers) async {
    final String? token = await getJwtToken();

    if (token == null) {
      print('JWT token is missing');
      return;
    }

    // Ensure that all controllers are initialized
    for (int i = 0; i < subSegment.columnCount; i++) {
      final controllerNames = [
        'index',
        'concept',
        'semanticCategory',
        'morphologicalSemantics',
        'speakersView',
        'CxN head',
        'Component Type',
        'Is Main',
        'Head Index',
        'Dep Rel',
        'Discourse Head Index',
        'Discourse Rel',
        'CO-ref'
      ];

      for (var name in controllerNames) {
        if (controllers[i][name] == null) {
          print('Controller for $name at column $i is missing');
          return;
        }
      }
    }

    // Build the lexico_conceptual array
    List<Map<String, dynamic>> lexicoConceptual = [];

    for (int i = 0; i < subSegment.columnCount; i++) {
      final conceptEntry = {
        "segment_index": subSegment.subIndex,
        "index": i + 1,
        "concept": controllers[i]['concept']!.text,
        "semantic_category": controllers[i]['semanticCategory']!.text,
        "morphological_semantics":
            controllers[i]['morphologicalSemantics']!.text,
        "speakers_view": controllers[i]['speakersView']!.text,
        "relational": [
          {
            "segment_index": subSegment.subIndex,
            "index": i + 1,
            "head_relation": controllers[i]['Component Type']!.text,
            "head_index": controllers[i]['Head Index']!.text,
            "relation": controllers[i]['Dep Rel']!.text,
            "is_main": controllers[i]['Is Main']!.text.toLowerCase() == 'true'
          }
        ], // Add relational data here if needed
        "construction": [
          {
            "segment_index": subSegment.subIndex,
            "index": i + 1,
            "construction":
                '${controllers[i]['CxN head']!.text}: ${controllers[i]['Component Type']!.text}',
            "cxn_index": int.tryParse(controllers[i]['CxN head']!.text) ?? 0,
            "component_type": controllers[i]['Component Type']!.text,
          }
        ],
        "discourse": [
          {
            "segment_index": subSegment.subIndex,
            "index": i + 1,
            "head_index": controllers[i]['Discourse Head Index']!.text,
            "relation":
                controllers[i]['Dep Rel']!.text, // Check if the key is correct
            "discourse":
                '${controllers[i]['Discourse Head Index']!.text}: ${controllers[i]['Discourse Rel']!.text}', // Formatting value
          }
        ],
        // "domain_term": [
        //   {
        //     "segment_index": subSegment.subIndex,
        //     "index": i + 1,
        //     "domain_term": controllers[i]['domainTerm']!.text
        //   }
        // ]
      };
      lexicoConceptual.add(conceptEntry);
    }

    // Build the request body
    final Map<String, dynamic> requestBody = {
      "segment_id": subSegment.segmentId,
      "segment_text": subSegment.text,
      "segment_type": subSegment.indexType,
      "lexico_conceptual": lexicoConceptual,
    };

    print('Request body: ${jsonEncode(requestBody)}');
    final response = await http.post(
      Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/segment_details/segment_details'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Data successfully submitted');
    } else {
      print('Failed to submit data: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  buildConceptDataTable() {
    ScrollController horizontalScrollController = ScrollController();

    return Scrollbar(
      controller: horizontalScrollController,
      thumbVisibility: true, // Keeps the scrollbar visible
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        child: DataTable(
          columnSpacing: 12,
          columns: _buildHeaderRow(),
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataColumn> _buildHeaderRow() {
    // Add one more column for the row headers
    List<DataColumn> headers = [
      const DataColumn(label: Text('COLUMN')), // Header for the row header
    ];

    headers.addAll(List.generate(
      widget.subSegment.columnCount,
      (index) => DataColumn(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${index + 1}'),
          ],
        ),
      ),
    ));
    return headers;
  }

  List<DataRow> _buildDataRows() {
    List<String> properties = [
      'Index',
      'Concept',
      'Semantic Category',
      'Morphological Semantics',
      "Speaker's View"
    ];

    return List.generate(properties.length, (rowIndex) {
      return DataRow(cells: [
        DataCell(Text(properties[rowIndex])), // Row header
        ...List.generate(widget.subSegment.columnCount, (columnIndex) {
          final conceptDef = widget.subSegment.conceptDefinitions[columnIndex];
          switch (rowIndex) {
            case 0: // Index
              return DataCell(
                Text(conceptDef.index
                    .toString()), // Display index starting from 1
              );
            case 1: // Concept
              String conceptValue = conceptDef.concept;

              // Check if the concept starts and ends with []
              return DataCell(
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: conceptValue,
                                selection: TextSelection.collapsed(
                                    offset: conceptValue.length))),
                        onChanged: (value) {
                          updateConceptProperty(
                            columnIndex,
                            properties[rowIndex],
                            value,
                          );
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        // Check if the concept starts and ends with []
                        if (conceptValue.startsWith('[') &&
                            conceptValue.endsWith(']')) {
                          // Display constructionOptions if the concept is within brackets
                          _showConstructionOptionsPopup(
                              columnIndex, conceptValue);
                        } else {
                          // Otherwise, continue fetching options dynamically
                          _showConceptOptionsPopup(columnIndex, conceptValue);
                        }
                      },
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              );
            case 2: // Semantic Category dropdown
              return DataCell(_buildDropdown(
                conceptDef.semCat,
                semanticCategories,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            case 3: // Morphological Semantics dropdown
              return DataCell(_buildDropdown(
                conceptDef.morphSem,
                morphologicalSemantics,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            case 4: // Speaker's View dropdown
              return DataCell(_buildDropdown(
                conceptDef.speakerView,
                speakersViews,
                (value) => updateConceptProperty(
                    columnIndex, properties[rowIndex], value),
              ));
            default:
              return DataCell(
                SizedBox(
                  width: 120, // Adjust width as needed
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

  void _showConstructionOptionsPopup(int columnIndex, String conceptValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Construction Option'),
          content: SingleChildScrollView(
            child: Scrollbar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: constructionOptions.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      // Update concept with selected construction option
                      updateConceptProperty(columnIndex, 'Concept', option);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown(
    String selectedValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    List<String> updatedOptions = List.from(options);
    if (!updatedOptions.contains('others')) {
      updatedOptions.add('others');
    }

    // Ensure that the selected value is in the updated options list
    if (selectedValue.isNotEmpty && !updatedOptions.contains(selectedValue)) {
      updatedOptions.add(selectedValue);
    }

    return SizedBox(
      width: 150, // Set the desired fixed width for the dropdown
      child: DropdownButton<String>(
        isExpanded: true, // This ensures the dropdown content does not overflow
        value: selectedValue.isEmpty ? null : selectedValue,
        onChanged: (newValue) {
          if (newValue == 'others') {
            _showCustomInputDialog((customValue) {
              if (customValue.isNotEmpty) {
                if (!updatedOptions.contains(customValue)) {
                  updatedOptions.add(customValue);
                }
                onChanged(customValue);
              }
            });
          } else {
            onChanged(newValue!);
          }
        },
        items: updatedOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  void _showCustomInputDialog(ValueChanged<String> onCustomValueEntered) {
    String customValue = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Value'),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              customValue = value;
            },
            decoration: const InputDecoration(hintText: 'Enter value'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onCustomValueEntered(customValue);
              },
            ),
          ],
        );
      },
    );
  }

  void updateConceptProperty(int columnIndex, String property, String value) {
    ConceptDefinition conceptDef =
        widget.subSegment.conceptDefinitions[columnIndex];
    conceptDef.updateProperty(property, value);
    setState(() {});
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
    final url = Uri.parse(
        'https://canvas.iiit.ac.in/lc/api/lexicals/segment/$segmentId');
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
