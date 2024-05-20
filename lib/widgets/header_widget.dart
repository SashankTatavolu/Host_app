import 'package:flutter/material.dart';

class ChapterTableHeader extends StatelessWidget {
  const ChapterTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.indigo.shade200, // Background color for the header

      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Expanded(
            flex: 2,
            child: Text('Chapter Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text('Created By', style: TextStyle(fontWeight: FontWeight.bold)),
            flex: 1,
          ),
          Expanded(
            child: Text('Created On', style: TextStyle(fontWeight: FontWeight.bold)),
            flex: 1,
          ),
          Expanded(
            child: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold)),
            flex: 1,
          ),
          Expanded(
            child: Text('Segments', style: TextStyle(fontWeight: FontWeight.bold)),
            flex: 2,
          ),
          Expanded(
            child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            flex: 1,
          ),
        ],
      ),
    );
  }
}
