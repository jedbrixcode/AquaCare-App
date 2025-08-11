import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

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

class _CameraPageState extends State<CameraPage> {
  bool isManualMode = false;
  int selectedRotations = 3;
  bool isFeeding = false;
  bool isCameraActive = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {}
  void _closeCamera() {
    setState(() => isCameraActive = false);
  }

  void _startFeeding() => setState(() => isFeeding = true);
  void _stopFeeding() => setState(() => isFeeding = false);
  void _confirmRotationFeeding() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dispensing $selectedRotations rotations of food'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.aquariumName} - Automatic Feeder',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _closeCamera();
              Navigator.of(context).pop();
            },
            tooltip: 'Close Camera',
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(
                ResponsiveHelper.getScreenPadding(context).left,
              ),
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child:
                  isCameraActive
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: ResponsiveHelper.getFontSize(context, 48),
                            color: Colors.blue[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera Feed',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aquarium ${widget.aquariumId}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                14,
                              ),
                              color: Colors.blue[500],
                            ),
                          ),
                        ],
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
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getScreenPadding(context).left,
              ),
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
            Expanded(
              child: Container(
                margin: EdgeInsets.all(
                  ResponsiveHelper.getScreenPadding(context).left,
                ),
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
            ),
            SizedBox(height: ResponsiveHelper.getScreenPadding(context).bottom),
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
        Expanded(
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
          child: Row(
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
              SizedBox(
                width: ResponsiveHelper.getCardWidth(context),
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged:
                      (index) => setState(() => selectedRotations = index + 1),
                  children: List.generate(
                    10,
                    (index) => Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
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
