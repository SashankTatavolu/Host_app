import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lc_frontend/services/auth_service.dart';
import 'package:lc_frontend/views/file_download/USR_download_mobile.dart';
import 'package:http/http.dart' as http;
import '../models/chapter.dart';
import '../views/file_download/USR_download_web.dart';

class ChapterWidget extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap; // Callback for tap action

  const ChapterWidget({super.key, required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextColumn(chapter.chapterName, flex: 2),
            _buildTextColumn(chapter.createdBy,
                textAlign: TextAlign.center, flex: 1),
            _buildTextColumn(chapter.createdOn,
                textAlign: TextAlign.center, flex: 1),
            _buildAssignedTo(chapter, flex: 1),
            _buildProgress(chapter, flex: 2),
            _buildTextColumn(chapter.status,
                textAlign: TextAlign.center, flex: 1),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  // Show the dialog when the 'more' button is pressed
                  _showMoreOptionsDialog(context, chapter.chapterId);
                },
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsDialog(BuildContext context, int chapterId) {
    // Save the parent context to use later
    final parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("More Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  // Action for Download USRs (Future implementation)
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Download USRs coming soon!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Download USRs"),
              ),
              const SizedBox(height: 10), // Spacing between buttons
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Close the dialog

                  // Call the download method
                  await _downloadText(parentContext, chapterId);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Download Text"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _downloadText(BuildContext context, int chapterId) async {
  //   // Fetch the JWT token
  //   final token = await getJwtToken();

  //   if (token == null) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Error: Could not fetch JWT token.")),
  //       );
  //     }
  //     return;
  //   }

  //   // Prepare the API URL
  //   final url =
  //       Uri.parse('https://canvas.iiit.ac.in/lc/api/generate/process_bulk');

  //   try {
  //     // Send the POST request with the JWT token
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'chapter_id': chapterId,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       // Handle the successful response
  //       const fileName = 'Generated text.txt';

  //       // Use the response body directly
  //       final responseBody = response.body;

  //       // Create a StringBuffer to collect the segments
  //       final StringBuffer generatedText = StringBuffer();

  //       // Split the response into lines
  //       final lines = responseBody.split('\n');
  //       for (var line in lines) {
  //         if (line.trim().isNotEmpty) {
  //           generatedText.writeln(line.trim());
  //         }
  //       }

  //       // Check the content before saving
  //       if (generatedText.isNotEmpty) {
  //         if (kIsWeb) {
  //           downloadFileWeb(fileName, generatedText.toString());
  //         } else {
  //           await downloadFileIO(
  //               fileName, utf8.encode(generatedText.toString()));
  //         }

  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text("Download successful!")),
  //           );
  //         }
  //       } else {
  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text("Warning: No content to save.")),
  //           );
  //         }
  //       }
  //     } else {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Error: Failed to download text.")),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: $e")),
  //       );
  //     }
  //   }
  // }

  Future<void> _downloadText(BuildContext context, int chapterId) async {
    // Fetch the JWT token
    final token = await getJwtToken();

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Could not fetch JWT token.")),
        );
      }
      return;
    }

    // Prepare the API URL
    final url =
        Uri.parse('https://canvas.iiit.ac.in/lc/api/generate/process_bulk');

    try {
      // Send the POST request with the JWT token
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chapter_id': chapterId,
        }),
      );

      if (response.statusCode == 200) {
        const fileName = 'Generated text.txt';
        final responseBody = response.body;

        // Check if response body is not null or empty
        if (responseBody.isNotEmpty) {
          final StringBuffer generatedText = StringBuffer();
          final lines = responseBody.split('\n');

          for (var line in lines) {
            if (line.trim().isNotEmpty) {
              generatedText.writeln(line.trim());
            }
          }

          if (generatedText.isNotEmpty) {
            if (kIsWeb) {
              downloadFileWeb(fileName, generatedText.toString());
            } else {
              await downloadFileIO(
                  fileName, utf8.encode(generatedText.toString()));
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Download successful!")),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Warning: No content to save.")),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Response body is empty.")),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Failed to download text.")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Widget _buildTextColumn(String text,
      {TextAlign textAlign = TextAlign.start, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAssignedTo(Chapter chapter, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildAvatarList(chapter.assignedTo),
      ),
    );
  }

  List<Widget> _buildAvatarList(List<String> assignedTo) {
    int numberOfAvatars = assignedTo.length;
    List<Widget> avatars = [];
    int displayLimit = 3;

    for (int i = 0; i < min(displayLimit, numberOfAvatars); i++) {
      avatars.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.indigo,
          child: Text(
            _getInitials(assignedTo[i]),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ));
    }

    if (numberOfAvatars > displayLimit) {
      avatars.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.red,
          child: Text(
            '+${numberOfAvatars - displayLimit}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ));
    }

    return avatars;
  }

  Widget _buildProgress(Chapter chapter, {int flex = 2}) {
    double progress = chapter.totalSegments > 0
        ? chapter.completedSegments / chapter.totalSegments
        : 0.0;

    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                "${chapter.completedSegments} of ${chapter.totalSegments} Segments"),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    return names.length > 1 ? '${names[0][0]}${names[1][0]}' : names[0][0];
  }
}

// Your function to fetch the JWT token
Future<String?> getJwtToken() async {
  try {
    final authService =
        AuthService(); // Adjust based on your AuthService implementation
    final token = await authService.getToken();

    if (token == null) {
      print("Failed to obtain JWT token.");
      return null;
    }
    print('JWT Token: $token');
    return token;
  } catch (e) {
    print('Error fetching JWT token: $e');
    return null;
  }
}
