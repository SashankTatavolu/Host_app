import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

void downloadFileWeb(String fileName, String textData) {
  // Convert the string into a list of bytes (UTF-8 encoded)
  List<int> bytes = utf8.encode(textData);

  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  html.Url.revokeObjectUrl(url); // Clean up the object URL
}
