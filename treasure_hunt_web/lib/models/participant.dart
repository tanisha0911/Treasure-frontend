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
      id: json['id'],
      uniqueKey: json['uniqueKey'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
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

class Team {
  final String id;
  final String eventId;
  final String name;
  final List<String> participantKeys;
  final int score;
  final List<String> route;
  final int currentStep;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.eventId,
    required this.name,
    required this.participantKeys,
    required this.score,
    required this.route,
    required this.currentStep,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      eventId: json['eventId'],
      name: json['name'],
      participantKeys: List<String>.from(json['participantKeys']),
      score: json['score'],
      route: List<String>.from(json['route']),
      currentStep: json['currentStep'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'participantKeys': participantKeys,
      'score': score,
      'route': route,
      'currentStep': currentStep,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Location {
  final String id;
  final String eventId;
  final String name;
  final String hint;
  final String qrCode;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.eventId,
    required this.name,
    required this.hint,
    required this.qrCode,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      eventId: json['eventId'],
      name: json['name'],
      hint: json['hint'],
      qrCode: json['qrCode'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'hint': hint,
      'qrCode': qrCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
