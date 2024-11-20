class MappedProductRes {
  String? message;
  int? code;
  late List<MappedProduct> data;
  String? totalCount;

  MappedProductRes({this.message, this.code, required this.data, this.totalCount});

  MappedProductRes.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
    if (json['data'] != null) {
      data = <MappedProduct>[];
      json['data'].forEach((v) {
        data!.add(new MappedProduct.fromJson(v));
      });
    }
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class MappedProduct {
  int? id;
  int? dPid;
  String? oPacking;
  String? oPname;
  String? oParent;
  String? oChild;
  String? oRegcode;
  String? mPname;
  String? mPacking;
  String? mChild;
  String? mParent;
  int? mCompanyid;
  int? mItemdetailid;
  int? mPcode;
  String? mGrpidGenName;
  String? oGrpidGenName;

  MappedProduct(
      {
        required this.id,
        this.dPid,
        this.oPacking,
        this.oPname,
        this.oParent,
        this.oChild,
        this.oRegcode,
        this.mPname,
        this.mPacking,
        this.mChild,
        this.mParent,
        this.mCompanyid,
        this.mItemdetailid,
        this.mPcode,
        this.mGrpidGenName,
        this.oGrpidGenName});

  MappedProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    dPid = json['d_pid'];
    oPacking = json['o_packing'];
    oPname = json['o_pname'];
    oParent = json['o_parent'];
    oChild = json['o_child'];
    oRegcode = json['o_regcode'];
    mPname = json['m_pname'];
    mPacking = json['m_packing'];
    mChild = json['m_child'];
    mParent = json['m_parent'];
    mCompanyid = json['m_companyid'];
    mItemdetailid = json['m_itemdetailid'];
    mPcode = json['m_pcode'];
    mGrpidGenName = json['m_grpid_gen_name'];
    oGrpidGenName = json['o_grpid_gen_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['d_pid'] = this.dPid;
    data['o_packing'] = this.oPacking;
    data['o_pname'] = this.oPname;
    data['o_parent'] = this.oParent;
    data['o_child'] = this.oChild;
    data['o_regcode'] = this.oRegcode;
    data['m_pname'] = this.mPname;
    data['m_packing'] = this.mPacking;
    data['m_child'] = this.mChild;
    data['m_parent'] = this.mParent;
    data['m_companyid'] = this.mCompanyid;
    data['m_itemdetailid'] = this.mItemdetailid;
    data['m_pcode'] = this.mPcode;
    data['m_grpid_gen_name'] = this.mGrpidGenName;
    data['o_grpid_gen_name'] = this.oGrpidGenName;
    return data;
  }
}
