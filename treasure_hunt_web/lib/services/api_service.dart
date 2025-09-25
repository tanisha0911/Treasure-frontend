import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/event.dart';

class ApiService {
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Authentication
  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthToken(authResponse.token);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  static Future<AuthResponse> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthToken(authResponse.token);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Events
  static Future<List<Event>> getEvents() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/events'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['events'] as List).map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch events');
    }
  }

  static Future<Event> createEvent(
    String name,
    String description,
    DateTime startTime,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/events'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'startTime': startTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data['event']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create event');
    }
  }

  static Future<Event> getEvent(String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data['event']);
    } else {
      throw Exception('Failed to fetch event');
    }
  }

  static Future<Event> updateEventStatus(String eventId, String status) async {
    final response = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data['event']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update event status');
    }
  }

  // Participants
  static Future<List<Participant>> getParticipants() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/participants'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList();
    } else {
      throw Exception('Failed to fetch participants');
    }
  }

  static Future<Participant> createParticipant(String? name) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/participants'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Participant.fromJson(data['participant']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create participant');
    }
  }

  static Future<Participant> getParticipantByKey(String key) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/participants/key/$key'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Participant.fromJson(data['participant']);
    } else {
      throw Exception('Participant not found');
    }
  }

  // Locations
  static Future<List<Location>> getLocations(String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/locations/event/$eventId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['locations'] as List)
          .map((l) => Location.fromJson(l))
          .toList();
    } else {
      throw Exception('Failed to fetch locations');
    }
  }

  static Future<Location> createLocation(
    String eventId,
    String name,
    String hint,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/locations'),
      headers: _headers,
      body: jsonEncode({'eventId': eventId, 'name': name, 'hint': hint}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Location.fromJson(data['location']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create location');
    }
  }

  // Teams
  static Future<List<Team>> getTeams(String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/teams/event/$eventId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['teams'] as List).map((t) => Team.fromJson(t)).toList();
    } else {
      throw Exception('Failed to fetch teams');
    }
  }

  static Future<Team> createTeam(
    String eventId,
    String name,
    List<String> participantKeys,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/teams'),
      headers: _headers,
      body: jsonEncode({
        'eventId': eventId,
        'name': name,
        'participantKeys': participantKeys,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Team.fromJson(data['team']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create team');
    }
  }

  static Future<Team> getTeamProgress(String teamId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/scan/team/$teamId/progress'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Team.fromJson(data['team']);
    } else {
      throw Exception('Failed to fetch team progress');
    }
  }

  // Scanning
  static Future<Map<String, dynamic>> scanLocation(
    String qrData,
    String participantKey,
    String eventId,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/scan/location'),
      headers: _headers,
      body: jsonEncode({
        'qrData': qrData,
        'participantKey': participantKey,
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Scan failed');
    }
  }

  // QR Code Generation
  static Future<Map<String, dynamic>> getParticipantQR(
    String participantKey,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/qr/participant/$participantKey'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate participant QR');
    }
  }

  static Future<Map<String, dynamic>> getLocationQR(String locationId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/qr/location/$locationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate location QR');
    }
  }

  // Participant Dashboard
  Future<Map<String, dynamic>> getParticipantDashboard(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/participants/$token/dashboard'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch participant dashboard');
    }
  }

  // Participant actions
  Future<Map<String, dynamic>> joinEvent(String token, String eventId) async {
    final response = await http.post(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/participants/$token/events/$eventId/join'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to join event');
    }
  }

  Future<Map<String, dynamic>> scanQRCode(String token, String qrData) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/participants/$token/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'qrData': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Scan failed');
    }
  }

  // Participant token validation
  static Future<Map<String, dynamic>> validateParticipantToken(
      String token) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/participant/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Invalid participant token');
    }
  }

  // Generate participant token
  static Future<Map<String, dynamic>> generateParticipantToken() async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/participant/generate'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
          error['message'] ?? 'Failed to generate participant token');
    }
  }

  // Event management with proper endpoints
  static Future<Map<String, dynamic>> startEvent(String eventId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/start'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to start event');
    }
  }

  static Future<Map<String, dynamic>> endEvent(String eventId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/end'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to end event');
    }
  }

  // Team management with proper endpoints
  static Future<List<Map<String, dynamic>>> getEventTeams(
      String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/teams'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['teams'] ?? []);
    } else {
      throw Exception('Failed to fetch teams');
    }
  }

  static Future<Map<String, dynamic>> createEventTeam(
    String eventId,
    String name,
    List<String> participantTokens,
    List<String> route,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/teams'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'participantTokens': participantTokens,
        'route': route,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create team');
    }
  }

  // Analytics endpoints
  static Future<Map<String, dynamic>> getEventAnalytics(String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/analytics'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch event analytics');
    }
  }

  static Future<Map<String, dynamic>> getEventLeaderboard(
      String eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/leaderboard'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch leaderboard');
    }
  }

  static Future<Map<String, dynamic>> getScanLogs(
    String eventId, {
    String? teamId,
    String? locationCode,
    String? participantToken,
  }) async {
    var uri = Uri.parse('${AppConfig.apiBaseUrl}/events/$eventId/scan-logs');

    final queryParams = <String, String>{};
    if (teamId != null) queryParams['team_id'] = teamId;
    if (locationCode != null) queryParams['location_code'] = locationCode;
    if (participantToken != null)
      queryParams['participant_token'] = participantToken;

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch scan logs');
    }
  }

  // Coordinator endpoints
  Future<Map<String, dynamic>> getCoordinatorLocation(
      String coordinatorId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/coordinators/$coordinatorId/location'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch coordinator location');
    }
  }

  static Future<Map<String, dynamic>> assignCoordinatorToLocation(
    String eventId,
    String coordinatorId,
    String locationId,
  ) async {
    final response = await http.post(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/events/$eventId/coordinators/$coordinatorId/assign'),
      headers: _headers,
      body: jsonEncode({'locationId': locationId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to assign coordinator');
    }
  }

  // Location management with proper endpoints
  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/locations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['locations'] ?? []);
    } else {
      throw Exception('Failed to fetch locations');
    }
  }

  static Future<Map<String, dynamic>> createNewLocation(
    String name,
    String hint,
    Map<String, double>? coordinates,
    String? description,
  ) async {
    final body = <String, dynamic>{
      'name': name,
      'hint': hint,
    };

    if (coordinates != null) body['coordinates'] = coordinates;
    if (description != null) body['description'] = description;

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/locations'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create location');
    }
  }

  // Legacy methods kept for compatibility
  static Future<Map<String, dynamic>> getLeaderboard(String eventId) async {
    return getEventLeaderboard(eventId);
  }
}
