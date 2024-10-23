class PartyProductModel {
  int? status;
  List<Data>? data;

  PartyProductModel({this.status, this.data});

  PartyProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
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
        party!.add(new Party.fromJson(v));
      });
    }
    if (json['product'] != null) {
      product = <Product>[];
      json['product'].forEach((v) {
        product!.add(new Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.party != null) {
      data['party'] = this.party!.map((v) => v.toJson()).toList();
    }
    if (this.product != null) {
      data['product'] = this.product!.map((v) => v.toJson()).toList();
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

  Party(
      {this.regcode,
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
        this.locks});

  Party.fromJson(Map<String, dynamic> json) {
    regcode = json['regcode'];
    type = json['type'];
    ledidParty = json['ledid_party'];
    partycode = json['partycode'];
    partyname = json['partyname'];
    sman = json['sman'];
    add1 = json['add_1'];
    add2 = json['add_2'];
    area = json['area'];
    city = json['city'];
    pincode = json['pincode'];
    teleno = json['teleno'];
    mobileno = json['mobileno'];
    email = json['email'];
    zone = json['zone'];
    contactperson = json['contactperson'];
    ccategory = json['ccategory'];
    cgrade = json['cgrade'];
    cgradereason = json['cgradereason'];
    cmail = json['cmail'];
    smanid = json['smanid'];
    companyid = json['companyid'];
    creditDays = json['credit_days'];
    creditLimit = json['credit_limit'];
    cdPer = json['cd_per'];
    dl1 = json['dl1'];
    dl2 = json['dl2'];
    dl3 = json['dl3'];
    dlvalidupto = json['dlvalidupto'];
    alcode = json['alcode'];
    gstin = json['gstin'];
    pan1 = json['pan_1'];
    zoneid = json['zoneid'];
    locks = json['locks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['regcode'] = this.regcode;
    data['type'] = this.type;
    data['ledid_party'] = this.ledidParty;
    data['partycode'] = this.partycode;
    data['partyname'] = this.partyname;
    data['sman'] = this.sman;
    data['add_1'] = this.add1;
    data['add_2'] = this.add2;
    data['area'] = this.area;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['teleno'] = this.teleno;
    data['mobileno'] = this.mobileno;
    data['email'] = this.email;
    data['zone'] = this.zone;
    data['contactperson'] = this.contactperson;
    data['ccategory'] = this.ccategory;
    data['cgrade'] = this.cgrade;
    data['cgradereason'] = this.cgradereason;
    data['cmail'] = this.cmail;
    data['smanid'] = this.smanid;
    data['companyid'] = this.companyid;
    data['credit_days'] = this.creditDays;
    data['credit_limit'] = this.creditLimit;
    data['cd_per'] = this.cdPer;
    data['dl1'] = this.dl1;
    data['dl2'] = this.dl2;
    data['dl3'] = this.dl3;
    data['dlvalidupto'] = this.dlvalidupto;
    data['alcode'] = this.alcode;
    data['gstin'] = this.gstin;
    data['pan_1'] = this.pan1;
    data['zoneid'] = this.zoneid;
    data['locks'] = this.locks;
    return data;
  }
}

class Product {
  int? pid;
  String? pname;
  String? packing;
  String? dmfg;
  Null? pcategory;
  String? mrp;
  int? pcode;
  int? itemdetailid;
  String? box;
  String? ptr;
  int? dCompanyid;
  Null? locaked;
  String? companyname;
  String? totalStock;
  String? scheme;
  String? grpidGenNames;

  Product(
      {this.pid,
        this.pname,
        this.packing,
        this.dmfg,
        this.pcategory,
        this.mrp,
        this.pcode,
        this.itemdetailid,
        this.box,
        this.ptr,
        this.dCompanyid,
        this.locaked,
        this.companyname,
        this.totalStock,
        this.scheme,
        this.grpidGenNames});

  Product.fromJson(Map<String, dynamic> json) {
    pid = json['pid'];
    pname = json['pname'];
    packing = json['packing'];
    dmfg = json['dmfg'];
    pcategory = json['pcategory'];
    mrp = json['mrp'];
    pcode = json['pcode'];
    itemdetailid = json['itemdetailid'];
    box = json['box'];
    ptr = json['ptr'];
    dCompanyid = json['d_companyid'];
    locaked = json['locaked'];
    companyname = json['companyname'];
    totalStock = json['total_stock'];
    scheme = json['scheme'];
    grpidGenNames = json['grpid_gen_names'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pid'] = this.pid;
    data['pname'] = this.pname;
    data['packing'] = this.packing;
    data['dmfg'] = this.dmfg;
    data['pcategory'] = this.pcategory;
    data['mrp'] = this.mrp;
    data['pcode'] = this.pcode;
    data['itemdetailid'] = this.itemdetailid;
    data['box'] = this.box;
    data['ptr'] = this.ptr;
    data['d_companyid'] = this.dCompanyid;
    data['locaked'] = this.locaked;
    data['companyname'] = this.companyname;
    data['total_stock'] = this.totalStock;
    data['scheme'] = this.scheme;
    data['grpid_gen_names'] = this.grpidGenNames;
    return data;
  }
}
