import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProjectSetupData {
  final LatLng markerPosition;

  ProjectSetupData({required this.markerPosition});
}

class ProjectSetupDialog extends StatelessWidget {
  final ValueChanged<ProjectSetupData> onSetupComplete;

  const ProjectSetupDialog({super.key, required this.onSetupComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Project Setup',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Setup your project here',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Simulate setup completion with dummy data
              ProjectSetupData setupData = ProjectSetupData(
                markerPosition:
                    const LatLng(34.052235, -118.243683), // Dummy coordinates
              );
              onSetupComplete(setupData);
            },
            child: const Text('Complete Setup'),
          ),
        ],
      ),
    );
  }
}
