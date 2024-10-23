import 'dart:convert';

// Define the UserModel class
class UserModel {
  final String user_name;
  final String pwd;

  UserModel({
    required this.user_name,
    required this.pwd,
  });

  // Factory method to create an instance of UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      user_name: json['user_name'],
      pwd: json['pwd'],
    );
  }

  // Method to convert an instance of UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_name': user_name,
      'pwd': pwd,
    };
  }
}

void main() {
  // Example usage
  final jsonString = '{"user_name":"OS","pwd":"one@123"}';
  final jsonMap = jsonDecode(jsonString);

  // Convert JSON to UserModel
  final user = UserModel.fromJson(jsonMap);
  print('User Name: ${user.user_name}');
  print('Password: ${user.pwd}');

  // Convert UserModel back to JSON
  final userJson = user.toJson();
  print('User JSON: ${jsonEncode(userJson)}');
}
