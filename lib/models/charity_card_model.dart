import 'package:firebase_database/firebase_database.dart';

class CharityCardModel {
  final double raisedFunds;
  final double targetFunds;
  final String imageLink;
  final String city;
  final String causeName;
  final String description;
  final String type;
  final String id;
  final String userEmail;

  CharityCardModel({
    required this.raisedFunds,
    required this.targetFunds,
    required this.imageLink,
    required this.city,
    required this.causeName,
    required this.description,
    required this.type,
    required this.id,
    required this.userEmail
  });

  factory CharityCardModel.fromJson(Map<String, dynamic> json) {
    return CharityCardModel(
      raisedFunds: json['raisedFunds'] ?? 0.0,
      targetFunds: json['targetFunds'] ?? 0.0,
      imageLink: json['imageLink'] ?? '',
      city: json['city'] ?? '',
      causeName: json['causeName'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      id: json['id'] ?? "",
      userEmail: json['userEmail'] ?? ""
    );
  }

  factory CharityCardModel.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    String id = snapshot.key ?? "";
    values!['id'] = id;
    return CharityCardModel.fromJson(values.cast<String, dynamic>());
  }
}
