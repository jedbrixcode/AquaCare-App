import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class ManualFeedingWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                color: Colors.blue[700],
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
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 24),
        _buildFeedButton(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFoodToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: food == 'pellet' ? Colors.blue[800] : Colors.blue[400],
              fontWeight: food == 'pellet' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: food == 'flakes',
            onChanged: onFoodChanged,
            activeColor: Colors.blue[600],
            trackColor: Colors.blue[200],
          ),
          const SizedBox(width: 8),
          Text(
            'Flakes',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: food == 'flakes' ? Colors.blue[800] : Colors.blue[400],
              fontWeight: food == 'flakes' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onFeedingStart(),
      onTapUp: (_) => onFeedingStop(),
      onTapCancel: onFeedingStop,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: ResponsiveHelper.getCardWidth(context),
        height: ResponsiveHelper.getCardHeight(context),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isFeeding ? Icons.pause : Icons.play_arrow,
          size: ResponsiveHelper.getFontSize(context, 48),
          color: Colors.white,
        ),
      ),
    );
  }
}
