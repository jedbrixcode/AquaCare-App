import 'package:flutter/material.dart';
import 'package:aquacare_v5/utils/theme.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: ResponsiveHelper.verticalPadding(context),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, 20),
          fontWeight: FontWeight.bold,
          color:
              isDark
                  ? darkTheme.textTheme.displayLarge?.color
                  : lightTheme.textTheme.displayLarge?.color,
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onClose;
  const ErrorBanner({super.key, required this.errorMessage, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.verticalPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: Colors.red[600]),
            ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? darkTheme.colorScheme.surface : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color:
                    isDark
                        ? darkTheme.textTheme.bodyLarge?.color
                        : lightTheme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                color:
                    isDark
                        ? darkTheme.textTheme.bodyLarge?.color
                        : lightTheme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                Icons.add,
                color:
                    isDark
                        ? darkTheme.textTheme.bodyLarge?.color
                        : lightTheme.textTheme.bodyLarge?.color,
              ),
              label: Text(
                buttonText,
                style: TextStyle(
                  color:
                      isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
