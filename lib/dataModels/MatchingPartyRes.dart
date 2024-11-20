class MatchingPartyRes {
  List<MatchingParty>? data;

  MatchingPartyRes({this.data});

  MatchingPartyRes.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MatchingParty>[];
      json['data'].forEach((v) {
        data!.add(MatchingParty.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MatchingParty {
  String? regcode;
  String? type;
  int? ledidParty;
  String? partycode;
  String? partyname;
  String? sman;
  String? add1;
  String? add2;
  String? area;
  String? city;
  int? pincode;
  String? teleno;
  String? mobileno;
  String? email;
  String? zone;
  String? contactperson;
  String? ccategory;
  String? cgrade;
  String? cgradereason;
  String? cmail;
  int? smanid;
  int? companyid;
  int? creditDays;
  String? creditLimit;
  String? cdPer;
  String? dl1;
  String? dl2;
  String? dl3;
  String? dlvalidupto;
  String? alcode;
  String? gstin;
  String? pan1;
  int? zoneid;
  String? locks;
  List<MatchParty>? matchParty;

  MatchingParty({
    this.regcode,
    this.type,
    this.ledidParty,
    this.partycode,
    this.partyname,
    this.sman,
    this.add1,
    this.add2,
    this.area,
    this.city,
    this.pincode,
    this.teleno,
    this.mobileno,
    this.email,
    this.zone,
    this.contactperson,
    this.ccategory,
    this.cgrade,
    this.cgradereason,
    this.cmail,
    this.smanid,
    this.companyid,
    this.creditDays,
    this.creditLimit,
    this.cdPer,
    this.dl1,
    this.dl2,
    this.dl3,
    this.dlvalidupto,
    this.alcode,
    this.gstin,
    this.pan1,
    this.zoneid,
    this.locks,
    this.matchParty,
  });

  MatchingParty.fromJson(Map<String, dynamic> json) {
    regcode = json['regcode'];
    type = json['type'];
    ledidParty = json['ledid_party'] != null ? int.tryParse(json['ledid_party'].toString()) ?? 0 : 0;
    partycode = json['partycode'];
    partyname = json['partyname'];
    sman = json['sman'];
    add1 = json['add_1'];
    add2 = json['add_2'];
    area = json['area'];
    city = json['city'];
    pincode = json['pincode'] != null ? int.tryParse(json['pincode'].toString()) ?? 0 : 0;
    teleno = json['teleno'];
    mobileno = json['mobileno'];
    email = json['email'];
    zone = json['zone'];
    contactperson = json['contactperson'];
    ccategory = json['ccategory'];
    cgrade = json['cgrade'];
    cgradereason = json['cgradereason'];
    cmail = json['cmail'];
    smanid = json['smanid'] != null ? int.tryParse(json['smanid'].toString()) ?? 0 : 0;
    companyid = json['companyid'] != null ? int.tryParse(json['companyid'].toString()) ?? 0 : 0;
    creditDays = json['credit_days'] != null ? int.tryParse(json['credit_days'].toString()) ?? 0 : 0;
    creditLimit = json['credit_limit'];
    cdPer = json['cd_per'];
    dl1 = json['dl1'];
    dl2 = json['dl2'];
    dl3 = json['dl3'];
    dlvalidupto = json['dlvalidupto'];
    alcode = json['alcode'];
    gstin = json['gstin'];
    pan1 = json['pan_1'];
    zoneid = json['zoneid'] != null ? int.tryParse(json['zoneid'].toString()) ?? 0 : 0;
    locks = json['locks'];
    if (json['match_party'] != null) {
      matchParty = <MatchParty>[];
      json['match_party'].forEach((v) {
        matchParty!.add(MatchParty.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['regcode'] = regcode;
    data['type'] = type;
    data['ledid_party'] = ledidParty;
    data['partycode'] = partycode;
    data['partyname'] = partyname;
    data['sman'] = sman;
    data['add_1'] = add1;
    data['add_2'] = add2;
    data['area'] = area;
    data['city'] = city;
    data['pincode'] = pincode;
    data['teleno'] = teleno;
    data['mobileno'] = mobileno;
    data['email'] = email;
    data['zone'] = zone;
    data['contactperson'] = contactperson;
    data['ccategory'] = ccategory;
    data['cgrade'] = cgrade;
    data['cgradereason'] = cgradereason;
    data['cmail'] = cmail;
    data['smanid'] = smanid;
    data['companyid'] = companyid;
    data['credit_days'] = creditDays;
    data['credit_limit'] = creditLimit;
    data['cd_per'] = cdPer;
    data['dl1'] = dl1;
    data['dl2'] = dl2;
    data['dl3'] = dl3;
    data['dlvalidupto'] = dlvalidupto;
    data['alcode'] = alcode;
    data['gstin'] = gstin;
    data['pan_1'] = pan1;
    data['zoneid'] = zoneid;
    data['locks'] = locks;
    if (matchParty != null) {
      data['match_party'] = matchParty!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MatchParty {
  int? rId;
  String? area;
  String? city;
  String? state;
  String? rCode;
  String? regName;
  String? country;
  String? user;
  int? pan;
  int? gst;
  String? gstUrl;
  String? panUrl;

  MatchParty({
    this.rId,
    this.area,
    this.city,
    this.state,
    this.rCode,
    this.regName,
    this.country,
    this.user,
    this.pan,
    this.gst,
    this.gstUrl,
    this.panUrl,
  });

  MatchParty.fromJson(Map<String, dynamic> json) {
    rId = json['r_id'] != null ? int.tryParse(json['r_id'].toString()) ?? 0 : 0;
    area = json['area'];
    city = json['city'];
    state = json['state'];
    rCode = json['r_code'];
    regName = json['reg_name'];
    country = json['country'];
    user = json['user'];
    pan = json['pan'] != null ? int.tryParse(json['pan'].toString()) ?? 0 : 0;
    gst = json['gst'] != null ? int.tryParse(json['gst'].toString()) ?? 0 : 0;
    gstUrl = json['gst_url'];
    panUrl = json['pan_url'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['r_id'] = rId;
    data['area'] = area;
    data['city'] = city;
    data['state'] = state;
    data['r_code'] = rCode;
    data['reg_name'] = regName;
    data['country'] = country;
    data['user'] = user;
    data['pan'] = pan;
    data['gst'] = gst;
    data['gst_url'] = gstUrl;
    data['pan_url'] = panUrl;
    return data;
  }
}
