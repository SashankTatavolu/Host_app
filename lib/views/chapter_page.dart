import 'package:flutter/material.dart';
import 'package:lc_frontend/views/construction_tab.dart';
import 'package:lc_frontend/views/discourse_definition.dart';
import 'package:lc_frontend/views/domain_term.dart';
import 'package:lc_frontend/views/segment_tab.dart';
import 'package:lc_frontend/views/concept_definition_tab.dart';
import 'package:lc_frontend/widgets/custom_app_bar.dart';
import 'package:lc_frontend/views/coref_page.dart';

import '../models/segment.dart';
import '../widgets/navigation_bar.dart';
import 'chapter_tab.dart';

import 'dependency_relation_tab.dart';

class ChapterPage extends StatefulWidget {
  final int chapterId;
  const ChapterPage({super.key, required this.chapterId});

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Segment> segments = [
    Segment(
        mainSegment: '1',
        text:
            'इन धाराओं को अपसरण और अभिसरण क्रियाओं के साथ क्रमशः आरोही और अवरोही क्रमों में वर्गीकृत किया गया है। ',
        subSegments: [
          SubSegment(
            text:
                'इन धाराओं को अपसरण और अभिसरण क्रियाओं के साथ क्रमशः आरोही और अवरोही क्रमों में वर्गीकृत किया गया है। ',
            subIndex: 'Test_1_0001',
            indexType: 'Normal',
            columnCount: 15,
            isConceptDefinitionComplete: true,
            isDependencyRelationDefined: false,
            isConstructionDefined: false,
            conceptDefinitions: [
              ConceptDefinition(
                  index: 1, concept: 'wyax', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 2, concept: 'XArA_1', lexicalConceptualId: 1),
            ],
            dependencyRelations: [
              DependencyRelation(
                  index: 1,
                  targetIndex: 2,
                  relationType: 'k1',
                  isMain: false,
                  conceptId: 0,
                  relationalId: 0),
            ],
            segmentId: 1,
          ),
        ]),
    Segment(mainSegment: '2', text: 'इसका धरातल असमतल है।', subSegments: [
      SubSegment(
          text: 'इसका धरातल असमतल है।',
          subIndex: '2a',
          indexType: 'Normal',
          columnCount: 4,
          isConceptDefinitionComplete: true,
          isDependencyRelationDefined: true,
          conceptDefinitions: [
            ConceptDefinition(
                index: 1, concept: "\$wyax", lexicalConceptualId: 1),
          ],
          dependencyRelations: [
            DependencyRelation(
                index: 1,
                targetIndex: 1,
                relationType: 'r6',
                isMain: false,
                conceptId: 0,
                relationalId: 0),
          ],
          discourse: '1.1:coref',
          segmentId: 1),
    ]),
    Segment(
        mainSegment: '3',
        text:
            'पृथ्वी पर विविध प्रकार की भू आकृतियाँ - पर्वत, पठार, पहाड़ियाँ, मैदान,कटक तथा उत्खात भूमियाँ दिखाई देती हैं ।',
        subSegments: [
          SubSegment(
            text:
                'पृथ्वी पर विविध प्रकार की भू आकृतियाँ - पर्वत, पठार, पहाड़ियाँ, मैदान,कटक तथा उत्खात भूमियाँ दिखाई देती हैं ।',
            subIndex: '3a',
            indexType: 'Normal',
            columnCount: 12,
            isConceptDefinitionComplete: true,
            isDependencyRelationDefined: true,
            isConstructionDefined: true,
            conceptDefinitions: [
              ConceptDefinition(
                  index: 1, concept: 'pqWvI_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 2, concept: 'viviXa_1', lexicalConceptualId: 1),
            ],
            dependencyRelations: [
              DependencyRelation(
                  index: 1,
                  targetIndex: 11,
                  relationType: 'k7',
                  isMain: false,
                  conceptId: 0,
                  relationalId: 0),
            ],
            construction: "conj:[5,6,7,8,9,11]",
            segmentId: 1,
          ),
        ]),
    Segment(
        mainSegment: '4',
        text:
            'हमें भू पृष्ठ पर झुके हुए, मुड़े तथा टूटे हुए शैल संस्तर भी देखने को मिलते हैं, जो अपने मूल रूप में समानांतर रूपों में बिछे थे ।',
        subSegments: [
          SubSegment(
              text:
                  'हमें भू पृष्ठ पर झुके हुए, मुड़े तथा टूटे हुए शैल संस्तर भी देखने को मिलते हैं, जो अपने मूल रूप में समानांतर रूपों में बिछे थे ।',
              subIndex: '4a',
              indexType: 'Normal',
              columnCount: 15,
              isConceptDefinitionComplete: true,
              isDependencyRelationDefined: true,
              isConstructionDefined: true,
              conceptDefinitions: [
                ConceptDefinition(
                    index: 1, concept: '\$speaker', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 2, concept: 'BU+prqRTa_1', lexicalConceptualId: 1),
              ],
              dependencyRelations: [
                DependencyRelation(
                    index: 1,
                    targetIndex: 7,
                    relationType: 'k1',
                    isMain: false,
                    conceptId: 0,
                    relationalId: 0),
              ],
              construction: "conj:[3,4,5]",
              discourse: "6:coref",
              segmentId: 1),
        ]),
    Segment(
        mainSegment: '3',
        text:
            'पृथ्वी पर विविध प्रकार की भू आकृतियाँ - पर्वत, पठार, पहाड़ियाँ, मैदान,कटक तथा उत्खात भूमियाँ दिखाई देती हैं ।',
        subSegments: [
          SubSegment(
              text:
                  'पृथ्वी पर विविध प्रकार की भू आकृतियाँ - पर्वत, पठार, पहाड़ियाँ, मैदान,कटक तथा उत्खात भूमियाँ दिखाई देती हैं ।',
              subIndex: '3a',
              indexType: 'Normal',
              columnCount: 12,
              isConceptDefinitionComplete: true,
              isDependencyRelationDefined: true,
              isConstructionDefined: true,
              conceptDefinitions: [
                ConceptDefinition(
                    index: 1, concept: 'pqWvI_1', lexicalConceptualId: 1),
              ],
              dependencyRelations: [
                DependencyRelation(
                    index: 1,
                    targetIndex: 11,
                    relationType: 'k7',
                    isMain: false,
                    conceptId: 0,
                    relationalId: 0),
              ],
              construction: "conj:[5,6,7,8,9,11]",
              segmentId: 1),
        ]),
    Segment(mainSegment: '1', text: 'पृथ्वी अस्थिर है।', subSegments: [
      SubSegment(
        text: 'पृथ्वी अस्थिर है।',
        subIndex: '1a',
        indexType: 'Normal',
        columnCount: 3,
        isConceptDefinitionComplete: false,
        isDependencyRelationDefined: false,
        isConstructionDefined: false,
        conceptDefinitions: [
          ConceptDefinition(index: 1, concept: 'pqWvI', lexicalConceptualId: 1),
          ConceptDefinition(
              index: 2, concept: 'asWira', lexicalConceptualId: 1),
          ConceptDefinition(index: 3, concept: 'hE', lexicalConceptualId: 1)
        ],
        dependencyRelations: [
          DependencyRelation(
              index: 1,
              targetIndex: 2,
              relationType: 'k1',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 2,
              targetIndex: 2,
              relationType: 'k1s',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 3,
              targetIndex: 0,
              relationType: 'main',
              isMain: true,
              conceptId: 0,
              relationalId: 0)
        ],
        segmentId: 1,
      ),
    ]),
    Segment(mainSegment: '1', text: 'पृथ्वी अस्थिर है।', subSegments: [
      SubSegment(
        text: 'पृथ्वी अस्थिर है।',
        subIndex: '1a',
        indexType: 'Normal',
        columnCount: 3,
        isConceptDefinitionComplete: false,
        isDependencyRelationDefined: false,
        isConstructionDefined: false,
        conceptDefinitions: [
          ConceptDefinition(index: 1, concept: 'pqWvI', lexicalConceptualId: 1),
          ConceptDefinition(
              index: 2, concept: 'asWira', lexicalConceptualId: 1),
          ConceptDefinition(index: 3, concept: 'hE', lexicalConceptualId: 1)
        ],
        dependencyRelations: [
          DependencyRelation(
              index: 1,
              targetIndex: 2,
              relationType: 'k1',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 2,
              targetIndex: 2,
              relationType: 'k1s',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 3,
              targetIndex: 0,
              relationType: 'main',
              isMain: true,
              conceptId: 0,
              relationalId: 0)
        ],
        segmentId: 1,
      ),
    ]),
    Segment(mainSegment: '1', text: 'पृथ्वी अस्थिर है।', subSegments: [
      SubSegment(
        text: 'पृथ्वी अस्थिर है।',
        subIndex: '1a',
        indexType: 'Normal',
        columnCount: 3,
        isConceptDefinitionComplete: false,
        isDependencyRelationDefined: false,
        isConstructionDefined: false,
        conceptDefinitions: [
          ConceptDefinition(index: 1, concept: 'pqWvI', lexicalConceptualId: 1),
          ConceptDefinition(
              index: 2, concept: 'asWira', lexicalConceptualId: 1),
          ConceptDefinition(index: 3, concept: 'hE', lexicalConceptualId: 1)
        ],
        dependencyRelations: [
          DependencyRelation(
              index: 1,
              targetIndex: 2,
              relationType: 'k1',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 2,
              targetIndex: 2,
              relationType: 'k1s',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 3,
              targetIndex: 0,
              relationType: 'main',
              isMain: true,
              conceptId: 0,
              relationalId: 0)
        ],
        segmentId: 1,
      ),
    ]),
    Segment(mainSegment: '1', text: 'पृथ्वी अस्थिर है।', subSegments: [
      SubSegment(
        text: 'पृथ्वी अस्थिर है।',
        subIndex: '1a',
        indexType: 'Normal',
        columnCount: 3,
        isConceptDefinitionComplete: false,
        isDependencyRelationDefined: false,
        isConstructionDefined: false,
        conceptDefinitions: [
          ConceptDefinition(index: 1, concept: 'pqWvI', lexicalConceptualId: 1),
          ConceptDefinition(
              index: 2, concept: 'asWira', lexicalConceptualId: 1),
          ConceptDefinition(index: 3, concept: 'hE', lexicalConceptualId: 1)
        ],
        dependencyRelations: [
          DependencyRelation(
              index: 1,
              targetIndex: 2,
              relationType: 'k1',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 2,
              targetIndex: 2,
              relationType: 'k1s',
              isMain: false,
              conceptId: 0,
              relationalId: 0),
          DependencyRelation(
              index: 3,
              targetIndex: 0,
              relationType: 'main',
              isMain: true,
              conceptId: 0,
              relationalId: 0)
        ],
        segmentId: 1,
      ),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const NavigationMenu(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Material(
              color: Colors.indigo.shade300,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.indigo,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 18.0),
                tabs: const [
                  Tab(text: 'Chapter'),
                  Tab(text: 'Segment'),
                  Tab(text: 'Lexico Conceptual'),
                  Tab(text: 'Domain Term'),
                  Tab(text: 'Construction'),
                  Tab(text: 'Relational'),
                  Tab(text: 'Discourse'),
                  Tab(text: 'Coref')
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ChapterTab(chapterId: widget.chapterId),
                  SegmentTab(
                    chapterId: widget.chapterId,
                  ),
                  ConceptTab(
                    segments: segments,
                    chapterId: widget.chapterId,
                  ),
                  DomainTermTab(
                    chapterId: widget.chapterId,
                  ),
                  ConstructionTab(
                    chapterId: widget.chapterId.toString(),
                    // segments: segments,
                  ),
                  DependencyRelationPage(
                    chapterId: widget.chapterId,
                    // segments: segments,
                  ),
                  DiscourseTab(
                    chapterId: widget.chapterId,
                    // segments: segments,
                  ),
                  CorefTab(
                    chapterId: widget.chapterId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
