import 'package:flutter/material.dart';
import 'language_tag.dart';
import 'statistics_row.dart';

class StatsSection extends StatelessWidget {
  final String language;
  final String chapters;
  final String totalSegments;
  final String pendingSegments;

  const StatsSection({
    super.key,
    required this.language,
    required this.chapters,
    required this.totalSegments,
    required this.pendingSegments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      height: 200,
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LanguageTag(language: language),
          StatisticsRow(chapters: chapters, totalSegments: totalSegments, pendingSegments: pendingSegments),
        ],
      ),
    );
  }
}
