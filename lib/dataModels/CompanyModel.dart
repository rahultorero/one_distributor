class CompanyModel {
  int? statusCode;
  CompanyData? data;
  String? message;

  CompanyModel({this.statusCode, this.data, this.message});

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      statusCode: json['statusCode'],
      data: json['data'] != null ? CompanyData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class CompanyData {
  int? dId;
  dynamic regId;
  String? dCode;
  String? regName;
  String? add1;
  String? add2;
  String? lmark;
  int? fxdUsertype;
  dynamic fxdidState;
  int? nCode;
  int? pincode;
  String? fxdidCountry;
  String? email;
  String? cmail;
  String? tele;
  String? mob;
  int? fixidBusstype;
  String? wano;
  int? cusrid;
  String? con;
  dynamic grpidArea;
  String? grpidCity;
  String? grpCode;
  int? companyid;
  int? activeStatus;
  dynamic reasons;
  BusinessDetail? businessDetail;
  List<dynamic>? gstAndDrug;

  CompanyData({
    this.dId,
    this.regId,
    this.dCode,
    this.regName,
    this.add1,
    this.add2,
    this.lmark,
    this.fxdUsertype,
    this.fxdidState,
    this.nCode,
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
    this.grpidArea,
    this.grpidCity,
    this.grpCode,
    this.companyid,
    this.activeStatus,
    this.reasons,
    this.businessDetail,
    this.gstAndDrug,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      dId: json['d_id'],
      regId: json['reg_id'],
      dCode: json['d_code'],
      regName: json['reg_name'],
      add1: json['add1'],
      add2: json['add2'],
      lmark: json['lmark'],
      fxdUsertype: json['fxd_usertype'],
      fxdidState: json['fxdid_state'],
      nCode: json['n_code'],
      pincode: json['pincode'],
      fxdidCountry: json['fxdid_country'],
      email: json['email'],
      cmail: json['cmail'],
      tele: json['tele'],
      mob: json['mob'],
      fixidBusstype: json['fixid_busstype'],
      wano: json['wano'],
      cusrid: json['cusrid'],
      con: json['con'],
      grpidArea: json['grpid_area'],
      grpidCity: json['grpid_city'],
      grpCode: json['grp_code'],
      companyid: json['companyid'],
      activeStatus: json['active_status'],
      reasons: json['reasons'],
      businessDetail: json['business_detail'] != null
          ? BusinessDetail.fromJson(json['business_detail'])
          : null,
      gstAndDrug: json['gst_and_drug'] != null
          ? List<dynamic>.from(json['gst_and_drug'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['d_id'] = dId;
    data['reg_id'] = regId;
    data['d_code'] = dCode;
    data['reg_name'] = regName;
    data['add1'] = add1;
    data['add2'] = add2;
    data['lmark'] = lmark;
    data['fxd_usertype'] = fxdUsertype;
    data['fxdid_state'] = fxdidState;
    data['n_code'] = nCode;
    data['pincode'] = pincode;
    data['fxdid_country'] = fxdidCountry;
    data['email'] = email;
    data['cmail'] = cmail;
    data['tele'] = tele;
    data['mob'] = mob;
    data['fixid_busstype'] = fixidBusstype;
    data['wano'] = wano;
    data['cusrid'] = cusrid;
    data['con'] = con;
    data['grpid_area'] = grpidArea;
    data['grpid_city'] = grpidCity;
    data['grp_code'] = grpCode;
    data['companyid'] = companyid;
    data['active_status'] = activeStatus;
    data['reasons'] = reasons;
    if (businessDetail != null) {
      data['business_detail'] = businessDetail!.toJson();
    }
    if (gstAndDrug != null) {
      data['gst_and_drug'] = gstAndDrug;
    }
    return data;
  }
}

class BusinessDetail {
  int? fxdid;
  int? typeid;
  String? fxdname;
  String? fxdsubname;
  int? parentid;

  BusinessDetail({
    this.fxdid,
    this.typeid,
    this.fxdname,
    this.fxdsubname,
    this.parentid,
  });

  factory BusinessDetail.fromJson(Map<String, dynamic> json) {
    return BusinessDetail(
      fxdid: json['fxdid'],
      typeid: json['typeid'],
      fxdname: json['fxdname'],
      fxdsubname: json['fxdsubname'],
      parentid: json['parentid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fxdid'] = fxdid;
    data['typeid'] = typeid;
    data['fxdname'] = fxdname;
    data['fxdsubname'] = fxdsubname;
    data['parentid'] = parentid;
    return data;
  }
}
