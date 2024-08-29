// ignore_for_file: avoid_print

import 'dart:convert'; // for utf8 encoding
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // for API calls
import 'package:lc_frontend/models/chapter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lc_frontend/services/auth_service.dart';
import 'package:lc_frontend/widgets/custom_app_bar.dart';
import 'package:lc_frontend/widgets/navigation_bar.dart';
import '../widgets/chapter_list.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ProjectPage extends StatefulWidget {
  final int projectId;
  final VoidCallback onChapterAdded;

  const ProjectPage(
      {super.key, required this.projectId, required this.onChapterAdded});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<Chapter> chapters = [];
  List<Map<String, dynamic>> users = []; // To store users
  String? selectedUser; // To store the selected user ID
  PlatformFile? pickedFile; // To store the picked file
  List<String> selectedUsers = [];
  String errorMessage = '';
  String userRole = '';
  String userOrganization = '';

  @override
  void initState() {
    super.initState();
    fetchChapters();
    getUserRole(); // Fetch user role and organization first
  }

  Future<void> fetchChapters() async {
    final token = await getJwtToken();
    if (token == null) {
      print("Failed to obtain JWT token.");
      return;
    }

    final response = await http.get(
      Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/chapters/by_project/${widget.projectId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> chaptersJson = jsonDecode(response.body);
      setState(() {
        chapters = chaptersJson.map((json) => Chapter.fromJson(json)).toList();
      });

      for (var chapter in chapters) {
        print(
            'Chapter: ${chapter.chapterName}, AssignedTo: ${chapter.assignedTo}');
      }
    } else {
      print('Failed to load chapters: ${response.statusCode}');
    }
  }

  Future<void> fetchUsers() async {
    final token = await getJwtToken();
    if (token == null) {
      print("Failed to obtain JWT token.");
      return;
    }

    if (userOrganization.isEmpty) {
      print("User organization is not available.");
      return;
    }

    final response = await http.get(
      Uri.parse(
          'https://canvas.iiit.ac.in/lc/api/users/by_organization/$userOrganization'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      setState(() {
        users = usersJson.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load users: ${response.statusCode}');
    }
  }

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

  Future<void> addChapter(
      String name, PlatformFile file, List<String> userIds) async {
    final token = await getJwtToken();
    if (token == null) {
      print("Failed to obtain JWT token.");
      return;
    }

    try {
      String fileContent;
      if (file.bytes != null) {
        fileContent = utf8.decode(file.bytes!); // Decode bytes to utf8 string
      } else if (file.path != null) {
        fileContent = await io.File(file.path!).readAsString(encoding: utf8);
      } else {
        print("No file content available.");
        return;
      }

      final response = await http.post(
        Uri.parse('https://canvas.iiit.ac.in/lc/api/chapters/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'project_id': widget.projectId,
          'name': name,
          'text': fileContent,
          'user_ids': userIds, // Include user IDs
        }),
      );

      if (response.statusCode == 201) {
        // Chapter added successfully, fetch updated chapter list
        fetchChapters();
        final chapterData = jsonDecode(response.body);
        await assignUsersToProject(
            widget.projectId, userIds, chapterData['chapter_id']);
        widget.onChapterAdded();
      } else {
        print('Failed to add chapter: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding chapter: $e');
    }
  }

  Future<void> getUserRole() async {
    final authService = AuthService();
    final jwtToken = await authService.getToken();

    if (jwtToken == null) {
      setState(() {
        errorMessage = 'Failed to retrieve JWT token';
      });
      return;
    }

    try {
      print('JWT Token: $jwtToken'); // Verify JWT token

      // Decode JWT token to get the username
      Map<String, dynamic> decodedToken = Jwt.parseJwt(jwtToken);
      String username = decodedToken['username'];
      print('Username from JWT: $username'); // Print username from JWT

      final response = await http.get(
        Uri.parse('https://canvas.iiit.ac.in/lc/api/users/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> usersData = json.decode(response.body);
        final currentUser = usersData.firstWhere(
          (user) => user['username'] == username,
          orElse: () => null,
        );
        if (currentUser != null) {
          print(
              'User Role from API: ${currentUser['role']}'); // Print role received from API
          setState(() {
            userRole = currentUser['role']; // Update userRole state
            userOrganization =
                currentUser['organization']; // Update userOrganization state
          });
          print('User Role Set: $userRole'); // Print role set in state
          print(
              'User Organization Set: $userOrganization'); // Print organization set in state
          fetchUsers(); // Fetch users after setting the organization
        } else {
          setState(() {
            errorMessage = 'No user data found';
          });
          print(errorMessage);
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch user role: ${response.statusCode}';
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch user role: $e';
      });
      print(errorMessage);
    }
  }

  Future<void> assignUsersToProject(
      int projectId, List<String> userIds, int chapterId) async {
    final token = await getJwtToken();
    if (token == null) {
      print("Failed to obtain JWT token.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://canvas.iiit.ac.in/lc/api/projects/$projectId/assign_users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_ids': userIds,
          'chapter_id': chapterId,
        }),
      );

      if (response.statusCode == 200) {
        print('Users assigned to project and chapter successfully');
      } else {
        print(
            'Failed to assign users to project and chapter: ${response.statusCode}');
      }
    } catch (e) {
      print('Error assigning users to project and chapter: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: const CustomAppBar(),
      drawer: const NavigationMenu(),
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
                prefixIcon: const Icon(Icons.search),
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
          if (userRole == 'admin') const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Add Chapter',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: userRole == 'admin'
                ? () {
                    setState(() {
                      pickedFile = null;
                      selectedUsers = [];
                    });

                    // Show dialog to add a new chapter
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController nameController =
                            TextEditingController();
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('Add Chapter',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Chapter Name',
                                        hintText: 'Enter Chapter Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.upload_file),
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['txt'],
                                        );

                                        if (result != null) {
                                          setState(() {
                                            pickedFile = result.files.single;
                                          });
                                        }
                                      },
                                      label: const Text(
                                          'Select Chapter Text File'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (pickedFile != null)
                                      Text(
                                        'Selected file: ${pickedFile!.name}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    const SizedBox(height: 16),
                                    const Text('Select Users:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height:
                                          200, // Set a fixed height for the user list
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: users.map((user) {
                                            return CheckboxListTile(
                                              // title: Text(user['username']),
                                              title: Text(
                                                  '${user['username']} (${user['role']})'),
                                              value: selectedUsers.contains(
                                                  user['id'].toString()),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value != null) {
                                                    if (value) {
                                                      selectedUsers.add(
                                                          user['id']
                                                              .toString());
                                                    } else {
                                                      selectedUsers.remove(
                                                          user['id']
                                                              .toString());
                                                    }
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty &&
                                        pickedFile != null &&
                                        selectedUsers.isNotEmpty) {
                                      addChapter(nameController.text,
                                          pickedFile!, selectedUsers);
                                      Navigator.of(context).pop();
                                    } else {
                                      // Handle validation
                                      print(
                                          "Please fill all fields, select a file, and select at least one user.");
                                    }
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                : null, // Set onPressed to null if not admin
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              fixedSize: const Size(200, 55),
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
            child: ChapterListWidget(
              chapters: chapters,
            ),
          ),
        ],
      ),
    );
  }
}
