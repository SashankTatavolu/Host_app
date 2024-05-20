class Segment {
  final int mainSegment;
  String text;
  List<SubSegment> subSegments;

  Segment({required this.mainSegment, required this.text, required this.subSegments});
}
class SubSegment {
  String text;
  final String subIndex;
  final String indexType;
  int? columnCount;
  List<List<String>> tableData; // Data for each cell in the table
  Map<int, String?> dependencyRelations; // Changed to store nullable String

  SubSegment({
    required this.text,
    required this.subIndex,
    required this.indexType,
    this.columnCount,
    List<List<String>>? tableData,
    Map<int, String?>? dependencyRelations, // Changed to nullable String
  }) : this.tableData = tableData ?? List.generate(7, (_) => List.filled(columnCount ?? 0, '')),
        this.dependencyRelations = dependencyRelations ?? Map();
}
