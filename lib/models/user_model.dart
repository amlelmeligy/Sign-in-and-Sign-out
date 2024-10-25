import 'package:signin/core/api/end_points.dart';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String profilePic;
  final Map<String, dynamic> address;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePic,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      name: jsonData['user'][ApiKey.name],
      email: jsonData['user'][ApiKey.email],
      phone: jsonData['user'][ApiKey.phone],
      profilePic: jsonData['user'][ApiKey.profilePic],
      address: jsonData['user'][ApiKey.location],
    );
  }
}
