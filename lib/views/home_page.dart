import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/project_info_card_section.dart';
import '../widgets/stats_section.dart';
import 'project_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                hintText: 'Search projects...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 50),
          ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white,),
            label: Text('Add Project', style: TextStyle(color: Colors.white),),
            onPressed: () {
              // Define the action for the add project button
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              fixedSize: Size(200,55),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 30, // horizontal space between cards
                runSpacing: 20, // vertical space between rows
                children: List.generate(6, (index) => _buildProjectCard(index)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(int index) {
    return InkWell(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProjectPage(projectId: index)),
      );
    },
    child: Column(
    children: [
    StatsSection(
      language: "Hindi",
      chapters: "5",
      totalSegments: "54",
      pendingSegments: "5",
    ),
      ProjectInfoCardSection(
        projectName: "Project $index",
        timeAgo: "1 Day Ago",
      ),
      const SizedBox(height: 20),
    ],
    ),
    );
  }
}

