import 'package:aquacare_v5/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class ModeSwitchWidget extends StatelessWidget {
  final bool isManualMode;
  final ValueChanged<bool> onModeChanged;

  const ModeSwitchWidget({
    super.key,
    required this.isManualMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkTheme.cardColor : lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? darkTheme.colorScheme.primary
                  : lightTheme.colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rotation',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color:
                  isDark
                      ? darkTheme.textTheme.bodyLarge?.color
                      : lightTheme.textTheme.bodyLarge?.color,
            ),
          ),
          CupertinoSwitch(
            value: isManualMode,
            onChanged: onModeChanged,
            activeColor:
                isDark
                    ? darkTheme.colorScheme.primary
                    : lightTheme.colorScheme.primary,
            trackColor: Colors.blue[200],
          ),
          Text(
            'Manual',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
