import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Land {
  final String landId;
  String title;
  String category; // eg commercial,residential
  String nature; // eg rent,sale
  String hostId;
  double size;
  String address;
  List photos; // list of base64 strings
  double price;
  bool isnegotiable;
  String description;
  double dalaliFee;
  DateTime createdAt;
  Land({
    required this.landId,
    required this.title,
    required this.category,
    required this.nature,
    required this.hostId,
    required this.size,
    required this.address,
    required this.photos,
    required this.price,
    this.isnegotiable = false,
    required this.description,
    required this.dalaliFee,
    required this.createdAt,
  });

  Map<String, dynamic> toApiMap() {
    return <String, dynamic>{
      'title': title,
      'category': category,
      'nature': nature,
      'hostId': hostId,
      'size': size,
      'address': address,
      //'photos': photos,
      'price': price,
      'negotiable': isnegotiable,
      'description': description,
      'dalaliFee': dalaliFee,
      //'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Land.fromApiMap(Map<String, dynamic> map) {
    return Land(
      landId: map['_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      nature: map['nature'] as String,
      hostId: map['hostId'] as String,
      size: map['size'].toDouble() as double,
      address: map['address'] as String,
      photos: map['photos'],
      price: map['price'].toDouble() as double,
      isnegotiable: map['negotiable'] ?? false,
      description: map['description'] as String,
      dalaliFee: map['dalaliFee'].toDouble() as double,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toApiMap());

  factory Land.fromJson(String source) =>
      Land.fromApiMap(json.decode(source) as Map<String, dynamic>);
}
