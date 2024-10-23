class OrderListRes {
  final String userName;
  final String urlPhoto;
  final String companyName;
  final int ohid;
  final String distId;
  final String orderNo;
  final int companyId;
  final int smanId;
  final int cusrId;
  final String userType;
  final int orderStatus;
  final String? oreMark; // Nullable field
  final String dType;
  final String oDate;
  final int? ledIdParty; // Nullable field
  final String? oAmt; // Nullable field
  final String? rid; // Nullable field
  final String createdAt;
  final String? grpCode; // Nullable field
  final String issync;
  final int fxdId;
  final int typeId;
  final String fxdName;
  final String fxdSubName;
  final int parentId;
  final String deliveryType;
  final String partyName;
  final String partyCode;
  final String area;
  final String city;
  final String sman;

  OrderListRes({
    required this.userName,
    required this.urlPhoto,
    required this.companyName,
    required this.ohid,
    required this.distId,
    required this.orderNo,
    required this.companyId,
    required this.smanId,
    required this.cusrId,
    required this.userType,
    required this.orderStatus,
    this.oreMark,
    required this.dType,
    required this.oDate,
    this.ledIdParty,
    this.oAmt,
    this.rid,
    required this.createdAt,
    this.grpCode,
    required this.issync,
    required this.fxdId,
    required this.typeId,
    required this.fxdName,
    required this.fxdSubName,
    required this.parentId,
    required this.deliveryType,
    required this.partyName,
    required this.partyCode,
    required this.area,
    required this.city,
    required this.sman,
  });

  factory OrderListRes.fromJson(Map<String, dynamic> json) {
    return OrderListRes(
      userName: json['user_name'] as String? ?? '', // Use String? and provide default
      urlPhoto: json['url_photo'] as String? ?? '',
      companyName: json['companyname'] as String? ?? '',
      ohid: json['ohid'] as int? ?? 0, // Nullable int
      distId: json['dist_id'] as String? ?? '',
      orderNo: json['orderno'] as String? ?? '',
      companyId: json['companyid'] as int? ?? 0,
      smanId: json['smanid'] as int? ?? 0,
      cusrId: json['cusrid'] as int? ?? 0,
      userType: json['user_type'] as String? ?? '',
      orderStatus: json['order_status'] as int? ?? 0,
      oreMark: json['oremark'] as String?, // Nullable
      dType: json['d_type'] as String? ?? '',
      oDate: json['odate'] as String? ?? '',
      ledIdParty: json['ledid_party'] as int?, // Nullable
      oAmt: json['oamt'] as String?, // Nullable
      rid: json['rid'] as String?, // Nullable
      createdAt: json['createdat'] as String? ?? '',
      grpCode: json['grp_code'] as String?, // Nullable
      issync: json['issync'] as String? ?? '',
      fxdId: json['fxdid'] as int? ?? 0,
      typeId: json['typeid'] as int? ?? 0,
      fxdName: json['fxdname'] as String? ?? '',
      fxdSubName: json['fxdsubname'] as String? ?? '',
      parentId: json['parentid'] as int? ?? 0,
      deliveryType: json['delivery_type'] as String? ?? '',
      partyName: json['partyname'] as String? ?? '',
      partyCode: json['partycode'] as String? ?? '',
      area: json['area'] as String? ?? '',
      city: json['city'] as String? ?? '',
      sman: json['sman'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'url_photo': urlPhoto,
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
      'ledid_party': ledIdParty,
      'oamt': oAmt,
      'rid': rid,
      'createdat': createdAt,
      'grp_code': grpCode,
      'issync': issync,
      'fxdid': fxdId,
      'typeid': typeId,
      'fxdname': fxdName,
      'fxdsubname': fxdSubName,
      'parentid': parentId,
      'delivery_type': deliveryType,
      'partyname': partyName,
      'partycode': partyCode,
      'area': area,
      'city': city,
      'sman': sman,
    };
  }
}
