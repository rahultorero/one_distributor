class UpdateCompanyModel {
  String? regCode;
  UpdateFields? updateFields;
  List<Gst>? gst;

  UpdateCompanyModel({this.regCode, this.updateFields, this.gst});

  factory UpdateCompanyModel.fromJson(Map<String, dynamic> json) {
    return UpdateCompanyModel(
      regCode: json['reg_code'],
      updateFields: json['updateFields'] != null
          ? UpdateFields.fromJson(json['updateFields'])
          : null,
      gst: json['gst'] != null
          ? (json['gst'] as List).map((i) => Gst.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reg_code'] = regCode;
    if (updateFields != null) {
      data['updateFields'] = updateFields!.toJson();
    }
    if (gst != null) {
      data['gst'] = gst!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpdateFields {
  String? regName;
  String? add1;
  String? add2;
  String? lmark;
  int? fxdidState;
  dynamic? pincode;
  dynamic? fxdidCountry;
  String? email;
  String? cmail;
  String? tele;
  String? mob;
  int? fixidBusstype;
  String? wano;
  int? cusrid;

  UpdateFields({
    this.regName,
    this.add1,
    this.add2,
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
  });

  factory UpdateFields.fromJson(Map<String, dynamic> json) {
    return UpdateFields(
      regName: json['reg_name'],
      add1: json['add1'],
      add2: json['add2'],
      lmark: json['lmark'],
      fxdidState: json['fxdid_state'],
      pincode: json['pincode'],
      fxdidCountry: json['fxdid_country'],
      email: json['email'],
      cmail: json['cmail'],
      tele: json['tele'],
      mob: json['mob'],
      fixidBusstype: json['fixid_busstype'],
      wano: json['wano'],
      cusrid: json['cusrid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reg_name'] = regName;
    data['add1'] = add1;
    data['add2'] = add2;
    data['lmark'] = lmark;
    data['fxdid_state'] = fxdidState;
    data['pincode'] = pincode;
    data['fxdid_country'] = fxdidCountry;
    data['email'] = email;
    data['cmail'] = cmail;
    data['tele'] = tele;
    data['mob'] = mob;
    data['fixid_busstype'] = fixidBusstype;
    data['wano'] = wano;
    data['cusrid'] = cusrid;
    return data;
  }
}

class Gst {
  int? rgId;
  int? typeId;
  int? sId;
  int? fxdidRegtypebuss;
  int? fxdidType;
  String? regno;
  String? efrom;
  String? eto;
  bool? esrew;
  String? url;
  String? con;
  String? cusrid;
  String? eon;
  String? eusrid;

  Gst({
    this.rgId,
    this.typeId,
    this.sId,
    this.fxdidRegtypebuss,
    this.fxdidType,
    this.regno,
    this.efrom,
    this.eto,
    this.esrew,
    this.url,
    this.con,
    this.cusrid,
    this.eon,
    this.eusrid,
  });

  factory Gst.fromJson(Map<String, dynamic> json) {
    return Gst(
      rgId: json['rg_id'],
      typeId: json['type_id'],
      sId: json['s_id'],
      fxdidRegtypebuss: json['fxdid_regtypebuss'],
      fxdidType: json['fxdid_type'],
      regno: json['regno'],
      efrom: json['efrom'],
      eto: json['eto'],
      esrew: json['esrew'],
      url: json['url'],
      con: json['con'],
      cusrid: json['cusrid'],
      eon: json['eon'],
      eusrid: json['eusrid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rg_id'] = rgId;
    data['type_id'] = typeId;
    data['s_id'] = sId;
    data['fxdid_regtypebuss'] = fxdidRegtypebuss;
    data['fxdid_type'] = fxdidType;
    data['regno'] = regno;
    data['efrom'] = efrom;
    data['eto'] = eto;
    data['esrew'] = esrew;
    data['url'] = url;
    data['con'] = con;
    data['cusrid'] = cusrid;
    data['eon'] = eon;
    data['eusrid'] = eusrid;
    return data;
  }
}
