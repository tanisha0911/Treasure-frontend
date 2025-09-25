import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Participant> _participants = [];
  List<Team> _teams = [];
  Event? _selectedEvent;
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  List<Participant> get participants => _participants;
  List<Team> get teams => _teams;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedEvent(Event event) {
    _selectedEvent = event;
    notifyListeners();
  }

  // Events
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data instead of API calls for now
      await Future.delayed(const Duration(milliseconds: 500));

      _events = [
        Event(
          id: '1',
          name: 'Campus Treasure Hunt',
          description: 'Explore the campus and find hidden treasures!',
          status: 'active',
          admins: ['admin@treasurehunt.com'],
          coordinators: ['coordinator@treasurehunt.com'],
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Event(
          id: '2',
          name: 'City Adventure',
          description: 'Discover historical landmarks around the city',
          status: 'draft',
          admins: ['admin@treasurehunt.com'],
          coordinators: [],
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Event(
          id: '3',
          name: 'Mystery Quest',
          description: 'Solve puzzles and find the ultimate prize',
          status: 'completed',
          admins: ['admin@treasurehunt.com'],
          coordinators: ['coordinator@treasurehunt.com'],
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now().subtract(const Duration(hours: 20)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(
      String name, String description, DateTime startTime) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock API call delay instead of real HTTP request to prevent buffering
      await Future.delayed(const Duration(milliseconds: 500));

      // Create mock event data
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        status: 'draft',
        admins: ['admin@treasurehunt.com'], // Current user would be admin
        coordinators: [],
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 4)), // Default 4 hours
        createdAt: DateTime.now(),
      );

      _events.add(newEvent);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEventStatus(String eventId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await ApiService.updateEventStatus(eventId, status);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      if (_selectedEvent?.id == eventId) {
        _selectedEvent = updatedEvent;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Participants
  Future<void> loadParticipants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participants = await ApiService.getParticipants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createParticipant(String? name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newParticipant = await ApiService.createParticipant(name);
      _participants.add(newParticipant);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Teams
  Future<void> loadTeams(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await ApiService.getTeams(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTeam(
      String eventId, String name, List<String> participantKeys) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTeam =
          await ApiService.createTeam(eventId, name, participantKeys);
      _teams.add(newTeam);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Real-time updates
  void updateTeamProgress(Team updatedTeam) {
    final index = _teams.indexWhere((t) => t.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      notifyListeners();
    }
  }

  void addScanLog(ScanLog scanLog) {
    // Handle scan log updates if needed
    notifyListeners();
  }

  void refreshData() {
    if (_selectedEvent != null) {
      loadTeams(_selectedEvent!.id);
    }
    loadEvents();
    loadParticipants();
  }
}
