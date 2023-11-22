class Itinerary_class {
  String id;
  String destination;
  DateTime startDate;
  DateTime endDate;
  List<String> activities;

  Itinerary_class({
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.activities,
  });

  factory Itinerary_class.fromJson(Map<String, dynamic> json) {
    return Itinerary_class(
      id: json['id'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      activities: (json['activities'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'activities': activities,
    };
  }
}