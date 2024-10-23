class LoginResponse {
  String? message;
  UserData? data;

  LoginResponse({this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? user;
  String? businessType;
  bool? isWeekly;
  String? uNo;
  String? profilePic;
  String? division;
  String? grpCode;
  int? userId;
  String? token;
  String? role;
  int? companyId;
  String? wnote;
  int? smid;

  UserData({
    this.user,
    this.businessType,
    this.isWeekly,
    this.uNo,
    this.profilePic,
    this.division,
    this.grpCode,
    this.userId,
    this.token,
    this.role,
    this.companyId,
    this.wnote,
    this.smid
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: json['user'],
      businessType: json['business_type'],
      isWeekly: json['isweekly'],
      uNo: json['u_no'],
      profilePic: json['profile_pic'],
      division: json['Division'],
      grpCode: json['grp_code'],
      userId: json['user_id'],
      token: json['token'],
      role: json['role'],
      companyId: json['company_id'],
      wnote: json['wnote'],
      smid: json['smid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['business_type'] = businessType;
    data['isweekly'] = isWeekly;
    data['u_no'] = uNo;
    data['profile_pic'] = profilePic;
    data['Division'] = division;
    data['grp_code'] = grpCode;
    data['user_id'] = userId;
    data['token'] = token;
    data['role'] = role;
    data['company_id'] = companyId;
    data['wnote'] = wnote;
    data['smid'] = smid;
    return data;
  }
}
