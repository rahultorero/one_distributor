class ReceivableData {
  final String regcode;
  final int companyId;
  final int ledidParty;
  final String prefix;
  final String invType;
  final String paymentMethod;
  final int creditDays;
  final DateTime invDate;
  final int invNo;
  final double invAmt;
  final double cnAmt;
  final double recdAmt;
  final double balance;
  final String salesman;
  final String grade;
  final int branchId;
  final String? orderNo;
  final DateTime? orderDate;
  final DateTime dueDate;

  ReceivableData({
    required this.regcode,
    required this.companyId,
    required this.ledidParty,
    required this.prefix,
    required this.invType,
    required this.paymentMethod,
    required this.creditDays,
    required this.invDate,
    required this.invNo,
    required this.invAmt,
    required this.cnAmt,
    required this.recdAmt,
    required this.balance,
    required this.salesman,
    required this.grade,
    required this.branchId,
    this.orderNo,
    this.orderDate,
    required this.dueDate,
  });

  factory ReceivableData.fromJson(Map<String, dynamic> json) {
    return ReceivableData(
      regcode: json['regcode'].toString(), // Convert to String
      companyId: json['companyid'] is String ? int.parse(json['companyid']) : json['companyid'], // Convert to int
      ledidParty: json['ledid_party'] is String ? int.parse(json['ledid_party']) : json['ledid_party'], // Convert to int
      prefix: json['prefix'].toString(), // Convert to String
      invType: json['invtype'].toString(), // Convert to String
      paymentMethod: json['pm'].toString(), // Convert to String
      creditDays: json['creditdays'] is String ? int.parse(json['creditdays']) : json['creditdays'], // Convert to int
      invDate: DateTime.parse(json['invdate']),
      invNo: json['invno'] is String ? int.parse(json['invno']) : json['invno'], // Convert to int
      invAmt: double.tryParse(json['invamt'].toString()) ?? 0.0, // Ensure safe parsing
      cnAmt: double.tryParse(json['cnamt'].toString()) ?? 0.0, // Ensure safe parsing
      recdAmt: double.tryParse(json['recdamt'].toString()) ?? 0.0, // Ensure safe parsing
      balance: double.tryParse(json['balance'].toString()) ?? 0.0, // Ensure safe parsing
      salesman: json['sman'].toString(), // Convert to String
      grade: json['grade'].toString(), // Convert to String
      branchId: json['brchid'] is String ? int.parse(json['brchid']) : json['brchid'], // Convert to int
      orderNo: json['orderno']?.toString(), // Safe conversion to String
      orderDate: json['orderdate'] != null ? DateTime.tryParse(json['orderdate']) : null, // Handle nullable DateTime
      dueDate: DateTime.parse(json['duedate']),
    );
  }
}

class Party {
  final String partyName;
  final String partyCode;
  final String regCode;
  final String type;
  final int ledidParty;
  final String salesman;
  final String address1;
  final String? address2;
  final String area;
  final double totalBalance;
  final String city;
  final int pincode;
  final String? telephone;
  final String? mobile;
  final String? email;
  final String? zone;
  final String companyName;
  final int companyId;
  final List<ReceivableData> receivableData;

  Party({
    required this.partyName,
    required this.partyCode,
    required this.regCode,
    required this.type,
    required this.ledidParty,
    required this.salesman,
    required this.address1,
    this.address2,
    required this.area,
    required this.totalBalance,
    required this.city,
    required this.pincode,
    this.telephone,
    this.mobile,
    this.email,
    this.zone,
    required this.companyName,
    required this.companyId,
    required this.receivableData,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    var receivableDataList = (json['receivable_data'] as List)
        .map((i) => ReceivableData.fromJson(i))
        .toList();

    return Party(
      partyName: json['partyname'].toString(), // Convert to String
      partyCode: json['partycode'].toString(), // Convert to String
      regCode: json['regcode'].toString(), // Convert to String
      type: json['type'].toString(), // Convert to String
      ledidParty: json['ledid_party'] is String ? int.parse(json['ledid_party']) : json['ledid_party'], // Convert to int
      salesman: json['sman'].toString(), // Convert to String
      address1: json['add_1'].toString(), // Convert to String
      address2: json['add_2']?.toString(), // Convert to String
      area: json['area'].toString(), // Convert to String
      totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0.0, // Safe parsing
      city: json['city'].toString(), // Convert to String
      pincode: json['pincode'] is String ? int.parse(json['pincode']) : json['pincode'], // Convert to int
      telephone: json['teleno']?.toString(), // Safe conversion to String
      mobile: json['mobileno']?.toString(), // Safe conversion to String
      email: json['email']?.toString(), // Safe conversion to String
      zone: json['zone']?.toString(), // Safe conversion to String
      companyName: json['companyname'].toString(), // Convert to String
      companyId: json['companyid'] is String ? int.parse(json['companyid']) : json['companyid'], // Convert to int
      receivableData: receivableDataList,
    );
  }
}
