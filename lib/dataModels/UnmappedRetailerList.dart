class UnmappedRetailerList {
  String? message;
  int? statusCode;
  List<RetailerUnmapped>? data;
  int? totalCount;

  UnmappedRetailerList(
      {this.message, this.statusCode, this.data, this.totalCount});

  UnmappedRetailerList.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <RetailerUnmapped>[];
      json['data'].forEach((v) {
        data!.add(new RetailerUnmapped.fromJson(v));
      });
    }
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class RetailerUnmapped {
  String? areaName;
  String? cityName;
  String? stateName;
  String? countryName;
  int? rId;
  String? rCode;
  String? regName;
  String? add1;
  String? add2;
  int? grpidArea;
  int? grpidCity;
  String? lmark;
  int? fxdidState;
  int? pincode;
  int? fxdidCountry;
  String? email;
  String? cmail;
  String? tele;
  String? mob;
  int? fixidBusstype;
  String? wano;
  int? cusrid;
  String? con;
  int? nCode;
  int? regId;
  int? activeStatus;
  Set? reasons;

  RetailerUnmapped(
      {this.areaName,
        this.cityName,
        this.stateName,
        this.countryName,
        this.rId,
        this.rCode,
        this.regName,
        this.add1,
        this.add2,
        this.grpidArea,
        this.grpidCity,
        this.lmark,
        this.fxdidState,
        this.pincode,
        this.fxdidCountry,
        this.email,
        this.cmail,
        this.tele,
        this.mob,
        this.fixidBusstype,
        this.wano,
        this.cusrid,
        this.con,
        this.nCode,
        this.regId,
        this.activeStatus,
        this.reasons});

  RetailerUnmapped.fromJson(Map<String, dynamic> json) {
    areaName = json['area_name'];
    cityName = json['city_name'];
    stateName = json['state_name'];
    countryName = json['country_name'];
    rId = json['r_id'];
    rCode = json['r_code'];
    regName = json['reg_name'];
    add1 = json['add1'];
    add2 = json['add2'];
    grpidArea = json['grpid_area'];
    grpidCity = json['grpid_city'];
    lmark = json['lmark'];
    fxdidState = json['fxdid_state'];
    pincode = json['pincode'];
    fxdidCountry = json['fxdid_country'];
    email = json['email'];
    cmail = json['cmail'];
    tele = json['tele'];
    mob = json['mob'];
    fixidBusstype = json['fixid_busstype'];
    wano = json['wano'];
    cusrid = json['cusrid'];
    con = json['con'];
    nCode = json['n_code'];
    regId = json['reg_id'];
    activeStatus = json['active_status'];
    reasons = json['reasons'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area_name'] = this.areaName;
    data['city_name'] = this.cityName;
    data['state_name'] = this.stateName;
    data['country_name'] = this.countryName;
    data['r_id'] = this.rId;
    data['r_code'] = this.rCode;
    data['reg_name'] = this.regName;
    data['add1'] = this.add1;
    data['add2'] = this.add2;
    data['grpid_area'] = this.grpidArea;
    data['grpid_city'] = this.grpidCity;
    data['lmark'] = this.lmark;
    data['fxdid_state'] = this.fxdidState;
    data['pincode'] = this.pincode;
    data['fxdid_country'] = this.fxdidCountry;
    data['email'] = this.email;
    data['cmail'] = this.cmail;
    data['tele'] = this.tele;
    data['mob'] = this.mob;
    data['fixid_busstype'] = this.fixidBusstype;
    data['wano'] = this.wano;
    data['cusrid'] = this.cusrid;
    data['con'] = this.con;
    data['n_code'] = this.nCode;
    data['reg_id'] = this.regId;
    data['active_status'] = this.activeStatus;
    data['reasons'] = this.reasons;
    return data;
  }
}
