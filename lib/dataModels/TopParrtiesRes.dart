class TopPartiesRes {
  int? statusCode;
  List<TopParties>? data;

  TopPartiesRes({this.statusCode, this.data});

  TopPartiesRes.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <TopParties>[];
      json['data'].forEach((v) {
        data!.add(new TopParties.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopParties {
  String? partyname;
  String? partycode;
  int? ledidParty;
  int? invamt;
  int? invcount;

  TopParties(
      {this.partyname,
        this.partycode,
        this.ledidParty,
        this.invamt,
        this.invcount});

  TopParties.fromJson(Map<String, dynamic> json) {
    partyname = json['partyname'];
    partycode = json['partycode'];
    ledidParty = json['ledid_party'];
    invamt = json['invamt'];
    invcount = json['invcount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['partyname'] = this.partyname;
    data['partycode'] = this.partycode;
    data['ledid_party'] = this.ledidParty;
    data['invamt'] = this.invamt;
    data['invcount'] = this.invcount;
    return data;
  }
}
