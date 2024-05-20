import 'package:flutter/material.dart';
import 'package:lc_frontend/views/multiword_tab.dart';
import 'package:lc_frontend/views/segment_tab.dart';
import 'package:lc_frontend/views/usr_tab.dart';
import 'package:lc_frontend/widgets/custom_app_bar.dart';

import '../models/segment.dart';
import 'chapter_tab.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({Key? key}) : super(key: key);

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Material(
              color: Colors.indigo.shade300,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.indigo,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 18.0),
                tabs: [
                  Tab(text: 'Chapter'),
                  Tab(text: 'Segment'),
                  Tab(text: 'Multiword Expression'),
                  Tab(text: 'USR'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ChapterTab(),
                  SegmentTab(),
                  Container(),
                  USRPage(segments:[
                    Segment(mainSegment: 1, subSegments: [
                      SubSegment(text: "Segment 1a", subIndex: "1a", indexType: 'Normal'),
                      SubSegment(text: "Segment 1b", subIndex: "1b", indexType:  'Normal'),
                    ], text: 'The text is for segment 1'),
                    Segment(mainSegment: 2, subSegments: [
                      SubSegment(text: "Segment 2a", subIndex: "2a", indexType:  'Normal'),
                    ], text: 'The text is for segment 2'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Below are the definitions for each tab's content as previously described.
