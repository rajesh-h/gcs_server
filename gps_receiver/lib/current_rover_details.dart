import 'package:flutter/material.dart';
import 'package:gps_receiver/models/rover_details.dart';

class CurrentRoverDetails extends StatelessWidget {
  final RoverDetails roverDetails;

  const CurrentRoverDetails({Key? key, required this.roverDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildFirstSection(),
                      _buildSecondSection(),
                      _buildThirdSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 1,
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstSection() {
    return Expanded(
        flex: 2,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.agriculture, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 8.0),
              Text(
                roverDetails.roverId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            roverDetails.status,
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Icon(
            Icons.wifi,
            color: _getStatusColor(),
            size: 30,
          )
        ]));
  }

  Widget _buildSecondSection() {
    return Expanded(
      flex: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircularIndicator(roverDetails.missionProgress.taskCompletion),
          _buildVerticalIndicator('Battery', roverDetails.sensorData.battery),
          _buildVerticalIndicator('Fuel', roverDetails.sensorData.fuel),
          _buildVerticalIndicator('Payload', roverDetails.sensorData.payload),
        ],
      ),
    );
  }

  Widget _buildThirdSection() {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusIcon('Temperature', Icons.thermostat, true),
          _buildStatusIcon('Motors', Icons.settings, false),
          _buildStatusIcon('Sprayers', Icons.sanitizer, true),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(int percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildVerticalIndicator(String label, int percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$percentage%',
          style: TextStyle(color: Colors.red, fontSize: 16.0),
        ),
        const SizedBox(height: 4.0),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 10,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Container(
              width: 10,
              height: 60 * (percentage / 100),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String label, IconData icon, bool status) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: status ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.lightbulb, 'Light'),
        _buildActionButton(Icons.volume_up, 'Horn'),
        _buildActionButton(Icons.sensors, 'Object'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (roverDetails.status == 'OFFLINE') {
      return Colors.grey;
    } else if (roverDetails.status == 'ALERT') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }
}
