import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import 'admin_event_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Treasure Hunt'),
            actions: [
              // User info
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
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.role.toUpperCase(),
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
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showLogoutDialog(context, authProvider),
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: _buildBody(user.role),
        );
      },
    );
  }

  Widget _buildBody(String role) {
    return _buildEventsTab();
  }

  Widget _buildEventsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading events',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(appProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: appProvider.loadEvents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = appProvider.events;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Events',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isAdmin) {
                        return ElevatedButton.icon(
                          onPressed: _showCreateEventDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Event'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                'Create your first event to get started'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getEventStatusColor(event.status),
                                child: Icon(
                                  _getEventStatusIcon(event.status),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(event.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${event.status.toUpperCase()}',
                                    style: TextStyle(
                                      color: _getEventStatusColor(event.status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _selectEvent(event),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: AppTheme.accentColor,
          ),
          SizedBox(height: 16),
          Text(
            'QR Code Scanner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Scanner functionality will be implemented here'),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final participants = appProvider.participants;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Participants',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateParticipantDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Participant'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: participants.isEmpty
                    ? const Center(
                        child: Text('No participants yet'),
                      )
                    : ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(participant.name ?? 'Unnamed'),
                              subtitle: Text('Key: ${participant.uniqueKey}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.qr_code),
                                onPressed: () =>
                                    _showParticipantQR(participant),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getEventStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.infoColor;
      case 'draft':
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
      case 'draft':
        return Icons.edit;
      default:
        return Icons.event;
    }
  }

  void _selectEvent(event) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setSelectedEvent(event);

    // Navigate to admin event detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEventDetailScreen(event: event),
      ),
    );
  }

  void _showCreateEventDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedStartTime = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Event'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Enter event name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Start Time: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedStartTime,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(selectedStartTime),
                          );
                          if (time != null) {
                            setState(() {
                              selectedStartTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text(
                        '${selectedStartTime.day}/${selectedStartTime.month}/${selectedStartTime.year} ${selectedStartTime.hour}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ],
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
                    descriptionController.text.isNotEmpty) {
                  _createEvent(nameController.text, descriptionController.text,
                      selectedStartTime);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent(String name, String description, DateTime startTime) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      await appProvider.createEvent(name, description, startTime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "$name" created successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCreateParticipantDialog() {
    // Implementation for create participant dialog
  }

  void _showParticipantQR(participant) {
    // Implementation for showing participant QR code
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
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
              authProvider.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
