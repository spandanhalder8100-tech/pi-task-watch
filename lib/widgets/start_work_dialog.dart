import 'package:pi_task_watch/exports.dart';

import '../controllers/timesheet_controller.dart';
import '../models/timesheet_model.dart';

// Jayadrata dxx ggJaYadf
//
class StartTrackerForm extends StatefulWidget {
  final TaskModel? task;
  const StartTrackerForm({super.key, this.task});

  @override
  State<StartTrackerForm> createState() => _StartTrackerFormState();
}

class _StartTrackerFormState extends State<StartTrackerForm> {
  // final ApiController _apiController = Get.find<ApiController>();
  // project controller
  final ProjectController _projectController = Get.find<ProjectController>();
  final TaskController _taskController = Get.find<TaskController>();

  bool _isSubmitting = false;
  bool _isInitializing = true;
  bool _isLoadingProjects = false;
  bool _isLoadingTasks = false;

  int? selectedProjectId;
  String? selectedProjectName;
  int? selectedTaskId;
  String? selectedTaskName;
  List<ProjectModel> projects = [];
  List<TaskModel> tasks = [];

  final TextEditingController _noteController = TextEditingController();

  DateTime? _lastClickTime;
  late VoidCallback _textControllerListener;

  @override
  void initState() {
    super.initState();
    // Store listener reference for proper disposal
    _textControllerListener = () {
      if (mounted) setState(() {});
    };
    _noteController.addListener(_textControllerListener);
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (!mounted) return;

    setState(() => _isInitializing = true);

    try {
      if (widget.task != null) {
        selectedTaskId = widget.task!.id;
        selectedTaskName = widget.task!.name;
        selectedProjectId = widget.task!.projectId;
        await fetch();
      }
      await _loadProjects();
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;

    setState(() => _isLoadingProjects = true);

    try {
      projects = await _projectController.getAllProject();
      if (!mounted) return;

      if (selectedProjectId != null && selectedProjectName == null) {
        final project = projects.firstWhereOrNull(
          (p) => p.id == selectedProjectId,
        );
        if (project != null) {
          selectedProjectName = project.name;
        }
      }

      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        projects = [];
      });
      Get.snackbar(
        'Error',
        'Failed to load projects. Please try again.',
        backgroundColor: Colors.red[100],
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingProjects = false);
      }
    }
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() => _isLoadingTasks = true);

    try {
      tasks = await _taskController.getTaskList(projectId: selectedProjectId);

      if (!mounted) return;

      if (selectedTaskId != null) {
        final taskExists = tasks.any((t) => t.id == selectedTaskId);
        if (!taskExists) {
          selectedTaskId = null;
          selectedTaskName = null;
        } else if (selectedTaskName == null) {
          final task = tasks.firstWhere((t) => t.id == selectedTaskId);
          selectedTaskName = task.name;
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        tasks = [];
      });
      Get.snackbar(
        'Error',
        'Failed to load tasks. Please try again.',
        backgroundColor: Colors.red[100],
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingTasks = false);
      }
    }
  }

  void _startTracking() async {
    // Debounce: Prevent rapid multiple clicks
    final now = DateTime.now();
    if (_lastClickTime != null &&
        now.difference(_lastClickTime!).inMilliseconds < 1000) {
      return;
    }
    _lastClickTime = now;

    // Prevent multiple simultaneous submissions
    if (_isSubmitting ||
        _isInitializing ||
        _isLoadingProjects ||
        _isLoadingTasks) {
      return;
    }

    if (selectedTaskId == null) {
      Get.snackbar('Error', 'Please select a task');
      return;
    }

    if (_noteController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please add notes about your work');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final selectedTaskModel = tasks.firstWhereOrNull(
        (task) => task.id == selectedTaskId,
      );

      if (selectedTaskModel == null) {
        Get.snackbar('Error', 'Selected task not found. Please try again.');
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      // Find the matching project from projects list based on task's projectId
      final projectModel = projects.firstWhereOrNull(
        (project) => project.id == selectedTaskModel.projectId,
      );

      if (projectModel == null) {
        Get.snackbar(
          'Error',
          'Project not found for the selected task. Please try again.',
        );
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      final trackerData = StartWorkResult(
        task: selectedTaskModel,
        project: projectModel,
        notes: _noteController.text.trim(),
        startTime: DateTime.now(),
        timesheet: exitingTimesheet,
      );

      Get.back(result: trackerData);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start tracking. Please try again.',
        backgroundColor: Colors.red[100],
      );
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  TimesheetModel? exitingTimesheet;

  Future<void> fetch() async {
    if (widget.task == null) return;

    try {
      final now = DateTime.now();
      final task = widget.task!;
      final tList = await Get.find<TimesheetController>().getAllTimesheet(
        date: now,
      );

      for (final t in tList) {
        if (t.taskId != null && t.taskId == task.id) {
          exitingTimesheet = t;
          break;
        }
      }

      _noteController.text = exitingTimesheet?.description ?? '';
      // Add setState to update UI after loading notes
      if (mounted) setState(() {});
    } catch (e) {
      // Handle error silently or show snackbar if needed
    }
    // Removed the finally block with isLoading since we handle loading in _initializeForm
  }

  @override
  void dispose() {
    // Properly remove the stored listener reference
    _noteController.removeListener(_textControllerListener);
    _noteController.dispose();
    super.dispose();
  }

  bool get _isLoading =>
      _isInitializing || _isLoadingProjects || _isLoadingTasks;

  bool get _canSubmit {
    return !_isLoading &&
        !_isSubmitting &&
        selectedTaskId != null &&
        _noteController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isInitializing) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Field
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Project: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                Expanded(
                  child:
                      _isLoadingProjects
                          ? Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loading projects...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          )
                          : Text(
                            selectedProjectName ?? 'No project',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  selectedProjectName != null
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),

          // Task Field
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Task: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                Expanded(
                  child:
                      _isLoadingTasks
                          ? Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loading tasks...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          )
                          : Text(
                            selectedTaskName ?? 'No task',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  selectedTaskName != null
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notes Field
          Text(
            'Notes *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          CompactTextField(
            controller: _noteController,
            hintText: 'Add notes about what you\'re working on...',
            maxLines: 5,
            autogrow: false,
            // Remove the enabled parameter if it's not supported by CompactTextField
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    (_isSubmitting || _isLoading) ? null : () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _canSubmit ? _startTracking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Add visual feedback during submission
                  elevation: _isSubmitting ? 0 : 2,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text('Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
