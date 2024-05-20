import 'package:flutter/material.dart';

class ProjectInfoCardSection extends StatelessWidget {
  final String projectName;
  final String timeAgo;

  const ProjectInfoCardSection({
    Key? key,
    required this.projectName,
    required this.timeAgo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 70,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProjectDetails(),
          _buildMoreIcon(),
        ],
      ),
    );
  }

  Widget _buildProjectDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projectName,
          style: const TextStyle(color: Colors.indigo, fontSize: 20),
        ),
        Row(
          children: [
            const Icon(Icons.timelapse, color: Colors.indigo, size: 16),
            Text(
              timeAgo,
              style: const TextStyle(color: Colors.indigo, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreIcon() {
    return IconButton(
      onPressed: () {
        // Define the action for the more icon button
      },
      icon: const Icon(Icons.more_vert, color: Colors.indigo),
    );
  }
}
