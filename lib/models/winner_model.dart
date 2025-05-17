class WinnerResponse {
  final String message;
  final WinnerData? data;

  WinnerResponse({
    required this.message,
    this.data,
  });

  factory WinnerResponse.fromJson(Map<String, dynamic> json) {
    return WinnerResponse(
      message: json['message'] as String,
      data: json['data'] != null ? WinnerData.fromJson(json['data']) : null,
    );
  }
}

class WinnerData {
  final String name;
  final String location;
  final String amount;

  WinnerData({
    required this.name,
    required this.location,
    required this.amount,
  });

  factory WinnerData.fromJson(Map<String, dynamic> json) {
    return WinnerData(
      name: json['name'] as String,
      location: json['location'] as String,
      amount: json['amount'] as String,
    );
  }
}

class PastWinnersResponse {
  final List<WinnerData> pastWinners;

  PastWinnersResponse({
    required this.pastWinners,
  });

  factory PastWinnersResponse.fromJson(Map<String, dynamic> json) {
    return PastWinnersResponse(
      pastWinners: (json['pastWinners'] as List)
          .map((winner) => WinnerData.fromJson(winner))
          .toList(),
    );
  }
} 