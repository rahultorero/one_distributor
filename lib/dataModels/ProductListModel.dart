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
  double? get total => qty * (rate ?? 0);

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
    name = json['name'];
    packing = json['packing'];
    scheme = json['scheme'];
    itemDetailid = json['item_detailid'];
    ledidParty = json['ledid_party'];
    qty = json['qty'] ?? 0; // Ensure `qty` is not null
    free = json['free'] ?? 0; // Provide default value if null
    schPercentage = json['sch_percentage'];
    rate = (json['rate'] != null) ? (json['rate'] is int ? (json['rate'] as int).toDouble() : json['rate']) : null;
    mrp = json['mrp'];
    ptr = json['ptr'];
    amount = json['amount'];
    remark = json['remark'];
    companyid = json['companyid'];
    pid = json['pid'];
    odid = json['odid'];
    stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packing': packing,
      'scheme': scheme,
      'item_detailid': itemDetailid,
      'ledid_party': ledidParty,
      'qty': qty,
      'free': free,
      'sch_percentage': schPercentage,
      'rate': rate,
      'mrp': mrp,
      'ptr': ptr,
      'amount': amount,
      'remark': remark,
      'companyid': companyid,
      'pid': pid,
      'odid': odid,
      'stock': stock,
    };
  }
}
