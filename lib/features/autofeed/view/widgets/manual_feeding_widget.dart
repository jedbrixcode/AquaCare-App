import 'package:aquacare_v5/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class ManualFeedingWidget extends StatefulWidget {
  final String food;
  final bool isFeeding;
  final ValueChanged<bool> onFoodChanged;
  final VoidCallback onFeedingStart;
  final VoidCallback onFeedingStop;

  const ManualFeedingWidget({
    super.key,
    required this.food,
    required this.isFeeding,
    required this.onFoodChanged,
    required this.onFeedingStart,
    required this.onFeedingStop,
  });

  @override
  State<ManualFeedingWidget> createState() => _ManualFeedingWidgetState();
}

class _ManualFeedingWidgetState extends State<ManualFeedingWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Manual Feeding',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _buildFoodToggle(context),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Press and hold to feed manually',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: isDark ? darkTheme.textTheme.bodyLarge?.color : Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildFeedButton(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFoodToggle(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? darkTheme.colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? darkTheme.colorScheme.primary : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pellets',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color:
                  widget.food == 'pellet'
                      ? isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color
                      : isDark
                      ? darkTheme.textTheme.bodyLarge?.color
                      : lightTheme.textTheme.bodyLarge?.color,
              fontWeight:
                  widget.food == 'pellet' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: widget.food == 'flakes',
            onChanged: widget.onFoodChanged,
            activeColor:
                isDark
                    ? darkTheme.colorScheme.primary
                    : darkTheme.colorScheme.primary,
            trackColor:
                isDark
                    ? darkTheme.colorScheme.primary
                    : lightTheme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Flakes',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color:
                  widget.food == 'flakes'
                      ? isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color
                      : isDark
                      ? darkTheme.textTheme.bodyLarge?.color
                      : lightTheme.textTheme.bodyLarge?.color,
              fontWeight:
                  widget.food == 'flakes' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedButton(BuildContext context) {
    final width = ResponsiveHelper.getCardWidth(context);
    final height = ResponsiveHelper.getCardHeight(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onFeedingStart();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onFeedingStop();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onFeedingStop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _isPressed ? width * 0.9 : width,
        height: _isPressed ? height * 0.9 : height,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.blue[700] : Colors.blue[600],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(_isPressed ? 0.5 : 0.3),
              blurRadius: _isPressed ? 25 : 20,
              spreadRadius: _isPressed ? 10 : 8,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.isFeeding ? Icons.pause : Icons.play_arrow,
            size: ResponsiveHelper.getFontSize(context, 50),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
