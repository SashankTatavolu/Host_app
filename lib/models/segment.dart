class Segment {
  final String mainSegment;
  String text;
  List<SubSegment> subSegments;

  Segment({
    required this.mainSegment,
    required this.text,
    required this.subSegments,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    final List<SubSegment> subSegments = (json['segments'] as List)
        .map((subSegmentJson) => SubSegment.fromJson(subSegmentJson))
        .toList();

// Extract the last part of sentence_id after '0's
    final String sentenceId = json['sentence_id'];
    final String mainSegment = (sentenceId);

    return Segment(
      mainSegment: mainSegment,
      text: json['text'],
      subSegments: subSegments,
    );
  }

// Method to extract the last numeric part (with optional letters) of the sentence_id
// static String _extractMainSegment(String sentenceId) {
// final regex = RegExp(r'0*([0-9]+[a-zA-Z]*)');
// final match = regex.firstMatch(sentenceId);
// if (match != null) {
// return match.group(1) ?? sentenceId;
// }
// return sentenceId;
// }
}

class SubSegment {
  String text;
  final String subIndex;
  final String indexType;
  final int segmentId; // Added segmentId field
  int columnCount;
  bool isConceptDefinitionComplete;
  bool isDependencyRelationDefined;
  bool isConstructionDefined;
  bool isDiscourseDefined;
  List<ConceptDefinition> conceptDefinitions;
  List<DependencyRelation> dependencyRelations;
  String construction;
  String discourse;

  SubSegment({
    required this.text,
    required this.subIndex,
    required this.indexType,
    this.segmentId = 0, // Added segmentId parameter
    this.columnCount = 0,
    this.conceptDefinitions = const [],
    // List<ConceptDefinition>? conceptDefinitions,
    List<DependencyRelation>? dependencyRelations,
    this.construction = "",
    this.discourse = "",
    this.isConceptDefinitionComplete = false,
    this.isDependencyRelationDefined = false,
    this.isConstructionDefined = false,
    this.isDiscourseDefined = false,
  }) : dependencyRelations = dependencyRelations ?? [];

  factory SubSegment.fromJson(Map<String, dynamic> json) {
    final List<ConceptDefinition> conceptDefinitions =
        List<ConceptDefinition>.from(
      json['lexico_conceptual']
              ?.map((conceptJson) => ConceptDefinition.fromJson(conceptJson)) ??
          [],
    );
    return SubSegment(
      text: json['segment_text'] ?? '',
      subIndex: json['segment_index'] ?? '',
      indexType: json['index_type'] ?? '',
      segmentId: json['segment_id'] ?? 0, // Handle null values
      columnCount: conceptDefinitions
          .length, // Set columnCount based on conceptDefinitions length
      conceptDefinitions: conceptDefinitions,
    );
  }
}

class ConceptDefinition {
  int index;
  String concept;
  String semCat;
  String morphSem;
  String speakerView;
  List<String> relatedConcepts;
  String? selectedConcept;
  String conceptName;
  String? selectedValue;
  int lexicalConceptualId;

  ConceptDefinition(
      {required this.index,
      this.concept = "",
      this.semCat = "",
      this.morphSem = "",
      this.speakerView = "",
      this.relatedConcepts = const [],
      this.selectedConcept,
      this.conceptName = "",
      this.selectedValue,
      required this.lexicalConceptualId});

  factory ConceptDefinition.fromJson(Map<String, dynamic> json) {
    return ConceptDefinition(
      index: json['index'],
      concept: json['concept'] ?? "",
      semCat: json['semantic_category'] ?? "",
      morphSem: json['morphological_semantics'] ?? "",
      speakerView: json['speakers_view'] ?? "",
      relatedConcepts: List<String>.from(json['relatedConcepts'] ?? []),
      lexicalConceptualId: json['lexical_conceptual_id'],
    );
  }

  @override
  String toString() {
    return 'ConceptDefinition(index: $index, concept: $concept, semCat: $semCat, morphSem: $morphSem, speakerView: $speakerView, relatedConcepts: $relatedConcepts)';
  }

// Dynamic getter method
  String getProperty(String propertyName) {
    switch (propertyName) {
      case 'Concept':
        return concept;
      case 'Semantic Category':
        return semCat;
      case 'Morphological Semantics':
        return morphSem;
      case "Speaker's View":
        return speakerView;
      default:
        return '';
    }
  }

// Dynamic setter method
  void updateProperty(String propertyName, String value) {
    switch (propertyName) {
      case 'Concept':
        concept = value;
        break;
      case 'Semantic Category':
        semCat = value;
        break;
      case 'Morphological Semantics':
        morphSem = value;
        break;
      case "Speaker's View":
        speakerView = value;
        break;
    }
  }

// Factory method for creating a new instance with default values
  factory ConceptDefinition.create({required int index}) {
    return ConceptDefinition(
        index: index,
        concept: "",
        semCat: "",
        morphSem: "",
        speakerView: "",
        lexicalConceptualId: 1);
  }
}

class DependencyRelation {
  int index;
  int targetIndex;
  String relationType;
  bool isMain;
  String mainIndex;
  String relation;

// Constructor with default values
  DependencyRelation(
      {required this.index,
      this.targetIndex = 0,
      this.relationType = "",
      this.isMain = false,
      this.mainIndex = "",
      this.relation = ""});

  factory DependencyRelation.fromJson(Map<String, dynamic> json) {
    return DependencyRelation(
        targetIndex: json['target_index'] ?? 0,
        relationType: json['relation_type'] ?? 'None',
        isMain: json['is_main'] ?? false,
        index: json['index'],
        mainIndex: json['main_index'],
        relation: json['relation']);
  }
// Method to update the target index
  void updateTargetIndex(int newIndex) {
    targetIndex = newIndex;
  }

// Method to update the relation type
  void updateRelationType(String newType) {
    relationType = newType;
  }

  List<String> getRelationTypes() {
    return const [
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
  }

// Factory method to create a new instance with default values
  factory DependencyRelation.create({required int index}) {
    return DependencyRelation(
      index: index,
      targetIndex: 0,
      relationType: '',
    );
  }

  @override
  String toString() {
    return 'DependencyRelation(index: $index, targetIndex: $targetIndex, relationType: $relationType, isMain: $isMain, mainIndex: $mainIndex, relation : $relation)';
  }
}

abstract class Construction {
  String type; // To store the type of construction

  Construction(this.type);
}

class Conjunction extends Construction {
  List<int> indices;
  Conjunction(this.indices) : super('Conjunction');
}

class Disjunction extends Construction {
  List<int> indices;
  Disjunction(this.indices) : super('Disjunction');
}

class Measure extends Construction {
  String measureType; // Type of measurement
  String measureUnit; // Unit of measurement

  Measure(this.measureType, this.measureUnit) : super('Measure');
}
