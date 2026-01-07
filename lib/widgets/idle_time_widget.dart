import 'dart:async';

import 'package:pi_task_watch/exports.dart';

import '../models/idle_time_data.dart';

class IdleTimeWidget extends StatefulWidget {
  final int idleTime;
  final VoidCallback? onError;

  const IdleTimeWidget({super.key, required this.idleTime, this.onError});

  @override
  State<IdleTimeWidget> createState() => _IdleTimeWidgetState();
}

class _IdleTimeWidgetState extends State<IdleTimeWidget> {
  bool _showNoteField = true;
  final bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _noteController = TextEditingController();
  late int _currentIdleTime;
  Timer? _timer;

  // Task selection state
  List<TaskModel> _availableTasks = [];
  TaskModel? _selectedTask;
  bool _isLoadingTasks = false;
  final TrackerController _trackerController = Get.find<TrackerController>();
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _currentIdleTime = widget.idleTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentIdleTime++;
      });
    });

    // Fetch available tasks
    _fetchAvailableTasks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableTasks() async {
    setState(() => _isLoadingTasks = true);
    try {
      final currentProjectId =
          _trackerController.startWorkData.value?.project.id;
      final currentTaskId = _trackerController.startWorkData.value?.task.id;
      final tasks = await _taskController.getTaskList(
        projectId: currentProjectId,
      );
      setState(() {
        _availableTasks = tasks;
        _isLoadingTasks = false;

        // Set selected task from the fetched list by matching ID
        if (currentTaskId != null && tasks.isNotEmpty) {
          _selectedTask = tasks.firstWhere(
            (task) => task.id == currentTaskId,
            orElse: () => tasks.first,
          );
        }
      });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      setState(() => _isLoadingTasks = false);
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (parts.isEmpty || remainingSeconds > 0) {
      parts.add('${remainingSeconds}s');
    }

    return parts.join(' ');
  }

  void _returnResult(bool keepTime) {
    if (keepTime && _showNoteField && _noteController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please add a note');
      return;
    }

    Navigator.of(context).pop(
      IdleTimeData(
        timesheetId:
            Get.find<TrackerController>().startWorkData.value!.timesheetId,
        keepTime: keepTime,
        idleSeconds: _currentIdleTime,
        note: keepTime ? _noteController.text.trim() : 'Time deducted',
        projectId: _selectedTask?.projectId,
        taskId: _selectedTask?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Timer display
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_currentIdleTime),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Title text
              const Text(
                'Idle Time Detected',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 3),

              Text(
                'What would you like to do with this idle time?',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),

              const Divider(height: 12, thickness: 0.5),

              // Task selection dropdown
              if (_isLoadingTasks)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                )
              else if (_availableTasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DropdownButtonFormField<TaskModel>(
                    value: _selectedTask,
                    decoration: const InputDecoration(
                      labelText: 'Assign to Task',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                    isExpanded: true,
                    menuMaxHeight: 200,
                    selectedItemBuilder: (BuildContext context) {
                      return _availableTasks.map((task) {
                        return Text(
                          task.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }).toList();
                    },
                    items:
                        _availableTasks.map((task) {
                          return DropdownMenuItem<TaskModel>(
                            value: task,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    task.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (task.projectName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      task.projectName!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (TaskModel? newTask) {
                      setState(() {
                        _selectedTask = newTask;
                      });
                    },
                  ),
                ),

              // Keep time option
              SwitchListTile.adaptive(
                title: const Text(
                  'Keep idle time',
                  style: TextStyle(fontSize: 13),
                ),
                value: _showNoteField,
                onChanged: (value) => setState(() => _showNoteField = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),

              // Note field
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Add note (required)',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      maxLines: 3,
                      minLines: 3,
                    ),
                  ),
                ),
                crossFadeState:
                    _showNoteField
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),

              // Action buttons
              Row(
                children: [
                  // Skip time button (always visible)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : () => _returnResult(false),
                      icon: const Icon(Icons.remove_circle_outline, size: 14),
                      label: const Text(
                        'Remove Time',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  // Keep time button (only when switch is on)
                  if (_showNoteField)
                    Expanded(
                      child: TextButton.icon(
                        onPressed:
                            _isLoading ? null : () => _returnResult(true),
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text(
                          'Keep Time',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
