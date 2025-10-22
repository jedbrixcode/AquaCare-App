import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

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
                color: Colors.blue[700],
              ),
            ),
            _buildFoodToggle(context),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select number of rotations and confirm',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildRotationPicker(context),
        const SizedBox(height: 20),
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildFoodToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pellets',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color: food == 'pellet' ? Colors.blue[800] : Colors.blue[400],
              fontWeight: food == 'pellet' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          CupertinoSwitch(
            value: food == 'flakes',
            onChanged: onFoodChanged,
            activeColor: Colors.blue[600],
            trackColor: Colors.blue[200],
          ),
          const SizedBox(width: 6),
          Text(
            'Flakes',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color: food == 'flakes' ? Colors.blue[800] : Colors.blue[400],
              fontWeight: food == 'flakes' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationPicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
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
                  color: Colors.blue[700],
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
                      color: Colors.blue[600],
                      size: 26,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!, width: 1),
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
                              color: Colors.blue[600],
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
                      color: Colors.blue[600],
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
              color: Colors.blue[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
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
          ),
        ),
      ),
    );
  }
}
