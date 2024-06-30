import 'package:flutter/material.dart';
import 'package:gps_receiver/project_setup_dialog.dart';

class ProjectWidget extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<ProjectSetupData> onSetupComplete;

  const ProjectWidget(
      {super.key, required this.onClose, required this.onSetupComplete});

  void _onSetupPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProjectSetupDialog(
        onSetupComplete: onSetupComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                'No vehicles/mission setup.',
                style: Theme.of(context).textTheme.bodyLarge,
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
        ),
      ),
    );
  }
}
