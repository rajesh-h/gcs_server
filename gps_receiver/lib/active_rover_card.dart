import 'package:flutter/material.dart';
import 'package:gps_receiver/models/rover_details.dart';

typedef SelectionChangedCallback = void Function(
    RoverDetails rover, bool isSelected);

class ActiveRoverCard extends StatelessWidget {
  final RoverDetails roverDetails;
  final bool isSelected;
  final SelectionChangedCallback onSelectionChanged;

  ActiveRoverCard({
    required this.roverDetails,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: roverDetails.missionAssigned != 'N/A'
                ? (value) {
                    if (value != null) {
                      onSelectionChanged(roverDetails, value);
                    }
                  }
                : null,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16.0),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        roverDetails.roverName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Text(
                        roverDetails.missionAssigned,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      Text(
                        roverDetails.roverStatus,
                        style: TextStyle(
                          color: roverDetails.roverStatus == 'ONLINE'
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${roverDetails.speed} km/h',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.stop, color: Colors.red, size: 32),
                Text(
                  'STOP',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
