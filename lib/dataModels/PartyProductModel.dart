class PartyProductModel {
  int? status;
  List<Data>? data;

  PartyProductModel({this.status, this.data});

  PartyProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? 0;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  List<Party>? party;
  List<Product>? product;

  Data({this.party, this.product});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['party'] != null) {
      party = <Party>[];
      json['party'].forEach((v) {
        party!.add(Party.fromJson(v));
      });
    }
    if (json['product'] != null) {
      product = <Product>[];
      json['product'].forEach((v) {
        product!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (party != null) {
      data['party'] = party!.map((v) => v.toJson()).toList();
    }
    if (product != null) {
      data['product'] = product!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Party {
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

  Party.fromJson(Map<String, dynamic> json) {
    regcode = json['regcode'] ?? '';
    type = json['type'] ?? '';
    ledidParty = json['ledid_party'] ?? 0;
    partycode = json['partycode'] ?? '';
    partyname = json['partyname'] ?? '';
    sman = json['sman'] ?? '';
    add1 = json['add_1'] ?? '';
    add2 = json['add_2'] ?? '';
    area = json['area'] ?? '';
    city = json['city'] ?? '';
    pincode = json['pincode'] ?? 0;
    teleno = json['teleno'] ?? '';
    mobileno = json['mobileno'] ?? '';
    email = json['email'] ?? '';
    zone = json['zone'] ?? '';
    contactperson = json['contactperson'] ?? '';
    ccategory = json['ccategory'] ?? '';
    cgrade = json['cgrade'] ?? '';
    cgradereason = json['cgradereason'] ?? '';
    cmail = json['cmail'] ?? '';
    smanid = json['smanid'] ?? 0;
    companyid = json['companyid'] ?? 0;
    creditDays = json['credit_days'] ?? 0;
    creditLimit = json['credit_limit'] ?? '';
    cdPer = json['cd_per'] ?? '';
    dl1 = json['dl1'] ?? '';
    dl2 = json['dl2'] ?? '';
    dl3 = json['dl3'] ?? '';
    dlvalidupto = json['dlvalidupto'] ?? '';
    alcode = json['alcode'] ?? '';
    gstin = json['gstin'] ?? '';
    pan1 = json['pan_1'] ?? '';
    zoneid = json['zoneid'] ?? 0;
    locks = json['locks'] ?? '';
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
    return data;
  }
}

class Product {
  int? pid;
  String? pname;
  String? packing;
  String? dmfg;
  String? pcategory;
  String? mrp;
  int? pcode;
  int? itemdetailid;
  String? box;
  String? ptr;
  int? dCompanyid;
  String? locaked;
  String? companyname;
  String? totalStock;
  String? scheme;
  String? grpidGenNames;

  Product.fromJson(Map<String, dynamic> json) {
    pid = json['pid'] ?? 0;
    pname = json['pname'] ?? '';
    packing = json['packing'] ?? '';
    dmfg = json['dmfg'] ?? '';
    pcategory = json['pcategory'] ?? '';
    mrp = json['mrp'] ?? '';
    pcode = json['pcode'] ?? 0;
    itemdetailid = json['itemdetailid'] ?? 0;
    box = json['box'] ?? '';
    ptr = json['ptr'] ?? '';
    dCompanyid = json['d_companyid'] ?? 0;
    locaked = json['locaked'] ?? "";
    companyname = json['companyname'] ?? '';
    totalStock = json['total_stock'] ?? '';
    scheme = json['scheme'] ?? '';
    grpidGenNames = json['grpid_gen_names'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pid'] = pid;
    data['pname'] = pname;
    data['packing'] = packing;
    data['dmfg'] = dmfg;
    data['pcategory'] = pcategory;
    data['mrp'] = mrp;
    data['pcode'] = pcode;
    data['itemdetailid'] = itemdetailid;
    data['box'] = box;
    data['ptr'] = ptr;
    data['d_companyid'] = dCompanyid;
    data['locaked'] = locaked;
    data['companyname'] = companyname;
    data['total_stock'] = totalStock;
    data['scheme'] = scheme;
    data['grpid_gen_names'] = grpidGenNames;
    return data;
  }
}
