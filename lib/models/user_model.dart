import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel {
  final String email;
  final String username;
  final String id;
  final String key;

  UserModel({
    required this.email,
    required this.username,
    required this.id,
    required this.key
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      id: json['id'] ?? '',
      key: json['key'] ?? ''
    );
  }

  factory UserModel.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    User? currentUser = FirebaseAuth.instance.currentUser;
    values!['id'] = currentUser?.uid.toString();
    return UserModel.fromJson(values.cast<String, dynamic>());
  }
}
