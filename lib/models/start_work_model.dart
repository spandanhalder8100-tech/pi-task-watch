import 'package:intl/intl.dart';
import 'package:pi_task_watch/utils/date_to_simple_string.dart';

import '../exports.dart';

/// Model representing a work session that has been started
class StartWorkModel {
  /// The project being worked on
  ProjectModel project;

  /// The specific task being worked on
  TaskModel task;

  /// Optional notes about the work session
  String notes;

  /// The time when the work session started
  DateTime startTime;

  UserModel user;

  /// The timesheet ID associated with this work session
  int timesheetId;
  Duration duration;

  /// Creates a new StartWorkModel
  StartWorkModel({
    required this.user,
    required this.project,
    required this.task,
    this.notes = '',
    required this.startTime,
    required this.timesheetId,
    required this.duration,
  });

  /// Creates a copy of this StartWorkModel with the given fields replaced with new values
  StartWorkModel copyWith({
    UserModel? user,
    ProjectModel? project,
    TaskModel? task,
    String? notes,
    DateTime? startTime,
    int? timesheetId,
    Duration? duration,
  }) {
    return StartWorkModel(
      user: user ?? this.user,
      project: project ?? this.project,
      task: task ?? this.task,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      timesheetId: timesheetId ?? this.timesheetId,
      duration: duration ?? this.duration,
    );
  }

  /// Creates a StartWorkModel from a JSON map
  factory StartWorkModel.fromJson(Map<String, dynamic> json) {
    return StartWorkModel(
      user: UserModel.fromJson(json['user']),
      project: ProjectModel.fromJson(json['project']),
      task: TaskModel.fromJson(json['task']),
      notes: json['notes'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      timesheetId: json['timesheetId'],
      duration: Duration(seconds: json['duration'] ?? 0),
    );
  }

  /// Converts this StartWorkModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user': user.json,
      'project': project.toJson(),
      'task': task.json,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'timesheetId': timesheetId,
      'duration': duration.inSeconds,
    };
  }

  Map<String, dynamic> toCustomJson() {
    return toJsonForAPi();
    return {
      'id': timesheetId,
      "timesheet_id": timesheetId,
      'task_id': task.id,
      'task_name': task.name,
      'user_id': user.userId,
      'project_id': project.id,
      'project_name': project.name,
      'date': DateFormat('yyyy-MM-dd').format(startTime),
      'start_date': dateToSimpleString(startTime),
      'created_at': startTime.toIso8601String(),
      // 'end_date': dateToSimpleString(endDate), // Added field

      // 'description': notes,
      // 'notes': notes,
      // 'time_spent_in_seconds': timeSpentInSeconds,
      // "time_spent":
      //     Duration(seconds: timeSpentInSeconds).inMinutes +
      //     1, // Changed to seconds

      // 'mouse_click_count': mouseClickCount,
      // 'keyboard_press_count': keyboardPressCount,
      // 'screenshot_count': screenshotCount, // Added field
    };
  }

  //
  Map<String, dynamic> toJsonForAPi() => {
    'id': timesheetId,
    'timesheet_id': timesheetId,
    'task_id': task.id,
    'task_name': task.name,
    'user_id': user.userId,
    'project_id': project.id,
    'project_name': project.name,
    'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    'created_at': dateToSimpleString(DateTime.now()),
    'updated_at': dateToSimpleString(DateTime.now()),
    'description': notes,
    'notes': notes,
    'time_spent': duration.inMinutes,
  };
  //
}
