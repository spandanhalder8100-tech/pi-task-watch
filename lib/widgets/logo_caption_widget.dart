import 'package:flutter/material.dart';

class LogoCaptionWidget extends StatelessWidget {
  final double imageWidth;
  final double imageHeight;
  final TextStyle? captionStyle;
  final double zoomPercentage;

  const LogoCaptionWidget({
    super.key,
    this.imageWidth = 80,
    this.imageHeight = 80,
    this.captionStyle,
    this.zoomPercentage = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final scaledImageWidth = imageWidth * zoomPercentage;
    final scaledImageHeight = imageHeight * zoomPercentage;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: 1.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo-transparent.png',
            width: scaledImageWidth,
            height: scaledImageHeight,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12 * zoomPercentage),
          Text(
            'PI Task Watch',
            style:
                captionStyle?.copyWith(
                  fontSize: (captionStyle?.fontSize ?? 20) * zoomPercentage,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ) ??
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20 * zoomPercentage,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
