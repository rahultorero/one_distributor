class CountDashBoard {
  String? message;
  int? statusCode;
  int? syncCount;
  int? notSyncCount;
  int? totalInvoice;
  double? percentage;
  double? invamt;
  int? totalOrder;

  CountDashBoard(
      {this.message,
        this.statusCode,
        this.syncCount,
        this.notSyncCount,
        this.totalInvoice,
        this.percentage,
        this.invamt,
        this.totalOrder});

  CountDashBoard.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    syncCount = json['syncCount'];
    notSyncCount = json['notSyncCount'];
    totalInvoice = json['totalInvoice'];
    percentage = (json['percentage'] as num?)?.toDouble() ?? 0.0;
    invamt =(json['invamt'] as num?)?.toDouble() ?? 0.0;
    totalOrder = json['totalOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    data['syncCount'] = this.syncCount;
    data['notSyncCount'] = this.notSyncCount;
    data['totalInvoice'] = this.totalInvoice;
    data['percentage'] = this.percentage;
    data['invamt'] = this.invamt;
    data['totalOrder'] = this.totalOrder;
    return data;
  }
}
