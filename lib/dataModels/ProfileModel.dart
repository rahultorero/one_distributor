class ProfileModel {
  int? statusCode;
  ProfileData? data;

  ProfileModel({this.statusCode, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      statusCode: json['statusCode'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? businessType;
  int? uId;
  int? dId;
  String? duNo;
  String? userName;
  String? pwd;
  String? mobile;
  String? email;
  String? dob;
  String? wad;
  int? fxdidGen; // Changed to int
  int? idRole;
  int? fxdUsertype;
  String? wnote;
  String? urlPhoto;
  int? cusrid;
  bool? isActive;
  int? nCode; // Changed to int to match your response
  bool? isWeekly;
  int? smanid;
  int? verifyStatus;
  int? otp; // Changed to int because otp is typically a number
  String? otpTimestamp;

  ProfileData({
    this.businessType,
    this.uId,
    this.dId,
    this.duNo,
    this.userName,
    this.pwd,
    this.mobile,
    this.email,
    this.dob,
    this.wad,
    this.fxdidGen,
    this.idRole,
    this.fxdUsertype,
    this.wnote,
    this.urlPhoto,
    this.cusrid,
    this.isActive,
    this.nCode,
    this.isWeekly,
    this.smanid,
    this.verifyStatus,
    this.otp,
    this.otpTimestamp,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      businessType: json['business_type'],
      uId: json['u_id'],
      dId: json['d_id'],
      duNo: json['du_no'],
      userName: json['user_name'],
      pwd: json['pwd'],
      mobile: json['mobile'],
      email: json['email'],
      dob: json['dob'],
      wad: json['wad'],
      fxdidGen: json['fxdid_gen'], // Now int
      idRole: json['id_role'],
      fxdUsertype: json['fxd_usertype'],
      wnote: json['wnote'],
      urlPhoto: json['url_photo'],
      cusrid: json['cusrid'],
      isActive: json['isactive'],
      nCode: json['n_code'], // Now int
      isWeekly: json['isweekly'],
      smanid: json['smanid'],
      verifyStatus: json['verify_status'],
      otp: json['otp'], // Now int
      otpTimestamp: json['otp_timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_type'] = businessType;
    data['u_id'] = uId;
    data['d_id'] = dId;
    data['du_no'] = duNo;
    data['user_name'] = userName;
    data['pwd'] = pwd;
    data['mobile'] = mobile;
    data['email'] = email;
    data['dob'] = dob;
    data['wad'] = wad;
    data['fxdid_gen'] = fxdidGen; // Now int
    data['id_role'] = idRole;
    data['fxd_usertype'] = fxdUsertype;
    data['wnote'] = wnote;
    data['url_photo'] = urlPhoto;
    data['cusrid'] = cusrid;
    data['isactive'] = isActive;
    data['n_code'] = nCode; // Now int
    data['isweekly'] = isWeekly;
    data['smanid'] = smanid;
    data['verify_status'] = verifyStatus;
    data['otp'] = otp; // Now int
    data['otp_timestamp'] = otpTimestamp;
    return data;
  }
}
