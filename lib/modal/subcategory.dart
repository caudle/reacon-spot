import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Subcategory {
  final String subId;
  String category;
  String name;
  Subcategory({
    required this.subId,
    required this.category,
    required this.name,
  });

  Map<String, dynamic> toDbMap() {
    return <String, dynamic>{
      'subId': subId,
      'category': category,
      'name': name,
    };
  }

  factory Subcategory.fromDbMap(Map<String, dynamic> map) {
    return Subcategory(
      subId: map['subId'] as String,
      category: map['category'],
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toApiMap() {
    return <String, dynamic>{
      'category': category,
      'name': name,
    };
  }

  factory Subcategory.fromApiMap(Map<String, dynamic> map) {
    return Subcategory(
      subId: map['_id'] as String,
      category: map['category'],
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toApiMap());

  factory Subcategory.fromJson(String source) =>
      Subcategory.fromApiMap(json.decode(source) as Map<String, dynamic>);
}
