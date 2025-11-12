import 'dart:async';
import 'dart:io';
import 'package:aquacare_v5/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/core/config/backend_config.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/core/navigation/route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_android;
import '../viewmodel/autofeed_viewmodel.dart';
import 'widgets/camera_feed_widget.dart';
import 'widgets/rotation_feeding_widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const CameraPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage>
    with RouteAware, AutomaticKeepAliveClientMixin<CameraPage> {
  bool isCameraActive = true;
  bool _isCameraOffline = false;
  final String _cameraUrl = BackendConfig.piCamBaseUrl;

  late final webview.WebViewController _webViewController;
  bool _isWebViewLoading = true;
  Timer? _connectionStatusTimer;
  Timer? _webViewLoadingTimeout;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    try {
      ref
          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
          .connect(widget.aquariumId);
    } catch (_) {}
    // Use guarded handler to enable camera on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleCameraToggle(true);
    });
    _updateConnectionStatus();
    debugPrint('[CameraPage] initState: aquariumId=${widget.aquariumId}');
  }

  void _updateConnectionStatus() {
    _connectionStatusTimer?.cancel();
    _connectionStatusTimer = Timer.periodic(const Duration(seconds: 4), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        await Future(() {
          ref
              .read(autoFeedViewModelProvider(_cameraUrl).notifier)
              .updateConnectionStatus();
        });
      } catch (e) {
        debugPrint('Connection status update stopped: $e');
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[CameraPage] dispose: aquariumId=${widget.aquariumId}');
    _connectionStatusTimer?.cancel();
    _webViewLoadingTimeout?.cancel();
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    // Use guarded handler to avoid uncaught exceptions when camera backend is offline
    _handleCameraToggle(true);
  }

  @override
  void didPop() {
    // Guarded toggle off; ignore failures
    _handleCameraToggle(false);
    ref.read(autoFeedViewModelProvider(_cameraUrl).notifier).disconnect();
  }

  @override
  void didPushNext() {
    // Keep camera ON when opening dialogs/sheets; user controls the toggle
  }

  @override
  void didPopNext() {
    _handleCameraToggle(true);
  }

  void _initializeWebView() {
    final creationParams =
        const webview.PlatformWebViewControllerCreationParams();
    final controller =
        webview.WebViewController.fromPlatformCreationParams(creationParams)
          ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            webview.NavigationDelegate(
              onProgress: (progress) {
                if (mounted && _isWebViewLoading && progress > 5) {
                  setState(() => _isWebViewLoading = false);
                }
              },
              onPageFinished: (String _) {
                if (mounted) {
                  setState(() => _isWebViewLoading = false);
                }
              },
              onWebResourceError: (webview.WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  setState(() {
                    _isWebViewLoading = false;
                    _isCameraOffline = true;
                  });
                  _showReconnectingSnackbar();
                  _scheduleReconnect();
                }
              },
            ),
          );

    if (controller.platform is webview_android.AndroidWebViewController) {
      webview_android.AndroidWebViewController.enableDebugging(false);
      (controller.platform as webview_android.AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
    _webViewController.clearCache();
    _loadStream();

    _webViewLoadingTimeout?.cancel();
    _webViewLoadingTimeout = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isWebViewLoading = false);
      }
    });
  }

  void _loadStream() {
    _webViewController.loadRequest(
      Uri.parse('$_cameraUrl/aquarium/${widget.aquariumId}/video_feed'),
      headers: const {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        'Connection': 'keep-alive',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
    );
  }

  void _handleCameraToggle(bool value) async {
    try {
      if (!mounted) return;
      setState(() {
        isCameraActive = value;
        _isWebViewLoading = value;
        _isCameraOffline = false;
      });

      await ref
          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
          .toggleCamera(widget.aquariumId, value);

      if (value) {
        _webViewController.clearCache();
        _loadStream();
      } else {
        _webViewController.loadHtmlString(
          '<html><body style="background:#f4f4f4;display:flex;justify-content:center;align-items:center;height:100%;color:#999;"><h3>Camera is turned off</h3></body></html>',
        );
      }
    } on SocketException catch (_) {
      if (!mounted) return;
      setState(() {
        isCameraActive = false;
        _isWebViewLoading = false;
        _isCameraOffline = true;
      });
      _showOfflineSnackbar();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isCameraActive = false;
        _isWebViewLoading = false;
        _isCameraOffline = true;
      });
      _showOfflineSnackbar();
    }
  }

  void _showOfflineSnackbar() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Camera offline.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showReconnectingSnackbar() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Reconnecting to camera...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _scheduleReconnect() {
    if (!mounted || !isCameraActive) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !isCameraActive) return;
      _webViewController.clearCache();
      _loadStream();
    });
  }

  Widget _buildFoodToggle(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = ref.watch(autoFeedViewModelProvider(_cameraUrl));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? darkTheme.cardColor : lightTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? darkTheme.colorScheme.primary : Colors.white,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pellets',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color:
                  vm.food == 'pellet'
                      ? isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color
                      : isDark
                      ? darkTheme.textTheme.bodyLarge?.color
                      : lightTheme.textTheme.bodyLarge?.color,
              fontWeight:
                  vm.food == 'pellet' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          CupertinoSwitch(
            value: vm.food == 'flakes',
            onChanged:
                (value) => ref
                    .read(autoFeedViewModelProvider(_cameraUrl).notifier)
                    .setFood(value ? 'flakes' : 'pellet'),
            activeColor:
                isDark
                    ? darkTheme.colorScheme.primary
                    : darkTheme.colorScheme.primary,
            trackColor:
                isDark
                    ? darkTheme.colorScheme.primary
                    : lightTheme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Flakes',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color:
                  vm.food == 'flakes'
                      ? isDark
                          ? darkTheme.textTheme.bodyLarge?.color
                          : lightTheme.textTheme.bodyLarge?.color
                      : isDark
                      ? darkTheme.textTheme.bodyLarge?.color
                      : lightTheme.textTheme.bodyLarge?.color,
              fontWeight:
                  vm.food == 'flakes' ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRotationFeeding() async {
    final vm = ref.read(autoFeedViewModelProvider(_cameraUrl));
    final success = await ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .sendRotation(widget.aquariumId);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dispensing ${vm.rotations} rotations of food to TankPi',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feeder offline. Cannot dispense food.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRotationConfirmation() {
    final vm = ref.read(autoFeedViewModelProvider(_cameraUrl));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Confirm Feeding',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to dispense ${vm.rotations} rotations of food to ${widget.aquariumName}?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRotationFeeding();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = ref.watch(autoFeedViewModelProvider(_cameraUrl));

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark
                ? darkTheme.appBarTheme.backgroundColor
                : lightTheme.appBarTheme.backgroundColor,
        title: Text('${widget.aquariumName} - Auto Feed'),
        titleTextStyle: TextStyle(
          color:
              isDark
                  ? darkTheme.appBarTheme.titleTextStyle?.color
                  : lightTheme.appBarTheme.titleTextStyle?.color,
          fontSize: ResponsiveHelper.getFontSize(context, 24),
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context),
          vertical: ResponsiveHelper.verticalPadding(context),
        ),
        child: Column(
          children: [
            CameraFeedWidget(
              controller: _webViewController,
              isLoading: _isWebViewLoading,
              isConnected: vm.isConnected,
              isCameraActive: isCameraActive,
              isCameraOffline: _isCameraOffline,
            ),
            const SizedBox(height: 12),
            // Row with camera toggle switch only
            Container(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 12, bottom: 12, left: 18, right: 18),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? darkTheme.colorScheme.primary.withOpacity(0.6)
                        : lightTheme.colorScheme.primary.withOpacity(0.6),
                border: Border.all(
                  color:
                      isDark
                          ? darkTheme.colorScheme.secondary
                          : lightTheme.colorScheme.secondary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFoodToggle(context),

                  Text('Camera', style: TextStyle(color: Colors.white)),
                  Switch.adaptive(
                    value: isCameraActive,
                    onChanged: _handleCameraToggle,
                    activeColor:
                        isDark
                            ? darkTheme.colorScheme.primary
                            : lightTheme.colorScheme.background,
                    activeTrackColor:
                        isDark
                            ? lightTheme.colorScheme.primary
                            : darkTheme.colorScheme.background,
                    inactiveThumbColor:
                        isDark
                            ? darkTheme.colorScheme.primary
                            : lightTheme.colorScheme.background,
                    inactiveTrackColor:
                        isDark
                            ? lightTheme.colorScheme.primary
                            : darkTheme.colorScheme.background,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              height: 330,
              width: double.infinity,
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 20, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? darkTheme.colorScheme.primary.withOpacity(0.6)
                        : lightTheme.colorScheme.primary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark
                          ? darkTheme.colorScheme.secondary
                          : lightTheme.colorScheme.secondary,
                  width: 1,
                ),
              ),
              child: RotationFeedingWidget(
                food: vm.food,
                rotations: vm.rotations,
                onFoodChanged:
                    (value) => ref
                        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
                        .setFood(value ? 'flakes' : 'pellet'),
                onRotationsChanged:
                    (value) => ref
                        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
                        .setRotations(value),
                onConfirm: _showRotationConfirmation,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
