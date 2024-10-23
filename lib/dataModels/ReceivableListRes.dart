class ReceivableListRes {
  int? total;
  List<Receivable>? data;

  ReceivableListRes({this.total, this.data});

  ReceivableListRes.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['data'] != null) {
      data = <Receivable>[];
      json['data'].forEach((v) {
        data!.add(new Receivable.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Receivable {
  String? regcode;
  int? companyid;
  int? ledidParty;
  String? prefix;
  String? invtype;
  String? cpm;
  String? pm;
  int? creditdays;
  String? invdate;
  int? invno;
  String? ref;
  String? invamt;
  String? cnamt;
  String? recdamt;
  String? balance;
  String? sman;
  Null? grade;
  String? gradereason;
  String? transport;
  String? lrno;
  Null? lrdt;
  Null? ackdt;
  String? tradingac;
  int? brchid;
  String? orderno;
  String? orderdate;
  String? duedate;
  int? smanid;
  int? csmanid;
  int? id;
  String? uniquekey;

  Receivable(
      {this.regcode,
        this.companyid,
        this.ledidParty,
        this.prefix,
        this.invtype,
        this.cpm,
        this.pm,
        this.creditdays,
        this.invdate,
        this.invno,
        this.ref,
        this.invamt,
        this.cnamt,
        this.recdamt,
        this.balance,
        this.sman,
        this.grade,
        this.gradereason,
        this.transport,
        this.lrno,
        this.lrdt,
        this.ackdt,
        this.tradingac,
        this.brchid,
        this.orderno,
        this.orderdate,
        this.duedate,
        this.smanid,
        this.csmanid,
        this.id,
        this.uniquekey});

  Receivable.fromJson(Map<String, dynamic> json) {
    regcode = json['regcode'];
    companyid = json['companyid'];
    ledidParty = json['ledid_party'];
    prefix = json['prefix'];
    invtype = json['invtype'];
    cpm = json['cpm'];
    pm = json['pm'];
    creditdays = json['creditdays'];
    invdate = json['invdate'];
    invno = json['invno'];
    ref = json['ref'];
    invamt = json['invamt'];
    cnamt = json['cnamt'];
    recdamt = json['recdamt'];
    balance = json['balance'];
    sman = json['sman'];
    grade = json['grade'];
    gradereason = json['gradereason'];
    transport = json['transport'];
    lrno = json['lrno'];
    lrdt = json['lrdt'];
    ackdt = json['ackdt'];
    tradingac = json['tradingac'];
    brchid = json['brchid'];
    orderno = json['orderno'];
    orderdate = json['orderdate'];
    duedate = json['duedate'];
    smanid = json['smanid'];
    csmanid = json['csmanid'];
    id = json['id'];
    uniquekey = json['uniquekey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['regcode'] = this.regcode;
    data['companyid'] = this.companyid;
    data['ledid_party'] = this.ledidParty;
    data['prefix'] = this.prefix;
    data['invtype'] = this.invtype;
    data['cpm'] = this.cpm;
    data['pm'] = this.pm;
    data['creditdays'] = this.creditdays;
    data['invdate'] = this.invdate;
    data['invno'] = this.invno;
    data['ref'] = this.ref;
    data['invamt'] = this.invamt;
    data['cnamt'] = this.cnamt;
    data['recdamt'] = this.recdamt;
    data['balance'] = this.balance;
    data['sman'] = this.sman;
    data['grade'] = this.grade;
    data['gradereason'] = this.gradereason;
    data['transport'] = this.transport;
    data['lrno'] = this.lrno;
    data['lrdt'] = this.lrdt;
    data['ackdt'] = this.ackdt;
    data['tradingac'] = this.tradingac;
    data['brchid'] = this.brchid;
    data['orderno'] = this.orderno;
    data['orderdate'] = this.orderdate;
    data['duedate'] = this.duedate;
    data['smanid'] = this.smanid;
    data['csmanid'] = this.csmanid;
    data['id'] = this.id;
    data['uniquekey'] = this.uniquekey;
    return data;
  }
}
