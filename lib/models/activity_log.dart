class ActivityLog {
  int? id;
  String activityType;
  int durationInSeconds;
  DateTime endTime;

  ActivityLog({
    this.id,
    required this.activityType,
    required this.durationInSeconds,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'durationInSeconds': durationInSeconds,
      'endTime': endTime.toIso8601String(),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'],
      activityType: map['activityType'],
      durationInSeconds: map['durationInSeconds'],
      endTime: DateTime.parse(map['endTime']),
    );
  }
}