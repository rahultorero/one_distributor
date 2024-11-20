class MappedRetailerList {
  String? message;
  int? status;
  List<RetailerMapped>? data;

  MappedRetailerList({this.message, this.status, this.data});

  MappedRetailerList.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    if (json['data'] != null) {
      data = <RetailerMapped>[];
      json['data'].forEach((v) {
        data!.add(new RetailerMapped.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RetailerMapped {
  int? id;
  String? regDcode;
  int? rLedid;
  String? rAlcode;
  int? cusrid;
  int? eusrid;
  String? rRegcode;
  int? rId;
  int? companyId;
  int? requestStatus;
  int? partycode;
  String? partyname;
  Null? companyname;
  Null? regName;
  String? partyName;
  String? partyAdd1;
  String? partyAdd2;
  String? partyArea;
  String? partyCity;
  int? partyPincode;
  String? partyTeleno;
  String? partyMobileno;
  String? partyEmail;
  String? partyPartyCode;
  String? partyGstno;
  String? partyDlno;
  String? retaAdd1;
  String? retaAdd2;
  String? retaName;
  int? retaPincode;
  String? retaTele;
  String? retaArea;
  String? retaCity;
  String? retaState;
  String? retaCountry;
  String? retaEmail;
  String? retaMobile;

  RetailerMapped(
      {this.id,
        this.regDcode,
        this.rLedid,
        this.rAlcode,
        this.cusrid,
        this.eusrid,
        this.rRegcode,
        this.rId,
        this.companyId,
        this.requestStatus,
        this.partycode,
        this.partyname,
        this.companyname,
        this.regName,
        this.partyName,
        this.partyAdd1,
        this.partyAdd2,
        this.partyArea,
        this.partyCity,
        this.partyPincode,
        this.partyTeleno,
        this.partyMobileno,
        this.partyEmail,
        this.partyPartyCode,
        this.partyGstno,
        this.partyDlno,
        this.retaAdd1,
        this.retaAdd2,
        this.retaName,
        this.retaPincode,
        this.retaTele,
        this.retaArea,
        this.retaCity,
        this.retaState,
        this.retaCountry,
        this.retaEmail,
        this.retaMobile});

  RetailerMapped.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    regDcode = json['reg_dcode'];
    rLedid = json['r_ledid'];
    rAlcode = json['r_alcode'];
    cusrid = json['cusrid'];
    eusrid = json['eusrid'];
    rRegcode = json['r_regcode'];
    rId = json['r_id'];
    companyId = json['company_id'];
    requestStatus = json['request_status'];
    partycode = json['partycode'];
    partyname = json['partyname'];
    companyname = json['companyname'];
    regName = json['reg_name'];
    partyName = json['party_name'];
    partyAdd1 = json['party_add_1'];
    partyAdd2 = json['party_add_2'];
    partyArea = json['party_area'];
    partyCity = json['party_city'];
    partyPincode = json['party_pincode'];
    partyTeleno = json['party_teleno'];
    partyMobileno = json['party_mobileno'];
    partyEmail = json['party_email'];
    partyPartyCode = json['party_party_code'];
    partyGstno = json['party_gstno'];
    partyDlno = json['party_dlno'];
    retaAdd1 = json['reta_add1'];
    retaAdd2 = json['reta_add2'];
    retaName = json['reta_name'];
    retaPincode = json['reta_pincode'];
    retaTele = json['reta_tele'];
    retaArea = json['reta_area'];
    retaCity = json['reta_city'];
    retaState = json['reta_state'];
    retaCountry = json['reta_country'];
    retaEmail = json['reta_email'];
    retaMobile = json['reta_mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reg_dcode'] = this.regDcode;
    data['r_ledid'] = this.rLedid;
    data['r_alcode'] = this.rAlcode;
    data['cusrid'] = this.cusrid;
    data['eusrid'] = this.eusrid;
    data['r_regcode'] = this.rRegcode;
    data['r_id'] = this.rId;
    data['company_id'] = this.companyId;
    data['request_status'] = this.requestStatus;
    data['partycode'] = this.partycode;
    data['partyname'] = this.partyname;
    data['companyname'] = this.companyname;
    data['reg_name'] = this.regName;
    data['party_name'] = this.partyName;
    data['party_add_1'] = this.partyAdd1;
    data['party_add_2'] = this.partyAdd2;
    data['party_area'] = this.partyArea;
    data['party_city'] = this.partyCity;
    data['party_pincode'] = this.partyPincode;
    data['party_teleno'] = this.partyTeleno;
    data['party_mobileno'] = this.partyMobileno;
    data['party_email'] = this.partyEmail;
    data['party_party_code'] = this.partyPartyCode;
    data['party_gstno'] = this.partyGstno;
    data['party_dlno'] = this.partyDlno;
    data['reta_add1'] = this.retaAdd1;
    data['reta_add2'] = this.retaAdd2;
    data['reta_name'] = this.retaName;
    data['reta_pincode'] = this.retaPincode;
    data['reta_tele'] = this.retaTele;
    data['reta_area'] = this.retaArea;
    data['reta_city'] = this.retaCity;
    data['reta_state'] = this.retaState;
    data['reta_country'] = this.retaCountry;
    data['reta_email'] = this.retaEmail;
    data['reta_mobile'] = this.retaMobile;
    return data;
  }
}
