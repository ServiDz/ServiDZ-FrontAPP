class Booking {
  final String id;
  final String serviceType;
  final String description;
  final String date;
  final String address;
  final User? user;

  Booking({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.date,
    required this.address,
    this.user,
  });

factory Booking.fromJson(Map<String, dynamic> json) {
  return Booking(
    id: json['_id'] ?? '',
    serviceType: json['serviceType'] ?? '',
    description: json['description'] ?? '',
    date: json['date'] ?? '',
    address: json['location']?['address'] ?? '',
    user: json['userId'] != null ? User.fromJson(json['userId']) : null,
  );
}

}

class User {
  final String id;
  final String name;
  final String? avatar;
  final String? phone;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'],
      phone: json['phone'],
    );
  }
}