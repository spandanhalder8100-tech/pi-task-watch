/// Represents idle time data for tracking user inactivity periods
class IdleTimeData {
  /// Whether to keep the idle time or deduct it
  final bool keepTime;

  /// Duration of idle time in seconds
  final int idleSeconds;

  /// Optional note explaining why the time was kept
  final String note;

  /// ID of the associated timesheet
  final int timesheetId;

  /// Optional project ID for task reassignment
  final int? projectId;

  /// Optional task ID for task reassignment
  final int? taskId;

  /// Creates an idle time data instance
  ///
  /// [keepTime] indicates if the idle time should be kept or deducted
  /// [idleSeconds] represents the duration of inactivity
  /// [note] explains why time was kept
  /// [timesheetId] ID of the associated timesheet
  /// [projectId] Optional project ID when reassigning idle time to a different task
  /// [taskId] Optional task ID when reassigning idle time to a different task
  IdleTimeData({
    required this.keepTime,
    required this.idleSeconds,
    required this.timesheetId,
    this.note = '',
    this.projectId,
    this.taskId,
  });

  /// Creates an idle time data instance from JSON
  factory IdleTimeData.fromJson(Map<String, dynamic> json) {
    return IdleTimeData(
      keepTime: json['keepTime'] as bool,
      idleSeconds: json['idleSeconds'] as int,
      timesheetId: json['timesheetId'] as int,
      note: json['note'] as String? ?? '',
      projectId: json['projectId'] as int?,
      taskId: json['taskId'] as int?,
    );
  }

  /// Converts the idle time data to JSON
  Map<String, dynamic> toJson() {
    return {
      'keepTime': keepTime,
      'idleSeconds': idleSeconds,
      'timesheetId': timesheetId,
      'note': note,
      if (projectId != null) 'projectId': projectId,
      if (taskId != null) 'taskId': taskId,
    };
  }
}
