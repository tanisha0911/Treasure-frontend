class Event {
  final String id;
  final String name;
  final String description;
  final String status;
  final List<String> admins;
  final List<String> coordinators;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.admins,
    required this.coordinators,
    required this.startTime,
    this.endTime,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'draft',
      admins: List<String>.from(json['admins'] ?? []),
      coordinators: List<String>.from(json['coordinators'] ?? []),
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'admins': admins,
      'coordinators': coordinators,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isDraft => status == 'draft';
}

class Participant {
  final String id;
  final String uniqueKey;
  final String? name;
  final DateTime createdAt;

  Participant({
    required this.id,
    required this.uniqueKey,
    this.name,
    required this.createdAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? json['_id'] ?? '',
      uniqueKey: json['uniqueKey'] ?? '',
      name: json['name'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueKey': uniqueKey,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Location {
  final String id;
  final String name;
  final String uniqueCode;
  final String hint;
  final String eventId;
  final bool isStartLocation;
  final bool isEndLocation;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.name,
    required this.uniqueCode,
    required this.hint,
    required this.eventId,
    this.isStartLocation = false,
    this.isEndLocation = false,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      hint: json['hint'] ?? '',
      eventId: json['eventId'] ?? '',
      isStartLocation: json['isStartLocation'] ?? false,
      isEndLocation: json['isEndLocation'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uniqueCode': uniqueCode,
      'hint': hint,
      'eventId': eventId,
      'isStartLocation': isStartLocation,
      'isEndLocation': isEndLocation,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Team {
  final String id;
  final String name;
  final String eventId;
  final List<Participant> participants;
  final List<Location> route;
  final int totalScore;
  final int penalties;
  final int currentLocationIndex;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.eventId,
    required this.participants,
    required this.route,
    this.totalScore = 0,
    this.penalties = 0,
    this.currentLocationIndex = 0,
    this.status = 'active',
    this.completedAt,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      eventId: json['eventId'] ?? '',
      participants:
          (json['participants'] as List?)
              ?.map((p) => Participant.fromJson(p))
              .toList() ??
          [],
      route:
          (json['route'] as List?)?.map((l) => Location.fromJson(l)).toList() ??
          [],
      totalScore: json['totalScore'] ?? 0,
      penalties: json['penalties'] ?? 0,
      currentLocationIndex: json['currentLocationIndex'] ?? 0,
      status: json['status'] ?? 'active',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'participants': participants.map((p) => p.toJson()).toList(),
      'route': route.map((l) => l.toJson()).toList(),
      'totalScore': totalScore,
      'penalties': penalties,
      'currentLocationIndex': currentLocationIndex,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get finalScore => totalScore + penalties;
  bool get isCompleted => status == 'completed';
  double get progressPercentage =>
      route.isEmpty ? 0.0 : (currentLocationIndex / route.length) * 100;
  Location? get nextLocation =>
      currentLocationIndex < route.length ? route[currentLocationIndex] : null;
}

class ScanLog {
  final String id;
  final String teamId;
  final String locationId;
  final String scannedBy;
  final String eventId;
  final bool isCorrectLocation;
  final int scoreAwarded;
  final int penaltyApplied;
  final int routePosition;
  final String scanType;
  final DateTime timestamp;

  ScanLog({
    required this.id,
    required this.teamId,
    required this.locationId,
    required this.scannedBy,
    required this.eventId,
    required this.isCorrectLocation,
    this.scoreAwarded = 0,
    this.penaltyApplied = 0,
    required this.routePosition,
    required this.scanType,
    required this.timestamp,
  });

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id'] ?? json['_id'] ?? '',
      teamId: json['teamId'] ?? '',
      locationId: json['locationId'] ?? '',
      scannedBy: json['scannedBy'] ?? '',
      eventId: json['eventId'] ?? '',
      isCorrectLocation: json['isCorrectLocation'] ?? false,
      scoreAwarded: json['scoreAwarded'] ?? 0,
      penaltyApplied: json['penaltyApplied'] ?? 0,
      routePosition: json['routePosition'] ?? 0,
      scanType: json['scanType'] ?? 'unknown',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'locationId': locationId,
      'scannedBy': scannedBy,
      'eventId': eventId,
      'isCorrectLocation': isCorrectLocation,
      'scoreAwarded': scoreAwarded,
      'penaltyApplied': penaltyApplied,
      'routePosition': routePosition,
      'scanType': scanType,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
