// ignore: camel_case_types
class Itinerary_class {
  String id;
  String userId; // New field to associate the itinerary with a user
  String destination;
  DateTime startDate;
  DateTime endDate;
  List<String> activities;

  Itinerary_class({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.activities,
  });

  factory Itinerary_class.fromJson(Map<String, dynamic> json) {
    return Itinerary_class(
      id: json['id'] as String,
      userId: json['userId'] as String, // Map userId from JSON
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      activities: (json['activities'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId, // Include userId in JSON
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'activities': activities,
    };
  }
}
