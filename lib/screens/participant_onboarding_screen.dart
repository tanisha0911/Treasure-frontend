import 'package:flutter/material.dart';
import 'dart:math';
import '../config/theme.dart';
import '../widgets/qr_code_widget.dart';
import 'participant_dashboard_screen.dart';

class ParticipantOnboardingScreen extends StatefulWidget {
  const ParticipantOnboardingScreen({super.key});

  @override
  State<ParticipantOnboardingScreen> createState() =>
      _ParticipantOnboardingScreenState();
}

class _ParticipantOnboardingScreenState
    extends State<ParticipantOnboardingScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _hasExistingToken = false;
  String? _generatedToken;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Access'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Join the Hunt!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Do you already have a participant token?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Token Status Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Existing Token Option
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _hasExistingToken,
                        onChanged: (value) =>
                            setState(() => _hasExistingToken = value!),
                        title: const Text('I have an existing token'),
                        subtitle:
                            const Text('Enter your 5-digit participant token'),
                        activeColor: AppTheme.accentColor,
                      ),

                      // New Token Option
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _hasExistingToken,
                        onChanged: (value) =>
                            setState(() => _hasExistingToken = value!),
                        title: const Text('I need a new token'),
                        subtitle:
                            const Text('Generate a new participant token'),
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Content based on selection
              if (_hasExistingToken) _buildExistingTokenSection(),
              if (!_hasExistingToken) _buildNewTokenSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingTokenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Your Token',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Participant Token',
                hintText: '12345',
                prefixIcon: Icon(Icons.key),
                helperText: 'Enter your 5-digit token',
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _tokenController.text.length == 5
                  ? _verifyExistingToken
                  : null,
              icon: const Icon(Icons.login),
              label: const Text('Access Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your token was provided when you first joined or generated earlier. If you can\'t find it, generate a new one.',
                      style: TextStyle(
                        color: AppTheme.infoColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTokenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate New Token',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_generatedToken == null) ...[
              Text(
                'We\'ll create a unique 5-digit token for you. Make sure to save it!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateNewToken,
                icon: const Icon(Icons.generating_tokens),
                label: const Text('Generate My Token'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ] else ...[
              // Show generated token
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Token',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _generatedToken!,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                  letterSpacing: 4,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR Code for token
              QRCodeWidget(
                data: _generatedToken!,
                title: 'Your Token QR Code',
                subtitle: 'Take a screenshot and save this token safely',
                size: 150,
              ),
              const SizedBox(height: 24),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Important: Take a screenshot of this token! You\'ll need it to access your account later.',
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _proceedToDashboard,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue to Dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.successColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _generateNewToken() {
    // Generate a 5-digit token
    final random = Random();
    final token = (10000 + random.nextInt(90000)).toString();

    setState(() {
      _generatedToken = token;
    });

    // Here you would call the backend API to register the token
    _registerTokenWithBackend(token);
  }

  void _registerTokenWithBackend(String token) {
    // TODO: Make API call to register the token
    print('Registering token with backend: $token');
  }

  void _verifyExistingToken() {
    final token = _tokenController.text;
    if (token.length == 5) {
      // TODO: Verify token with backend
      _proceedToDashboard(token: token);
    }
  }

  void _proceedToDashboard({String? token}) {
    final participantToken = token ?? _generatedToken!;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ParticipantDashboardScreen(token: participantToken),
      ),
    );
  }
}
