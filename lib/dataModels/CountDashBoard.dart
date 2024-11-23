class CountDashBoard {
  String? message;
  int? statusCode;
  int? syncCount;
  int? notSyncCount;
  int? totalInvoice;
  int? invamtprecentage;
  int? invamt;
  int? totalInvoicePercentage;
  int? totalOrderPercentage;
  int? totalOrder;
  double? totalOrderAmtPercentage;
  double? totalAmtOrder;

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
    invamt = json['invamt'];
    totalInvoicePercentage = json['totalInvoicePercentage'];
    totalOrderPercentage = json['totalOrderPercentage'];
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
