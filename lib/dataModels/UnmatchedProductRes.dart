class UnMatchProductResponse {
  String? message;
  int? statusCode;
  int? count;
  List<UnMatchProductModel>? data;

  UnMatchProductResponse(
      {this.message, this.statusCode, this.count, this.data});

  UnMatchProductResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    count = json['count'];
    if (json['data'] != null) {
      data = <UnMatchProductModel>[];
      json['data'].forEach((v) {
        data!.add(new UnMatchProductModel.fromJson(v));
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

class UnMatchProductModel {
  Null? dmfgid;
  Null? pmfgid;
  String? pname;
  int? pid;
  String? aCode;
  String? dmfgName;
  String? pmfgName;
  String? packing;
  Null? grpidGenName;

  UnMatchProductModel(
      {this.dmfgid,
        this.pmfgid,
        this.pname,
        this.pid,
        this.aCode,
        this.dmfgName,
        this.pmfgName,
        this.packing,
        this.grpidGenName});

  UnMatchProductModel.fromJson(Map<String, dynamic> json) {
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
