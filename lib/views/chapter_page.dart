import 'package:flutter/material.dart';
import 'package:lc_frontend/views/construction_tab.dart';
import 'package:lc_frontend/views/discourse_definition.dart';
import 'package:lc_frontend/views/segment_tab.dart';
import 'package:lc_frontend/views/concept_definition_tab.dart';
import 'package:lc_frontend/widgets/custom_app_bar.dart';

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
              ConceptDefinition(
                  index: 3, concept: 'apasaraNa_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 4, concept: 'kriyA_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 5, concept: 'ArohI_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 6, concept: 'aBisaraNa_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 7, concept: 'kriyA_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 8, concept: 'avarohI_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 9, concept: 'krama_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 10, concept: 'vargIkqwa_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 11,
                  concept: 'kara_1-yA_gayA_hE_1',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 12,
                  concept: '[karmaXAraya_1]',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 13,
                  concept: '[karmaXAraya_2]',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 14, concept: '[conj_2]', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 15, concept: '[CP_1]', lexicalConceptualId: 1),
            ],
            dependencyRelations: [
              DependencyRelation(
                  index: 1, targetIndex: 2, relationType: 'k1', isMain: false),
              DependencyRelation(
                  index: 2, targetIndex: 2, relationType: 'k1s', isMain: false),
              DependencyRelation(
                  index: 3, targetIndex: 0, relationType: 'main', isMain: true)
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
            ConceptDefinition(
                index: 2, concept: 'XarAwala', lexicalConceptualId: 1),
            ConceptDefinition(
                index: 3, concept: 'asamawala', lexicalConceptualId: 1),
            ConceptDefinition(index: 4, concept: 'hE', lexicalConceptualId: 1)
          ],
          dependencyRelations: [
            DependencyRelation(
                index: 1, targetIndex: 1, relationType: 'r6', isMain: false),
            DependencyRelation(
                index: 2, targetIndex: 3, relationType: 'k1', isMain: false),
            DependencyRelation(
                index: 3, targetIndex: 3, relationType: 'k1s', isMain: false),
            DependencyRelation(
                index: 4, targetIndex: 0, relationType: 'main', isMain: true)
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
              ConceptDefinition(
                  index: 3, concept: 'prakAra_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 4,
                  concept: 'BU+Akqwi_1',
                  morphSem: 'p1',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 5, concept: 'parvawa_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 6, concept: 'paTAra_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 7,
                  concept: 'pahAdZI_1',
                  morphSem: 'p1',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 8, concept: 'mExAna_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 9, concept: 'kataka_1', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 10, concept: 'uwKAwa', lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 11,
                  concept: 'BUmi_1',
                  morphSem: 'p1',
                  lexicalConceptualId: 1),
              ConceptDefinition(
                  index: 12,
                  concept: 'xiKa_1-AI_xewA_hE_1',
                  lexicalConceptualId: 1),
            ],
            dependencyRelations: [
              DependencyRelation(
                  index: 1, targetIndex: 11, relationType: 'k7', isMain: false),
              DependencyRelation(
                  index: 2, targetIndex: 2, relationType: 'mod', isMain: false),
              DependencyRelation(
                  index: 3, targetIndex: 3, relationType: 'r6', isMain: false),
              DependencyRelation(
                  index: 4, targetIndex: 11, relationType: 'k2', isMain: false),
              DependencyRelation(
                  index: 5, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 6, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 7, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 8, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 9, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 10,
                  targetIndex: 10,
                  relationType: 'mod',
                  isMain: false),
              DependencyRelation(
                  index: 11, targetIndex: 3, relationType: 'ru', isMain: false),
              DependencyRelation(
                  index: 12, targetIndex: 0, relationType: 'main', isMain: true)
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
                ConceptDefinition(
                    index: 3, concept: 'Juka_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 4,
                    concept: 'muda_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 5, concept: 'tUta_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 6,
                    concept: 'SEla_1+saMswara_1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 7,
                    concept: 'xeKa_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 8,
                    concept: 'mila_1-wA_hE_1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 9, concept: '\$yax', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 10, concept: 'apaNa', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 11,
                    concept: 'mUla_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 12, concept: 'rUpa_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 10,
                    concept: 'samAnAMwara_1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 11,
                    concept: 'rUpa_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 12,
                    concept: 'biCa_1-yA_WA_1',
                    lexicalConceptualId: 1),
              ],
              dependencyRelations: [
                DependencyRelation(
                    index: 1,
                    targetIndex: 7,
                    relationType: 'k1',
                    isMain: false),
                DependencyRelation(
                    index: 2,
                    targetIndex: 7,
                    relationType: 'k7p',
                    isMain: false),
                DependencyRelation(
                    index: 3,
                    targetIndex: 7,
                    relationType: 'rbks',
                    isMain: false),
                DependencyRelation(
                    index: 4,
                    targetIndex: 7,
                    relationType: 'rbks',
                    isMain: false),
                DependencyRelation(
                    index: 5,
                    targetIndex: 7,
                    relationType: 'RBKS',
                    isMain: false),
                DependencyRelation(
                    index: 6,
                    targetIndex: 7,
                    relationType: 'k1',
                    isMain: false),
                DependencyRelation(
                    index: 7,
                    targetIndex: 7,
                    relationType: 'r2',
                    isMain: false),
                DependencyRelation(
                    index: 8,
                    targetIndex: 0,
                    relationType: 'main',
                    isMain: true),
                DependencyRelation(
                    index: 9,
                    targetIndex: 12,
                    relationType: 'k1',
                    isMain: false),
                DependencyRelation(
                    index: 10,
                    targetIndex: 10,
                    relationType: 'r6',
                    isMain: false),
                DependencyRelation(
                    index: 11,
                    targetIndex: 15,
                    relationType: '',
                    isMain: false),
                DependencyRelation(
                    index: 12,
                    targetIndex: 12,
                    relationType: 'k7',
                    isMain: true),
                DependencyRelation(
                    index: 13,
                    targetIndex: 12,
                    relationType: 'k7',
                    isMain: false),
                DependencyRelation(
                    index: 14,
                    targetIndex: 5,
                    relationType: 'rcdelim',
                    isMain: false),
                DependencyRelation(
                    index: 15,
                    targetIndex: 0,
                    relationType: 'main',
                    isMain: true)
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
                ConceptDefinition(
                    index: 2, concept: 'viviXa_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 3, concept: 'prakAra_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 4,
                    concept: 'BU+Akqwi_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 5, concept: 'parvawa_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 6, concept: 'paTAra_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 7,
                    concept: 'pahAdZI_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 8, concept: 'mExAna_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 9, concept: 'kataka_1', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 10, concept: 'uwKAwa', lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 11,
                    concept: 'BUmi_1',
                    morphSem: 'p1',
                    lexicalConceptualId: 1),
                ConceptDefinition(
                    index: 12,
                    concept: 'xiKa_1-AI_xewA_hE_1',
                    lexicalConceptualId: 1),
              ],
              dependencyRelations: [
                DependencyRelation(
                    index: 1,
                    targetIndex: 11,
                    relationType: 'k7',
                    isMain: false),
                DependencyRelation(
                    index: 2,
                    targetIndex: 2,
                    relationType: 'mod',
                    isMain: false),
                DependencyRelation(
                    index: 3,
                    targetIndex: 3,
                    relationType: 'r6',
                    isMain: false),
                DependencyRelation(
                    index: 4,
                    targetIndex: 11,
                    relationType: 'k2',
                    isMain: false),
                DependencyRelation(
                    index: 5,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 6,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 7,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 8,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 9,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 10,
                    targetIndex: 10,
                    relationType: 'mod',
                    isMain: false),
                DependencyRelation(
                    index: 11,
                    targetIndex: 3,
                    relationType: 'ru',
                    isMain: false),
                DependencyRelation(
                    index: 12,
                    targetIndex: 0,
                    relationType: 'main',
                    isMain: true)
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
              index: 1, targetIndex: 2, relationType: 'k1', isMain: false),
          DependencyRelation(
              index: 2, targetIndex: 2, relationType: 'k1s', isMain: false),
          DependencyRelation(
              index: 3, targetIndex: 0, relationType: 'main', isMain: true)
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
              index: 1, targetIndex: 2, relationType: 'k1', isMain: false),
          DependencyRelation(
              index: 2, targetIndex: 2, relationType: 'k1s', isMain: false),
          DependencyRelation(
              index: 3, targetIndex: 0, relationType: 'main', isMain: true)
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
              index: 1, targetIndex: 2, relationType: 'k1', isMain: false),
          DependencyRelation(
              index: 2, targetIndex: 2, relationType: 'k1s', isMain: false),
          DependencyRelation(
              index: 3, targetIndex: 0, relationType: 'main', isMain: true)
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
              index: 1, targetIndex: 2, relationType: 'k1', isMain: false),
          DependencyRelation(
              index: 2, targetIndex: 2, relationType: 'k1s', isMain: false),
          DependencyRelation(
              index: 3, targetIndex: 0, relationType: 'main', isMain: true)
        ],
        segmentId: 1,
      ),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
                  Tab(text: 'Construction'),
                  Tab(text: 'Relational'),
                  Tab(text: 'Discourse'),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
