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

class TopProduct {
  String? pname;
  String? packing;
  String? invoiceDate;
  num? rate;
  num? totalStock;
  num? grsamt;
  num? productQuantity;
  num? itemdetailid;
  num? percentagediff;

  TopProduct(
      {this.pname,
        this.packing,
        this.invoiceDate,
        this.rate,
        this.totalStock,
        this.grsamt,
        this.productQuantity,
        this.itemdetailid,
        this.percentagediff});

  TopProduct.fromJson(Map<String, dynamic> json) {
    pname = json['pname'];
    packing = json['packing'];
    invoiceDate = json['invoice_date'];
    rate = json['rate'];
    totalStock = json['total_stock'];
    grsamt = json['grsamt'];
    productQuantity = json['product_quantity'];
    itemdetailid = json['itemdetailid'];
    percentagediff = json['percentagediff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pname'] = this.pname;
    data['packing'] = this.packing;
    data['invoice_date'] = this.invoiceDate;
    data['rate'] = this.rate;
    data['total_stock'] = this.totalStock;
    data['grsamt'] = this.grsamt;
    data['product_quantity'] = this.productQuantity;
    data['itemdetailid'] = this.itemdetailid;
    data['percentagediff'] = this.percentagediff;
    return data;
  }
}
