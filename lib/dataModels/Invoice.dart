class Invoice {
  String regcode;
  int companyid;
  int invid;
  String invdate;
  int invno;
  String orderno;
  String orderdate;
  int creditdays;
  int ledidParty;
  double invamt;
  double cnamt;
  double recdamt;
  double balance;
  String? transport;
  String lrno;
  String? lrdate;
  int brchid;
  String prefix;
  String duedate;
  int smanid;
  String lupdate;
  String? dupdate;
  String dman;
  String? mobile;
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
  String? dCode;
  String area;
  String add1;
  String add2;
  String city;
  int? pincode; // Make nullable
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
    this.pincode, // Nullable
    required this.mobileno,
    required this.email,
    required this.teleno,
    this.details,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      regcode: json['regcode'] ?? '',
      companyid: json['companyid'] ?? 0,
      invid: json['invid'] ?? 0,
      invdate: json['invdate'] ?? '',
      invno: json['invno'] ?? 0,
      orderno: json['orderno'] ?? '',
      orderdate: json['orderdate'] ?? '',
      creditdays: json['creditdays'] ?? 0,
      ledidParty: json['ledid_party'] ?? 0,
      invamt: double.tryParse(json['invamt'].toString()) ?? 0.0,
      cnamt: double.tryParse(json['cnamt'].toString()) ?? 0.0,
      recdamt: double.tryParse(json['recdamt'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      transport: json['transport'],
      lrno: json['lrno'] ?? '',
      lrdate: json['lrdate'],
      brchid: json['brchid'] ?? 0,
      prefix: json['prefix'] ?? '',
      duedate: json['duedate'] ?? '',
      smanid: json['smanid'] ?? 0,
      lupdate: json['lupdate'] ?? '',
      dupdate: json['dupdate'],
      dman: json['dman'] ?? '',
      mobile: json['mobile'],
      barcode: json['barcode'] ?? '',
      tdamount: json['tdamount'] != null ? double.tryParse(json['tdamount'].toString()) : null,
      cdamount: json['cdamount'] != null ? double.tryParse(json['cdamount'].toString()) : null,
      schamt: double.tryParse(json['schamt'].toString()) ?? 0.0,
      sgstamt: double.tryParse(json['sgstamt'].toString()) ?? 0.0,
      cgstamt: double.tryParse(json['cgstamt'].toString()) ?? 0.0,
      igstamt: double.tryParse(json['igstamt'].toString()) ?? 0.0,
      gcessamt: double.tryParse(json['gcessamt'].toString()) ?? 0.0,
      tdamt: double.tryParse(json['tdamt'].toString()) ?? 0.0,
      cdamt: double.tryParse(json['cdamt'].toString()) ?? 0.0,
      partyname: json['partyname'] ?? '',
      dCode: json['d_code'],
      area: json['area'] ?? '',
      add1: json['add_1'] ?? '',
      add2: json['add_2'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'], // Nullable
      mobileno: json['mobileno'] ?? '',
      email: json['email'] ?? '',
      teleno: json['teleno'] ?? '',
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
  String invdate;
  String orderno;
  String orderdate;
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
  String duedate;
  int smanid;
  String pname;
  String package;

  ItemDetail({
    required this.regcode,
    required this.companyid,
    required this.invid,
    required this.invno,
    required this.invdate,
    required this.orderno,
    required this.orderdate,
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
    required this.duedate,
    required this.smanid,
    required this.pname,
    required this.package,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      regcode: json['regcode'] ?? '',
      companyid: json['companyid'] ?? 0,
      invid: json['invid'] ?? 0,
      invno: json['invno'] ?? 0,
      invdate: json['invdate'] ?? '',
      orderno: json['orderno'] ?? '',
      orderdate: json['orderdate'] ?? '',
      ledidParty: json['ledid_party'] ?? 0,
      itemdetailid: json['itemdetailid'] ?? 0,
      qty: json['qty'] ?? 0,
      schqty: json['schqty'] ?? 0,
      rate: double.tryParse(json['rate'].toString()) ?? 0.0,
      mrp: double.tryParse(json['mrp'].toString()) ?? 0.0,
      schPer: double.tryParse(json['sch_per'].toString()) ?? 0.0,
      cdPer: double.tryParse(json['cd_per'].toString()) ?? 0.0,
      brchid: json['brchid'] ?? 0,
      sgstPer: double.tryParse(json['sgst_per'].toString()) ?? 0.0,
      cgstPer: double.tryParse(json['cgst_per'].toString()) ?? 0.0,
      igstPer: double.tryParse(json['igst_per'].toString()) ?? 0.0,
      gcessPer: double.tryParse(json['gcess_per'].toString()) ?? 0.0,
      sgstAmt: double.tryParse(json['sgst_amt'].toString()) ?? 0.0,
      cgstAmt: double.tryParse(json['cgst_amt'].toString()) ?? 0.0,
      igstAmt: double.tryParse(json['igst_amt'].toString()) ?? 0.0,
      gcessAmt: double.tryParse(json['gcess_amt'].toString()) ?? 0.0,
      prefix: json['prefix'] ?? '',
      creditdays: json['creditdays'] ?? 0,
      duedate: json['duedate'] ?? '',
      smanid: json['smanid'] ?? 0,
      pname: json['pname'] ?? '',
      package: json['package'] ?? '',
    );
  }
}
