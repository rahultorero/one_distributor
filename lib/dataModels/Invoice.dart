class Invoice {
  String regcode;
  int companyid;
  int invid;
  String invdate; // Changed to String
  int invno;
  String orderno;
  String orderdate; // Changed to String
  int creditdays;
  int ledidParty;
  double invamt;
  double cnamt;
  double recdamt;
  double balance;
  String? transport;
  String lrno;
  String? lrdate; // Changed to String?
  int brchid;
  String prefix;
  String duedate; // Changed to String
  int smanid;
  String lupdate; // Changed to String
  String? dupdate; // Changed to String?
  String dman;
  String? mobile; // Changed to String?
  String barcode;
  double? tdamount;
  double? cdamount;
  double schamt;
  double sgstamt;
  double cgstamt;
  double igstamt;
  double gcessamt;
  double tdamt;
  double cdamt;
  String partyname;
  String? dCode; // Changed to String?
  String area;
  String add1;
  String add2;
  String city;
  int pincode;
  String mobileno;
  String email;
  String teleno;
  List<ItemDetail>? details;

  Invoice({
    required this.regcode,
    required this.companyid,
    required this.invid,
    required this.invdate,
    required this.invno,
    required this.orderno,
    required this.orderdate,
    required this.creditdays,
    required this.ledidParty,
    required this.invamt,
    required this.cnamt,
    required this.recdamt,
    required this.balance,
    this.transport,
    required this.lrno,
    this.lrdate,
    required this.brchid,
    required this.prefix,
    required this.duedate,
    required this.smanid,
    required this.lupdate,
    this.dupdate,
    required this.dman,
    this.mobile,
    required this.barcode,
    this.tdamount,
    this.cdamount,
    required this.schamt,
    required this.sgstamt,
    required this.cgstamt,
    required this.igstamt,
    required this.gcessamt,
    required this.tdamt,
    required this.cdamt,
    required this.partyname,
    this.dCode,
    required this.area,
    required this.add1,
    required this.add2,
    required this.city,
    required this.pincode,
    required this.mobileno,
    required this.email,
    required this.teleno,
    this.details,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      regcode: json['regcode'] ?? '', // Provide a default value
      companyid: json['companyid'],
      invid: json['invid'],
      invdate: json['invdate'] ?? '', // Provide a default value
      invno: json['invno'],
      orderno: json['orderno'] ?? '', // Provide a default value
      orderdate: json['orderdate'] ?? '', // Provide a default value
      creditdays: json['creditdays'],
      ledidParty: json['ledid_party'],
      invamt: double.tryParse(json['invamt'].toString()) ?? 0.0, // Handle parsing
      cnamt: double.tryParse(json['cnamt'].toString()) ?? 0.0, // Handle parsing
      recdamt: double.tryParse(json['recdamt'].toString()) ?? 0.0, // Handle parsing
      balance: double.tryParse(json['balance'].toString()) ?? 0.0, // Handle parsing
      transport: json['transport'],
      lrno: json['lrno'] ?? '', // Provide a default value
      lrdate: json['lrdate'] ?? '', // Provide a default value
      brchid: json['brchid'],
      prefix: json['prefix'] ?? '', // Provide a default value
      duedate: json['duedate'] ?? '', // Provide a default value
      smanid: json['smanid'],
      lupdate: json['lupdate'] ?? '', // Provide a default value
      dupdate: json['dupdate'] ?? '', // Provide a default value
      dman: json['dman'] ?? '', // Provide a default value
      mobile: json['mobile'], // Keep as nullable
      barcode: json['barcode'] ?? '', // Provide a default value
      tdamount: json['tdamount'] != null ? double.tryParse(json['tdamount'].toString()) : null,
      cdamount: json['cdamount'] != null ? double.tryParse(json['cdamount'].toString()) : null,
      schamt: double.tryParse(json['schamt'].toString()) ?? 0.0, // Handle parsing
      sgstamt: double.tryParse(json['sgstamt'].toString()) ?? 0.0, // Handle parsing
      cgstamt: double.tryParse(json['cgstamt'].toString()) ?? 0.0, // Handle parsing
      igstamt: double.tryParse(json['igstamt'].toString()) ?? 0.0, // Handle parsing
      gcessamt: double.tryParse(json['gcessamt'].toString()) ?? 0.0, // Handle parsing
      tdamt: double.tryParse(json['tdamt'].toString()) ?? 0.0, // Handle parsing
      cdamt: double.tryParse(json['cdamt'].toString()) ?? 0.0, // Handle parsing
      partyname: json['partyname'] ?? '', // Provide a default value
      dCode: json['d_code'], // Keep as nullable
      area: json['area'] ?? '', // Provide a default value
      add1: json['add_1'] ?? '', // Provide a default value
      add2: json['add_2'] ?? '', // Provide a default value
      city: json['city'] ?? '', // Provide a default value
      pincode: json['pincode'] ?? 0, // Provide a default value
      mobileno: json['mobileno'] ?? '', // Provide a default value
      email: json['email'] ?? '', // Provide a default value
      teleno: json['teleno'] ?? '', // Provide a default value
      details: json['details'] != null && (json['details'] is List)
          ? (json['details'] as List).map((i) => ItemDetail.fromJson(i)).toList()
          : null,
    );
  }
}

class ItemDetail {
  String regcode;
  int companyid;
  int invid;
  int invno;
  String invdate; // Changed to String
  String orderno;
  String orderdate; // Changed to String
  int ledidParty;
  int itemdetailid;
  int qty;
  int schqty;
  double rate;
  double mrp;
  double schPer;
  double cdPer;
  int brchid;
  double sgstPer;
  double cgstPer;
  double igstPer;
  double gcessPer;
  double sgstAmt;
  double cgstAmt;
  double igstAmt;
  double gcessAmt;
  String prefix;
  int creditdays;
  String duedate; // Changed to String
  int smanid;
  String pname;
  String packageUnit;
  int packUnit;

  ItemDetail({
    required this.regcode,
    required this.companyid,
    required this.invid,
    required this.invno,
    required this.invdate, // Keep as String
    required this.orderno,
    required this.orderdate, // Keep as String
    required this.ledidParty,
    required this.itemdetailid,
    required this.qty,
    required this.schqty,
    required this.rate,
    required this.mrp,
    required this.schPer,
    required this.cdPer,
    required this.brchid,
    required this.sgstPer,
    required this.cgstPer,
    required this.igstPer,
    required this.gcessPer,
    required this.sgstAmt,
    required this.cgstAmt,
    required this.igstAmt,
    required this.gcessAmt,
    required this.prefix,
    required this.creditdays,
    required this.duedate, // Keep as String
    required this.smanid,
    required this.pname,
    required this.packageUnit,
    required this.packUnit,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      regcode: json['regcode'] ?? '', // Provide a default value
      companyid: json['companyid'],
      invid: json['invid'],
      invno: json['invno'],
      invdate: json['invdate'] ?? '', // Provide a default value
      orderno: json['orderno'] ?? '', // Provide a default value
      orderdate: json['orderdate'] ?? '', // Provide a default value
      ledidParty: json['ledid_party'],
      itemdetailid: json['itemdetailid'],
      qty: json['qty'],
      schqty: json['schqty'],
      rate: double.tryParse(json['rate'].toString()) ?? 0.0, // Handle parsing
      mrp: double.tryParse(json['mrp'].toString()) ?? 0.0, // Handle parsing
      schPer: double.tryParse(json['sch_per'].toString()) ?? 0.0, // Handle parsing
      cdPer: double.tryParse(json['cd_per'].toString()) ?? 0.0, // Handle parsing
      brchid: json['brchid'],
      sgstPer: double.tryParse(json['sgst_per'].toString()) ?? 0.0, // Handle parsing
      cgstPer: double.tryParse(json['cgst_per'].toString()) ?? 0.0, // Handle parsing
      igstPer: double.tryParse(json['igst_per'].toString()) ?? 0.0, // Handle parsing
      gcessPer: double.tryParse(json['gcess_per'].toString()) ?? 0.0, // Handle parsing
      sgstAmt: double.tryParse(json['sgst_amt'].toString()) ?? 0.0, // Handle parsing
      cgstAmt: double.tryParse(json['cgst_amt'].toString()) ?? 0.0, // Handle parsing
      igstAmt: double.tryParse(json['igst_amt'].toString()) ?? 0.0, // Handle parsing
      gcessAmt: double.tryParse(json['gcess_amt'].toString()) ?? 0.0, // Handle parsing
      prefix: json['prefix'] ?? '', // Provide a default value
      creditdays: json['creditdays'],
      duedate: json['duedate'] ?? '', // Provide a default value
      smanid: json['smanid'],
      pname: json['pname'] ?? '', // Provide a default value
      packageUnit: json['package_unit'] ?? '', // Provide a default value
      packUnit: json['pack_unit'] ?? 0, // Provide a default value
    );
  }
}
