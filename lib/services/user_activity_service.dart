import 'package:pi_task_watch/exports.dart';
import 'package:pi_task_watch/rust/api/keyboard_listener.dart';
import 'package:pi_task_watch/rust/api/mouse_listener.dart';

class UserActivityService {
  void startWork() {
    startMouseListener().listen((event) {
      Get.find<TrackerController>().onUserActivity(
        type: UserActivityType.mouseClick,
      );
    });

    startKeyboardListener().listen((event) {
      Get.find<TrackerController>().onUserActivity(
        type: UserActivityType.keyboardPress,
      );
    });
  }
}
