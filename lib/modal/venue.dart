import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Venue {
  final String venueId;
  String title;
  String category; // eg commercial,residential
  String nature; // eg rent,sale
  String hostId;
  int capacity; // number of people
  String address;
  List photos; // list of base64 strings
  double price;
  bool isnegotiable;
  String description;
  String duration; // hours
  double dalaliFee;
  DateTime createdAt;
  Venue({
    required this.venueId,
    required this.title,
    required this.category,
    required this.nature,
    required this.hostId,
    required this.capacity,
    required this.address,
    required this.photos,
    required this.price,
    this.isnegotiable = false,
    required this.description,
    required this.duration,
    required this.dalaliFee,
    required this.createdAt,
  });

  Map<String, dynamic> toDbMap() {
    return <String, dynamic>{
      'VenueId': venueId,
      'title': title,
      'category': category,
      'nature': nature,
      'hostId': hostId,
      'capacity': capacity,
      'address': address,
      'photos': listtoJson(photos),
      'price': price,
      'negotiable': isnegotiable ? 1 : 0,
      'description': description,
      'duration': duration,
      'dalaliFee': dalaliFee,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Venue.fromDbMap(Map<String, dynamic> map) {
    return Venue(
      venueId: map['venueId'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      nature: map['nature'] as String,
      hostId: map['hostId'] as String,
      capacity: map['capacity'] as int,
      address: map['address'] as String,
      photos: jsontoList(map['photos']),
      price: map['price'] as double,
      isnegotiable: map['isnegotiable'] == 1 ? true : false,
      description: map['description'] as String,
      duration: map['duration'] as String,
      dalaliFee: map['dalaliFee'] as double,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toApiMap() {
    return <String, dynamic>{
      'title': title,
      'category': category,
      'nature': nature,
      'hostId': hostId,
      'capacity': capacity,
      'address': address,
      //'photos': photos,
      'price': price,
      'negotiable': isnegotiable,
      'description': description,
      'duration': duration,
      'dalaliFee': dalaliFee,
      //'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Venue.fromApiMap(Map<String, dynamic> map) {
    return Venue(
      venueId: map['_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      nature: map['nature'] as String,
      hostId: map['hostId'] as String,
      capacity: map['capacity'] as int,
      address: map['address'] as String,
      photos: map['photos'],
      price: map['price'].toDouble() as double,
      isnegotiable: map['negotiable'] ?? false,
      description: map['description'] as String,
      duration: map['duration'] as String,
      dalaliFee: map['dalaliFee'].toDouble() as double,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // conv amenities 2 json
  static String listtoJson(List list) => json.encode({"data": list});
  static List jsontoList(String source) {
    final Map<String, dynamic> map = json.decode(source);
    return map['data'] as List;
  }

  String toJson() => json.encode(toApiMap());

  factory Venue.fromJson(String source) =>
      Venue.fromApiMap(json.decode(source) as Map<String, dynamic>);
}
