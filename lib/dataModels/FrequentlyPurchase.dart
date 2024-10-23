class FrequentlyPurchase {
  String? message;
  int? status;
  List<FrequentlyItems>? data;

  FrequentlyPurchase({this.message, this.status, this.data});

  FrequentlyPurchase.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    if (json['data'] != null) {
      data = <FrequentlyItems>[];
      json['data'].forEach((v) {
        data!.add(new FrequentlyItems.fromJson(v));
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

class FrequentlyItems {
  int? itemdetailid;
  int? pid;
  String? pname;
  String? packing;
  String? genericName;
  String? totalQty;
  String? totalStock;
  String? scheme;
  int? ptime;
  int? pcode;
  int? dCompanyid;
  String? ptr;
  double rate =  0.0;
  String? mrp;
  int qty = 0;
  int free = 0;
  String? remark;
  double get total => qty! * rate!;

  FrequentlyItems(
      {this.itemdetailid,
        this.pid,
        this.pname,
        this.packing,
        this.genericName,
        this.totalQty,
        this.totalStock,
        this.scheme,
        this.ptime,
        this.pcode,
        this.dCompanyid,
        this.ptr,
        this.mrp});

  FrequentlyItems.fromJson(Map<String, dynamic> json) {
    itemdetailid = json['itemdetailid'];
    pid = json['pid'];
    pname = json['pname'];
    packing = json['packing'];
    genericName = json['generic_name'];
    totalQty = json['total_qty'];
    totalStock = json['total_stock'];
    scheme = json['scheme'];
    ptime = json['ptime'];
    pcode = json['pcode'];
    dCompanyid = json['d_companyid'];
    ptr = json['ptr'];
    mrp = json['mrp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemdetailid'] = this.itemdetailid;
    data['pid'] = this.pid;
    data['pname'] = this.pname;
    data['packing'] = this.packing;
    data['generic_name'] = this.genericName;
    data['total_qty'] = this.totalQty;
    data['total_stock'] = this.totalStock;
    data['scheme'] = this.scheme;
    data['ptime'] = this.ptime;
    data['pcode'] = this.pcode;
    data['d_companyid'] = this.dCompanyid;
    data['ptr'] = this.ptr;
    data['mrp'] = this.mrp;
    return data;
  }
}
