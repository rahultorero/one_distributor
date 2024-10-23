class SalesManModel {
  String? regcode;
  int? smanid;
  int? scode;
  String? sman;
  String? mobile;
  String? status;

  SalesManModel({
    this.regcode,
    this.smanid,
    this.scode,
    this.sman,
    this.mobile,
    this.status,
  });

  factory SalesManModel.fromJson(Map<String, dynamic> json) {
    return SalesManModel(
      regcode: json['regcode'],
      smanid: json['smanid'],
      scode: json['scode'],
      sman: json['sman'],
      mobile: json['mobile'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regcode': regcode,
      'smanid': smanid,
      'scode': scode,
      'sman': sman,
      'mobile': mobile,
      'status': status,
    };
  }
}
