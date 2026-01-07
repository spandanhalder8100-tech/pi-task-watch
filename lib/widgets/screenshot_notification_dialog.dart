import 'dart:async';
import 'package:flutter/material.dart';

class ScreenshotNotificationDialog extends StatefulWidget {
  const ScreenshotNotificationDialog({super.key});

  @override
  State<ScreenshotNotificationDialog> createState() =>
      _ScreenshotNotificationDialogState();
}

class _ScreenshotNotificationDialogState
    extends State<ScreenshotNotificationDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    // Auto-dismiss after 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Screenshot Captured',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'Your work activity has been recorded',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Auto-dismiss indicator
            Text(
              'This message will close automatically',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
