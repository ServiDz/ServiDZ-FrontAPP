class Tasker {
  final String id;
  final String fullName;
  final String profession;
  final String location;
  final bool isAvailable;
  final String profilePic;
  final double rating;
  final String description;

  Tasker({
    required this.id,
    required this.fullName,
    required this.profession,
    required this.location,
    required this.isAvailable,
    required this.profilePic,
    required this.rating,
    required this.description,
  });

  factory Tasker.fromJson(Map<String, dynamic> json) {
    return Tasker(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      profession: json['profession'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      isAvailable: json['isAvailable'] ?? false,
      profilePic: json['profilePic'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}
