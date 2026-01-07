import 'dart:io';

import 'package:pi_task_watch/controllers/timesheet_controller.dart';
import 'package:pi_task_watch/my_app.dart';
import 'package:pi_task_watch/rust/frb_generated.dart';
import 'package:pi_task_watch/services/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  // await initSystemTray();
  //

  // Initialize Rust library
  await RustLib.init();

  //
  await WindowManager.instance.ensureInitialized();

  //
  // LogUtils.init();

  // Initialize controllers before the app starts
  setAllController();

  // Initialize lifecycle service to prevent freezing during system sleep/idle
  await AppLifecycleService().initialize();

  // Start user activity monitoring
  UserActivityService().startWork();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Set window size and position
    setupWindowSize();
  }
  // jaya
  runApp(const MyApp());

  // Future.delayed(const Duration(seconds: 2), () async {
  //   await WindowManager.instance.setAlwaysOnTop(true);
  // });
}

void setupWindowSize() {
  // We'll set the sizes after getting screen information
  getCurrentScreen().then((screen) async {
    if (screen != null) {
      final screenFrame = screen.visibleFrame;
      final screenWidth = screenFrame.width;
      final screenHeight = screenFrame.height;

      // Calculate window dimensions based on screen size with dynamic bounds
      double windowWidth = screenWidth * 0.25; // 25% of screen width
      double windowHeight =
          screenHeight * 0.85; // 75% of screen height (increased from 60%)

      // Set minimum size based on screen dimensions
      final minWidth = screenWidth * 0.15; // At least 15% of screen width
      final maxWidth = screenWidth * 0.3; // At most 30% of screen width
      windowWidth = windowWidth.clamp(minWidth, maxWidth);

      // Set minimum and maximum height relative to screen size
      final minHeight = screenHeight * 0.3; // At least 30% of screen height
      final maxHeight =
          screenHeight *
          0.8; // At most 80% of screen height (increased from 70%)

      // Adjust width-to-height ratio for better appearance
      final aspectRatio =
          0.7; // Width to height ratio (reduced from 0.9 to make window taller)
      windowHeight = windowWidth / aspectRatio;

      // Ensure the height is within reasonable bounds relative to screen
      windowHeight = windowHeight.clamp(minHeight, maxHeight);

      // Hide default window frame for custom header
      await WindowManager.instance.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );

      // Set minimum and maximum window size with the calculated dimensions
      setWindowMinSize(Size(windowWidth, windowHeight));
      setWindowMaxSize(Size(windowWidth, windowHeight));

      // Calculate position for bottom right corner with platform-specific adjustments
      double windowLeft;
      double windowTop;

      // Calculate margin as a percentage of screen size
      final marginFactor = 0.02; // 2% of screen dimension
      final horizontalMargin = screenWidth * marginFactor;
      final verticalMargin = screenHeight * marginFactor;

      // Platform-specific positioning
      if (Platform.isLinux) {
        // Linux often needs different offsets due to window manager decorations
        windowLeft = screenWidth - windowWidth - horizontalMargin;
        windowTop = screenHeight - windowHeight - verticalMargin;

        // Add dynamic adjustment for panels/docks based on screen height
        final panelAdjustment =
            screenHeight * 0.03; // Approximately 3% of screen height
        windowTop -= panelAdjustment;
      } else {
        // macOS and Windows
        // Use the visibleFrame which already accounts for dock/taskbar on macOS
        windowLeft = screenFrame.right - windowWidth - horizontalMargin;
        windowTop = screenFrame.bottom - windowHeight - verticalMargin;
      }

      // Set window position to bottom right corner with margin
      setWindowFrame(
        Rect.fromLTWH(windowLeft, windowTop, windowWidth, windowHeight),
      );

      // Make sure window is visible and on top
      setWindowTitle('PI Task Watch');
      setWindowVisibility(visible: true);
    }
  });
}

void setAllController() {
  Get.put(TrackerController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ProjectController(), permanent: true);
  Get.put(TaskController(), permanent: true);
  Get.put(TimesheetController(), permanent: true);
}

// user : mailto:mark.brown23@example.com
// password : 123456
//
// Thats is complete
//
//
