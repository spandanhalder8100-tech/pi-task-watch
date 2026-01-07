import 'package:pi_task_watch/exports.dart';
import 'package:pi_task_watch/rust/api/take_full_screenshot.dart';
import 'package:pi_task_watch/utils/compress_image.dart';

Future<String> captureScreenshot() async {
  //
  print('🔵 Starting screenshot capture process...');

  String? rawImage;
  String? compressedImage;

  print('🔵 Platform check: isWindows = ${GetPlatform.isWindows}');

  if (GetPlatform.isWindows) {
    print('🔵 Using Windows optimized screenshot method...');
    try {
      // Use the Rust backend which has multiple Windows-specific methods:
      // 1. Screenshots crate (primary)
      // 2. NirCmd (silent, Windows native)
      // 3. PowerShell with hidden window (fallback)
      print('🔵 Attempting Rust-based Windows screenshot...');
      rawImage =
          GetPlatform.isWindows
              ? await takeScreenshotWindowsNircmd()
              : await takeFullScreenshot();
      print('✅ Windows screenshot captured successfully');
    } catch (e) {
      print('❌ Windows screenshot failed: $e');
      // This should rarely happen as the Rust implementation has multiple fallbacks
      print('🔄 All Windows methods exhausted, screenshot failed');
      rethrow; // Don't suppress the error, let it bubble up
    }
  } else {
    print('🔵 Using cross-platform screenshot method...');
    rawImage = await takeFullScreenshot();
    print('✅ Cross-platform screenshot captured successfully');
  }

  print('🔵 Starting image compression...');
  compressedImage = compressBase64Image(rawImage);
  print('✅ Image compression completed');

  print('🔵 Screenshot capture process finished successfully');
  return compressedImage;
}
