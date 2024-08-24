// rover_details.dart
class RoverDetails {
  final String roverId;
  final String roverName;
  final String missionAssigned;
  final String roverStatus;
  final double speed;
  final bool temperatureStatus;
  final bool motorsStatus;
  final bool sprayersStatus;
  final int batteryPercentage;
  final int fuelPercentage;
  final int payloadPercentage;
  final int missionCompletionPercentage;
  bool isSelected;

  RoverDetails(
      {required this.roverId,
      required this.roverName,
      required this.missionAssigned,
      required this.roverStatus,
      this.speed = 0,
      this.isSelected = false,
      this.temperatureStatus = true,
      this.motorsStatus = true,
      this.batteryPercentage = 80,
      this.fuelPercentage = 30,
      this.payloadPercentage = 50,
      this.missionCompletionPercentage = 40,
      this.sprayersStatus = false});
}
