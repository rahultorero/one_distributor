class OutStandingDashBoard {
  String? message;
  int? statusCode;
  double? receivableBalance;
  int? stockDetails;
  double? payableBalance;

  OutStandingDashBoard({
    this.message,
    this.statusCode,
    this.receivableBalance,
    this.stockDetails,
    this.payableBalance,
  });

  OutStandingDashBoard.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    receivableBalance = (json['receivableBalance'] as num?)?.toDouble();
    stockDetails = json['stockDetails'];
    payableBalance = (json['payableBalance'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    data['receivableBalance'] = this.receivableBalance;
    data['stockDetails'] = this.stockDetails;
    data['payableBalance'] = this.payableBalance;
    return data;
  }
}
