import 'dart:ffi';

class RoverDetails {
  String roverId;
  String lon;
  String lat;
  String status;
  String missionAssigned;
  SensorData sensorData;
  RosData rosData;
  Mission mission;
  MissionProgress missionProgress;
  CompletedPath completedPath;

  RoverDetails(
      {required this.roverId,
      this.lon = '0',
      this.lat = '0',
      this.status = 'Online',
      this.missionAssigned = 'N/A',
      required this.mission,
      required this.sensorData,
      required this.rosData,
      required this.missionProgress,
      required this.completedPath});

  factory RoverDetails.fromJson(Map<String, dynamic> json) {
    return RoverDetails(
      roverId: json['rover_id'],
      lon: json['lon'],
      lat: json['lat'],
      status: json['status'],
      mission: json['mission'],
      missionAssigned: json['mission_assigned'],
      sensorData: SensorData.fromJson(json['sensor_data']),
      rosData: RosData.fromJson(json['ros_data']),
      missionProgress: MissionProgress.fromJson(json['mission_progress']),
      completedPath: CompletedPath.fromJson(json['completed_path']),
    );
  }
}

class SensorData {
  String timestamp;
  String roverId;
  int battery;
  int fuel;
  int payload;
  int flowRateLeftSprayer;
  int flowRateRightSprayer;
  int hydraulicSys;
  int engineTemp;
  String id;

  SensorData(
      {this.timestamp = "00:00:00",
      this.roverId = "rover_id",
      this.battery = 0,
      this.fuel = 0,
      this.payload = 0,
      this.flowRateLeftSprayer = 0,
      this.flowRateRightSprayer = 0,
      this.hydraulicSys = 0,
      this.engineTemp = 0,
      this.id = "0"});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: json['timestamp'],
      roverId: json['rover_id'],
      battery: json['battery'].toInt(),
      fuel: json['fuel'].toInt(),
      payload: json['payload'].toInt(),
      flowRateLeftSprayer: json['flow_rate_left_sprayer'].toInt(),
      flowRateRightSprayer: json['flow_rate_right_sprayer'].toInt(),
      hydraulicSys: json['hydraulic_sys'].toInt(),
      engineTemp: json['engine_temp'].toInt(),
      id: json['_id'],
    );
  }
}

class RosData {
  String timestamp;
  String roverId;
  String rosError;
  String rtkLeft;
  String rtkRight;
  String rtkDualValid;
  String speed;
  int yaw;
  int attitude;
  int satelitesVisible;
  String id;

  RosData(
      {this.timestamp = "00:00:00",
      this.roverId = "rover_id",
      this.rosError = "ros_error",
      this.rtkLeft = "rtk_left",
      this.rtkRight = "rtk_right",
      this.rtkDualValid = "rtk_dual_valid",
      this.speed = "0",
      this.yaw = 0,
      this.attitude = 0,
      this.satelitesVisible = 0,
      this.id = "0"});

  factory RosData.fromJson(Map<String, dynamic> json) {
    return RosData(
      timestamp: json['timestamp'],
      roverId: json['rover_id'],
      rosError: json['ros_error'],
      rtkLeft: json['rtk_left'],
      rtkRight: json['rtk_right'],
      rtkDualValid: json['rtk_dual_valid'],
      speed: json['speed'],
      yaw: json['yaw'].toInt(),
      attitude: json['attitude'].toInt(),
      satelitesVisible: json['satelites_visible'].toInt(),
      id: json['_id'],
    );
  }
}

class Mission {
  String missionId;
  String status;
  String scheduledDate;
  String startTime;
  String endTime;
  String sprayerMode;
  String operator;
  List<dynamic> trees;
  double rowsHeading;
  List<dynamic> startingPoint;
  List<dynamic> geofence;
  List<dynamic> path;
  String roverId;

  Mission({
    this.missionId = "mission_id",
    this.status = "status",
    this.scheduledDate = "1900-01-01",
    this.startTime = "1900-01-01T00:00:00Z",
    this.endTime = "1900-01-01T00:00:00Z",
    this.sprayerMode = "AUTO",
    this.operator = "Fakri",
    this.trees = const [
      [0, 0],
      [0, 0]
    ],
    this.rowsHeading = 0.0,
    this.startingPoint = const [0.0, 0.0],
    this.geofence = const [
      [0.0, 0.0],
      [0.0, 0.0]
    ],
    this.path = const [
      [0.0, 0.0],
      [0.0, 0.0]
    ],
    this.roverId = "rover_id",
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      missionId: json['mission_id'],
      status: json['status'],
      scheduledDate: json['scheduled_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      sprayerMode: json['sprayer_mode'],
      operator: json['operator'],
      trees: json['trees'].map((e) => e.cast<double>()).toList(),
      rowsHeading: json['rows_heading'],
      startingPoint: List<double>.from(json['starting_point']),
      geofence: json['geofence'].map((e) => e.cast<double>()).toList(),
      path: json['path'].map((e) => e.cast<double>()).toList(),
      roverId: json['rover_id'],
    );
  }
}

class MissionProgress {
  String timestamp;
  String roverId;
  int taskCompletion;
  int homePtDistance;
  int totalTrees;
  int totalTreesSprayed;
  int totalHectaresSprayed;
  int timeStarted;
  String id;

  MissionProgress({
    this.timestamp = "00:00:00",
    this.roverId = "rover_id",
    this.taskCompletion = 0,
    this.homePtDistance = 0,
    this.totalTrees = 0,
    this.totalTreesSprayed = 0,
    this.totalHectaresSprayed = 0,
    this.timeStarted = 0,
    this.id = "0",
  });

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      timestamp: json['timestamp'],
      roverId: json['rover_id'],
      taskCompletion: json['task_completion'].toInt(),
      homePtDistance: json['home_pt_distance'].toInt(),
      totalTrees: json['total_trees'].toInt(),
      totalTreesSprayed: json['total_trees_sprayed'].toInt(),
      totalHectaresSprayed: json['total_hectares_sprayed'].toInt(),
      timeStarted: json['time_started'].toInt(),
      id: json['_id'],
    );
  }
}

class CompletedPath {
  List<dynamic> completedPath;
  String roverId;

  CompletedPath({
    required this.completedPath,
    required this.roverId,
  });

  factory CompletedPath.fromJson(Map<String, dynamic> json) {
    return CompletedPath(
      completedPath: json['completed_path']
          .map((path) => path.map((point) => point.toDouble()).toList())
          .toList(),
      roverId: json['rover_id'],
    );
  }
}
