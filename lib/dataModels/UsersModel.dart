class UserListRes {
  final String businessType;
  final int uId;
  final int dId;
  final String? duNo;           // Nullable
  final String userName;
  final String pwd;
  final String mobile;
  final String? email;          // Nullable
  final String? dob;            // Nullable
  final String? wad;            // Nullable
  final int fxdidGen;
  final int idRole;
  final int fxdUsertype;
  final String? wnote;          // Nullable
  final String? urlPhoto;       // Nullable
  final int cusrid;
  final bool isActive;
  final int nCode;
  final bool isWeekly;
  final int smanid;
  final int verifyStatus;
  final String? otp;            // Nullable
  final String? otpTimestamp;   // Nullable
  final String? salesmanName;   // Nullable

  UserListRes({
    required this.businessType,
    required this.uId,
    required this.dId,
    this.duNo,                    // Nullable
    required this.userName,
    required this.pwd,
    required this.mobile,
    this.email,                   // Nullable
    this.dob,                     // Nullable
    this.wad,                     // Nullable
    required this.fxdidGen,
    required this.idRole,
    required this.fxdUsertype,
    this.wnote,                   // Nullable
    this.urlPhoto,                // Nullable
    required this.cusrid,
    required this.isActive,
    required this.nCode,
    required this.isWeekly,
    required this.smanid,
    required this.verifyStatus,
    this.otp,                     // Nullable
    this.otpTimestamp,            // Nullable
    this.salesmanName,            // Nullable
  });

  factory UserListRes.fromJson(Map<String, dynamic> json) {
    return UserListRes(
      businessType: json['business_type'] ?? '',        // Provide a default value if null
      uId: json['u_id'] ?? 0,                           // Default to 0 if null
      dId: json['d_id'] ?? 0,
      duNo: json['du_no'],                              // Nullable field
      userName: json['user_name'] ?? '',                // Provide a default value if null
      pwd: json['pwd'] ?? '',                            // Provide a default value if null
      mobile: json['mobile'] ?? '',                      // Provide a default value if null
      email: json['email'],                              // Nullable field
      dob: json['dob'],                                  // Nullable field
      wad: json['wad'],                                  // Nullable field
      fxdidGen: json['fxdid_gen'] ?? 0,
      idRole: json['id_role'] ?? 0,
      fxdUsertype: json['fxd_usertype'] ?? 0,
      wnote: json['wnote'],                              // Nullable field
      urlPhoto: json['url_photo'],                       // Nullable field
      cusrid: json['cusrid'] ?? 0,
      isActive: json['isactive'] ?? false,              // Handle boolean field
      nCode: json['n_code'] ?? 0,
      isWeekly: json['isweekly'] ?? false,
      smanid: json['smanid'] ?? 0,
      verifyStatus: json['verify_status'] ?? 0,
      otp: json['otp'],                                  // Nullable field
      otpTimestamp: json['otp_timestamp'],               // Nullable field
      salesmanName: json['salesman_name'],               // Nullable field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_type': businessType,
      'u_id': uId,
      'd_id': dId,
      'du_no': duNo,
      'user_name': userName,
      'pwd': pwd,
      'mobile': mobile,
      'email': email,
      'dob': dob,
      'wad': wad,
      'fxdid_gen': fxdidGen,
      'id_role': idRole,
      'fxd_usertype': fxdUsertype,
      'wnote': wnote,
      'url_photo': urlPhoto,
      'cusrid': cusrid,
      'isactive': isActive,
      'n_code': nCode,
      'isweekly': isWeekly,
      'smanid': smanid,
      'verify_status': verifyStatus,
      'otp': otp,
      'otp_timestamp': otpTimestamp,
      'salesman_name': salesmanName,
    };
  }

  UserListRes copyWith({
    String? businessType,
    int? uId,
    int? dId,
    String? duNo,
    String? userName,
    String? pwd,
    String? mobile,
    String? email,
    String? dob,
    String? wad,
    int? fxdidGen,
    int? idRole,
    int? fxdUsertype,
    String? wnote,
    String? urlPhoto,
    int? cusrid,
    bool? isActive,
    int? nCode,
    bool? isWeekly,
    int? smanid,
    int? verifyStatus,
    String? otp,
    String? otpTimestamp,
    String? salesmanName,
  }) {
    return UserListRes(
      businessType: businessType ?? this.businessType,
      uId: uId ?? this.uId,
      dId: dId ?? this.dId,
      duNo: duNo ?? this.duNo,
      userName: userName ?? this.userName,
      pwd: pwd ?? this.pwd,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      wad: wad ?? this.wad,
      fxdidGen: fxdidGen ?? this.fxdidGen,
      idRole: idRole ?? this.idRole,
      fxdUsertype: fxdUsertype ?? this.fxdUsertype,
      wnote: wnote ?? this.wnote,
      urlPhoto: urlPhoto ?? this.urlPhoto,
      cusrid: cusrid ?? this.cusrid,
      isActive: isActive ?? this.isActive,
      nCode: nCode ?? this.nCode,
      isWeekly: isWeekly ?? this.isWeekly,
      smanid: smanid ?? this.smanid,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      otp: otp ?? this.otp,
      otpTimestamp: otpTimestamp ?? this.otpTimestamp,
      salesmanName: salesmanName ?? this.salesmanName,
    );
  }
}
