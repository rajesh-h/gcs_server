import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gps_receiver/services.dart'; // Import your services

class MissionSetup extends StatefulWidget {
  final String roverId;
  final VoidCallback onBackPressed;
  final VoidCallback onLoadProjectData;

  const MissionSetup(
      {Key? key,
      required this.roverId,
      required this.onBackPressed,
      required this.onLoadProjectData})
      : super(key: key);

  @override
  _MissionSetupState createState() => _MissionSetupState();
}

class _MissionSetupState extends State<MissionSetup> {
  List<dynamic> _missions = [];
  String? _selectedMissionId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    try {
      final response =
          await Services.getRequest('rovers/${widget.roverId}/missions');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _missions = List<String>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load missions: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load missions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMissionAssigned(String missionId) async {
    print('Update mission assigned: $missionId');
    try {
      final response = await Services.patchRequest(
        'rovers/available_rovers/${widget.roverId}',
        {'mission_assigned': missionId},
      );

      if (response.statusCode == 200) {
        setState(() {
          _selectedMissionId = missionId;
        });
        _showMissionAssignedDialog(missionId);
      } else {
        setState(() {
          _errorMessage = 'Failed to update mission: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update mission: $e';
      });
    }
  }

  void _showMissionAssignedDialog(String missionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mission Assigned'),
          content: Text(
              'Mission $missionId is assigned to rover ${widget.roverId}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                widget.onBackPressed(); //Call back button
                widget.onLoadProjectData();
                // Navigator.of(context).pop(); // Go back to the previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: _missions.length,
            itemBuilder: (context, index) {
              final mission = _missions[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMissionId = mission;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedMissionId == mission
                        ? Colors.blue
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedMissionId == mission
                          ? Colors.blue
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mission,
                      style: TextStyle(
                        color: _selectedMissionId == mission
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (_selectedMissionId != null) {
                _updateMissionAssigned(_selectedMissionId!);
              }
            },
            child: const Text('Assign Mission'),
          ),
        ),
      ],
    );
  }
}
