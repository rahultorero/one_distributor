class CountDashBoard {
  String? message;
  num? statusCode;
  num? syncCount;
  num? notSyncCount;
  num? totalInvoice;
  num? invamtprecentage;
  num? invamt;
  num? totalInvoicePercentage;
  num? totalOrderPercentage;
  num? totalOrder;
  num? totalOrderAmtPercentage;
  num? totalAmtOrder;

  CountDashBoard(
      {this.message,
        this.statusCode,
        this.syncCount,
        this.notSyncCount,
        this.totalInvoice,
        this.invamtprecentage,
        this.invamt,
        this.totalInvoicePercentage,
        this.totalOrderPercentage,
        this.totalOrder,
        this.totalOrderAmtPercentage,
        this.totalAmtOrder});

  CountDashBoard.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    syncCount = json['syncCount'];
    notSyncCount = json['notSyncCount'];
    totalInvoice = json['totalInvoice'];
    invamtprecentage = json['invamtprecentage'];
    invamt = (json['invamt'] ?? 0.0).toDouble();
    totalInvoicePercentage = json['totalInvoicePercentage'];
    totalOrderPercentage = (json['totalOrderPercentage'] ?? 0.0).toDouble();
    totalOrder = json['totalOrder'];
    totalOrderAmtPercentage = json['totalOrderAmtPercentage'];
    totalAmtOrder = json['totalAmtOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    data['syncCount'] = this.syncCount;
    data['notSyncCount'] = this.notSyncCount;
    data['totalInvoice'] = this.totalInvoice;
    data['invamtprecentage'] = this.invamtprecentage;
    data['invamt'] = this.invamt;
    data['totalInvoicePercentage'] = this.totalInvoicePercentage;
    data['totalOrderPercentage'] = this.totalOrderPercentage;
    data['totalOrder'] = this.totalOrder;
    data['totalOrderAmtPercentage'] = this.totalOrderAmtPercentage;
    data['totalAmtOrder'] = this.totalAmtOrder;
    return data;
  }
}
