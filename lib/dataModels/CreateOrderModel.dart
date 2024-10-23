class CreateOrderModel {
  List<Orders>? data;
  String? remark;
  String? grpCode;
  int? ohid;
  List<int>? companyId;
  int? salesmanId;
  int? cusrid;
  String? userType;
  int? dType;
  int? orderStatus;

  CreateOrderModel({
    this.data,
    this.remark,
    this.grpCode,
    this.ohid,
    this.companyId,
    this.salesmanId,
    this.cusrid,
    this.userType,
    this.dType,
    this.orderStatus,
  });

  // fromJson constructor
  CreateOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Orders>[];
      json['data'].forEach((v) {
        data!.add(Orders.fromJson(v));
      });
    }
    remark = json['remark'];
    grpCode = json['grp_code'];
    ohid = json['ohid'];
    companyId = json['company_id']?.cast<int>();
    salesmanId = json['salesman_id'];
    cusrid = json['cusrid'];
    userType = json['user_type'];
    dType = json['d_type'];
    orderStatus = json['order_status'];
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['remark'] = remark;
    data['grp_code'] = grpCode;
    data['ohid'] = ohid;
    data['company_id'] = companyId;
    data['salesman_id'] = salesmanId;
    data['cusrid'] = cusrid;
    data['user_type'] = userType;
    data['d_type'] = dType;
    data['order_status'] = orderStatus;
    return data;
  }
}

class Orders {
  int? itemDetailid;
  int? ledidParty;
  int? qty;
  int? free;
  double? schPercentage;
  String? rate;
  String? mrp;
  String? ptr;
  String? amount;
  String? remark;
  int? companyid;
  int? pid;
  int? odid;

  Orders({
    this.itemDetailid,
    this.ledidParty,
    this.qty,
    this.free,
    this.schPercentage,
    this.rate,
    this.mrp,
    this.ptr,
    this.amount,
    this.remark,
    this.companyid,
    this.pid,
    this.odid,
  });

  // fromJson constructor
  Orders.fromJson(Map<String, dynamic> json) {
    itemDetailid = json['item_detailid'];
    ledidParty = json['ledid_party'];
    qty = json['qty'];
    free = json['free'];
    schPercentage = json['sch_percentage'];
    rate = json['rate'].toString(); // Ensure that rate is a string
    mrp = json['mrp'].toString(); // Ensure that mrp is a string
    ptr = json['ptr'].toString(); // Ensure that ptr is a string
    amount = json['amount'].toString(); // Ensure that amount is a string
    remark = json['remark'];
    companyid = json['companyid'];
    pid = json['pid'];
    odid = json['odid'];
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_detailid'] = itemDetailid;
    data['ledid_party'] = ledidParty;
    data['qty'] = qty;
    data['free'] = free;
    data['sch_percentage'] = schPercentage;
    data['rate'] = rate;
    data['mrp'] = mrp;
    data['ptr'] = ptr;
    data['amount'] = amount;
    data['remark'] = remark;
    data['companyid'] = companyid;
    data['pid'] = pid;
    data['odid'] = odid;
    return data;
  }
}
