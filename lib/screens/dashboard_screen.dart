import 'dart:convert';

import 'package:pi_task_watch/rust/api/take_full_screenshot.dart';
import 'package:pi_task_watch/utils/confirmation_alert.dart';
import 'package:pi_task_watch/widgets/recent_activity_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../exports.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late TrackerController _trackerController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _trackerController = Get.find<TrackerController>();
    _authController = Get.find<AuthController>();
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.7) {
      return Colors.green.shade400;
    } else if (progress < 1.0) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [_buildDashboardSection(), _buildBottomSection()],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Critical error in dashboard build: $e');
      debugPrint('Stack trace: $stackTrace');

      // Return a safe fallback UI
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: _buildErrorWidget(
              'Dashboard failed to load. Please restart the app.',
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDashboardSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.pink.shade400,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 12, left: 6, right: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CustomHeader(title: "title"),
          _buildHeader(),
          const SizedBox(height: 6),
          _buildCounterSection(),
          const SizedBox(height: 6),
          _buildRunningTaskSection(),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Obx(() {
        final duration = _trackerController.trackerDuration.value;
        final isRunning = _trackerController.isTracking.value;
        final breakDuration = _trackerController.totalBreakDuration.value;
        final isBreakOverLimit = breakDuration.inMinutes >= 60;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    isRunning
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  iconSize: 22.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _handleTrackingToggle,
                ),
              ],
            ),
            // Break time indicator
            if (breakDuration.inSeconds > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isBreakOverLimit
                          ? Colors.red.withOpacity(0.2)
                          : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isBreakOverLimit
                            ? Colors.red.shade300
                            : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBreakOverLimit ? Icons.warning_amber : Icons.coffee,
                      size: 12,
                      color:
                          isBreakOverLimit
                              ? Colors.red.shade100
                              : Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Break: ${_formatTimeHM(breakDuration)}',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isBreakOverLimit
                                ? Colors.red.shade100
                                : Colors.white.withOpacity(0.9),
                        fontWeight:
                            isBreakOverLimit
                                ? FontWeight.bold
                                : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildRunningTaskSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.pink.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 0.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        try {
          final startWorkModel = _trackerController.startWorkData.value;

          if (startWorkModel == null) {
            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_off_outlined,
                      size: 20,
                      color: Colors.pink.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No active task',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Start tracking to see your current task',
                    style: TextStyle(fontSize: 10, color: Colors.pink.shade500),
                  ),
                ],
              ),
            );
          }

          // Validate start work model data before proceeding
          if (startWorkModel.task.name.isEmpty ||
              startWorkModel.project.name.isEmpty) {
            debugPrint('Warning: Invalid start work model data detected');
            return _buildErrorWidget(
              'Invalid task data detected. Please restart tracking.',
            );
          }

          return _buildActiveTaskContent(startWorkModel);
        } catch (e, stackTrace) {
          debugPrint('Error in running task section: $e');
          debugPrint('Stack trace: $stackTrace');
          return _buildErrorWidget(
            'Error loading task information. Please restart tracking.',
          );
        }
      }),
    );
  }

  Widget _buildActiveTaskContent(StartWorkModel startWorkModel) {
    try {
      final task = startWorkModel.task;
      final allocatedDuration =
          task.getAllocatedTimeDuration() ?? Duration.zero;
      final existingUsedTime = task.getUsedTime() ?? Duration.zero;
      final taskStartTime = startWorkModel.startTime;
      final taskNotes = startWorkModel.notes;

      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(task, startWorkModel),
            const SizedBox(height: 6),
            _buildProgressBar(allocatedDuration, existingUsedTime),
            const SizedBox(height: 6),
            _buildTimeDetails(
              taskStartTime,
              allocatedDuration,
              existingUsedTime,
            ),
            if (taskNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildNotesSection(taskNotes),
            ],
          ],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building active task content: $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildErrorWidget(
        'Error displaying task details. Please restart tracking.',
      );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              try {
                _trackerController.stopWork(notes: "Error recovery stop");
              } catch (e) {
                debugPrint('Error during emergency stop: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Emergency Stop',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(TaskModel task, StartWorkModel startWorkModel) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.pink.shade500,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.task_alt, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  try {
                    final taskUrl = task.url;
                    if (taskUrl.isNotEmpty) {
                      launchUrlString(taskUrl);
                    } else {
                      debugPrint('No URL available for this task');
                    }
                  } catch (e) {
                    debugPrint('Error launching URL: $e');
                  }
                },
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 10,
                    color: Colors.pink.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    startWorkModel.project.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          final taskStartAt = _trackerController.startWorkData.value?.startTime;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                taskStartAt != null
                    ? FormatUtils.formatTime(taskStartAt)
                    : '--:--',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.pink.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimeHM(
                  _trackerController.currentTimeEntryDuration.value,
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.pink.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProgressBar(
    Duration allocatedDuration,
    Duration existingUsedTime,
  ) {
    return Obx(() {
      final currentSessionDuration =
          _trackerController.currentTimeEntryDuration.value;
      final totalUsedTime = Duration(
        minutes: existingUsedTime.inMinutes + currentSessionDuration.inMinutes,
      );
      final progress =
          allocatedDuration.inMinutes > 0
              ? (totalUsedTime.inMinutes / allocatedDuration.inMinutes)
              : 0.0;
      final progressBarValue = progress.clamp(0.0, 1.0);
      final progressColor = _getProgressColor(progress);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress: ${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              Text(
                "${_formatTimeHM(totalUsedTime)} / ${_formatTimeHM(allocatedDuration)}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressBarValue,
              backgroundColor: Colors.pink.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimeDetails(
    DateTime? taskStartTime,
    Duration allocatedDuration,
    Duration existingUsedTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Row(
        children: [
          _buildCompactStatItem(
            icon: Icons.schedule_outlined,
            label: "Allocated",
            value: _formatTimeHM(allocatedDuration),
            color: Colors.pink.shade600,
          ),
          _buildCompactDivider(),
          _buildCompactStatItem(
            icon: Icons.hourglass_bottom_outlined,
            label: "Used",
            valueBuilder: () {
              final currentSessionDuration =
                  _trackerController.currentTimeEntryDuration.value;
              final totalUsedTime = Duration(
                minutes:
                    existingUsedTime.inMinutes +
                    currentSessionDuration.inMinutes,
              );
              return _formatTimeHM(totalUsedTime);
            },
            color: Colors.orange.shade600,
          ),
          _buildCompactDivider(),
          _buildCompactStatItem(
            icon: Icons.timer_outlined,
            label: "Remaining",
            valueBuilder: () {
              final currentSessionDuration =
                  _trackerController.currentTimeEntryDuration.value;
              final totalUsedTime = Duration(
                minutes:
                    existingUsedTime.inMinutes +
                    currentSessionDuration.inMinutes,
              );
              final isOverAllocated =
                  totalUsedTime.inMinutes > allocatedDuration.inMinutes;
              final displayTime =
                  isOverAllocated
                      ? Duration(
                        minutes:
                            totalUsedTime.inMinutes -
                            allocatedDuration.inMinutes,
                      )
                      : Duration(
                        minutes:
                            allocatedDuration.inMinutes -
                            totalUsedTime.inMinutes,
                      );
              return isOverAllocated
                  ? "-${_formatTimeHM(displayTime)}"
                  : _formatTimeHM(displayTime);
            },
            color: Colors.green.shade600,
            isAlert: () {
              final currentSessionDuration =
                  _trackerController.currentTimeEntryDuration.value;
              final totalUsedTime = Duration(
                minutes:
                    existingUsedTime.inMinutes +
                    currentSessionDuration.inMinutes,
              );
              return totalUsedTime.inMinutes > allocatedDuration.inMinutes;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDivider() {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.pink.shade100,
    );
  }

  //Jayadrata Middey
  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    String? value,
    Function? valueBuilder,
    required Color color,
    Function? isAlert,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 1),
          valueBuilder != null
              ? Obx(() {
                final displayValue = valueBuilder();
                final alert = isAlert?.call() ?? false;
                return Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        alert ? Colors.red.shade600 : Colors.blueGrey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                );
              })
              : Text(
                value!,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String taskNotes) {
    // Safely handle null or empty notes
    final safeNotes = taskNotes.isEmpty ? 'No notes added' : taskNotes;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.notes_outlined, size: 10, color: Colors.pink.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              safeNotes,
              style: TextStyle(
                fontSize: 10,
                color:
                    taskNotes.isEmpty
                        ? Colors.grey.shade500
                        : Colors.blueGrey.shade800,
                fontStyle:
                    taskNotes.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => _showEditNotesDialog(taskNotes),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.pink.shade500,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final user = _authController.user.value;
      final isTracking = _trackerController.isTracking.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final base64ImageResult =
                        await takeScreenshotWindowsNircmd();

                    print(
                      "Screenshot taken: ${base64ImageResult.length} characters",
                    );

                    // show screenshot in a dialog
                    DialogUtils.showAppDialog(
                      context: context,
                      title: "Screenshot",
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.memory(
                            base64Decode(base64ImageResult),
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white.withAlpha(77),
                    child:
                        user?.userId != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: OdooNetworkImage(
                                directImageUrl: user!.imageUrl,
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white,
                            ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        user?.email ?? "",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isTracking
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isTracking
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isTracking
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                    boxShadow:
                        isTracking
                            ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 3,
                                spreadRadius: 0.5,
                              ),
                            ]
                            : null,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  isTracking ? 'Active' : 'Stopped',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(isTracking ? 1 : 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              confirmationAlert(
                content: "Are you sure you want to logout?",
                onConfirm: () {
                  _authController.logout();
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.login, color: Colors.white, size: 14),
            ),
          ),
        ],
      );
    });
  }

  void _handleTrackingToggle() {
    try {
      final isTracking = _trackerController.isTracking.value;

      if (isTracking) {
        final startWorkData = _trackerController.startWorkData.value;
        if (startWorkData == null) {
          debugPrint(
            'Warning: Trying to stop tracking but no start work data found',
          );
          _showErrorDialog('No active task found to stop');
          return;
        }

        EndWorkDialog.show(
          context: context,
          trackedDuration: _trackerController.currentTimeEntryDuration.value,
          project: startWorkData.project,
          task: startWorkData.task,
          onStop: (EndWorkResult result) {
            try {
              _trackerController.stopWork(notes: result.notes);
            } catch (e) {
              debugPrint('Error stopping work: $e');
              _showErrorDialog('Failed to stop tracking. Please try again.');
            }
          },
        );
      } else {
        _showTaskSelectionDialog();
      }
    } catch (e, stackTrace) {
      debugPrint('Error in tracking toggle: $e');
      debugPrint('Stack trace: $stackTrace');
      _showErrorDialog(
        'An error occurred while toggling tracking. Please restart the app if this persists.',
      );
    }
  }

  void _showTaskSelectionDialog({TaskModel? exitingTask}) async {
    try {
      final isTracking = Get.find<TrackerController>().isTracking.value;
      if (isTracking) {
        debugPrint('Warning: Trying to start task but already tracking');
        return;
      }

      final TaskModel? task = exitingTask ?? await Get.to(MyTaskListScreen());
      if (task == null) {
        debugPrint('No task selected');
        return;
      }

      final StartWorkResult? result = await DialogUtils.showAppDialog(
        context: Get.context!,
        title: "Start work",
        content: StartTrackerForm(task: task),
      );

      if (result != null) {
        try {
          _trackerController.startWork(
            project: result.project,
            task: result.task,
            timesheet: result.timesheet,
            notes: result.notes,
          );
        } catch (e) {
          debugPrint('Error starting work: $e');
          _showErrorDialog(
            'Failed to start tracking. Please check your connection and try again.',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in task selection dialog: $e');
      debugPrint('Stack trace: $stackTrace');
      _showErrorDialog(
        'An error occurred while selecting task. Please try again.',
      );
    }
  }

  void _showErrorDialog(String message) {
    DialogUtils.showAppDialog(
      context: context,
      title: "Error",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditNotesDialog(String currentNotes) {
    try {
      final notesController = TextEditingController(text: currentNotes);

      DialogUtils.showAppDialog(
        context: context,
        title: "Edit Notes",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink.shade200),
                color: Colors.white,
              ),
              child: TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'Enter task notes...',
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final newNotes = notesController.text.trim();
                      _trackerController.updateNotes(newNotes);
                      Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Error updating notes: $e');
                      _showErrorDialog(
                        'Failed to update notes. Please try again.',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing edit notes dialog: $e');
      debugPrint('Stack trace: $stackTrace');
      _showErrorDialog('Failed to open notes editor. Please try again.');
    }
  }

  String _formatDuration(Duration duration) {
    return FormatUtils.formatDuration(duration);
  }

  String _formatTimeHM(Duration duration) {
    return FormatUtils.formatTimeHM(duration);
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: _buildRecentTasksSection(),
    );
  }

  Widget _buildRecentTasksSection() {
    return RecentActivityWidget(handleStartTask: _showTaskSelectionDialog);
  }
}
