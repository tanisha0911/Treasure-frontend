import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/event.dart';
import '../widgets/qr_code_widget.dart' hide QRScannerWidget;
import '../widgets/qr_scanner_widget.dart' as scanner;
import '../widgets/web_qr_scanner.dart';

class AdminEventDetailScreen extends StatefulWidget {
  final Event event;

  const AdminEventDetailScreen({super.key, required this.event});

  @override
  State<AdminEventDetailScreen> createState() => _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState extends State<AdminEventDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late String _eventStatus; // Local variable to track event status

  // Mock data - replace with actual API calls
  List<Map<String, dynamic>> _eventAdmins = [];
  List<Map<String, dynamic>> _eventCoordinators = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _teams = [];
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _eventStatus = widget.event.status; // Initialize local status
    _loadEventData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _eventAdmins = [
          {
            'id': '1',
            'name': 'Admin User',
            'email': 'admin@treasurehunt.com',
            'role': 'admin',
          }
        ];

        _eventCoordinators = [
          {
            'id': '2',
            'name': 'Coordinator User',
            'email': 'coordinator@treasurehunt.com',
            'role': 'coordinator',
            'assignedLocationId': 'loc_1',
          }
        ];

        _locations = [
          {
            'id': 'loc_1',
            'name': 'Library Entrance',
            'hint': 'Where knowledge begins, look for the golden statue',
            'coordinatorEmail': 'coordinator@treasurehunt.com',
            'qrCode': 'LOCATION_${DateTime.now().millisecondsSinceEpoch}',
            'order': 1,
          },
          {
            'id': 'loc_2',
            'name': 'Campus Garden',
            'hint': 'Among the roses, find what glows',
            'coordinatorEmail': '',
            'qrCode':
                'LOCATION_${DateTime.now().millisecondsSinceEpoch + 1000}',
            'order': 2,
          },
        ];

        _teams = [
          {
            'id': 'team_1',
            'name': 'Team Alpha',
            'participants': [
              {'id': '12345', 'name': 'John Doe'},
              {'id': '67890', 'name': 'Jane Smith'},
            ],
            'currentLocation': 1,
            'score': 85,
            'completedAt': null,
          },
          {
            'id': 'team_2',
            'name': 'Team Beta',
            'participants': [
              {'id': '11111', 'name': 'Bob Wilson'},
              {'id': '22222', 'name': 'Alice Brown'},
            ],
            'currentLocation': 2,
            'score': 92,
            'completedAt': DateTime.now().subtract(const Duration(minutes: 15)),
          },
        ];

        _leaderboard = List.from(_teams)
          ..sort((a, b) {
            // Completed teams first, then by score
            if (a['completedAt'] != null && b['completedAt'] == null) return -1;
            if (a['completedAt'] == null && b['completedAt'] != null) return 1;
            return (b['score'] as int).compareTo(a['score'] as int);
          });

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          // Event Start/Stop Control
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _eventStatus == 'active' ? Icons.stop : Icons.play_arrow,
                  color: _eventStatus == 'active' ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _toggleEventStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _eventStatus == 'active' ? Colors.red : Colors.green,
                  ),
                  child: Text(
                    _eventStatus == 'active' ? 'Stop Event' : 'Start Event',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Staff'),
            Tab(text: 'Locations'),
            Tab(text: 'Teams'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Event Status Banner
                if (_eventStatus != 'active')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: _eventStatus == 'draft'
                        ? Colors.orange.shade100
                        : Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _eventStatus == 'draft'
                              ? Icons.edit
                              : Icons.check_circle,
                          color: _eventStatus == 'draft'
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _eventStatus == 'draft'
                              ? 'Event is in DRAFT mode - Locations hidden from participants'
                              : 'Event is COMPLETED - Treasure hunt has ended',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _eventStatus == 'draft'
                                ? Colors.orange.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStaffTab(),
                      _buildLocationsTab(),
                      _buildTeamsTab(),
                      _buildLeaderboardTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStaffTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Admins Section
          _buildStaffSection(
            'Event Admins',
            _eventAdmins,
            'admin',
            Icons.admin_panel_settings,
          ),
          const SizedBox(height: 24),

          // Coordinators Section
          _buildStaffSection(
            'Event Coordinators',
            _eventCoordinators,
            'coordinator',
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection(
    String title,
    List<Map<String, dynamic>> staff,
    String role,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(role),
                icon: const Icon(Icons.add),
                label: Text('Add ${role == 'admin' ? 'Admin' : 'Coordinator'}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: staff.isEmpty
                ? Center(
                    child: Text(
                      'No ${role}s assigned yet',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: staff.length,
                    itemBuilder: (context, index) {
                      final member = staff[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: role == 'admin'
                                ? AppTheme.errorColor
                                : AppTheme.accentColor,
                            child: Icon(
                              role == 'admin'
                                  ? Icons.admin_panel_settings
                                  : Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(member['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member['email']),
                              if (role == 'coordinator' &&
                                  member['assignedLocationId'] != null)
                                Text(
                                  'Assigned to location',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeStaffMember(role, index),
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

  Widget _buildLocationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Treasure Hunt Locations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Location'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All participants will have the same start and end points with randomized middle locations',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _locations.isEmpty
                ? const Center(child: Text('No locations added yet'))
                : ReorderableListView.builder(
                    itemCount: _locations.length,
                    onReorder: _reorderLocations,
                    itemBuilder: (context, index) {
                      final location = _locations[index];
                      return Card(
                        key: Key(location['id']),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.accentColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(location['name']),
                          subtitle: Text(
                            location['coordinatorEmail'].isEmpty
                                ? 'No coordinator assigned'
                                : 'Assigned to: ${location['coordinatorEmail']}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLocationDetail(
                                      'Hint', location['hint']),
                                  const SizedBox(height: 12),
                                  _buildLocationDetail(
                                      'QR Code', location['qrCode']),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _editLocation(location),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showLocationQR(location),
                                          icon: const Icon(Icons.qr_code),
                                          label: const Text('Show QR'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teams',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showScanParticipantQR,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan to Add Team'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _teams.isEmpty
                ? const Center(child: Text('No teams created yet'))
                : ListView.builder(
                    itemCount: _teams.length,
                    itemBuilder: (context, index) {
                      final team = _teams[index];
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: team['completedAt'] != null
                                ? AppTheme.successColor
                                : AppTheme.infoColor,
                            child: const Icon(Icons.group, color: Colors.white),
                          ),
                          title: Text(team['name']),
                          subtitle: Text(
                            'Score: ${team['score']} | ${team['completedAt'] != null ? 'Completed' : 'In Progress (Location ${team['currentLocation']})'}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Team Members:',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ...team['participants']
                                      .map<Widget>((participant) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person, size: 20),
                                          const SizedBox(width: 8),
                                          Text(participant['name']),
                                          const SizedBox(width: 16),
                                          Chip(
                                            label: Text(participant['id']),
                                            backgroundColor:
                                                AppTheme.accentColor,
                                            labelStyle: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _editTeam(team),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit Team'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _removeTeam(index),
                                          icon: const Icon(Icons.delete),
                                          label: const Text('Remove'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _leaderboard.isEmpty
                ? const Center(child: Text('No teams to display'))
                : ListView.builder(
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final team = _leaderboard[index];
                      final position = index + 1;
                      Color positionColor = AppTheme.textMuted;

                      if (position == 1)
                        positionColor = const Color(0xFFFFD700);
                      if (position == 2) positionColor = Colors.grey;
                      if (position == 3) positionColor = Colors.orange;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: positionColor,
                            child: Text(
                              '$position',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(team['name']),
                          subtitle: Text(
                            team['completedAt'] != null
                                ? 'Completed at ${_formatTime(team['completedAt'])}'
                                : 'In Progress',
                          ),
                          trailing: Chip(
                            label: Text(
                              '${team['score']} pts',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.accentColor,
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

  Widget _buildLocationDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _reorderLocations(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, item);
    });
  }

  void _showAddStaffDialog(String role) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${role == 'admin' ? 'Admin' : 'Coordinator'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _addStaffMember(role, emailController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog() {
    final nameController = TextEditingController();
    final hintController = TextEditingController();
    String selectedCoordinator = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hintController,
              decoration: const InputDecoration(labelText: 'Hint'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCoordinator.isEmpty ? null : selectedCoordinator,
              decoration:
                  const InputDecoration(labelText: 'Assign Coordinator'),
              items: [
                const DropdownMenuItem(
                    value: '', child: Text('No coordinator')),
                ..._eventCoordinators.map((coord) => DropdownMenuItem(
                      value: coord['email'],
                      child: Text(coord['email']),
                    )),
              ],
              onChanged: (value) => selectedCoordinator = value ?? '',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  hintController.text.isNotEmpty) {
                _addLocation(
                  nameController.text,
                  hintController.text,
                  selectedCoordinator,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showScanParticipantQR() {
    if (kIsWeb) {
      // Use web camera scanner for laptop camera
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebQRScanner(
            title: 'Scan Participant QR',
            subtitle: 'Scan a participant\'s QR code to create a team',
            onScanResult: _handleParticipantQRScan,
          ),
        ),
      );
    } else {
      // Use real scanner for mobile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => scanner.QRScannerWidget(
            title: 'Scan Participant QR',
            subtitle: 'Scan a participant\'s QR code to create a team',
            onScanResult: _handleParticipantQRScan,
          ),
        ),
      );
    }
  }

  void _handleParticipantQRScan(String qrCode) {
    Navigator.pop(context); // Close scanner

    // Parse QR code to get participant info
    // Expected format: PARTICIPANT_12345 or just 12345
    String participantId = qrCode;
    if (qrCode.startsWith('PARTICIPANT_')) {
      participantId = qrCode.substring(12);
    }

    _showCreateTeamDialog(participantId);
  }

  void _showCreateTeamDialog(String scannedParticipantId) {
    final teamNameController = TextEditingController();
    final participantIdController =
        TextEditingController(text: scannedParticipantId);
    final participantNameController = TextEditingController();
    List<Map<String, String>> teamMembers = [
      {'id': scannedParticipantId, 'name': ''}
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Team'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    hintText: 'Enter team name',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Team Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...teamMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller:
                                  TextEditingController(text: member['id']),
                              decoration: const InputDecoration(
                                labelText: 'Participant ID',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                teamMembers[index]['id'] = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller:
                                  TextEditingController(text: member['name']),
                              decoration: const InputDecoration(
                                labelText: 'Name (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                teamMembers[index]['name'] = value;
                              },
                            ),
                          ),
                          if (teamMembers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setDialogState(() {
                                  teamMembers.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      teamMembers.add({'id': '', 'name': ''});
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Team Member'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (teamNameController.text.isNotEmpty &&
                    teamMembers.any((member) => member['id']!.isNotEmpty)) {
                  _createTeam(teamNameController.text, teamMembers);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Team'),
            ),
          ],
        ),
      ),
    );
  }

  void _createTeam(String teamName, List<Map<String, String>> members) {
    setState(() {
      _teams.add({
        'id': 'team_${DateTime.now().millisecondsSinceEpoch}',
        'name': teamName,
        'participants': members
            .where((m) => m['id']!.isNotEmpty)
            .map((m) => {
                  'id': m['id']!,
                  'name': m['name']!.isNotEmpty
                      ? m['name']!
                      : 'Participant ${m['id']}',
                })
            .toList(),
        'currentLocation': 0,
        'score': 0,
        'completedAt': null,
      });

      // Update leaderboard
      _leaderboard = List.from(_teams)
        ..sort((a, b) {
          if (a['completedAt'] != null && b['completedAt'] == null) return -1;
          if (a['completedAt'] == null && b['completedAt'] != null) return 1;
          return (b['score'] as int).compareTo(a['score'] as int);
        });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Team "$teamName" created successfully!')),
    );
  }

  void _showLocationQR(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QRCodeWidget(
                data: location['qrCode'],
                title: location['name'],
                subtitle: 'Location QR Code',
                size: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addStaffMember(String role, String email) {
    setState(() {
      final newMember = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        'email': email,
        'role': role,
        if (role == 'coordinator') 'assignedLocationId': null,
      };

      if (role == 'admin') {
        _eventAdmins.add(newMember);
      } else {
        _eventCoordinators.add(newMember);
      }
    });
  }

  void _addLocation(String name, String hint, String coordinatorEmail) {
    setState(() {
      _locations.add({
        'id': 'loc_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'hint': hint,
        'coordinatorEmail': coordinatorEmail,
        'qrCode': 'LOCATION_${DateTime.now().millisecondsSinceEpoch}',
        'order': _locations.length + 1,
      });
    });
  }

  void _removeStaffMember(String role, int index) {
    setState(() {
      if (role == 'admin') {
        _eventAdmins.removeAt(index);
      } else {
        _eventCoordinators.removeAt(index);
      }
    });
  }

  void _toggleEventStatus() {
    setState(() {
      if (_eventStatus == 'active') {
        _eventStatus = 'completed';
      } else {
        _eventStatus = 'active';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _eventStatus == 'active'
              ? 'Event started! Locations are now visible to participants.'
              : 'Event stopped! Locations are hidden from participants.',
        ),
        backgroundColor:
            _eventStatus == 'active' ? Colors.green : Colors.orange,
      ),
    );
  }

  void _editLocation(Map<String, dynamic> location) {
    final nameController = TextEditingController(text: location['name']);
    final hintController = TextEditingController(text: location['hint']);
    String selectedCoordinator = location['coordinatorEmail'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Location'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hintController,
                decoration: const InputDecoration(labelText: 'Hint'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCoordinator.isEmpty ? null : selectedCoordinator,
                decoration:
                    const InputDecoration(labelText: 'Assign Coordinator'),
                items: [
                  const DropdownMenuItem(
                      value: '', child: Text('No coordinator')),
                  ..._eventCoordinators.map((coord) => DropdownMenuItem(
                        value: coord['email'],
                        child: Text(coord['email']),
                      )),
                ],
                onChanged: (value) => selectedCoordinator = value ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  hintController.text.isNotEmpty) {
                setState(() {
                  location['name'] = nameController.text;
                  location['hint'] = hintController.text;
                  location['coordinatorEmail'] = selectedCoordinator;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Location updated successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTeam(Map<String, dynamic> team) {
    final teamNameController = TextEditingController(text: team['name']);
    List<Map<String, String>> teamMembers = List.from(
      team['participants'].map<Map<String, String>>((participant) => {
            'id': participant['id'].toString(),
            'name': participant['name'].toString(),
          }),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Team'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    hintText: 'Enter team name',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Team Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...teamMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller:
                                  TextEditingController(text: member['id']),
                              decoration: const InputDecoration(
                                labelText: 'Participant ID',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                teamMembers[index]['id'] = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller:
                                  TextEditingController(text: member['name']),
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                teamMembers[index]['name'] = value;
                              },
                            ),
                          ),
                          if (teamMembers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setDialogState(() {
                                  teamMembers.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      teamMembers.add({'id': '', 'name': ''});
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Team Member'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (teamNameController.text.isNotEmpty &&
                    teamMembers.any((member) => member['id']!.isNotEmpty)) {
                  setState(() {
                    team['name'] = teamNameController.text;
                    team['participants'] = teamMembers
                        .where((m) => m['id']!.isNotEmpty)
                        .map((m) => {
                              'id': m['id']!,
                              'name': m['name']!.isNotEmpty
                                  ? m['name']!
                                  : 'Participant ${m['id']}',
                            })
                        .toList();
                  });

                  // Update leaderboard
                  _leaderboard = List.from(_teams)
                    ..sort((a, b) {
                      if (a['completedAt'] != null && b['completedAt'] == null)
                        return -1;
                      if (a['completedAt'] == null && b['completedAt'] != null)
                        return 1;
                      return (b['score'] as int).compareTo(a['score'] as int);
                    });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team updated successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeTeam(int index) {
    setState(() {
      _teams.removeAt(index);
      _leaderboard.removeAt(index);
    });
  }
}
