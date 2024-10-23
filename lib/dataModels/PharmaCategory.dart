class PharmaCategory {
  final String fxdname;
  final int fxdid;
  final String fxdsubname;

  PharmaCategory({
    required this.fxdname,
    required this.fxdid,
    required this.fxdsubname,
  });

  // Factory method to create a PharmaCategory from JSON
  factory PharmaCategory.fromJson(Map<String, dynamic> json) {
    return PharmaCategory(
      fxdname: json['fxdname'] as String,
      fxdid: json['fxdid'] as int,
      fxdsubname: json['fxdsubname'] as String,
    );
  }

  // Convert a PharmaCategory object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fxdname': fxdname,
      'fxdid': fxdid,
      'fxdsubname': fxdsubname,
    };
  }
}

class CategoryResponse {
  final List<PharmaCategory> pharma;
  final List<PharmaCategory> fmcg;
  final List<PharmaCategory> others;

  CategoryResponse({
    required this.pharma,
    required this.fmcg,
    required this.others,
  });

  // Factory method to create a CategoryResponse from JSON
  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return CategoryResponse(
      pharma: (data['pharma'] as List<dynamic>).map((item) => PharmaCategory.fromJson(item as Map<String, dynamic>)).toList(),
      fmcg: (data['fmcg'] as List<dynamic>).map((item) => PharmaCategory.fromJson(item as Map<String, dynamic>)).toList(),
      others: (data['others'] as List<dynamic>).map((item) => PharmaCategory.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  // Convert a CategoryResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pharma': pharma.map((item) => item.toJson()).toList(),
      'fmcg': fmcg.map((item) => item.toJson()).toList(),
      'others': others.map((item) => item.toJson()).toList(),
    };
  }
}
