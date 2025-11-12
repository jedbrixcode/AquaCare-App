import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/utils/theme.dart';

class RotationFeedingWidget extends StatelessWidget {
  final String food;
  final int rotations;
  final ValueChanged<bool> onFoodChanged;
  final ValueChanged<int> onRotationsChanged;
  final VoidCallback onConfirm;

  const RotationFeedingWidget({
    super.key,
    required this.food,
    required this.rotations,
    required this.onFoodChanged,
    required this.onRotationsChanged,
    required this.onConfirm,
  });

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
              'Rotation Feeding',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color:
                    isDark
                        ? darkTheme.textTheme.bodyLarge?.color
                        : Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select number of rotations and confirm',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: isDark ? darkTheme.textTheme.bodyLarge?.color : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildRotationPicker(context),
        const SizedBox(height: 20),
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildRotationPicker(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark
                ? darkTheme.colorScheme.onSecondary.withOpacity(0.4)
                : lightTheme.colorScheme.onSecondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? darkTheme.colorScheme.primary
                  : lightTheme.colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rotations:',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (rotations > 1) {
                        onRotationsChanged(rotations - 1);
                      }
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color:
                          isDark ? darkTheme.colorScheme.primary : Colors.white,
                      size: 26,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? darkTheme.colorScheme.onSecondary.withOpacity(
                                0.4,
                              )
                              : lightTheme.colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isDark
                                ? darkTheme.colorScheme.primary
                                : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: CupertinoPicker(
                      itemExtent: 35,
                      onSelectedItemChanged:
                          (index) => onRotationsChanged(index + 1),
                      children: List.generate(
                        10,
                        (index) => Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                16,
                              ),
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? darkTheme.textTheme.bodyLarge?.color
                                      : lightTheme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (rotations < 10) {
                        onRotationsChanged(rotations + 1);
                      }
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      color:
                          isDark ? darkTheme.colorScheme.primary : Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selected: $rotations rotation${rotations > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color:
                  isDark ? darkTheme.textTheme.bodyLarge?.color : Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor:
              isDark
                  ? darkTheme.textTheme.bodyLarge?.color
                  : lightTheme.textTheme.bodyLarge?.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Confirm Feeding',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
