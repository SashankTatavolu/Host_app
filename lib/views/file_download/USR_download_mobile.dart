import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFileIO(String fileName, List<int> bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(bytes);
  print('File saved at: $filePath');
  // OpenFile.open(filePath); // Not applicable in web
}
