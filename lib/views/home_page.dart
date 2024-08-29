// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lc_frontend/widgets/navigation_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/project_info_card_section.dart';
import '../widgets/stats_section.dart';
import 'project_page.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:jwt_decode/jwt_decode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;
  String errorMessage = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    fetchProjects();
    getUserRole(); // Fetch user role when HomePage initializes
  }

  Future<void> fetchProjects() async {
    const url = 'https://canvas.iiit.ac.in/lc/api/projects/all';
    final authService = AuthService();
    final jwtToken = await authService.getToken();

    if (jwtToken == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to retrieve JWT token';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> projectsData = json.decode(response.body);
        setState(() {
          projects = projectsData
              .map((project) => project as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load projects: ${response.statusCode}';
          isLoading = false;
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load projects: $e';
        isLoading = false;
      });
      print(errorMessage);
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
          });
          print('User Role Set: $userRole'); // Print role set in state
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

  Future<void> addProject(
      String projectName, String description, String language) async {
    const url = 'https://canvas.iiit.ac.in/lc/api/projects/add';
    final authService = AuthService();
    final jwtToken = await authService.getToken();

    if (jwtToken == null) {
      setState(() {
        errorMessage = 'Failed to retrieve JWT token';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'name': projectName,
          'description': description,
          'language': language,
        }),
      );

      if (response.statusCode == 201) {
        await fetchProjects();
      } else {
        setState(() {
          errorMessage = 'Failed to add project: ${response.statusCode}';
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to add project: $e';
      });
      print(errorMessage);
    }
  }

  void _handleChapterAdded() {
    fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: const CustomAppBar(),
      drawer: const NavigationMenu(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildBody(),
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
          if (userRole == 'admin') const SizedBox(width: 50),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Add Project',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: userRole == 'admin'
                ? () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController nameController =
                            TextEditingController();
                        TextEditingController descriptionController =
                            TextEditingController();
                        TextEditingController languageController =
                            TextEditingController();
                        return AlertDialog(
                          title: const Text('Add Project',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Project Name',
                                    hintText: 'Enter project name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'Enter project description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: languageController,
                                  decoration: InputDecoration(
                                    labelText: 'Language',
                                    hintText: 'Enter project language',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String projectName = nameController.text.trim();
                                String description =
                                    descriptionController.text.trim();
                                String language =
                                    languageController.text.trim();
                                if (projectName.isNotEmpty &&
                                    description.isNotEmpty &&
                                    language.isNotEmpty) {
                                  addProject(
                                      projectName, description, language);
                                }
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Add',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 30, // horizontal space between cards
                runSpacing: 20, // vertical space between rows
                children: List.generate(
                    projects.length, (index) => _buildProjectCard(index)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(int index) {
    if (index < projects.length) {
      Map<String, dynamic> project = projects[index];
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProjectPage(
                      projectId: project['id'],
                      onChapterAdded: _handleChapterAdded,
                    )),
          );
        },
        child: Column(
          children: [
            StatsSection(
              language: project['language'],
              chapters: project['total_chapters'].toString(),
              totalSegments: project['total_segments'].toString(),
              pendingSegments: project['pending_segments'].toString(),
            ),
            ProjectInfoCardSection(
              projectName: project['name'],
              timeAgo: project['created_at'],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
