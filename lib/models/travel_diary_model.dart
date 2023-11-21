class TravelDiaryEntry {
  String id;
  String title;
  String description;
  List<String> imageUrls;

  TravelDiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
  });

  TravelDiaryEntry.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? '',
        title = map['title'] ?? '',
        description = map['description'] ?? '',
        imageUrls = List<String>.from(map['imageUrls'] ?? []);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
    };
  }
}
