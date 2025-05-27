class WinnerResponse {
  final String? message;
  final WinnerData? data;

  WinnerResponse({
    this.message,
    this.data,
  });

  factory WinnerResponse.fromJson(Map<String, dynamic> json) {
    return WinnerResponse(
      message: json['message'] as String?,
      data: json['firstWinner'] != null ? WinnerData.fromJson(json) : null,
    );
  }
}

class WinnerData {
  final WinnerInfo firstWinner;
  final WinnerInfo secondWinner;
  final WinnerInfo thirdWinner;

  WinnerData({
    required this.firstWinner,
    required this.secondWinner,
    required this.thirdWinner,
  });

  factory WinnerData.fromJson(Map<String, dynamic> json) {
    return WinnerData(
      firstWinner: WinnerInfo.fromJson(json['firstWinner']),
      secondWinner: WinnerInfo.fromJson(json['secondWinner']),
      thirdWinner: WinnerInfo.fromJson(json['thirdWinner']),
    );
  }
}

class WinnerInfo {
  final UserInfo user;
  final String ticket;
  final int winningAmount;

  WinnerInfo({
    required this.user,
    required this.ticket,
    required this.winningAmount,
  });

  factory WinnerInfo.fromJson(Map<String, dynamic> json) {
    return WinnerInfo(
      user: UserInfo.fromJson(json['user']),
      ticket: json['ticket'],
      winningAmount: json['winningAmount'],
    );
  }
}

class UserInfo {
  final String id;
  final String fullname;
  final String email;

  UserInfo({
    required this.id,
    required this.fullname,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      fullname: json['fullname'],
      email: json['email'],
    );
  }
}

class PastWinnersResponse {
  final List<PastWinnerData> pastWinners;

  PastWinnersResponse({required this.pastWinners});

  factory PastWinnersResponse.fromJson(Map<String, dynamic> json) {
    return PastWinnersResponse(
      pastWinners: (json['pastWinners'] as List)
          .map((winner) => PastWinnerData.fromJson(winner))
          .toList(),
    );
  }
}

class PastWinnerData {
  final String plan;
  final DateTime date;
  final UserInfo firstWinner;
  final UserInfo secondWinner;
  final UserInfo thirdWinner;

  PastWinnerData({
    required this.plan,
    required this.date,
    required this.firstWinner,
    required this.secondWinner,
    required this.thirdWinner,
  });

  factory PastWinnerData.fromJson(Map<String, dynamic> json) {
    return PastWinnerData(
      plan: json['plan'],
      date: DateTime.parse(json['date']),
      firstWinner: UserInfo.fromJson(json['firstWinner']),
      secondWinner: UserInfo.fromJson(json['secondWinner']),
      thirdWinner: UserInfo.fromJson(json['thirdWinner']),
    );
  }
} 