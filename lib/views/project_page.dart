import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lc_frontend/widgets/custom_app_bar.dart';

import '../models/chapter.dart';
import '../widgets/chapter_list.dart';

class ProjectPage extends StatefulWidget {
  final int projectId;

  const ProjectPage({super.key, required this.projectId});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final List<Chapter> chapters = [
    Chapter(
      chapterName: 'Chapter 1',
      createdBy: 'Michael',
      createdOn: '5 Days ago',
      assignedTo: ['Name 1', 'Name 2', 'Name 3', 'Name 4' ],
      totalSegments: 20,
      completedSegments: 20,
      status: 'Completed',
    ),
    Chapter(
      chapterName: 'Chapter 1',
      createdBy: 'Michael',
      createdOn: '5 Days ago',
      assignedTo: ['Name 1', 'Name 2'],
      totalSegments: 20,
      completedSegments: 20,
      status: 'Completed',
    ),
    Chapter(
      chapterName: 'Chapter 1',
      createdBy: 'Michael',
      createdOn: '5 Days ago',
      assignedTo: ['Name 1', 'Name 2'],
      totalSegments: 20,
      completedSegments: 20,
      status: 'Completed',
    ),
    // More chapters...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: CustomAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Chapters...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white,),
            label: Text('Add Chapter', style: TextStyle(color: Colors.white),),
            onPressed: () {
              // Define the action for the add chapter button
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              fixedSize: Size(200, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ChapterListWidget(chapters: chapters), // Use the new ChapterListWidget
          ),
        ],
      ),
    );
  }
}
