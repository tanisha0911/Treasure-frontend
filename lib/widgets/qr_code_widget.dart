import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme.dart';

class QRCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final String? title;
  final String? subtitle;
  final bool showCopyButton;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = 200.0,
    this.title,
    this.subtitle,
    this.showCopyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // QR Code with white foreground on dark background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.qrBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF404040),
                    width: 1,
                  ),
                ),
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: size,
                  backgroundColor: AppTheme.qrBackground,
                  foregroundColor: AppTheme.qrForeground,
                  padding: const EdgeInsets.all(8),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),

              const SizedBox(height: 16),

              // Data display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF404040),
                    width: 1,
                  ),
                ),
                child: Text(
                  data,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: AppTheme.accentColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (showCopyButton) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context, data),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareQRCode(context, data),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Note: In web, we'd use web APIs or a plugin like flutter/services
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _shareQRCode(BuildContext context, String text) {
    // Note: In web, we'd use the Web Share API or fallback to copy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $text'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final Function(String) onScanSuccess;
  final String? title;

  const QRScannerWidget({
    super.key,
    required this.onScanSuccess,
    this.title,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Camera scanner placeholder (web implementation needed)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF404040),
                  width: 2,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'QR Scanner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Camera scanner will be implemented here\nfor web using getUserMedia API',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Manual input section
            Text(
              'Or enter code manually:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualInputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter QR code data',
                      prefixIcon: Icon(Icons.edit),
                    ),
                    onSubmitted: _handleManualInput,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _handleManualInput,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleManualInput([String? value]) {
    final input = value ?? _manualInputController.text.trim();
    if (input.isNotEmpty) {
      widget.onScanSuccess(input);
      _manualInputController.clear();
    }
  }
}
