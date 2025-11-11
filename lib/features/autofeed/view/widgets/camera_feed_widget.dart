import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:aquacare_v5/utils/theme.dart';

class CameraFeedWidget extends StatelessWidget {
  final webview.WebViewController controller;
  final bool isLoading;
  final bool isConnected;
  final bool isCameraActive;
  final bool isCameraOffline;

  const CameraFeedWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.isConnected,
    required this.isCameraActive,
    required this.isCameraOffline,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            isDark
                ? darkTheme.colorScheme.onSecondary.withOpacity(0.4)
                : lightTheme.colorScheme.onSecondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? darkTheme.colorScheme.primary
                  : lightTheme.colorScheme.primary,
          width: 1,
        ),
      ),
      child:
          (!isCameraOffline && isCameraActive)
              ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    webview.WebViewWidget(controller: controller),
                    if (isLoading) _buildLoadingOverlay(),
                    _buildConnectionStatus(),
                  ],
                ),
              )
              : Center(
                child: Text(
                  'Camera Offline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? darkTheme.textTheme.bodyLarge?.color
                            : lightTheme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.blue[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(color: Colors.blue[600])],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isConnected ? Colors.green[100] : Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected ? Colors.green[300]! : Colors.orange[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              size: 12,
              color: isConnected ? Colors.green[700] : Colors.orange[700],
            ),
            const SizedBox(width: 4),
            Text(
              isConnected ? 'Aquacare Feeder: ON' : 'Aquacare Feeder: OFF',
              style: TextStyle(
                fontSize: 10,
                color: isConnected ? Colors.green[700] : Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Camera switch moved to parent row below the feed
}
