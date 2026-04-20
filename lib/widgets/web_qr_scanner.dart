import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class WebQRScanner extends StatefulWidget {
  final Function(String) onScanResult;
  final String? title;
  final String? subtitle;

  const WebQRScanner({
    super.key,
    required this.onScanResult,
    this.title,
    this.subtitle,
  });

  @override
  State<WebQRScanner> createState() => _WebQRScannerState();
}

class _WebQRScannerState extends State<WebQRScanner> {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  bool _isScanning = false;
  bool _cameraStarted = false;
  String? _error;
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopCamera();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Create video element
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '300px'
        ..style.objectFit = 'cover';

      // Request camera access
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'environment'} // Prefer back camera
      });

      _videoElement!.srcObject = stream;

      // Create canvas for QR scanning
      _canvasElement = html.CanvasElement(width: 400, height: 300);

      setState(() {
        _cameraStarted = true;
        _error = null;
      });

      // Start scanning after camera is ready
      _startScanning();
    } catch (e) {
      setState(() {
        _error = 'Camera access denied or unavailable: $e';
        _cameraStarted = false;
      });
    }
  }

  void _startScanning() {
    if (!_cameraStarted || _isScanning) return;

    setState(() {
      _isScanning = true;
    });

    // Inject QR scanning library
    _injectQRScanningScript();
  }

  void _injectQRScanningScript() {
    // Add QR code scanning using jsQR library
    js.context.callMethod('eval', [
      '''
      if (typeof window.jsQR === 'undefined') {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js';
        script.onload = function() {
          window.startQRScanning();
        };
        document.head.appendChild(script);
      } else {
        window.startQRScanning();
      }
      
      window.startQRScanning = function() {
        const video = document.querySelector('video');
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        
        function scanQR() {
          if (video && video.readyState === video.HAVE_ENOUGH_DATA) {
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
            const code = jsQR(imageData.data, imageData.width, imageData.height);
            
            if (code) {
              window.onQRCodeDetected(code.data);
              return;
            }
          }
          requestAnimationFrame(scanQR);
        }
        
        scanQR();
      };
      
      window.onQRCodeDetected = function(data) {
        console.log('QR Code detected:', data);
        window.flutter_qr_result = data;
      };
    '''
    ]);

    // Check for QR results periodically
    _checkForQRResults();
  }

  void _checkForQRResults() {
    if (!_isScanning) return;

    final result = js.context['flutter_qr_result'];
    if (result != null) {
      js.context['flutter_qr_result'] = null; // Clear the result
      setState(() {
        _isScanning = false;
      });
      widget.onScanResult(result.toString());
      return;
    }

    // Check again after 500ms
    Future.delayed(const Duration(milliseconds: 500), _checkForQRResults);
  }

  void _stopCamera() {
    if (_videoElement?.srcObject != null) {
      final tracks = (_videoElement!.srcObject as html.MediaStream).getTracks();
      for (final track in tracks) {
        track.stop();
      }
    }
    setState(() {
      _isScanning = false;
      _cameraStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
            onPressed: _isScanning ? _stopScanning : _startScanning,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Camera view
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildCameraView(),
                  ),
                  const SizedBox(height: 20),

                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isScanning
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.visibility : Icons.visibility_off,
                          color: _isScanning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isScanning
                              ? 'Scanning for QR codes...'
                              : 'Camera stopped',
                          style: TextStyle(
                            color: _isScanning ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Manual input section
                  const Text(
                    'Or enter QR code manually:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter QR code data',
                            labelText: 'QR Code',
                          ),
                          onSubmitted: (_) => _handleManualInput(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _handleManualInput,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Test buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry Camera'),
            ),
          ],
        ),
      );
    }

    if (!_cameraStarted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting camera...'),
          ],
        ),
      );
    }

    // Return a placeholder that will be replaced by the video element
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: const Center(
            child: Text(
              'Camera View\n(Video element will be inserted here)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        if (_isScanning)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  void _handleManualInput() {
    if (_manualController.text.trim().isNotEmpty) {
      widget.onScanResult(_manualController.text.trim());
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }
}
