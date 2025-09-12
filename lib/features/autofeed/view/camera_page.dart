import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/core/navigation/route_observer.dart';
import 'package:aquacare_v5/core/services/websocket_service.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const CameraPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with RouteAware {
  bool isManualMode = false;
  int selectedRotations = 3;
  bool isFeeding = false;
  bool isCameraActive = true;
  final WebSocketService _webSocketService = WebSocketService.instance;
  final String _backendUrl =
      'https://aquacare.alfreds.dev'; // Production backend base URL

  late final webview.WebViewController _webViewController;
  bool _isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _initializeCamera();
    _toggleCamera(true); // Turn camera ON when page opens
    debugPrint(
      '[CameraPage] initState: entering page for aquariumId=${widget.aquariumId}',
    );
  }

  @override
  void dispose() {
    debugPrint(
      '[CameraPage] dispose: leaving page for aquariumId=${widget.aquariumId}',
    );
    _toggleCamera(false);
    _webSocketService.disconnect();
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe to route observer
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    debugPrint('[CameraPage] didPush: became visible');
    _toggleCamera(true);
  }

  @override
  void didPop() {
    debugPrint('[CameraPage] didPop: popped and now hidden');
    _toggleCamera(false);
  }

  @override
  void didPushNext() {
    debugPrint('[CameraPage] didPushNext: another page covered this one');
    _toggleCamera(false);
  }

  @override
  void didPopNext() {
    debugPrint('[CameraPage] didPopNext: returned to this page');
    _toggleCamera(true);
  }

  Future<void> _toggleCamera(bool switchOn) async {
    try {
      final url = Uri.parse(
        "$_backendUrl/aquarium/${widget.aquariumId}/camera_switch/$switchOn",
      );
      await http.post(url);
    } catch (e) {
      debugPrint("Error toggling camera: $e");
    }
  }

  void _initializeWebView() {
    _webViewController =
        webview.WebViewController()
          ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            webview.NavigationDelegate(
              onPageFinished: (String url) {
                _webViewController.runJavaScript('''
            var video = document.querySelector("img, video");
            if (video) {
              video.style.width = "50%";
              video.style.height = "50%";
              video.style.objectFit = "cover"; // fills container
            }
            document.body.style.margin = "0";
            document.body.style.padding = "0";
            document.documentElement.style.overflow = "hidden";
          ''');
                setState(() {
                  _isWebViewLoading = false;
                });
              },
              onWebResourceError: (webview.WebResourceError error) {
                print('WebView error: ${error.description}');
                setState(() {
                  _isWebViewLoading = false;
                });
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              'https://aquacare.alfreds.dev/aquarium/${widget.aquariumId}/video_feed',
            ),
          );
  }

  void _initializeCamera() async {
    // Connect to TankPi WebSocket
    final connected = await _webSocketService.connectToFeeder(
      widget.aquariumId,
      _backendUrl,
    );

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to connect to TankPi feeder. Please check your network connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _closeCamera() {
    setState(() => isCameraActive = false);
    _toggleCamera(false); // Turn camera OFF
    _webSocketService.disconnect();
  }

  void _startFeeding() {
    setState(() => isFeeding = true);
    _triggerManualFeeding();
  }

  void _stopFeeding() {
    setState(() => isFeeding = false);
    _stopManualFeeding();
  }

  void _triggerManualFeeding() async {
    final success = await _webSocketService.startManualFeeding();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to start manual feeding. Check TankPi connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopManualFeeding() async {
    final success = await _webSocketService.stopManualFeeding();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to stop manual feeding. Check TankPi connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmRotationFeeding() async {
    final success = await _webSocketService.sendRotationFeeding(
      selectedRotations,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dispensing $selectedRotations rotations of food to TankPi',
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
        // Removed close action; rely on navigation back behavior to close camera
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
                            // WebView for camera feed
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
                                      const SizedBox(height: 16),
                                      Text(
                                        'Loading Camera Feed...',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getFontSize(
                                                context,
                                                16,
                                              ),
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                      _webSocketService.isConnected
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _webSocketService.isConnected
                                            ? Colors.green[300]!
                                            : Colors.orange[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _webSocketService.isConnected
                                          ? Icons.wifi
                                          : Icons.wifi_off,
                                      size: 12,
                                      color:
                                          _webSocketService.isConnected
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _webSocketService.isConnected
                                          ? 'Aquacare Feeder: ON'
                                          : 'Aquacare Feeder: OFF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            _webSocketService.isConnected
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
                    value: isManualMode,
                    onChanged: (value) => setState(() => isManualMode = value),
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
                  isManualMode
                      ? _buildManualFeeding()
                      : _buildRotationFeeding(),
            ),

            // Bottom padding for safe area
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFeeding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manual Feeding',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Press and hold to feed manually',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200, // Fixed height instead of Expanded
          child: Center(
            child: GestureDetector(
              onTapDown: (_) => _startFeeding(),
              onTapUp: (_) => _stopFeeding(),
              onTapCancel: () => _stopFeeding(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: ResponsiveHelper.getCardWidth(context),
                height: ResponsiveHelper.getCardHeight(context),
                decoration: BoxDecoration(
                  color: isFeeding ? Colors.blue[400] : Colors.blue[600],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: isFeeding ? 10 : 5,
                    ),
                  ],
                ),
                child: Icon(
                  isFeeding ? Icons.pause : Icons.play_arrow,
                  size: ResponsiveHelper.getFontSize(context, 48),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRotationFeeding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rotation Feeding',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Select number of rotations and confirm',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 24),
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
                      // Down arrow
                      IconButton(
                        onPressed: () {
                          if (selectedRotations > 1) {
                            setState(() => selectedRotations--);
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.blue[600],
                          size: 30,
                        ),
                      ),
                      // Picker
                      Container(
                        width: _getPickerWidth(context),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: CupertinoPicker(
                          itemExtent: 40,
                          onSelectedItemChanged:
                              (index) =>
                                  setState(() => selectedRotations = index + 1),
                          children: List.generate(
                            10,
                            (index) => Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(
                                    context,
                                    18,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Up arrow
                      IconButton(
                        onPressed: () {
                          if (selectedRotations < 10) {
                            setState(() => selectedRotations++);
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.blue[600],
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selected: $selectedRotations rotation${selectedRotations > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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

  // Helper method to get responsive picker width
  double _getPickerWidth(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return 100; // Smaller for mobile
    } else if (ResponsiveHelper.isTablet(context)) {
      return 120; // Medium for tablet
    } else {
      return 140; // Larger for desktop
    }
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
            'Are you sure you want to dispense $selectedRotations rotations of food to ${widget.aquariumName}?',
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
