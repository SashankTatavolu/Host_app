// import 'package:flutter/material.dart';
// import 'package:lc_frontend/views/chapter_page.dart';

// import '../models/chapter.dart';
// import 'chapter_widget.dart';
// import 'header_widget.dart';

// class ChapterListWidget extends StatelessWidget {
//   final List<Chapter> chapters;

//   const ChapterListWidget({super.key, required this.chapters});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const ChapterTableHeader(),
//         Expanded(
//           child: ListView.builder(
//             itemCount: chapters.length,
//             itemBuilder: (context, index) {
//               return ChapterWidget(
//                 chapter: chapters[index],
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const ChapterPage()),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lc_frontend/views/chapter_page.dart';

import '../models/chapter.dart';
import 'chapter_widget.dart';
import 'header_widget.dart';

class ChapterListWidget extends StatelessWidget {
  final List<Chapter> chapters;

  const ChapterListWidget({super.key, required this.chapters});

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
                      builder: (context) => ChapterPage(
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
