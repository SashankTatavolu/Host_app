import 'package:flutter/material.dart';

class StatisticsRow extends StatelessWidget {
  final String chapters;
  final String totalSegments;
  final String pendingSegments;

  const StatisticsRow({
    super.key,
    required this.chapters,
    required this.totalSegments,
    required this.pendingSegments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildStatColumn(chapters, "Chapters")),
        const VerticalDivider(width: 3, thickness: 3, color: Colors.blue),
        Expanded(child: _buildStatColumn(totalSegments, "Total Segments")),
        const VerticalDivider(width: 1),
        Expanded(child: _buildStatColumn(pendingSegments, "Pending Segments")),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.indigo, fontSize: 40)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.indigo)),
      ],
    );
  }
}
