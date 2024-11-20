class UnMappedProductRes {
  String? message;
  int? statusCode;
  int? count;
  List<UnmappedProduct>? data;

  UnMappedProductRes({this.message, this.statusCode, this.count, this.data});

  UnMappedProductRes.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    count = json['count'];
    if (json['data'] != null) {
      data = <UnmappedProduct>[];
      json['data'].forEach((v) {
        data!.add(new UnmappedProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UnmappedProduct {
  String? dmfgid;
  String? pmfgid;
  String? pname;
  int? pid;
  String? aCode;
  String? dmfgName;
  String? pmfgName;
  String? packing;
  String? grpidGenName;

  UnmappedProduct(
      {this.dmfgid,
        this.pmfgid,
        this.pname,
        this.pid,
        this.aCode,
        this.dmfgName,
        this.pmfgName,
        this.packing,
        this.grpidGenName});

  UnmappedProduct.fromJson(Map<String, dynamic> json) {
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
