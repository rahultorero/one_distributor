class UserUpdate {
  final int cusrId;
  final String? dob;          // Nullable
  final String? email;       // Nullable
  final int fxdIdGen;
  final int idRole;
  final String mobile;
  final String pwd;
  final String? urlPhoto;    // Nullable
  final String userName;
  final String? wad;         // Nullable
  final String? wnote;       // Nullable
  final int fxdUsertype;
  final int smid;

  UserUpdate({
    required this.cusrId,
    this.dob,
    this.email,
    required this.fxdIdGen,
    required this.idRole,
    required this.mobile,
    required this.pwd,
    this.urlPhoto,
    required this.userName,
    this.wad,
    this.wnote,
    required this.fxdUsertype,
    required this.smid,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) {
    return UserUpdate(
      cusrId: json['CusrId'] ?? 0,
      dob: json['DOB'],
      email: json['Email'],
      fxdIdGen: json['FxdId_Gen'] ?? 0,
      idRole: json['Id_Role'] ?? 0,
      mobile: json['Mobile'] ?? '',
      pwd: json['Pwd'] ?? '',
      urlPhoto: json['Url_Photo'],
      userName: json['User_Name'] ?? '',
      wad: json['WAD'],
      wnote: json['WNote'],
      fxdUsertype: json['fxd_usertype'] ?? 0,
      smid: json['smid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CusrId': cusrId,
      'DOB': dob,
      'Email': email,
      'FxdId_Gen': fxdIdGen,
      'Id_Role': idRole,
      'Mobile': mobile,
      'Pwd': pwd,
      'Url_Photo': urlPhoto,
      'User_Name': userName,
      'WAD': wad,
      'WNote': wnote,
      'fxd_usertype': fxdUsertype,
      'smid': smid,
    };
  }
}
