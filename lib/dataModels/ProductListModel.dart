class ProductListItem {
  List<ProductList>? data;
  String? remark;
  String? grpCode;
  int? ohid;
  List<int>? companyId;
  int? salesmanId;
  int? cusrid;
  String? userType;
  int? dType;
  int? orderStatus;

  ProductListItem(
      {this.data,
        this.remark,
        this.grpCode,
        this.ohid,
        this.companyId,
        this.salesmanId,
        this.cusrid,
        this.userType,
        this.dType,
        this.orderStatus});

  ProductListItem.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ProductList>[];
      json['data'].forEach((v) {
        data!.add(new ProductList.fromJson(v));
      });
    }
    remark = json['remark'];
    grpCode = json['grp_code'];
    ohid = json['ohid'];
    companyId = json['company_id'].cast<int>();
    salesmanId = json['salesman_id'];
    cusrid = json['cusrid'];
    userType = json['user_type'];
    dType = json['d_type'];
    orderStatus = json['order_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['remark'] = this.remark;
    data['grp_code'] = this.grpCode;
    data['ohid'] = this.ohid;
    data['company_id'] = this.companyId;
    data['salesman_id'] = this.salesmanId;
    data['cusrid'] = this.cusrid;
    data['user_type'] = this.userType;
    data['d_type'] = this.dType;
    data['order_status'] = this.orderStatus;
    return data;
  }
}

class ProductList {
  String? name;
  String? packing;
  String? scheme;
  int? itemDetailid;
  int? ledidParty;
  int qty = 0;
  int? free;
  String? schPercentage;
  double? rate;
  String? mrp;
  String? ptr;
  String? amount;
  String? remark;
  int? companyid;
  int? pid;
  int? odid;
  String? stock;
  double? get total => qty! * rate!;

  ProductList(
      {
        this.name,
        this.packing,
        this.scheme,
        this.itemDetailid,
        this.ledidParty,
        required this.qty,
        this.free,
        this.schPercentage,
        this.rate,
        this.mrp,
        this.ptr,
        this.amount,
        this.remark,
        this.companyid,
        this.pid,
        this.stock,
        this.odid});

  ProductList.fromJson(Map<String, dynamic> json) {
    itemDetailid = json['item_detailid'];
    ledidParty = json['ledid_party'];
    qty = json['qty'];
    free = json['free'] ?? 0;
    schPercentage = json['sch_percentage'];
    rate = json['rate'];
    mrp = json['mrp'];
    ptr = json['ptr'];
    amount = json['amount'];
    remark = json['remark'];
    companyid = json['companyid'];
    pid = json['pid'];
    odid = json['odid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_detailid'] = this.itemDetailid;
    data['ledid_party'] = this.ledidParty;
    data['qty'] = this.qty;
    data['free'] = this.free;
    data['sch_percentage'] = this.schPercentage;
    data['rate'] = this.rate;
    data['mrp'] = this.mrp;
    data['ptr'] = this.ptr;
    data['amount'] = this.amount;
    data['remark'] = this.remark;
    data['companyid'] = this.companyid;
    data['pid'] = this.pid;
    data['odid'] = this.odid;
    return data;
  }
}
