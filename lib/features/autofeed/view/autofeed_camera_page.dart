import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/core/navigation/route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_android;
import '../viewmodel/autofeed_viewmodel.dart';

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
  final String _cameraUrl = 'https://pi-cam.alfreds.dev';

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

    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .connect(widget.aquariumId);
    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .toggleCamera(widget.aquariumId, true);

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
    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .toggleCamera(widget.aquariumId, true);
  }

  @override
  void didPop() {
    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .toggleCamera(widget.aquariumId, false);
    ref.read(autoFeedViewModelProvider(_cameraUrl).notifier).disconnect();
  }

  @override
  void didPushNext() {
    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .toggleCamera(widget.aquariumId, false);
  }

  @override
  void didPopNext() {
    ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .toggleCamera(widget.aquariumId, true);
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
                  _isWebViewLoading = false;
                  setState(() {});
                }
              },
              onPageFinished: (String _) {
                if (mounted) {
                  _isWebViewLoading = false;
                  setState(() {});
                }
              },
              onWebResourceError: (webview.WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  _isWebViewLoading = false;
                  setState(() {});
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

    // Clear any previous cache and aggressively disable network caching via headers.
    _webViewController.clearCache();
    _loadStream();

    // As streams often never fire onPageFinished, hide loader ASAP.
    _webViewLoadingTimeout?.cancel();
    _webViewLoadingTimeout = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isWebViewLoading = false;
        setState(() {});
      }
    });
  }

  void _loadStream() {
    _webViewController.loadRequest(
      Uri.parse('$_cameraUrl/aquarium/${widget.aquariumId}/video_feed'),
      headers: const {
        // Prevent caching/buffering where possible
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        // Keep connection open; some servers benefit during MJPEG streaming
        'Connection': 'keep-alive',
        // Typical accept to avoid content negotiation delays
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
    );
  }

  void _handleManualFeeding(bool isStarting) async {
    final vm = ref.read(autoFeedViewModelProvider(_cameraUrl));
    if (!vm.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autofeed is offline. Please check TankPi connection.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isStarting) {
      ref
          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
          .startManual(widget.aquariumId);
    } else {
      ref
          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
          .stopManual(widget.aquariumId);
    }
  }

  void _confirmRotationFeeding() async {
    final vm = ref.read(autoFeedViewModelProvider(_cameraUrl));
    if (!vm.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to send rotation feeding command. Check connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(autoFeedViewModelProvider(_cameraUrl).notifier)
        .sendRotation(widget.aquariumId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dispensing ${vm.rotations} rotations of food to TankPi',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to send rotation feeding command. Check TankPi connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // keeps state alive with AutomaticKeepAliveClientMixin
    final vm = ref.watch(autoFeedViewModelProvider(_cameraUrl));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.aquariumName} - Auto Feed',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveHelper.getScreenPadding(context).left,
        ),
        child: Column(
          children: [
            // Camera Feed Container
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child:
                  isCameraActive
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // WebView for camera feed (persistent controller)
                            webview.WebViewWidget(
                              controller: _webViewController,
                            ),

                            // Loading indicator overlay
                            if (_isWebViewLoading)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.blue[50],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.blue[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Connection status overlay
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      vm.isConnected
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        vm.isConnected
                                            ? Colors.green[300]!
                                            : Colors.orange[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      vm.isConnected
                                          ? Icons.wifi
                                          : Icons.wifi_off,
                                      size: 12,
                                      color:
                                          vm.isConnected
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      vm.isConnected
                                          ? 'Aquacare Feeder: ON'
                                          : 'Aquacare Feeder: OFF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            vm.isConnected
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Camera toggle switch
                            Positioned(
                              top: 8,
                              left: 8,
                              child: CupertinoSwitch(
                                value: isCameraActive,
                                onChanged: (value) async {
                                  setState(() {
                                    isCameraActive = value;
                                    _isWebViewLoading = value;
                                  });

                                  await ref
                                      .read(
                                        autoFeedViewModelProvider(
                                          _cameraUrl,
                                        ).notifier,
                                      )
                                      .toggleCamera(widget.aquariumId, value);

                                  if (value) {
                                    _webViewController.clearCache();
                                    _loadStream();
                                  } else {
                                    _webViewController.loadHtmlString(
                                      '<html><body style="background:#f4f4f4;display:flex;justify-content:center;align-items:center;height:100%;color:#999;"><h3>Camera is turned off</h3></body></html>',
                                    );
                                  }
                                },
                                activeColor: Colors.greenAccent,
                                trackColor: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                      )
                      : const Center(
                        child: Text(
                          'Camera Offline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 32),

            // Mode Switch Container
            Container(
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
                    value: vm.isManualMode,
                    onChanged:
                        (value) => ref
                            .read(
                              autoFeedViewModelProvider(_cameraUrl).notifier,
                            )
                            .setManualMode(value),
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
            ),
            const SizedBox(height: 24),

            // Feeding Controls Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child:
                  vm.isManualMode
                      ? _buildManualFeeding(vm)
                      : _buildRotationFeeding(vm),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFeeding(AutoFeedState vm) {
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
            Container(
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
                      color:
                          vm.food == 'pellet'
                              ? Colors.blue[800]
                              : Colors.blue[400],
                      fontWeight:
                          vm.food == 'pellet'
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: vm.food == 'flakes',
                    onChanged: (value) {
                      ref
                          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
                          .setFood(value ? 'flakes' : 'pellet');
                    },
                    activeColor: Colors.blue[600],
                    trackColor: Colors.blue[200],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Flakes',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                      color:
                          vm.food == 'flakes'
                              ? Colors.blue[800]
                              : Colors.blue[400],
                      fontWeight:
                          vm.food == 'flakes'
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
        GestureDetector(
          onTapDown: (_) => _handleManualFeeding(true),
          onTapUp: (_) => _handleManualFeeding(false),
          onTapCancel: () => _handleManualFeeding(false),
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
              vm.isFeeding ? Icons.pause : Icons.play_arrow,
              size: ResponsiveHelper.getFontSize(context, 48),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRotationFeeding(AutoFeedState vm) {
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
            Container(
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
                      color:
                          vm.food == 'pellet'
                              ? Colors.blue[800]
                              : Colors.blue[400],
                      fontWeight:
                          vm.food == 'pellet'
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CupertinoSwitch(
                    value: vm.food == 'flakes',
                    onChanged: (value) {
                      ref
                          .read(autoFeedViewModelProvider(_cameraUrl).notifier)
                          .setFood(value ? 'flakes' : 'pellet');
                    },
                    activeColor: Colors.blue[600],
                    trackColor: Colors.blue[200],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Flakes',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 13),
                      color:
                          vm.food == 'flakes'
                              ? Colors.blue[800]
                              : Colors.blue[400],
                      fontWeight:
                          vm.food == 'flakes'
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
        Container(
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
                          if (vm.rotations > 1) {
                            ref
                                .read(
                                  autoFeedViewModelProvider(
                                    _cameraUrl,
                                  ).notifier,
                                )
                                .setRotations(vm.rotations - 1);
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
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: CupertinoPicker(
                          itemExtent: 35,
                          onSelectedItemChanged:
                              (index) => ref
                                  .read(
                                    autoFeedViewModelProvider(
                                      _cameraUrl,
                                    ).notifier,
                                  )
                                  .setRotations(index + 1),
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
                          if (vm.rotations < 10) {
                            ref
                                .read(
                                  autoFeedViewModelProvider(
                                    _cameraUrl,
                                  ).notifier,
                                )
                                .setRotations(vm.rotations + 1);
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
                'Selected: ${vm.rotations} rotation${vm.rotations > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showRotationConfirmation(),
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
        ),
      ],
    );
  }

  void _showRotationConfirmation() {
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
            'Are you sure you want to dispense ${ref.read(autoFeedViewModelProvider(_cameraUrl)).rotations} rotations of food to ${widget.aquariumName}?',
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
                _confirmRotationFeeding();
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
}
