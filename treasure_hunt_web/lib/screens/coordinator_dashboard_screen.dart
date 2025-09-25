import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/qr_code_widget.dart';
import '../providers/auth_provider.dart';
import '../models/participant.dart';

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends State<CoordinatorDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedEvents = [];
  Map<String, dynamic>? _selectedEvent;
  Location? _assignedLocation;

  @override
  void initState() {
    super.initState();
    _loadCoordinatorData();
  }

  Future<void> _loadCoordinatorData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final coordinatorId = authProvider.user?.id ?? '2';

      setState(() {
        _assignedEvents = [
          {
            'id': '1',
            'name': 'Campus Treasure Hunt',
            'status': 'active',
            'description': 'Explore the campus and find hidden treasures!',
            'participantsCount': 25,
            'coordinatorId': coordinatorId,
            'assignedLocation': {
              'id': 'loc_1',
              'name': 'Library Entrance',
              'hint': 'Where knowledge begins, look for the golden statue',
              'qrCode': 'LOCATION_${DateTime.now().millisecondsSinceEpoch}',
            }
          },
          {
            'id': '2',
            'name': 'City Adventure',
            'status': 'upcoming',
            'description': 'Discover historical landmarks around the city',
            'participantsCount': 12,
            'coordinatorId': coordinatorId,
            'assignedLocation': {
              'id': 'loc_2',
              'name': 'City Hall Steps',
              'hint': 'Where decisions are made, count the columns',
              'qrCode':
                  'LOCATION_${DateTime.now().millisecondsSinceEpoch + 1000}',
            }
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Dashboard'),
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
                    Text(
                      authProvider.user?.name ?? 'Coordinator',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Coordinator',
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
                    Icons.person_outline,
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
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your assigned events...'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedEvent != null) {
      return _buildLocationQRView();
    } else {
      return _buildEventsList();
    }
  }

  Widget _buildEventsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Assigned Events',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on an event to view your location QR code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _assignedEvents.isEmpty
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
                          'No Events Assigned',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'Contact an admin to get assigned to events'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _assignedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _assignedEvents[index];
                      final location = event['assignedLocation'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _selectEvent(event),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _getEventStatusColor(
                                                event['status'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getEventStatusIcon(event['status']),
                                        color: _getEventStatusColor(
                                            event['status']),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['name'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            event['description'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppTheme.textMuted,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.infoColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AppTheme.infoColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppTheme.infoColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your Assigned Location',
                                              style: TextStyle(
                                                color: AppTheme.infoColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              location['name'],
                                              style: TextStyle(
                                                color: AppTheme.infoColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Hint: ${location['hint']}',
                                              style: TextStyle(
                                                color: AppTheme.infoColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      label: Text(event['status']
                                          .toString()
                                          .toUpperCase()),
                                      backgroundColor:
                                          _getEventStatusColor(event['status']),
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${event['participantsCount']} participants',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildLocationQRView() {
    final location = _selectedEvent!['assignedLocation'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and header
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedEvent = null),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEvent!['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Location: ${location['name']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Location QR Code
                  QRCodeWidget(
                    data: location['qrCode'],
                    title: 'Location QR Code',
                    subtitle:
                        'Show this QR code to participants when they reach your location',
                    size: 200,
                  ),
                  const SizedBox(height: 32),

                  // Location details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Location Name', location['name']),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              'Hint for Participants', location['hint']),
                          const SizedBox(height: 12),
                          _buildDetailRow('QR Code Data', location['qrCode']),
                          const SizedBox(height: 20),
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
                                  Icons.info_outline,
                                  color: AppTheme.warningColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'When participants scan this QR code, their progress will be recorded automatically.',
                                    style: TextStyle(
                                      color: AppTheme.warningColor,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

  void _selectEvent(Map<String, dynamic> event) {
    setState(() {
      _selectedEvent = event;
    });
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
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
