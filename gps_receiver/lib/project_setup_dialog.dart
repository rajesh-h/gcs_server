import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gps_receiver/services.dart'; // Import your sample data

class ProjectSetupData {
  final List<Map<String, dynamic>> selectedAGVs;

  ProjectSetupData(this.selectedAGVs);
}

class ProjectSetupDialog extends StatefulWidget {
  final void Function(ProjectSetupData) onSetupComplete;
  final VoidCallback onLoadProjectData;

  const ProjectSetupDialog(
      {super.key,
      required this.onSetupComplete,
      required this.onLoadProjectData});

  @override
  _ProjectSetupDialogState createState() => _ProjectSetupDialogState();
}

class _ProjectSetupDialogState extends State<ProjectSetupDialog> {
  List<Map<String, dynamic>> _availableAGVs = [];
  String? _selectedProject;
  List<String> _availableProjects = []; // Initialize with an empty list
  List<String> _selectedProjectRobots = []; // Initialize with an empty list
  final List<Map<String, dynamic>> _selectedAGVs = []; // Track selected AGVs

  @override
  void initState() {
    super.initState();
    _getActiveProjects();
    // .then((_) {
    //   if (_selectedProject != null) {
    //     _fetchAndSetSelectedProjectAGVs();
    //   }
    // });
    _getActiveAGVs();
  }

  Future<void> _getActiveProjects() async {
    try {
      print('Fetching active projects...');
      final response = await Services.getRequest('/projects');

      if (response.statusCode == 200) {
        print('Projects Response: ${response.body}');
        List<dynamic> activeProjects = jsonDecode(response.body);

        // Ensure the data is in the correct format
        setState(() {
          _availableProjects = activeProjects
              .map((project) => project['project_name'] as String)
              .toList();
          print('Available Projects: $_availableProjects');
          _selectedProject =
              _availableProjects.isNotEmpty ? _availableProjects.first : null;
          _fetchAndSetSelectedProjectAGVs();
        });
      } else {
        // Handle error
        print('Failed to load Projects: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Failed to load Projects: $e');
    }
  }

  Future<List<String>> _selectedProjectAGVs(String selectedProject) async {
    final response =
        await Services.getRequest('/projects/name/$selectedProject');

    if (response.statusCode == 200) {
      print('Project AGVs Response: ${response.body}');
      Map<String, dynamic> activeProject = jsonDecode(response.body);

      var selectedProjectRobots = activeProject['robots'] as List<dynamic>;
      return selectedProjectRobots.map((robot) => robot.toString()).toList();
    } else {
      // Handle error
      print('Failed to load Project AGVs: ${response.statusCode}');
      return [];
    }
  }

  Future<void> _getActiveAGVs() async {
    try {
      print('Fetching active AGVs...');
      final response = await Services.getRequest('/rovers');

      if (response.statusCode == 200) {
        print('AGVs Response: ${response.body}');
        List<dynamic> data = jsonDecode(response.body);

        // Ensure the data is in the correct format
        setState(() {
          _availableAGVs = data.map<Map<String, dynamic>>((agv) {
            return agv as Map<String, dynamic>;
          }).toList();
          print('Available AGVs: $_availableAGVs');
        });
      } else {
        // Handle error
        print('Failed to load AGVs: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Failed to load AGVs: $e');
    }
  }

  void _toggleAGVSelection(Map<String, dynamic> agv) {
    setState(() {
      if (_selectedAGVs.contains(agv)) {
        _selectedAGVs.remove(agv);
      } else {
        _selectedAGVs.add(agv);
      }
    });
  }

  Future<void> _completeSetup() async {
    TextEditingController projectNameController = TextEditingController();

    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Project Name'),
          content: TextField(
            controller: projectNameController,
            decoration: const InputDecoration(hintText: 'Project Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String projectName = projectNameController.text;
                if (projectName.isNotEmpty) {
                  await _sendPostRequest(projectName, _selectedAGVs);
                  Navigator.of(context).pop(true);
                  widget.onLoadProjectData();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      widget.onSetupComplete(ProjectSetupData(_selectedAGVs));
      Navigator.of(context).pop(); // Close the dialog after setup completion
    }
  }

  Future<void> _sendPostRequest(
      String projectName, List<Map<String, dynamic>> agvs) async {
    try {
      final response = await Services.postRequest('/projects', {
        'project_name': projectName,
        'robots': agvs.map((agv) => agv['rover_id']).toList(),
      });

      if (response.statusCode == 201) {
        print('Project created successfully');
        await Services.setCurrentProject(projectName); // Set current project
      } else {
        print('Failed to create project: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create project: $e');
    }
  }

  Future<void> _fetchAndSetSelectedProjectAGVs() async {
    if (_selectedProject != null) {
      _selectedProjectRobots = await _selectedProjectAGVs(_selectedProject!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: DefaultTabController(
        length: 2,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Available AGVs'),
                    Tab(text: 'Active Projects'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAvailableAGVsTab(),
                    _buildActiveProjectsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableAGVsTab() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _getActiveAGVs();
          },
          child: const Text('Refresh AGVs'),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _getActiveAGVs();
            },
            child: ListView.builder(
              itemCount: (_availableAGVs.length / 2).ceil(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: index * 2 < _availableAGVs.length
                            ? _buildAGVTile(index * 2, _availableAGVs)
                            : const SizedBox(),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: index * 2 + 1 < _availableAGVs.length
                            ? _buildAGVTile(index * 2 + 1, _availableAGVs)
                            : const SizedBox(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedAGVs.isNotEmpty ? _completeSetup : null,
          child: const Text('Complete Setup'),
        ),
      ],
    );
  }

  Widget _buildAGVTileForProject(int index, List<String> robots) {
    var robot = robots[index];
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              robot,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )));
  }

  Widget _buildAGVTile(int index, List<Map<String, dynamic>> agvs) {
    var agv = agvs[index];
    print(agv);
    bool isSelected = _selectedAGVs.contains(agv);

    return GestureDetector(
      onTap: () => _toggleAGVSelection(agv),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : Colors.black, // Toggle color based on selection
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agv['rover_id'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Location: (${agv['lat']}, ${agv['lon']})',
              ),
              const Text('Mission: N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveProjectsTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select a project to view its AGVs',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        DropdownButton<String>(
          hint: const Text('Select a Project'),
          value: _selectedProject,
          onChanged: (String? newValue) async {
            setState(() {
              _selectedProject = newValue!;
            });
            _fetchAndSetSelectedProjectAGVs();
          },
          items:
              _availableProjects.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedProjectRobots.length,
            itemBuilder: (context, index) {
              return _buildAGVTileForProject(index, _selectedProjectRobots);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _selectProject(_selectedProject);
            Navigator.of(context).pop(true);
          },
          child: const Text('Select Project'),
        ),
      ],
    );
  }

  _selectProject(String? selectedProject) {
    if (selectedProject != null) {
      Services.setCurrentProject(selectedProject); // Set current project
    }
  }

  void main() {
    runApp(MaterialApp(
      home: ProjectSetupDialog(
        onSetupComplete: (data) {
          // Handle setup completion if needed
          print('Selected AGVs: ${data.selectedAGVs}');
        },
        onLoadProjectData: widget.onLoadProjectData,
      ),
    ));
  }
}
