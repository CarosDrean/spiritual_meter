class ActivityLog {
  int? id; // ID autoincremental de la base de datos
  String activityType; // "prayer" o "bibleReading"
  int durationInSeconds; // Duración de la actividad en segundos
  DateTime endTime; // Fecha y hora en que terminó la actividad

  ActivityLog({
    this.id,
    required this.activityType,
    required this.durationInSeconds,
    required this.endTime,
  });

  // Convierte un objeto ActivityLog a un Map (para insertar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'durationInSeconds': durationInSeconds,
      'endTime': endTime.toIso8601String(), // Guardar como String ISO 8601
    };
  }

  // Crea un objeto ActivityLog desde un Map (para leer de la base de datos)
  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'],
      activityType: map['activityType'],
      durationInSeconds: map['durationInSeconds'],
      endTime: DateTime.parse(map['endTime']),
    );
  }
}