class TopProductRes {
  int? statusCode;
  List<TopProduct>? data;

  TopProductRes({this.statusCode, this.data});

  TopProductRes.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <TopProduct>[];
      json['data'].forEach((v) {
        data!.add(new TopProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopProduct{
  String? pname;
  String? packing;
  int? itemdetailid;
  int? productCount;

  TopProduct({this.pname, this.packing, this.itemdetailid, this.productCount});

  TopProduct.fromJson(Map<String, dynamic> json) {
    pname = json['pname'];
    packing = json['packing'];
    itemdetailid = json['itemdetailid'];
    productCount = json['product_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pname'] = this.pname;
    data['packing'] = this.packing;
    data['itemdetailid'] = this.itemdetailid;
    data['product_count'] = this.productCount;
    return data;
  }
}
