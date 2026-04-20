import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onScanResult;
  final String? title;
  final String? subtitle;
  final bool showFlashToggle;
  final bool showCameraToggle;

  const QRScannerWidget({
    super.key,
    required this.onScanResult,
    this.title,
    this.subtitle,
    this.showFlashToggle = true,
    this.showCameraToggle = true,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });
        widget.onScanResult(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'QR Scanner'),
        backgroundColor: Colors.black,
        actions: [
          if (widget.showFlashToggle)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              onPressed: () => cameraController.toggleTorch(),
            ),
          if (widget.showCameraToggle)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              onPressed: () => cameraController.switchCamera(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.subtitle != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                // Simple scanning overlay
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Position the QR code within the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isScanning = true;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan Again'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple QR Scanner Dialog
class QRScannerDialog extends StatelessWidget {
  final Function(String) onScanResult;
  final String? title;
  final String? subtitle;

  const QRScannerDialog({
    super.key,
    required this.onScanResult,
    this.title,
    this.subtitle,
  });

  static Future<String?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    String? result;
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QRScannerDialog(
        title: title,
        subtitle: subtitle,
        onScanResult: (code) {
          result = code;
          Navigator.pop(context, code);
        },
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: QRScannerWidget(
        title: title ?? 'Scan QR Code',
        subtitle: subtitle,
        onScanResult: onScanResult,
      ),
    );
  }
}

// Mock QR Scanner for web/testing
class MockQRScanner extends StatefulWidget {
  final Function(String) onScanResult;
  final String? title;
  final String? subtitle;

  const MockQRScanner({
    super.key,
    required this.onScanResult,
    this.title,
    this.subtitle,
  });

  @override
  State<MockQRScanner> createState() => _MockQRScannerState();
}

class _MockQRScannerState extends State<MockQRScanner> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'QR Scanner (Mock)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Mock QR Scanner for Web Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter a QR code value manually:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter QR code value (e.g., 12345)',
                labelText: 'QR Code Value',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Quick test buttons
                ElevatedButton(
                  onPressed: () => widget.onScanResult('12345'),
                  child: const Text('Test: 12345'),
                ),
                ElevatedButton(
                  onPressed: () => widget.onScanResult('54321'),
                  child: const Text('Test: 54321'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onScanResult(_controller.text);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
