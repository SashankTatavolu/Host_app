import 'package:flutter/material.dart';
import 'package:lc_frontend/views/USR_creation/USR_chapter_contents.dart';

import '/models/chapter.dart';
import 'package:lc_frontend/widgets/chapter_widget.dart';
import 'package:lc_frontend/widgets/header_widget.dart';

class USRChapterListWidget extends StatelessWidget {
  final List<Chapter> chapters;

  const USRChapterListWidget({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    for (var chapter in chapters) {
      print('Chapter ID: ${chapter.chapterId}');
    }

    return Column(
      children: [
        const ChapterTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return ChapterWidget(
                chapter: chapters[index],
                onTap: () {
                  print(
                      'Navigating to chapter ID: ${chapters[index].chapterId}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => USRChapterContentsPage(
                        chapterId: chapters[index].chapterId, // Pass chapter id
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
