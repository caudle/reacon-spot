import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Listing {
  final String listingId;
  String name;
  String category; // eg house,apt
  String nature; // eg rent,sale
  String hostId;
  int baths;
  int beds;
  double size;
  String address;
  List amenities;
  bool isfurnished;
  bool ispets;
  List photos; // list of base64 strings
  double price;
  bool isnegotiable;
  String description;
  double dalaliFee;
  String duration; // per month, per quarter
  DateTime createdAt;
  Listing({
    required this.listingId,
    required this.name,
    required this.category,
    required this.nature,
    required this.hostId,
    required this.baths,
    required this.beds,
    required this.size,
    required this.address,
    required this.amenities,
    this.isfurnished = false,
    this.ispets = false,
    required this.photos,
    required this.price,
    this.isnegotiable = false,
    required this.description,
    required this.dalaliFee,
    this.duration = "",
    required this.createdAt,
  });

  Map<String, dynamic> toApiMap() {
    return <String, dynamic>{
      'name': name,
      'category': category,
      'nature': nature,
      'hostId': hostId,
      'baths': baths,
      'beds': beds,
      'size': size,
      'address': address,
      'amenities': amenities,
      'furnished': isfurnished,
      'pets': ispets,
      //'photos': photos,
      'price': price,
      'negotiable': isnegotiable,
      'description': description,
      'dalaliFee': dalaliFee,
      'duration': duration,
      //'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Listing.fromApiMap(Map<String, dynamic> map) {
    return Listing(
      listingId: map['_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      nature: map['nature'] as String,
      hostId: map['hostId'] as String,
      baths: map['baths'] as int,
      beds: map['beds'] as int,
      size: map['size'].toDouble() as double,
      address: map['address'] as String,
      amenities: map['amenities'],
      isfurnished: map['furnished'],
      ispets: map['pets'],
      photos: map['photos'],
      price: map['price'].toDouble() as double,
      isnegotiable: map['negotiable'] ?? false,
      description: map['description'] as String,
      dalaliFee: map['dalaliFee'].toDouble() as double,
      duration: map['duration'] as String,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toApiMap());

  factory Listing.fromJson(String source) =>
      Listing.fromApiMap(json.decode(source) as Map<String, dynamic>);
}
