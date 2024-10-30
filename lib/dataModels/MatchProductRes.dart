class MatchProductResponse {
  List<MatchProductModel>? data;
  int totalProduct;

  MatchProductResponse({this.data, required this.totalProduct});

  MatchProductResponse.fromJson(Map<String, dynamic> json)
      : totalProduct = json['totalProduct'] ?? 0 { // Add default if 'totalProduct' is null
    if (json['data'] != null) {
      data = <MatchProductModel>[];
      json['data'].forEach((v) {
        data!.add(MatchProductModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalProduct'] = totalProduct;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class MatchProductModel {
  String? pname;
  String? regcode;
  String? packing;
  int? itemdetailid;
  int? companyid;
  String? dmfg;
  String? pmfg;
  String? generic;
  int? pcode;
  List<MatchProduct>? matchProduct;

  MatchProductModel(
      {this.pname,
        this.regcode,
        this.packing,
        this.itemdetailid,
        this.companyid,
        this.dmfg,
        this.pmfg,
        this.generic,
        this.pcode,
        this.matchProduct});

  MatchProductModel.fromJson(Map<String, dynamic> json) {
    pname = json['pname'];
    regcode = json['regcode'];
    packing = json['packing'];
    itemdetailid = json['itemdetailid'];
    companyid = json['companyid'];
    dmfg = json['dmfg'];
    pmfg = json['pmfg'];
    generic = json['generic'];
    pcode = json['pcode'];
    if (json['match_product'] != null) {
      matchProduct = <MatchProduct>[];
      json['match_product'].forEach((v) {
        matchProduct!.add(new MatchProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pname'] = this.pname;
    data['regcode'] = this.regcode;
    data['packing'] = this.packing;
    data['itemdetailid'] = this.itemdetailid;
    data['companyid'] = this.companyid;
    data['dmfg'] = this.dmfg;
    data['pmfg'] = this.pmfg;
    data['generic'] = this.generic;
    data['pcode'] = this.pcode;
    if (this.matchProduct != null) {
      data['match_product'] =
          this.matchProduct!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MatchProduct {
  int? dmfgid;
  int? pmfgid;
  String? pname;
  int? pid;
  String? aCode;
  String? dmfgName;
  String? pmfgName;
  String? packing;
  String? grpidGenName;

  MatchProduct(
      {this.dmfgid,
        this.pmfgid,
        this.pname,
        this.pid,
        this.aCode,
        this.dmfgName,
        this.pmfgName,
        this.packing,
        this.grpidGenName});

  MatchProduct.fromJson(Map<String, dynamic> json) {
    dmfgid = json['dmfgid'];
    pmfgid = json['pmfgid'];
    pname = json['pname'];
    pid = json['pid'];
    aCode = json['a_code'];
    dmfgName = json['dmfg_name'];
    pmfgName = json['pmfg_name'];
    packing = json['packing'];
    grpidGenName = json['grpid_gen_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dmfgid'] = this.dmfgid;
    data['pmfgid'] = this.pmfgid;
    data['pname'] = this.pname;
    data['pid'] = this.pid;
    data['a_code'] = this.aCode;
    data['dmfg_name'] = this.dmfgName;
    data['pmfg_name'] = this.pmfgName;
    data['packing'] = this.packing;
    data['grpid_gen_name'] = this.grpidGenName;
    return data;
  }
}
