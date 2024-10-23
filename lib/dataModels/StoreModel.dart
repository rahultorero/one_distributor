class Store {
  final String regCode;
  final String companyName;
  final int companyId;

  Store({
    required this.regCode,
    required this.companyName,
    required this.companyId,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      regCode: json['regcode'] as String,
      companyName: json['companyname'] as String,
      companyId: json['companyid'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regcode': regCode,
      'companyname': companyName,
      'companyid': companyId,
    };
  }
}
