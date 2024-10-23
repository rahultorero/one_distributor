import 'package:meta/meta.dart';

class DraftOrderRes {
  final String userName;
  final String companyName;
  final int? ohid;
  final String distId;
  final String orderNo;
  final int? companyId;
  final int? smanId;
  final int? cusrId;
  final String userType;
  final int? orderStatus;
  final String oreMark;
  final String dType;
  final String oDate;
  final String ledidParty;
  final String oAmt;
  final String rid;
  final String createdAt;
  final String? grpCode;
  final String isSync;
  final int? fxdid;
  final int? typeId;
  final String fxdName;
  final String fxdSubName;
  final int? parentId;
  final String deliveryType;
  final String regCode;
  final String type;
  final String partyCode;
  final String partyName;
  final String sman;
  final String add1;
  final String add2;
  final String area;
  final String city;
  final int? pincode;
  final String teleno;
  final String mobileNo;
  final String email;
  final String zone;
  final String contactPerson;
  final String cCategory;
  final String cGrade;
  final String cGradeReason;
  final String cMail;
  final int? creditDays;
  final String creditLimit;
  final String cdPer;
  final String dl1;
  final String dl2;
  final String dl3;
  final String dlValidUpto;
  final String alCode;
  final String gstin;
  final String pan1;
  final int? zoneId;
  final String locks;
  final List<OrderDetail> details;

  DraftOrderRes({
    required this.userName,
    required this.companyName,
    this.ohid,
    required this.distId,
    required this.orderNo,
    this.companyId,
    this.smanId,
    this.cusrId,
    required this.userType,
    this.orderStatus,
    required this.oreMark,
    required this.dType,
    required this.oDate,
    required this.ledidParty,
    required this.oAmt,
    required this.rid,
    required this.createdAt,
    this.grpCode,
    required this.isSync,
    this.fxdid,
    this.typeId,
    required this.fxdName,
    required this.fxdSubName,
    this.parentId,
    required this.deliveryType,
    required this.regCode,
    required this.type,
    required this.partyCode,
    required this.partyName,
    required this.sman,
    required this.add1,
    required this.add2,
    required this.area,
    required this.city,
    this.pincode,
    required this.teleno,
    required this.mobileNo,
    required this.email,
    required this.zone,
    required this.contactPerson,
    required this.cCategory,
    required this.cGrade,
    required this.cGradeReason,
    required this.cMail,
    this.creditDays,
    required this.creditLimit,
    required this.cdPer,
    required this.dl1,
    required this.dl2,
    required this.dl3,
    required this.dlValidUpto,
    required this.alCode,
    required this.gstin,
    required this.pan1,
    this.zoneId,
    required this.locks,
    required this.details,
  });

  factory DraftOrderRes.fromJson(Map<String, dynamic> json) {
    var detailsFromJson = json['details'] as List;
    List<OrderDetail> detailsList = detailsFromJson.map((i) => OrderDetail.fromJson(i)).toList();

    return DraftOrderRes(
      userName: json['user_name']?.toString() ?? '',
      companyName: json['companyname']?.toString() ?? '',
      ohid: json['ohid'] as int?,
      distId: json['dist_id']?.toString() ?? '',
      orderNo: json['orderno']?.toString() ?? '',
      companyId: json['companyid'] as int?,
      smanId: json['smanid'] as int?,
      cusrId: json['cusrid'] as int?,
      userType: json['user_type']?.toString() ?? '',
      orderStatus: json['order_status'] as int?,
      oreMark: json['oremark']?.toString() ?? '',
      dType: json['d_type']?.toString() ?? '',
      oDate: json['odate']?.toString() ?? '',
      ledidParty: json['ledid_party']?.toString() ?? '',
      oAmt: json['oamt']?.toString() ?? '',
      rid: json['rid']?.toString() ?? '',
      createdAt: json['createdat']?.toString() ?? '',
      grpCode: json['grp_code']?.toString(),
      isSync: json['issync']?.toString() ?? '',
      fxdid: json['fxdid'] as int?,
      typeId: json['typeid'] as int?,
      fxdName: json['fxdname']?.toString() ?? '',
      fxdSubName: json['fxdsubname']?.toString() ?? '',
      parentId: json['parentid'] as int?,
      deliveryType: json['delivery_type']?.toString() ?? '',
      regCode: json['regcode']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      partyCode: json['partycode']?.toString() ?? '',
      partyName: json['partyname']?.toString() ?? '',
      sman: json['sman']?.toString() ?? '',
      add1: json['add_1']?.toString() ?? '',
      add2: json['add_2']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode'] as int?,
      teleno: json['teleno']?.toString() ?? '',
      mobileNo: json['mobileno']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      contactPerson: json['contactperson']?.toString() ?? '',
      cCategory: json['ccategory']?.toString() ?? '',
      cGrade: json['cgrade']?.toString() ?? '',
      cGradeReason: json['cgradereason']?.toString() ?? '',
      cMail: json['cmail']?.toString() ?? '',
      creditDays: json['credit_days'] as int?,
      creditLimit: json['credit_limit']?.toString() ?? '',
      cdPer: json['cd_per']?.toString() ?? '',
      dl1: json['dl1']?.toString() ?? '',
      dl2: json['dl2']?.toString() ?? '',
      dl3: json['dl3']?.toString() ?? '',
      dlValidUpto: json['dlvalidupto']?.toString() ?? '',
      alCode: json['alcode']?.toString() ?? '',
      gstin: json['gstin']?.toString() ?? '',
      pan1: json['pan_1']?.toString() ?? '',
      zoneId: json['zoneid'] as int?,
      locks: json['locks']?.toString() ?? '',
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'companyname': companyName,
      'ohid': ohid,
      'dist_id': distId,
      'orderno': orderNo,
      'companyid': companyId,
      'smanid': smanId,
      'cusrid': cusrId,
      'user_type': userType,
      'order_status': orderStatus,
      'oremark': oreMark,
      'd_type': dType,
      'odate': oDate,
      'ledid_party': ledidParty,
      'oamt': oAmt,
      'rid': rid,
      'createdat': createdAt,
      'grp_code': grpCode,
      'issync': isSync,
      'fxdid': fxdid,
      'typeid': typeId,
      'fxdname': fxdName,
      'fxdsubname': fxdSubName,
      'parentid': parentId,
      'delivery_type': deliveryType,
      'regcode': regCode,
      'type': type,
      'partycode': partyCode,
      'partyname': partyName,
      'sman': sman,
      'add_1': add1,
      'add_2': add2,
      'area': area,
      'city': city,
      'pincode': pincode,
      'teleno': teleno,
      'mobileno': mobileNo,
      'email': email,
      'zone': zone,
      'contactperson': contactPerson,
      'ccategory': cCategory,
      'cgrade': cGrade,
      'cgradereason': cGradeReason,
      'cmail': cMail,
      'credit_days': creditDays,
      'credit_limit': creditLimit,
      'cd_per': cdPer,
      'dl1': dl1,
      'dl2': dl2,
      'dl3': dl3,
      'dlvalidupto': dlValidUpto,
      'alcode': alCode,
      'gstin': gstin,
      'pan_1': pan1,
      'zoneid': zoneId,
      'locks': locks,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class OrderDetail {
  final int? odid;
  final int? ohid;
  final int? pid;
  final int? itemDetailId;
  final int? qty;
  final int? free;
  final String schPercentage;
  final String rate;
  final String mrp;
  final String ptr;
  final String amount;
  final String remark;
  final int? companyId;
  final String schRate;
  final int? itemNo;
  final String pname;
  final dynamic pcode;
  final dynamic companyName;
  final dynamic package;
  final dynamic packUnit;

  OrderDetail({
    this.odid,
    this.ohid,
    this.pid,
    this.itemDetailId,
    this.qty,
    this.free,
    required this.schPercentage,
    required this.rate,
    required this.mrp,
    required this.ptr,
    required this.amount,
    required this.remark,
    this.companyId,
    required this.schRate,
    this.itemNo,
    required this.pname,
    this.pcode,
    this.companyName,
    this.package,
    this.packUnit,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      odid: json['odid'],
      ohid: json['ohid'],
      pid: json['pid'],
      itemDetailId: json['item_detail_id'],
      qty: json['qty'],
      free: json['free'],
      schPercentage: json['sch_percentage'] ?? '',
      rate: json['rate'] ?? '',
      mrp: json['mrp'] ?? '',
      ptr: json['ptr'] ?? '',
      amount: json['amount'] ?? '',
      remark: json['remark'] ?? '',
      companyId: json['company_id'],
      schRate: json['sch_rate'] ?? '',
      itemNo: json['item_no'],
      pname: json['pname'] ?? '',
      pcode: json['pcode'],
      companyName: json['companyname'],
      package: json['package'],
      packUnit: json['packunit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'odid': odid,
      'ohid': ohid,
      'pid': pid,
      'item_detail_id': itemDetailId,
      'qty': qty,
      'free': free,
      'sch_percentage': schPercentage,
      'rate': rate,
      'mrp': mrp,
      'ptr': ptr,
      'amount': amount,
      'remark': remark,
      'company_id': companyId,
      'sch_rate': schRate,
      'item_no': itemNo,
      'pname': pname,
      'pcode': pcode,
      'companyname': companyName,
      'package': package,
      'packunit': packUnit,
    };
  }
}