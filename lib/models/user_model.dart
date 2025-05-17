class UserModel {
  final String id;
  final String email;
  final String token;
  final String? fullname;
  final String? dob;
  final String? isVerified;
  final WalletModel? wallet;

  UserModel({
    required this.id,
    required this.email,
    required this.token,
    this.fullname,
    this.dob,
    this.isVerified,
    this.wallet,
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
        wallet: json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null,
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
        wallet: data['user']['wallet'] != null ? WalletModel.fromJson(data['user']['wallet']) : null,
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
      'wallet': wallet?.toJson(),
    };
  }
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullname: $fullname, dob: $dob, isVerified: $isVerified, token: ${token.substring(0, 10)}...)';
  }
}

class WalletModel {
  final String id;
  final String user;
  final double balance;
  final bool autoDeduct;
  final List<dynamic> transactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.user,
    required this.balance,
    required this.autoDeduct,
    required this.transactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      autoDeduct: json['autoDeduct'] ?? false,
      transactions: json['transactions'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'balance': balance,
      'autoDeduct': autoDeduct,
      'transactions': transactions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 