import 'dart:math';

import 'package:flutter/material.dart';

import '../models/chapter.dart';

class ChapterWidget extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap; // Callback for tap action

  const ChapterWidget({Key? key, required this.chapter, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextColumn(chapter.chapterName, flex: 2),
            _buildTextColumn(chapter.createdBy, textAlign: TextAlign.center, flex: 1),
            _buildTextColumn(chapter.createdOn, textAlign: TextAlign.center, flex: 1),
            _buildAssignedTo(chapter, flex: 1),
            _buildProgress(chapter, flex: 2),
            _buildTextColumn(chapter.status, textAlign: TextAlign.center, flex: 1),
            Expanded(
              flex: 1, child: IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_rounded)),

            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextColumn(String text, {TextAlign textAlign = TextAlign.start, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAssignedTo(Chapter chapter, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildAvatarList(chapter.assignedTo),
      ),
    );
  }

  List<Widget> _buildAvatarList(List<String> assignedTo) {
    int numberOfAvatars = assignedTo.length;
    List<Widget> avatars = [];
    int displayLimit = 3;

    // Generate avatars for the first three users or less
    for (int i = 0; i < min(displayLimit, numberOfAvatars); i++) {
      avatars.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.indigo,
          child: Text(
            _getInitials(assignedTo[i]),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ));
    }

    // If there are more than three users, add a "+" avatar with the count of additional users
    if (numberOfAvatars > displayLimit) {
      avatars.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.red,
          child: Text(
            '+${numberOfAvatars - displayLimit}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ));
    }

    return avatars;
  }

  Widget _buildProgress(Chapter chapter, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: chapter.completedSegments / chapter.totalSegments,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text("${chapter.completedSegments} of ${chapter.totalSegments} Segments"),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    return names.length > 1 ? names[0][0] + names[1][0] : names[0][0];
  }
}
