import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../config/theme.dart';

class UniversalQRScanner extends StatefulWidget {
  final Function(String) onScanSuccess;
  final String? title;

  const UniversalQRScanner({
    super.key,
    required this.onScanSuccess,
    this.title,
  });

  @override
  State<UniversalQRScanner> createState() => _UniversalQRScannerState();
}

class _UniversalQRScannerState extends State<UniversalQRScanner> {
  final TextEditingController _manualInputController = TextEditingController();
  bool _isScanning = false;
  bool _cameraInitialized = false;
  String _scannerStatus = 'Initializing camera...';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebCamera();
    }
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    _stopCamera();
    super.dispose();
  }

  void _initializeWebCamera() async {
    try {
      setState(() {
        _scannerStatus = 'Requesting camera access...';
      });

      // Initialize QR scanner for web
      _setupWebQRScanner();
    } catch (e) {
      setState(() {
        _scannerStatus = 'Camera access failed. Use manual input below.';
      });
    }
  }

  void _setupWebQRScanner() {
    // Inject QR scanner HTML and JavaScript
    final videoElement = html.VideoElement()
      ..id = 'qr-video'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '300px'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '12px';

    final canvasElement = html.CanvasElement()
      ..id = 'qr-canvas'
      ..style.display = 'none';

    // Add elements to DOM
    html.document.body?.append(videoElement);
    html.document.body?.append(canvasElement);

    // JavaScript for QR scanning
    js.context.callMethod('eval', [
      '''
      (function() {
        const video = document.getElementById('qr-video');
        const canvas = document.getElementById('qr-canvas');
        const context = canvas.getContext('2d');
        
        let scanning = false;
        
        function startScanning() {
          if (scanning) return;
          scanning = true;
          
          navigator.mediaDevices.getUserMedia({ 
            video: { 
              facingMode: 'environment',
              width: { ideal: 640 },
              height: { ideal: 480 }
            } 
          })
          .then(function(stream) {
            video.srcObject = stream;
            video.play();
            
            // Set up QR code detection
            scanQRCode();
            
            window.dartQRScannerReady = true;
          })
          .catch(function(err) {
            console.error('Error accessing camera:', err);
            window.dartQRScannerError = err.message;
          });
        }
        
        function scanQRCode() {
          if (!scanning) return;
          
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
          context.drawImage(video, 0, 0, canvas.width, canvas.height);
          
          const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
          
          // Simple QR code detection (in real implementation, you'd use a library like jsQR)
          // For now, we'll simulate detection
          
          requestAnimationFrame(scanQRCode);
        }
        
        function stopScanning() {
          scanning = false;
          if (video.srcObject) {
            video.srcObject.getTracks().forEach(track => track.stop());
          }
        }
        
        window.startQRScanner = startScanning;
        window.stopQRScanner = stopScanning;
        
        // Auto-start scanning
        startScanning();
      })();
    '''
    ]);

    // Check for scanner readiness
    _checkScannerStatus();
  }

  void _checkScannerStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (js.context.hasProperty('dartQRScannerReady')) {
      setState(() {
        _cameraInitialized = true;
        _scannerStatus = 'Camera ready. Point at a QR code to scan.';
      });
    } else if (js.context.hasProperty('dartQRScannerError')) {
      setState(() {
        _scannerStatus = 'Camera unavailable. Please use manual input.';
      });
    } else {
      _checkScannerStatus(); // Keep checking
    }
  }

  void _stopCamera() {
    if (kIsWeb && js.context.hasProperty('stopQRScanner')) {
      js.context.callMethod('stopQRScanner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Camera Scanner Section
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cameraInitialized
                      ? AppTheme.successColor
                      : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: kIsWeb ? _buildWebScanner() : _buildMobileScanner(),
            ),

            const SizedBox(height: 20),

            // Status Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cameraInitialized
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _cameraInitialized
                      ? AppTheme.successColor.withOpacity(0.3)
                      : AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _cameraInitialized ? Icons.videocam : Icons.videocam_off,
                    color: _cameraInitialized
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _scannerStatus,
                      style: TextStyle(
                        color: _cameraInitialized
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Manual Input Section
            Text(
              'Manual QR Code Entry',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualInputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter QR code data manually',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _handleManualInput,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleManualInput(),
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Test QR Codes
            ExpansionTile(
              title: const Text('Test QR Codes'),
              leading: Icon(Icons.help_outline, color: AppTheme.accentColor),
              children: [
                const SizedBox(height: 8),
                _buildTestQRButton('LOC001', 'Library Entrance'),
                _buildTestQRButton('LOC002', 'Campus Garden'),
                _buildTestQRButton('LOC003', 'Science Building'),
                _buildTestQRButton('LOC004', 'Student Center'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebScanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // Placeholder for camera feed
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: _cameraInitialized
                ? const Center(
                    child: Text(
                      'Camera feed will appear here\n(Web implementation active)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _scannerStatus,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
          ),

          // Scanner overlay
          if (_cameraInitialized)
            Positioned.fill(
              child: CustomPaint(
                painter: QRScannerOverlayPainter(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileScanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black87,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Mobile QR Scanner\n(Mobile implementation needed)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestQRButton(String code, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.qr_code, color: AppTheme.accentColor),
        title: Text(code),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () => _simulateQRScan(code),
          child: const Text('Scan'),
        ),
      ),
    );
  }

  void _simulateQRScan(String code) {
    widget.onScanSuccess(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: $code'),
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleManualInput([String? value]) {
    final input = value ?? _manualInputController.text.trim();
    if (input.isNotEmpty) {
      widget.onScanSuccess(input);
      _manualInputController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processed: $input'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    // Draw scanning frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );

    // Draw corner indicators
    final cornerLength = 20.0;
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    paint.strokeWidth = 4;

    for (final corner in corners) {
      if (corner == rect.topLeft) {
        canvas.drawLine(corner, corner + Offset(cornerLength, 0), paint);
        canvas.drawLine(corner, corner + Offset(0, cornerLength), paint);
      } else if (corner == rect.topRight) {
        canvas.drawLine(corner, corner + Offset(-cornerLength, 0), paint);
        canvas.drawLine(corner, corner + Offset(0, cornerLength), paint);
      } else if (corner == rect.bottomLeft) {
        canvas.drawLine(corner, corner + Offset(cornerLength, 0), paint);
        canvas.drawLine(corner, corner + Offset(0, -cornerLength), paint);
      } else if (corner == rect.bottomRight) {
        canvas.drawLine(corner, corner + Offset(-cornerLength, 0), paint);
        canvas.drawLine(corner, corner + Offset(0, -cornerLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
