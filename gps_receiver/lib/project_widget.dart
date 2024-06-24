import 'package:flutter/material.dart';

class ProjectWidget extends StatelessWidget {
  final VoidCallback onClose;
  final Function(ProjectSetupData) onSetupComplete;

  const ProjectWidget({
    super.key,
    required this.onClose,
    required this.onSetupComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      // margin: EdgeInsets.only(
      //   top: MediaQuery.of(context).size.height * 0.05,
      //   right: MediaQuery.of(context).size.width * 0.05,
      // ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              Text(
                'No vehicles/mission setup.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ProjectSetupDialog(
                      onSetupComplete: onSetupComplete,
                    ),
                  );
                },
                child: const Text('Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectSetupDialog extends StatelessWidget {
  final Function(ProjectSetupData) onSetupComplete;

  const ProjectSetupDialog({super.key, required this.onSetupComplete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Project Setup'),
      content: const Text('Placeholder for project setup form.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // Simulate setup completion
            onSetupComplete(ProjectSetupData());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ProjectSetupData {
  // Add fields as needed for project setup data
}
