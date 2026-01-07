import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A custom header widget that provides window controls and branding
/// Supports dragging, maximizing/minimizing, and displays app logo/title
class CustomHeader extends StatelessWidget {
  static const double _defaultHeight = 50.0;
  static const double _iconSize = 28.0;
  static const double _logoSize = 40.0;
  static const double _controlButtonWidth = 36.0;
  static const double _controlButtonHeight = 32.0;

  final String title;
  final String? logoPath;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final double height;

  const CustomHeader({
    super.key,
    required this.title,
    this.logoPath,
    this.fallbackIcon,
    this.backgroundColor,
    this.height = _defaultHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onPanStart: (_) => WindowManager.instance.startDragging(),
          onDoubleTap: _toggleMaximize,
          child: Container(
            height: height,
            decoration: _buildHeaderDecoration(),
            child: Row(
              children: [
                const SizedBox(width: 8), // Reduced padding
                _buildBrandingSection(), // Logo and title
                const Spacer(), // Push window controls to the right
                _buildWindowControls(),
                const SizedBox(width: 8), // Reduced padding
              ],
            ),
          ),
        ),
        _buildBottomSeparator(),
      ],
    );
  }

  /// Creates the header decoration with gradient and shadow
  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFfef7f7), Color(0xFFfdf2f2)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.shade100.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Builds an elegant bottom separator with evaluation-style design
  Widget _buildBottomSeparator() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.pink.shade100.withOpacity(0.3),
            Colors.pink.shade200.withOpacity(0.5),
            Colors.pink.shade300.withOpacity(0.7),
            Colors.pink.shade200.withOpacity(0.5),
            Colors.pink.shade100.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle dot pattern for evaluation-style design
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                20,
                (index) => Container(
                  width: 1,
                  height: 1,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade300.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the branding section with logo and title
  Widget _buildBrandingSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppIcon(),
        const SizedBox(width: 8), // Reduced spacing
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2c2c2e),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
            overflow: TextOverflow.ellipsis, // Handle text overflow
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Builds the app icon with fallback support
  Widget _buildAppIcon() {
    if (logoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          logoPath!,
          width: _logoSize,
          height: _logoSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(),
        ),
      );
    }
    return _buildFallbackIcon();
  }

  /// Builds the fallback icon when logo is not available
  Widget _buildFallbackIcon() {
    return Icon(
      fallbackIcon ?? Icons.access_time,
      color: Colors.grey.shade600,
      size: _iconSize,
    );
  }

  /// Builds the window control buttons
  Widget _buildWindowControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _MoreOptionsButton(),
        // const SizedBox(width: 4),
        _WindowControlButton(
          icon: Icons.remove,
          onPressed: () => WindowManager.instance.minimize(),
        ),
        const SizedBox(width: 4), // Reduced spacing
        _WindowControlButton(
          icon: Icons.crop_square_outlined,
          onPressed: _toggleMaximize,
        ),
        const SizedBox(width: 4), // Reduced spacing
        _WindowControlButton(
          icon: Icons.close,
          onPressed: () => WindowManager.instance.close(),
          isCloseButton: true,
        ),
      ],
    );
  }

  /// Toggles window maximize/restore state
  Future<void> _toggleMaximize() async {
    final bool isMaximized = await WindowManager.instance.isMaximized();
    if (isMaximized) {
      await WindowManager.instance.unmaximize();
    } else {
      await WindowManager.instance.maximize();
    }
  }
}

/// A custom window control button with hover effects
class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isCloseButton;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    this.isCloseButton = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: CustomHeader._controlButtonWidth,
          height: CustomHeader._controlButtonHeight,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 16, color: _getIconColor()),
        ),
      ),
    );
  }

  /// Updates hover state safely
  void _setHovered(bool hovered) {
    if (mounted) {
      setState(() => _isHovered = hovered);
    }
  }

  /// Returns appropriate background color based on hover state
  Color _getBackgroundColor() {
    if (!_isHovered) return Colors.transparent;

    return widget.isCloseButton
        ? Colors.red.withOpacity(0.1)
        : Colors.grey.shade100;
  }

  /// Returns appropriate icon color based on hover state and button type
  Color _getIconColor() {
    if (_isHovered && widget.isCloseButton) {
      return Colors.red.shade700;
    }
    return Colors.grey.shade600;
  }
}

/// A more options button with dropdown menu
class _MoreOptionsButton extends StatefulWidget {
  @override
  State<_MoreOptionsButton> createState() => _MoreOptionsButtonState();
}

class _MoreOptionsButtonState extends State<_MoreOptionsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsMenu(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: Container(
          width: CustomHeader._controlButtonWidth,
          height: CustomHeader._controlButtonHeight,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.more_vert, size: 16, color: _getIconColor()),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      items: [
        _buildMenuItem(Icons.settings, 'Settings', 'settings'),
        _buildMenuItem(Icons.info_outline, 'About', 'about'),
        _buildMenuItem(Icons.help_outline, 'Help', 'help'),
        const PopupMenuDivider(),
        _buildMenuItem(Icons.exit_to_app, 'Exit', 'exit'),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        // Handle settings
        break;
      case 'about':
        // Handle about
        break;
      case 'help':
        // Handle help
        break;
      case 'exit':
        WindowManager.instance.close();
        break;
    }
  }

  void _setHovered(bool hovered) {
    if (mounted) {
      setState(() => _isHovered = hovered);
    }
  }

  Color _getBackgroundColor() {
    return _isHovered ? Colors.pink.shade50 : Colors.transparent;
  }

  Color _getIconColor() {
    return _isHovered ? Colors.pink.shade400 : Colors.grey.shade600;
  }
}
