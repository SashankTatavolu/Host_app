// ignore_for_file: avoid_print

class Chapter {
  final int chapterId;
  final String chapterName;
  final String createdBy;
  final String createdOn;
  final List<String> assignedTo;
  final int totalSegments;
  final int completedSegments;
  final String status;

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.createdBy,
    required this.createdOn,
    required this.assignedTo,
    required this.totalSegments,
    required this.completedSegments,
    required this.status,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    // Handle null or missing values gracefully
    print('JSON received: $json');

    var assignedToList = json['assigned_to'];
    List<String> assignedTo = [];

    if (assignedToList != null) {
      assignedTo = assignedToList is List
          ? List<String>.from(assignedToList)
          : [assignedToList.toString()]; // Convert to string if not list
    }

    print('Creating Chapter with chapterId: ${json['id']}');

    return Chapter(
      chapterId: json['id'] ?? 0, // Provide default values if needed
      chapterName: json['name'] ?? '',
      createdBy: json['uploaded_by'] ?? '',
      createdOn: json['created_at'] ?? '',
      assignedTo: assignedTo,
      totalSegments: json['totalSegments'] ?? 0,
      completedSegments: json['completedSegments'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': chapterId,
      'chapterName': chapterName,
      'createdBy': createdBy,
      'createdOn': createdOn,
      'assignedTo': assignedTo,
      'totalSegments': totalSegments,
      'completedSegments': completedSegments,
      'status': status,
    };
  }
}
