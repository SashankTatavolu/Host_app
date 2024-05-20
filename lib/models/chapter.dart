class Chapter {
  final String chapterName;
  final String createdBy;
  final String createdOn;
  final List<String> assignedTo;  // List to handle multiple users
  final int totalSegments;
  final int completedSegments;
  final String status;

  Chapter({
    required this.chapterName,
    required this.createdBy,
    required this.createdOn,
    required this.assignedTo,
    required this.totalSegments,
    required this.completedSegments,
    required this.status,
  });
}
