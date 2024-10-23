class OrderDetailsRes {
  String message;
  int status;
  List<OrderDetail> data;

  OrderDetailsRes({
    required this.message,
    required this.status,
    required this.data,
  });

  factory OrderDetailsRes.fromJson(Map<String, dynamic> json) {
    return OrderDetailsRes(
      message: json['message'] ?? '', // Default to an empty string if null
      status: json['status'] ?? 0,     // Default to 0 if null
      data: (json['data'] as List<dynamic>)
          .map((item) => OrderDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderDetail {
  int pid;
  String productName;
  int pcode;
  String packing;
  String manufacturerName;
  int odid;
  int ohid;
  int itemDetailId;
  int qty;
  int free;
  String? schPercentage; // Nullable field
  String rate;
  String mrp;
  String ptr;
  String amount;
  String? remark; // Nullable field
  int companyId;
  String schRate;
  int itemNo;
  String? lsq; // Nullable field

  OrderDetail({
    required this.pid,
    required this.productName,
    required this.pcode,
    required this.packing,
    required this.manufacturerName,
    required this.odid,
    required this.ohid,
    required this.itemDetailId,
    required this.qty,
    required this.free,
    this.schPercentage, // Nullable
    required this.rate,
    required this.mrp,
    required this.ptr,
    required this.amount,
    this.remark, // Nullable
    required this.companyId,
    required this.schRate,
    required this.itemNo,
    this.lsq, // Nullable
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      pid: json['pid'],
      productName: json['product_name'] ?? '', // Default to an empty string if null
      pcode: json['pcode'],
      packing: json['packing'] ?? '', // Default to an empty string if null
      manufacturerName: json['manufacturer_name'] ?? '', // Default to an empty string if null
      odid: json['odid'],
      ohid: json['ohid'],
      itemDetailId: json['item_detailid'],
      qty: json['qty'],
      free: json['free'],
      schPercentage: json['sch_percentage'], // Nullable
      rate: json['rate'],
      mrp: json['mrp'],
      ptr: json['ptr'],
      amount: json['amount'],
      remark: json['remark'], // Nullable
      companyId: json['companyid'],
      schRate: json['sch_rate'],
      itemNo: json['item_no'],
      lsq: json['lsq'], // Nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'product_name': productName,
      'pcode': pcode,
      'packing': packing,
      'manufacturer_name': manufacturerName,
      'odid': odid,
      'ohid': ohid,
      'item_detailid': itemDetailId,
      'qty': qty,
      'free': free,
      'sch_percentage': schPercentage, // Nullable
      'rate': rate,
      'mrp': mrp,
      'ptr': ptr,
      'amount': amount,
      'remark': remark, // Nullable
      'companyid': companyId,
      'sch_rate': schRate,
      'item_no': itemNo,
      'lsq': lsq, // Nullable
    };
  }
}
