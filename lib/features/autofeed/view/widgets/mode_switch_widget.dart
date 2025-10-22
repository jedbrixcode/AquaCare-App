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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rotation',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          CupertinoSwitch(
            value: isManualMode,
            onChanged: onModeChanged,
            activeColor: Colors.blue[600],
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
