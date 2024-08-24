import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gps_receiver/active_rover_card.dart';
import 'package:gps_receiver/current_rover_details.dart';
import 'package:gps_receiver/mission_setup.dart';
import 'package:gps_receiver/models/rover_details.dart';
import 'package:gps_receiver/project_setup_dialog.dart';
import 'package:gps_receiver/services.dart';

typedef SelectionChangedCallback = void Function(
    RoverDetails rover, bool isSelected);

class ProjectWidget extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<ProjectSetupData> onSetupComplete;
  final SelectionChangedCallback onSelectionChanged;

  const ProjectWidget({
    super.key,
    required this.onClose,
    required this.onSetupComplete,
    required this.onSelectionChanged,
  });

  @override
  _ProjectWidgetState createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  RoverDetails? _selectedRover;
  String? currentProject;
  List<RoverDetails> _roverDetailsList = [];
  Map<String, bool> _selectionMap = {};

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    try {
      currentProject = await Services.getCurrentProject();
      if (currentProject != null) {
        final projectResponse =
            await Services.getRequest('/projects/name/$currentProject');
        if (projectResponse.statusCode == 200) {
          final projectData = jsonDecode(projectResponse.body);
          final List<dynamic> agvs = projectData['robots'];

          // Fetch rover details using AGV IDs
          final roverResponse = await Services.getRequest('/rovers');
          if (roverResponse.statusCode == 200) {
            final List<dynamic> rovers = jsonDecode(roverResponse.body);
            setState(() {
              _roverDetailsList = rovers
                  .where((rover) => agvs.contains(rover['rover_id']))
                  .map((rover) {
                return RoverDetails(
                  roverId: rover['rover_id'],
                  roverName: rover['rover_id'] ?? 'Unknown',
                  missionAssigned: rover['mission_assigned'] ?? 'N/A',
                  roverStatus: rover['status'] ?? 'Unknown',
                  speed:
                      double.tryParse(rover['speed']?.toString() ?? '0') ?? 0,
                );
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      print('Failed to load project data: $e');
    }
  }

  void _onSetupPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProjectSetupDialog(
        onSetupComplete: widget.onSetupComplete,
        onLoadProjectData: _loadProjectData,
      ),
    );
  }

  void _onRoverSelected(RoverDetails roverDetails) {
    setState(() {
      _selectedRover = roverDetails;
    });
    widget.onSelectionChanged(roverDetails, true);
  }

  void _onBackPressed() {
    widget.onSelectionChanged(_selectedRover!, false);
    setState(() {
      _selectedRover = null;
    });
  }

  void _handleSelectionChanged(RoverDetails rover, bool isSelected) {
    setState(() {
      _selectionMap[rover.roverId] = isSelected;
    });
    widget.onSelectionChanged(rover, isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SizedBox(
        height:
            deviceHeight * 0.7, // Set the height to 50% of the device height
        child: Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _selectedRover == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Project Details - $currentProject',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadProjectData,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      if (_roverDetailsList.isEmpty)
                        Center(
                          child: Text(
                            'No vehicles/mission setup.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _roverDetailsList.length,
                            itemBuilder: (context, index) {
                              final rover = _roverDetailsList[index];
                              final isSelected =
                                  _selectionMap[rover.roverId] ?? false;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => _onRoverSelected(rover),
                                  child: ActiveRoverCard(
                                    roverDetails: rover,
                                    isSelected: isSelected,
                                    onSelectionChanged: _handleSelectionChanged,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _onSetupPressed(context),
                          child: const Text('Setup'),
                        ),
                      ),
                    ],
                  )
                : _selectedRover?.missionAssigned == 'N/A'
                    ? Column(
                        children: [
                          Expanded(
                            child: MissionSetup(
                              roverId: _selectedRover!.roverId,
                              onBackPressed: _onBackPressed,
                              onLoadProjectData: _loadProjectData,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _onBackPressed,
                            child: const Text('Back'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: CurrentRoverDetails(
                                roverDetails: _selectedRover!),
                          ),
                          ElevatedButton(
                            onPressed: _onBackPressed,
                            child: const Text('Back'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
