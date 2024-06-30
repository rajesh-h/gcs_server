import 'package:flutter/material.dart';
import 'package:gps_receiver/sample_data.dart'; // Import your sample data

class ProjectSetupData {
  // This class can be used to pass data back when the setup is complete
  final List<Map<String, dynamic>> selectedAGVs;

  ProjectSetupData(this.selectedAGVs);
}

class ProjectSetupDialog extends StatefulWidget {
  final void Function(ProjectSetupData) onSetupComplete;

  const ProjectSetupDialog({super.key, required this.onSetupComplete});

  @override
  _ProjectSetupDialogState createState() => _ProjectSetupDialogState();
}

class _ProjectSetupDialogState extends State<ProjectSetupDialog> {
  late List<Map<String, dynamic>> _availableAGVs = [];
  String? _selectedProject;
  late List<String> _availableProjects;
  final List<Map<String, dynamic>> _selectedAGVs = []; // Track selected AGVs

  @override
  void initState() {
    super.initState();
    _availableProjects =
        activeProjects.map((project) => project['name'] as String).toList();
    _selectedProject =
        _availableProjects.isNotEmpty ? _availableProjects.first : null;
    _getActiveAGVs();
  }

  void _getActiveAGVs() {
    // Simulating fetching of AGVs (replace with actual HTTP call in real app)
    setState(() {
      _availableAGVs =
          availableAGVs.map((agv) => agv as Map<String, dynamic>).toList();
    });
  }

  List<Map<String, dynamic>> get _selectedProjectAGVs {
    if (_selectedProject == null) {
      return [];
    }
    var project = activeProjects.firstWhere(
      (project) => project['name'] == _selectedProject,
      orElse: () => {'agvs': []},
    );
    var agvs = project['agvs'] as List<dynamic>;
    return agvs
        .map<Map<String, dynamic>>((agv) => agv as Map<String, dynamic>)
        .toList();
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
              ElevatedButton(
                onPressed: _selectedAGVs.isNotEmpty ? _completeSetup : null,
                child: const Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeSetup() {
    widget.onSetupComplete(ProjectSetupData(_selectedAGVs));
    Navigator.of(context).pop(); // Close the dialog after setup completion
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
      ],
    );
  }

  Widget _buildAGVTile(int index, List<Map<String, dynamic>> agvs) {
    var agv = agvs[index];
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
                agv['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Location: (${agv['current_location']['latitude']}, ${agv['current_location']['longitude']})',
              ),
              Text(
                'Mission: ${agv['mission_assigned']}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveProjectsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Active Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButton<String>(
            value: _selectedProject,
            hint: const Text('Select Project'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedProject = newValue;
                _selectedAGVs
                    .clear(); // Clear selected AGVs when project changes
              });
            },
            items: _availableProjects
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _selectedProject != null
              ? ListView.builder(
                  itemCount: (_selectedProjectAGVs.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: index * 2 < _selectedProjectAGVs.length
                                ? _buildAGVTile(index * 2, _selectedProjectAGVs)
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: index * 2 + 1 < _selectedProjectAGVs.length
                                ? _buildAGVTile(
                                    index * 2 + 1, _selectedProjectAGVs)
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('Select a project to view its AGVs.'),
                ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProjectSetupDialog(
      onSetupComplete: (data) {
        // Handle setup completion if needed
        print('Selected AGVs: ${data.selectedAGVs}');
      },
    ),
  ));
}
