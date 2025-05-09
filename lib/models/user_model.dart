class UserModel {
  final String id;
  final String email;
  final String token;
  final String? fullname;
  final String? dob;
  final String? isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.token,
    this.fullname,
    this.dob,
    this.isVerified,
  });

  // Create a user model from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    try {
      print('Creating UserModel from: $json');
      return UserModel(
        id: json['_id'] ?? json['id'] ?? '',
        email: json['email'] ?? '',
        token: token,
        fullname: json['fullname'],
        dob: json['dob'],
        isVerified: json['isVerified'],
      );
    } catch (e) {
      print('Error creating UserModel: $e');
      print('JSON data: $json, token: $token');
      // Return a default model in case of error to avoid crashes
      return UserModel(
        id: '',
        email: '',
        token: token,
      );
    }
  }

  // Create a user model specifically from register API response
  factory UserModel.fromRegisterResponse(Map<String, dynamic> data) {
    try {
      print('Creating UserModel from register response: $data');
      return UserModel(
        id: data['user']['id'] ?? '',
        email: data['user']['email'] ?? '',
        token: data['token'] ?? '',
        isVerified: 'true', // Since response indicates user is created and verified
      );
    } catch (e) {
      print('Error creating UserModel from register response: $e');
      print('Data: $data');
      // Return a default model in case of error to avoid crashes
      return UserModel(
        id: '',
        email: '',
        token: data['token'] ?? '',
      );
    }
  }

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'fullname': fullname,
      'dob': dob,
      'isVerified': isVerified,
    };
  }
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullname: $fullname, dob: $dob, isVerified: $isVerified, token: ${token.substring(0, 10)}...)';
  }
} 