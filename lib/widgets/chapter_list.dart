import 'package:flutter/material.dart';

import '../models/chapter.dart';
import 'chapter_widget.dart';
import 'header_widget.dart';


class ChapterListWidget extends StatelessWidget {
  final List<Chapter> chapters;

  const ChapterListWidget({Key? key, required this.chapters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChapterTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return ChapterWidget(chapter: chapters[index], onTap: () {  },);
            },
          ),
        ),
      ],
    );
  }
}
