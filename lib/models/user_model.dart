class UserModel {
  final String id;
  final String fullname;
  final String email;
  final String dob;
  final String isVerified;
  final UserKyc? userKyc;
  final String token;
  final WalletModel? wallet;

  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.dob,
    required this.isVerified,
    this.userKyc,
    required this.token,
    this.wallet,
  });

  // Create a user model from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    try {
      print('Creating UserModel from: $json');
      return UserModel(
        id: json['_id'] ?? json['id'] ?? '',
        fullname: json['fullname'] ?? '',
        email: json['email'] ?? '',
        dob: json['dob'] ?? '',
        isVerified: json['isVerified'] ?? '',
        userKyc: json['userKyc'] != null ? UserKyc.fromJson(json['userKyc']) : null,
        token: token,
        wallet: json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null,
      );
    } catch (e) {
      print('Error creating UserModel: $e');
      print('JSON data: $json, token: $token');
      // Return a default model in case of error to avoid crashes
      return UserModel(
        id: '',
        fullname: '',
        email: '',
        dob: '',
        isVerified: '',
        userKyc: null,
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
        fullname: data['user']['fullname'] ?? '',
        email: data['user']['email'] ?? '',
        dob: data['user']['dob'] ?? '',
        isVerified: 'true', // Since response indicates user is created and verified
        userKyc: data['user']['userKyc'] != null ? UserKyc.fromJson(data['user']['userKyc']) : null,
        token: data['token'] ?? '',
        wallet: data['user']['wallet'] != null ? WalletModel.fromJson(data['user']['wallet']) : null,
      );
    } catch (e) {
      print('Error creating UserModel from register response: $e');
      print('Data: $data');
      // Return a default model in case of error to avoid crashes
      return UserModel(
        id: '',
        fullname: '',
        email: '',
        dob: '',
        isVerified: '',
        userKyc: null,
        token: data['token'] ?? '',
      );
    }
  }

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'email': email,
      'dob': dob,
      'isVerified': isVerified,
      'userKyc': userKyc?.toJson(),
      'token': token,
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

class UserKyc {
  final String bankAccountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String kycDocumentNumber;

  UserKyc({
    required this.bankAccountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.kycDocumentNumber,
  });

  factory UserKyc.fromJson(Map<String, dynamic> json) {
    return UserKyc(
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      branchName: json['branchName'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      kycDocumentNumber: json['kycDocumentNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'branchName': branchName,
      'ifscCode': ifscCode,
      'kycDocumentNumber': kycDocumentNumber,
    };
  }
} 