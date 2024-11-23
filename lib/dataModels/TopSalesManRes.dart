class TopSalesManRes {
  int? statusCode;
  List<TopSalesMan>? data;

  TopSalesManRes({this.statusCode, this.data});

  TopSalesManRes.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <TopSalesMan>[];
      json['data'].forEach((v) {
        data!.add(new TopSalesMan.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopSalesMan {
  String? sman;
  String? regcode;
  int? companyid;
  int? smanid;
  String? invdate;
  String? status;
  int? invamt;

  TopSalesMan(
      {this.sman,
        this.regcode,
        this.companyid,
        this.smanid,
        this.invdate,
        this.status,
        this.invamt});

  TopSalesMan.fromJson(Map<String, dynamic> json) {
    sman = json['sman'];
    regcode = json['regcode'];
    companyid = json['companyid'];
    smanid = json['smanid'];
    invdate = json['invdate'];
    status = json['status'];
    invamt = json['invamt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sman'] = this.sman;
    data['regcode'] = this.regcode;
    data['companyid'] = this.companyid;
    data['smanid'] = this.smanid;
    data['invdate'] = this.invdate;
    data['status'] = this.status;
    data['invamt'] = this.invamt;
    return data;
  }
}
