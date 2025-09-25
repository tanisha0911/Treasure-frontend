import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/qr_code_widget.dart';
import '../widgets/universal_qr_scanner.dart';
import '../services/api_service.dart';

class ParticipantDashboardScreen extends StatefulWidget {
  final String token;

  const ParticipantDashboardScreen({
    super.key,
    required this.token,
  });

  @override
  State<ParticipantDashboardScreen> createState() =>
      _ParticipantDashboardScreenState();
}

class _ParticipantDashboardScreenState
    extends State<ParticipantDashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _participantData;
  List<Map<String, dynamic>> _availableEvents = [];
  Map<String, dynamic>? _currentEvent;
  Map<String, dynamic>? _teamData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipantData();
  }

  Future<void> _loadParticipantData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // Load participant dashboard data from API
      final response = await apiService.getParticipantDashboard(widget.token);

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _participantData = data['participant'];
          _currentEvent = data['currentEvent'];
          _teamData = data['team'];
          _availableEvents =
              List<Map<String, dynamic>>.from(data['availableEvents'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(
            response['message'] ?? 'Failed to load participant data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Hunt'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Participant',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Token: ${widget.token}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Progress',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your data...'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildEventsTab();
      case 1:
        return _buildScannerTab();
      case 2:
        return _buildProgressTab();
      default:
        return _buildEventsTab();
    }
  }

  Widget _buildEventsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_currentEvent != null) ...[
            // Current Event Card
            Card(
              color: AppTheme.accentColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle,
                          color: AppTheme.accentColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Currently Playing',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _currentEvent!['name'],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentEvent!['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openEventDetails(_currentEvent!),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Join New Events',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _availableEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events available',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Check back later for new treasure hunts!'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _availableEvents.length,
                    itemBuilder: (context, index) {
                      final event = _availableEvents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getEventStatusColor(event['status']),
                            child: Icon(
                              _getEventStatusIcon(event['status']),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(event['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event['description']),
                              const SizedBox(height: 4),
                              Text(
                                '${event['participantsCount']} participants',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: event['status'] == 'active'
                              ? ElevatedButton(
                                  onPressed: () => _joinEvent(event),
                                  child: const Text('Join'),
                                )
                              : Chip(
                                  label: Text(event['status'].toUpperCase()),
                                  backgroundColor:
                                      _getEventStatusColor(event['status']),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'QR Scanner',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_currentEvent == null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Event',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Join an event first to start scanning QR codes'),
                  ],
                ),
              ),
            ),
          ] else ...[
            UniversalQRScanner(
              title: 'Scan Location QR Code',
              onScanSuccess: _handleQRScan,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Participant Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.accentColor,
                        radius: 30,
                        child: Text(
                          widget.token[0],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participant ${widget.token}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Token: ${widget.token}',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QRCodeWidget(
                    data: widget.token,
                    title: 'Your Participant QR Code',
                    subtitle: 'Show this to event coordinators',
                    size: 120,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_currentEvent != null && _teamData != null) ...[
            // Team Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.groups, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text(
                          _teamData!['name'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${_teamData!['score']} pts'),
                          backgroundColor: AppTheme.accentColor,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Team members
                    Text(
                      'Team Members:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...(_teamData!['members'] as List).map(
                      (member) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(member.toString()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Next Clue:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_teamData!['hint']}',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_teamData!['completedLocations'].isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Completed Locations:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...(_teamData!['completedLocations'] as List).map(
                        (location) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: AppTheme.successColor),
                              const SizedBox(width: 8),
                              Text(location.toString()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Not in a Team',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Join an event to be assigned to a team'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getEventStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.infoColor;
      case 'upcoming':
        return AppTheme.warningColor;
      default:
        return AppTheme.textMuted;
    }
  }

  IconData _getEventStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      case 'upcoming':
        return Icons.schedule;
      default:
        return Icons.event;
    }
  }

  void _joinEvent(Map<String, dynamic> event) async {
    try {
      final apiService = ApiService();
      final response = await apiService.joinEvent(widget.token, event['id']);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${event['name']}!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Reload participant data to get updated state
        _loadParticipantData();
      } else {
        throw Exception(response['message'] ?? 'Failed to join event');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join event: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _openEventDetails(Map<String, dynamic> event) {
    // TODO: Navigate to event details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['name']),
        content: Text(event['description']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleQRScan(String data) async {
    if (_teamData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ No active team found'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final apiService = ApiService();
      final response = await apiService.scanQRCode(widget.token, data);

      if (response['success'] == true) {
        final scanData = response['data'];
        final result = scanData['result'];
        final message = scanData['message'];
        final completed = scanData['completed'] ?? false;

        // Update local team data with response
        if (scanData['newScore'] != null) {
          _teamData!['score'] = scanData['newScore'];
        }

        if (scanData['nextLocation'] != null) {
          final nextLocation = scanData['nextLocation'];
          _teamData!['currentLocationCode'] = nextLocation['code'];
          _teamData!['hint'] = nextLocation['hint'];
        }

        if (completed) {
          _teamData!['currentLocationCode'] = 'COMPLETED';
          _teamData!['hint'] =
              'Congratulations! Your team has completed the hunt!';
        }

        // Show appropriate message based on result
        Color backgroundColor;
        IconData icon;

        switch (result) {
          case 'correct':
            backgroundColor = AppTheme.successColor;
            icon = Icons.check_circle;
            break;
          case 'completed':
            backgroundColor = AppTheme.successColor;
            icon = Icons.emoji_events;
            break;
          case 'wrong':
          default:
            backgroundColor = AppTheme.errorColor;
            icon = Icons.error;
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh data to get updated state
        _loadParticipantData();

        // Auto-switch to progress tab to show updated score
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _currentIndex = 2);
          }
        });
      } else {
        throw Exception(response['message'] ?? 'Scan failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Scan failed: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
